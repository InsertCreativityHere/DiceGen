
require 'singleton'

module DiceGen

# Module containing general use utility code.
module Util
    module_function

    # Stores the currently active Sketchup model.
    MAIN_MODEL = Sketchup::active_model

    # Path the base directory of the script.
    RESOURCE_DIR = "/Users/austin/DiceStuff/Resources"
    SCRIPT_DIR = "/Users/austin/DiceStuff/Script"

    # Hash that stores the definitions for everything we import to prevent reloading the same defintion twice.
    # Values are the stringified name of the ComponentDefinition, and keys are the filenames that the definitions were
    # imported from.
    @@import_cache = Hash::new()

    # Imports a file and returns a reference to the imported definition. Note that this function will cause the
    # imported definition to appear at the mouse cursor in the UI, this is a limitation of the API. Hitting <ESC>
    # Will get rid of the extra instance.
    #   file: The absolute path of the file to import from.
    #   return: A ComponentDefinition corresponding to the imported definition.
    def import_definition(file)
        # Check if we've already imported the file, and if so, return the cached definition.
        if @@import_cache.key?(file)
            return MAIN_MODEL.definitions[@@import_cache[file]]
        end

        # Check if the file exists and is reachable.
        unless File.exist?(file)
            raise "Failed to locate the file '#{file}'"
        end

        # Try to import the file's model and check if it was successful.
        result = MAIN_MODEL.import(file)
        unless result
            raise "Failed to import model from the file '#{file}'"
        end
        puts "    Loaded '#{File.basename(file, ".dae")}.dae'"

        # Cache and return the most recently created definition; ie: the one we just imported.
        definition = MAIN_MODEL.definitions[-1]
        @@import_cache[file] = definition.guid()
        return definition
    end

    # Scales a vector by the provided scale factor like 'vector * scale' would normally.
    #   vector: The vector to scale. Note that this vector isn't altered by the function, instead it's components
    #           components are copied into a new vector and that is scaled and returned.
    #   scale: The scale factor to scale the vector by.
    #   return: A new vector with the same components as the provided vector, but scaled by 'scale_factor'.
    def scale_vector(vector, scale)
        return Geom::Vector3d::new(vector.x * scale, vector.y * scale, vector.z * scale)
    end

    # Manually reloads all the dice and font definitions by manually deleting their definitions from the current Ruby
    # session, and then re-requiring them. This might be dangerous, but it seems to work so far *shrugs*.
    # This really helps when editing dice definitions on the fly in Sketchup, since IRB never needs to be restarted.
    def reload_script_definitions()
        # First we manually delete any of the classes or modules that we've loaded from the definition scripts.
        # We assume that these files are all directly in the 'Fonts' and 'Dice' namespace, and then delete anything
        # except for a list of protected classes and modules that we know are defined in this file.

        # List of all the core objects that are defined in this main script file that shouldn't be undefined.
        protected_objects = [:DiceGen, :Util, :Fonts, :FontUtil, :Font, :SystemFont, :RawFont, :SplicedFont, :Dice,
                             :DiceUtil, :DieModel]
        # Create a list of all the objects defined in the 'Fonts' and 'Dice' namespaces, then filter it to only keep the
        # non-protected (removable) objects.
        removable_fonts_objects = DiceGen::Dice.constants().select{|obj| !protected_objects.include?(obj)}
        removable_dice_objects = DiceGen::Fonts.constants().select{|obj| !protected_objects.include?(obj)}

        # Cross your fingers and undefine everything listed in the removable object lists.
        puts "Unloading and deleting imported definitions..."
        removable_fonts_objects.each() do |obj|
            puts "    Unloading Dice::#{obj}"
            Dice.send(:remove_const, obj)
        end
        removable_dice_objects.each() do |obj|
            puts "    Unloading Fonts::#{obj}"
            Fonts.send(:remove_const, obj)
        end

        # All the files that have been imported into the current ruby session are stored in a variable named $"
        # We manually remove any files relating to dice or font defitions from this list to 'un-require' them, so that
        # we when 'require' them in the next step, Ruby will load a fresh copy of the file.
        $".delete_if{|file| file.start_with?("#{SCRIPT_DIR}/DiceDefinitions/") || file == "#{SCRIPT_DIR}/Dice.rb"}
        $".delete_if{|file| file.start_with?("#{SCRIPT_DIR}/FontDefinitions/") || file == "#{SCRIPT_DIR}/Fonts.rb"}

        # Clear the import cache, so that any old definitions will get re-imported from scratch.
        @@import_cache = Hash::new()

        # Re-require the font and dice definition files.
        puts "Reloading definitions..."
        require_relative "Fonts.rb"
        require_relative "Dice.rb"
    end
end



##### FONTS #####
module Fonts
    include DiceGen

    # Module containing font specific utility code.
    module FontUtil
        module_function

        # Imports all the mesh definitions that make up a font.
        #   font_folder: The absolute path of the base font folder. This is NOT the folder immediately containing
        #                the mesh files, but the one above it; This function expects our custom directory scheme to be
        #                followed, and so it's the actual font folder that it expects to get.
        #   mesh_names:  Array listing the names of the meshes that should be imported (without file extensions). When
        #                specified, only these meshes are loaded, and a warning message is issues if any names aren't
        #                loaded. When set to 'nil', all meshes are loaded instead. Defaults to 'nil'
        #   return: A hash of mesh definitions whose keys are the names of each imported file (without their extensions)
        #           and each value is the ComponentDefinition for the mesh that was imported from that file.
        def import_meshes(font_folder:, mesh_names: nil)
            # Check the provided font folder exists.
            unless File.exists?(font_folder)
                raise "Folder '#{font_folder}' does not exist or is inaccessible."
            end
            # And that it has a "meshes" subdirectory.
            unless File.exists?(font_folder + "/meshes")
                raise "Folder '#{font_folder}' does not contain a 'meshes' subdirectory."
            end

            meshes = Hash::new()
            puts "Importing meshes from '#{font_folder}/meshes':"

            # If no meshes were explicitely listed, try to import every mesh file for the font.
            # Otherwise, only attempt to import the specified mesh files.
            if (mesh_names.nil?())
                (Dir["#{font_folder}/meshes/*.dae"]).each() do |file|
                    # Get the file name on it's own, and without it's extension.
                    filename = File.basename(file, ".dae")

                    meshes[filename] = Util.import_definition(file)
                end
            else
                mesh_names.each() do |mesh|
                    meshes[mesh] = Util.import_definition("#{font_folder}/meshes/#{mesh}.dae")
                end
            end

            return meshes
        end

        # Combines 2 glyphs together into a composite glyph, with the glyphs placed to the left and right of each other.
        #   glyphs: Array of ComponentDefinitions containing the glyphs to be spliced together. The original glyphs are
        #           in no way altered by this function.
        #   padding: The amount of horizontal space to place between the glyphs when combining them.
        #   return: The ComponentDefinition of the new composite glyph.
        def splice_glyphs(glyphs:, padding:)
            # The new glyph's definition name is formed by concatenating the names of the component glyphs.
            name = ""
            # Calculate the total width of the combined glyphs and the padding in between them.
            total_width = padding * (glyphs.count() - 1)
            glyphs.each() do |glyph|
                name += glyph.name()
                total_width += glyph.bounds().width()
            end

            # Create a new definition to splice the glyphs into.
            definition = Util::MAIN_MODEL.definitions.add(name)
            entities = definition.entities()

            # Keep a running tally of the current x position, starting at the leftmost point.
            xPos = -total_width / 2

            # Create instances of the component glyphs in the new definition.
            glyphs.each() do |glyph|
                # Calculate the x position to place the glyph at so the new spliced glyph is still centered.
                width = glyph.bounds().width()
                offset = Geom::Point3d::new(xPos + (width / 2), 0, 0)
                # Create an instance of the component glyph to splice it into the definition.
                entities.add_instance(glyph, Geom::Transformation.translation(offset))
                # Increment the position by the width of the glyph we just placed, plus the padding between glyphs.
                xPos += width + padding
            end

            return definition
        end
    end

    # A bare-bones font that creates glyphs directly from ComponentDefinition objects, and the base class for all fonts.
    class Font
        # The plain-text name of the font.
        attr_reader :name
        # Hash of all the glyphs making up the font, it's keys are the names for each glyph (the text that the glyph
        # represents), and it's values are ComponentDefinitions containing the actual mesh definitions for each glyph.
        attr_reader :glyphs

        # Create a new font with the specified name and whose glyphs are provided by a hash of ComponentDefinitions.
        #   name: The plain-text name of the font.
        #   definitions: A hash of ComponentDefinitions that store the 2D glyph mesh models making up the font. It's
        #                keys must be the names for each glyph (usually the text it represents), and the corresponding
        #                values are the ComponentDefinitions of the glyph's meshes.
        def initialize(name:, definitions:)
            @name = name
            @glyphs = definitions
        end

        # Sets the definition for a collection of glyphs.
        #   glyphs: A hash of glyphs to add into the font, following the same scheme as '@glyphs'. If the font already
        #           contains a glyph with the same name as one of the new glyphs, it is replaced with the new glyph.
        def set_glyphs(glyphs)
            @glyphs.merge(glyphs)
        end

        # Scales the glyphs by a hash of scale factors.
        #   scales: A hash of scale factors; Keys must correspond to the name of a glyph in this font, and it's value is
        #           the factor to scale the glyphs definition by. A factor of 1 will have no effect on the glyph.
        def set_scales(scales)
            scales.each() do |name, scale|
                entities = @glyphs[name].entities()
                entities.transform_entities(Geom::Transformation.scaling(scale), entities.to_a())
            end
        end

        # Translate the glyphs by a hash of (x,y) offset pairs.
        #   offsets: A hash of offset pairs; Keys must correspond to the name of a glyph in this font, and it's value is
        #            a pair of offsets specifying how much to translate the glyph in each direction (x and y).
        def set_offsets(offsets)
            offsets.each() do |name, offset|
                entities = @glyphs[name].entities()
                vectorOffset = Geom::Vector3d::new(offset[0], offset[1], 0)
                entities.transform_entities(Geom::Transformation.translation(vectorOffset), entities.to_a())
            end
        end

        # Creates and returns an instance of the specified glyph as a 2D model. The glyph is always created in it's own
        # enclosing group, and this group is added to the provided entities (instead of placing the glyph directly).
        #   name: The name of the glyph to create, usually this is the text the glyph represents.
        #   entities: The entities collection to place the glyph's group into, and hence the glyph itself.
        #   transform: A custom transformation that is applied to the glyph after placement. Defaults to no transform.
        #   return: The group that immediately components the glyph's mesh.
        def create_glyph(name:, entities:, transform: IDENTITY)
            return entities.add_instance(@glyphs[name], transform).make_unique()
        end
    end

    # A font where glyphs are defined by system fonts and are created with Sketchup's 3D text tool
    class SystemFont < Font
        # The name of the system font that this is using.
        attr_reader :system_font
        # Whether the font should be created in italics. Note, not all fonts support being italicized.
        attr_reader :is_italic
        # Whether the font should be created in bold. Note, not all fonts support being bolded.
        attr_reader :is_bold

        # Creates a new font using the specified system font, and modifiers.
        #   name: The plain-text name of the font.
        #   system_font: the name of the system font to use. This must exactly match the name of the installed font.
        #   italic: Whether the glyphs created by this font should be italicized.
        #   bold: Whether the glyphs created by this font should be bolded.
        def initialize(name:, system_font:, italic: false, bold: false)
            super(name: name, definitions: Hash::new())
            @system_font = system_font
            @is_italic = italic
            @is_bold = bold
        end

        # Creates and returns an instance of the specified glyph as a 2D model. The glyph is always created in it's own
        # enclosing group, and this group is added to the provided entities (instead of placing the glyph directly).
        # This method delegates to the base implementation, but just makes sure to generate the requested glyph via
        # the 3D-Text-Tool if it hasn't been created ted. After possibly generating, the base method is called.
        #   name: The name of the glyph to create, usually this is the text the glyph represents.
        #   entities: The entities collection to place the glyph's group into, and hence the glyph itself.
        #   transform: A custom transformation that is applied to the glyph after placement. Defaults to no transform.
        #   return: The group that immediately components the glyph's mesh.
        def create_glyph(name:, entities:, transform: IDENTITY)
            # Lazily create the requested glyph via the 3D text tool if we haven't already created and cached it before.
            unless @glyphs.key?(name)
                # Create a new definition to draw the text into.
                definition = Util::MAIN_MODEL.definitions.add(@name + '_' + name)
                def_entitites = definition.entities()

                # Draw the 3D text centered with the correct attributes and a letter-height of 8mm.
                def_entitites.add_3d_text(name, TextAlignCenter, system_font, is_bold, is_italic, 314.961)

                # Center the glyph's bounding box to the origin.
                offset = ORIGIN - definition.bounds().center()
                def_entitites.transform_entities(Geom::Transformation.translation(offset), def_entitites.to_a())

                # Cache the definition to avoid having to create it again.
                @glyphs[name] = definition
            end
            return super
        end
    end

    # A font where every glyph is defined by it's own unique mesh model, and no combining of glyphs is performed.
    class RawFont < Font
        # The absolute path of the base folder that contains all the data for this font.
        attr_reader :folder

        # Create a new raw font with the specified name, and whose glyphs are defined by meshes stored in DAE files.
        #   name: The plain-text name of the font.
        #   folder: The absolute path of the base font folder. This is NOT the folder immediately containing the mesh
        #         files, but the one above it; This function expects our custom directory scheme to be followed, and so
        #         it's the actual font folder that it expects to get.
        def initialize(name:, folder:)
            @folder = folder
            # Construct the base Font object using the imported mesh definitions.
            super(name: name, definitions: FontUtil.import_meshes(font_folder: @folder))
        end
    end

    # A font where a base set of glyphs is provided that all other composite glyphs can be generated from. For instance,
    # supplying an glyphs for every single individual digits, allows for generating glyphs for any base 10 number.
    class SplicedFont < RawFont
        # The amount of horizontal space to leave in between glyphs when splicing them together
        attr_reader :padding

        # Create a new spliced font with the specified font, and whose base glyphs are defined by meshes stored in DAE
        # files. Every mesh in the font folder is loaded, and afterwards, composite glyphs are generated as needed.
        #   name: The plain-text name of the font.
        #   folder: The absolute path of the base font folder. This is NOT the folder immediately containing the mesh
        #         files, but the one above it; This function expects our custom directory scheme to be followed, and so
        #         it's the actual font folder that it expects to get.
        #   padding: The amount of horizontal space to leave in between glyphs when splicing them together.
        def initialize(name:, folder:, padding:)
            super(name: name, folder: folder)
            @padding = padding
        end

        # Creates and returns an instance of the specified glyph as a 2D model. The glyph is always created in it's own
        # enclosing group, and this group is added to the provided entities (instead of placing the glyph directly).
        # This method delegates to the base implementation, but just makes sure to generate the requested glyph via
        # splicing if it hasn't been created yet. After the check (and possible splicing), the base method is called.
        #   name: The name of the glyph to create, usually this is the text the glyph represents.
        #   entities: The entities collection to place the glyph's group into, and hence the glyph itself.
        #   transform: A custom transformation that is applied to the glyph after placement. Defaults to no transform.
        #   return: The group that immediately components the glyph's mesh.
        def create_glyph(name:, entities:, transform: IDENTITY)
            # Lazily create the requested glyph via splicing if it doesn't already have a definition.
            unless @glyphs.key?(name)
                char_glyphs = name.chars().map{ |char| @glyphs[char] }
                @glyphs[name] = FontUtil.splice_glyphs(glyphs: char_glyphs, padding: padding)
            end
            return super
        end
    end
end



##### DICE #####
module Dice
    include DiceGen

    #  Module containing dice specific utility code.
    module DiceUtil
        module_function

        # Computes the center-point of an edge by averaging the vertices at it's ends.
        #   edge: The edge segment to find the middle of.
        #   return: A Point3d holding the coordinates of the edge's middle.
        def find_edge_center(edge)
            return Geom::Point3d.linear_combination(0.5, edge.start.position(), 0.5, edge.end.position())
        end

        # Computes the geometric center-point of a face by average all it's vertices.
        #   face: The face to find the center of.
        #   return: A Point3d holding the coordinates of the face's geometric center.
        def find_face_center(face)
            x = 0; y = 0; z = 0;

            # Iterate through each of the vertices of the face and add them onto the totals.
            face.vertices().each() do |vertex|
                pos = vertex.position()
                x += pos.x(); y += pos.y(); z += pos.z();
            end

            # Compute the average position by dividing through by the total number of vertices.
            count = face.vertices().length()
            return Geom::Point3d::new(x / count, y / count, z / count)
        end

        # Computes and returns a transformation that maps the global coordinate system to a face local one where the
        # origin is at the center of the face, and the x,y plane is coplanar to the face, with the z axis pointing out.
        # All axes are, of course, an orthonormal basis when taken together.
        #   face: The face to compute the transform for.
        #   return: The transformation as described above.
        def get_face_transform(face)
            # Get the normal vector that's pointing out from the face. This is going to become the new '+z' direction.
            normal = face.normal()

            # Compute the center point of the face and the center it's bottom edge.
            face_center = find_face_center(face)
            edge_center = find_edge_center(face.edges()[0])

            # Compute the positive y axes by subtracting the centers and normalizing. By subtracting the face center
            # from the edge center we ensure that it's pointing up.
            y_vector = Geom::Vector3d::new((face_center - edge_center).to_a()).normalize()
            # Compute the positive x axis by crossing the y and z axes vectors, again minding the order.
            x_vector = y_vector.cross(normal)

            return Geom::Transformation.axes(face_center, x_vector, y_vector, normal)
        end
    end

    # Abstract base class for all die models.
    class DieModel
        # The ComponentDefinition that defines the die's mesh model.
        attr_reader :definition
        # The size of the die in mm, calculated by measuring the distance between two diametric faces, or a face and the
        # vertex diametrically opposed to it if necessary (such as for a tetrahedron (D4)).
        attr_accessor :die_size
        # The height of the glyphs on the die in mm.
        attr_accessor :font_size
        # An array of transformations used to place glyphs onto the faces of this die model. Each entry is a coordinate
        # transformation that maps the standard world coordinates to a face-local system with it's origin at the
        # geometric center of the face, and it's axes rotated to be coplanar to the face (with +z pointing out).
        # Each face has it's respective transformation, and they're ordered in the same way faces are numbered by.
        attr_reader :face_transforms
        # A hash of glyph mappings keyed by their names. Each glyph mapping is made up of 2 arrays. The first specifies
        # what glyph should be placed on a face, and the second array specifies the angle that the glyph should be
        # rotated by prior to embossing. The arrays follow the same order as the faces, so the 'i'th entry in each
        # array will be used for the 'i'th face of the die.
        attr_accessor :glyph_mappings

        # Super constructor for all dice models that stores the die's model definition, and computes a set of
        # transformations from the die's faces that can be used to easily add glyphs to the die later on.
        #   definition: The ComponentDefinition that holds the die's mesh definition.
        #   faces: Array of all the die's faces, in the same order the face's should be numbered by.
        #   die_size: The distance between two diametrically opposed faces of the die (in mm), or between a face
        #             and the vertex diametric to it if no diametric face exists (such as a tetrahedron (D4)).
        #   die_scale: The amount to scale the die model by to make it 'die_size' mm large. This scaling is applied
        #              before any glyphs are placed onto the die.
        #   font_size: The height to scale the glyphs to before embossing them onto the die (in mm).
        #   font_scale: The factor to scale the glyphs by to make them 'font_size' mm tall. This is applied directly
        #               after the glyph has been placed, but not embossed.
        def initialize(definition:, faces:, die_size:, die_scale:, font_size:, font_scale:)
            @definition = definition
            @die_size = die_size
            @font_size = font_size
            entities = @definition.entities()
            entities.transform_entities(Geom::Transformation.scaling(die_scale), entities.to_a())

            face_count = faces.length()
            @face_transforms = Array::new(face_count)
            # Iterate through each face of the die and compute their face-local coordinate transformations.
            faces.each_with_index() do |face, i|
                @face_transforms[i] = DiceUtil.get_face_transform(face) * Geom::Transformation.scaling(font_scale)
            end

            # Create a hash for holding the glyph mappings and add the default mapping into it.
            @glyph_mappings = {"default" => [(1..face_count).to_a(), ([0.0] * face_count)]}
        end

        # Sets how much each glyph should be offset in the x and y direction relative to the face it's being placed on.
        # Calling this function a second time will not remove the previous glyph offsets, and instead will combine the
        # two offsets togther. It is advised that this method should only be called once.
        #   x_offset: The distance to offset the glyph in the horizontal direction (in mm).
        #   y_offset: The distance to offset the glyph in the vertical direction (in mm).
        def set_glyph_offsets(x_offset, y_offset)
            @face_transforms.each() do |face_transform|
                # Add an extra translation transformsion that offsets the glyphs in face-local coordinates.
                offset_vector = Util.scale_vector(face_transform.xaxis, x_offset) +
                                Util.scale_vector(face_transform.yaxis, y_offset)
                @face_transform = Geom::Transformation.translation(offset_vector) * @face_transform
            end
        end

        # Creates a new instance of this die with the specified type and font, amoungst other arguments.
        #   font: The font to use for generating glyphs on the die. If set to nil, no glyphs will be embossed onto the
        #         die. Defaults to nil.
        #   type: Either the stringified name for the type of die being created, or the maximum number to count up to.
        #         When specified as a number, it must divide the number of glyph faces on the die. If the type number
        #         is the same as the number of faces, the die will be numbered 'standardly', otherwise the glyphs are
        #         simply repeated. For example, creating a D20 with a type of 5, will cause each number to be repeated
        #         4 times. There are also special types of die that can only be used for some models, for example 'D4'
        #         will only work with a Tetrahedron, and places glyphs in the corners instead of the face. The following
        #         list contains every special type of die: "D4", "D%". If set as nil, the type will be set to the number
        #         of faces on the die, producing a die with no repeated glyphs. Defaults to nil.
        #   group: The group to generate the die into. If left 'nil' then a new top-level group is created for it.
        #          In practice, the die is always created within it's own die group, and the die group is what's placed
        #          into the provided group. Defaults to nil.
        #   scale: The amount to scale the die by after it's been created. Defaults to 1.0 (no scaling).
        #   die_size: The size to make the die in mm. Specifically this sets the distance between two diametric faces,
        #             or a face and the vertex diametrically opposite to it if necessary (like for tetrahedrons (D4)).
        #             If left as nil, it uses the default size for the die. Defaults to nil.
        #   font_size: The height to make the glyphs on the die, in mm. If nil, it uses the default glyph size for the
        #              die. Defaults to nil.
        #   glyph_mapping: String representing which glyph mapping to use. If left as nil, the default mapping is used
        #                  where no rotating is performed, and each face is embossed with a glyph corresponding to it's
        #                  numerical index.
        #   transform: A custom transformation that is applied to the die after generation. Defaults to no transform.
        def create_instance(font: nil, type: nil, group: nil, scale: 1.0, die_size: nil, font_size: nil, glyph_mapping: nil, transform: IDENTITY)
            # If no group was provided, create a new top-level group for the die.
            group ||= Util::MAIN_MODEL.entities().add_group()

            # Start a new operation so that creating the die can be undone/aborted if necessary.
            Util::MAIN_MODEL.start_operation('Create ' + self.class.name.split('::').last(), true)

            # Create an instance of the die model within the enclosing group.
            # We have to make 2 instances so that 'make_unique' works correctly. If only one instance exists,
            # make_unique does nothing, since it's already unique, and hence changes to the die affect the definition
            # when it shouldn't. By making a fake_instance first, when we call make_unique on the second instance, it
            # will actually create a new underlying definition for it, preventing any changes to the die from leaking
            # through to the definition.
            fake_instance = group.entities().add_instance(@definition, IDENTITY)
            instance = group.entities().add_instance(@definition, IDENTITY).make_unique()
            fake_instance.erase!()

            die_def = instance.definition()
            die_mesh = die_def.entities()
            # Scale the die mesh model to the specified size.
            unless die_size.nil?()
                die_mesh.transform_entities(Geom::Transformation.scaling(die_size.to_f() / @die_size), die_mesh.to_a())
            end

            # Create a separate group for placing glyphs into.
            glyph_group = group.entities().add_group()
            glyph_mesh = glyph_group.entities()

            # Place the glyphs onto the die in preperation for embossing by calling the provided function.
            unless font.nil?()
                place_glyphs(font: font, mesh: glyph_mesh, type: type, die_size: die_size, font_size: font_size, glyph_mapping: glyph_mapping)
            end

            # Force Sketchup to recalculate the bounds of all the groups so that the intersection works properly.
            die_def.invalidate_bounds()
            glyph_group.definition().invalidate_bounds()

            # Emboss the glyphs onto the faces of the die, then delete the glyphs.
            # TODO figure out why things aren't embossed correctly still.
            die_mesh.intersect_with(false, IDENTITY, die_mesh, IDENTITY, true, glyph_mesh.to_a())
            glyph_group.erase!()

            # Intersect the die mesh with itself to make sure the glyphs get embossed correctly. There's an issue where
            # without this, the inner edges of glyphs don't connect to form a subface on the face of the die.
            # This line doesn't completely fix the issue, it still happens, but it helps reduce it's prevalence.
            die_mesh.intersect_with(false, IDENTITY, die_mesh, IDENTITY, true, die_mesh.to_a())

            # Combine the scaling transformation with the provided external transform and apply them both to the die.
            die_mesh.transform_entities(transform * Geom::Transformation.scaling(scale), die_mesh.to_a())

            # Commit the operation to signal to Sketchup that the die has been created.
            Util::MAIN_MODEL.commit_operation()
        end

        # Creates and places glyphs onto the faces of the die. This default implementation iterates through each face
        # and places the corresponding number on it, but subclasses can override this method for custom glyph placement.
        #   font: The font to create the glyphs in.
        #   mesh: The collection of entities where glyphs should be generated into.
        #   type: The type of die that the glyphs are being placed for. This can either be a special type like "D4" or
        #         "D%" which are handled by overriden versions of this function, or a number indicating the maximum
        #         number to count up to on the die. If there are more faces than the type number, numbers are repeated.
        #         However, the die type must divide the number of faces evenly.
        #   die_size: The size of the die in mm. Specifically, this must be the distance between two diametric faces, or
        #             a face and a vertex diametrically opposite to it if necessary (like for the tetrahedron (D4)).
        #             If left as nil, it uses the default size for the die. Defaults to nil.
        #   font_size: The height to make the glyphs on the die, in mm. If nil, it uses the default glyph size for the
        #              die. Defaults to nil.
        #   glyph_mapping: String representing which glyph mapping to use. If left as nil, the default mapping is used
        #                  where no rotating is performed, and each face is embossed with a glyph corresponding to it's
        #                  numerical index.
        def place_glyphs(font:, mesh:, type: nil, die_size: nil, font_size: nil, glyph_mapping: nil)
            # First ensure that the die model is compatible with the provided type.
            unless (@face_transforms.length() % type == 0)
                face_count = @face_transforms.length()
                raise "Incompatible die type: a D#{face_count} model cannot be used to generate D#{type} dice."
            end

            # If no glyph_mapping was provided, use the default mapping.
            glyph_mapping ||= "default"
            glyph_angles = []
            glyph_names = []
            # Look up the glyph mapping by name.
            if @glyph_mappings.key?(glyph_mapping)
                glyphs, offsets = @glyph_mappings[glyph_mapping]
            else
                model_name = self.class().name().split("::").last()
                raise "Specified glyph mapping: '#{glyph_mapping}' isn't defined for the #{model_name} die model."
            end

            # Calcaulte the scale factors for the die and the font.
            die_scale = (die_size.nil?()? 1.0 : (die_size.to_f() / @die_size))
            font_scale = (font_size.nil?()? 1.0 : (font_size.to_f() / @font_size))

            # If no type was provided, set it the number of faces on the die.
            type ||= @face_transforms.length()

            # Iterate through each face in order and generate the corresponding number on it.
            @face_transforms.each_with_index() do |face_transform, i|
                # First scale and rotate the glyph, then perform the face-local coordinate transformation.
                glyph_rotation = Geom::Transformation.rotation(ORIGIN, Z_AXIS, glyph_angles[i])
                full_transform = face_transform * glyph_rotation * Geom::Transformation.scaling(font_scale)
                # Then, translate the glyph by a z-offset that ensures the glyph and face are coplanar, even if the die
                # has been scaled up.
                offset_vector = Util.scale_vector(face_transform.origin - ORIGIN, (die_scale - 1.0))
                full_transform = Geom::Transformation.translation(offset_vector) * full_transform

                glyph_name = glyph_names[(i % type) + 1].to_s()
                font.create_glyph(name: glyph_name, entities: mesh, transform: full_transform)
            end
        end
    end

    # Helper method that just forwards to the 'create_instance' method of the specified die model.
    def create_die(model:, font: nil, type: nil, group: nil, scale: 1.0, die_size: nil, font_size: nil,  glyph_mapping: nil, transform: IDENTITY)
        # If no specific model instance was passed, use the standard instance for the specified model.
        if model.is_a?(Class)
            model = model::STANDARD
        end
        model.create_instance(font: font, type: type, group: group, scale: scale, die_size: die_size, font_size: font_size, glyph_mapping: glyph_mapping, transform: transform)
    end

end
end



# These lines just make life easier when typing things into IRB, by making it so we don't have to explicitely state the
# modules for the 'DiceGen', 'Fonts', and 'Dice' namespaces.
include DiceGen
include Fonts
include Dice

# Import all the fonts that we've created so far.
require_relative "Fonts.rb"
# Import all the die model that we've created so far.
require_relative "Dice.rb"
