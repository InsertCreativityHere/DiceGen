
require 'singleton'

module DiceGen

# Module containing general use utility code.
module Util
    module_function

    # Stores the currently active Sketchup model.
    MAIN_MODEL = Sketchup::active_model

    # Dummy transformation that represents the transformation of doing nothing.
    NO_TRANSFORM = Geom::Transformation::new()

    # Imports a file and returns a reference to the imported definition. Note that this function will cause the
    # imported definition to appear at the mouse cursor in the UI, this is a limitation of the API. Hitting <ESC>
    # Will get rid of the extra instance.
    #   file: The absolute path of the file to import from.
    #   return: A ComponentDefinition corresponding to the imported definition.
    def import_definition(file)
        # Check if the file exists and is reachable.
        if !File.exist?(file)
            raise "Failed to locate the file '#{file}'"
        end

        # Try to import the file's model and check if it was successful.
        result = MAIN_MODEL.import(file)
        if !result
            raise "Failed to import model from the file '#{file}'"
        end

        # Return the most recently created definition; ie: the one we just imported.
        return MAIN_MODEL.definitions[-1]
    end

    # Scales a vector by the provided scale factor like 'vector * scale' would normally.
    #   vector: The vector to scale. Note that this vector isn't altered by the function, instead it's components
    #           components are copied into a new vector and that is scaled and returned.
    #   scale: The scale factor to scale the vector by.
    #   return: A new vector with the same components as the provided vector, but scaled by 'scale_factor'.
    def scale_vector(vector, scale)
        return Geom::Vector3d::new(vector.x * scale, vector.y * scale, vector.z * scale)
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
            if (mesh_names.nil?)
                (Dir["#{font_folder}/meshes/*.dae"]).each() do |file|
                    # Get the file name on it's own, and without it's extension.
                    filename = File.basename(file, ".dae")
                    meshes[filename] = Util.import_definition(file)
                    puts "    Loaded '#{filename}.dae'"
                end
            else
                mesh_names.each() do |mesh|
                    # Get the absolute path of the mesh file to import.
                    file = "#{font_folder}/meshes/#{mesh}.dae"
                    if (File.exists?(file))
                        meshes[mesh] = Util.import_definition(file)
                        puts "    Loaded '#{mesh}.dae'"
                    else
                        puts "    Failed to load '#{mesh}.dae'"
                    end
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
            definition = MAIN_MODEL.definitions.add(name)
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

        # Transforms the provided value to a first place percentile (percentile for the digits place) by subtracting 1.
        # Value must a string that represents an integer, calling this with anything else will raise an error.
        #   value: The integer value to convert to a first place percentile, passed as a string.
        #   return: The converted value.
        def convertForPercentile0(value)
            return String(Integer(value) - 1)
        end

        # Transforms the provided value to a second place percentile (percentile for the tens place) by subtracting 1
        # and concatenating a '0' on the end. Value must a string that represents an integer, calling this with anything
        # else will raise an error.
        #   value: The integer value to convert to a second place percentile, passed as a string.
        #   return: The converted value.
        def convertForPercentile00(value)
            return String(Integer(value) - 1) + '0'
        end
    end

    # A bare-bones font that creates glyphs directly from ComponentDefinition objects, and the base class for all fonts.
    class Font
        # Limits this class (and it's subclasses) to only ever having a single instance which is globally available.
        include Singleton

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
            @glyphs.merge(glyphs);
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
        def create_glyph(name:, entities:, transform: Util::NO_TRANSFORM)
            return entities.add_instance(@glyphs[name], transform).make_unique()
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
        attr_reader :padding;

        # Create a new spliced font with the specified font, and whose base glyphs are defined by meshes stored in DAE
        # files. Every mesh in the font folder is loaded, and afterwards, composite glyphs are generated as needed.
        #   name: The plain-text name of the font.
        #   folder: The absolute path of the base font folder. This is NOT the folder immediately containing the mesh
        #         files, but the one above it; This function expects our custom directory scheme to be followed, and so
        #         it's the actual font folder that it expects to get.
        #   padding: The amount of horizontal space to leave in between glyphs when splicing them together.
        def initialize(name:, folder:, padding:)
            super(name: name, folder: folder)
            @padding = padding;
        end

        # Creates and returns an instance of the specified glyph as a 2D model. The glyph is always created in it's own
        # enclosing group, and this group is added to the provided entities (instead of placing the glyph directly).
        # This method delegates to the base implementation, but just makes sure to generate the requested glyph via
        # splicing if it hasn't been created yet. After the check (and possible splicing), the base method is called.
        #   name: The name of the glyph to create, usually this is the text the glyph represents.
        #   entities: The entities collection to place the glyph's group into, and hence the glyph itself.
        #   transform: A custom transformation that is applied to the glyph after placement. Defaults to no transform.
        #   return: The group that immediately components the glyph's mesh.
        def create_glyph(name:, entities:, transform: Util::NO_TRANSFORM)
            # Lazily create the requested glyph via splicing if it doesn't already have a definition.
            unless @glyphs.key?(name)
                char_glyphs = name.chars().map{ |char| @glyphs[char] }
                @glyphs[name] = FontUtil.splice_glyphs(glyphs: char_glyphs, padding: padding);
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

        # Stores the order that numbers should be placed onto the faces of a D4 with. Each entry starts with the number
        # corresponding to a respective face, then lists the numbers for each remaining vertex in clockwise order.
        D4_NUMBERING = [['1', '2', '3'], ['2', '4', '3'], ['3', '4', '1'], ['4', '2', '1']]

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
    class Die
        # Limits this class (and it's subclasses) to only ever having a single instance which is globally available.
        # We use the singleton pattern here because we only want to create the definition of each model once, and these
        # classes represent the die model definitions, not their component instances, of which there can be multiple.
        include Singleton

        # The ComponentDefinition that defines the die's mesh model.
        attr_reader :definition
        # An array of transformations used to place glyphs onto the faces of this die model. Each entry is a coordinate
        # transformation that maps the standard world coordinates to a face-local system with it's origin at the
        # geometric center of the face, and it's axes rotated to be coplanar to the face (with +z pointing out).
        # Each face has it's respective transformation, and they're ordered in the same way faces are numbered by.
        attr_reader :face_transforms

        # Super constructor for all dice models that stores the die's model definition, and computes a set of
        # transformations from the die's faces that can be used to easily add glyphs to the die later on.
        #   definition: The ComponentDefinition that holds the die's mesh definition.
        #   faces: Array of all the die's faces, in the same order the face's should be numbered by.
        #   die_scale: The amount to scale the die by to make it 'standard size' (as defined by our Chessex dice).
        #              This scaling is applied before any glyphs are placed onto the die.
        #              Defaults to 1.0, so no scaling is performed.
        #   font_scale: The amount to scale each glyph by. This is applied directly after the glyph has been placed,
        #               but not embossed. Defaults to 1.0, so no scaling is performed.
        def initialize(definition:, faces:, die_scale: 1.0, font_scale: 1.0)
            @definition = definition
            entities = @definition.entities()
            entities.transform_entities(Geom::Transformation.scaling(die_scale), entities.to_a())

            @face_transforms = Array::new(faces.length())
            # Iterate through each face of the die and compute their face-local coordinate transformations.
            faces.each_with_index() do |face, i|
                @face_transforms[i] = DiceUtil.get_face_transform(face) * Geom::Transformation.scaling(font_scale)
            end
        end

        # Creates a new instance of this die with the specified type and font, amoungst other arguments.
        #   font: The font to use for generating glyphs on the die.
        #   type: The stringified name for the type of die being created. Some models can be used to create multiple
        #             types of die; for instance the D10 model is used for both "D10" and "D%" type dice.
        #             Standard values are "D4", "D6", "D8", "D10", "D%", "D12", and "D20".
        #   group: The group to generate the die into. If left 'nil' then a new top-level group is created for it.
        #          In practice, the die is always created within it's own die group, and the die group is what's placed
        #          into the provided group. Defaults to nil.
        #   scale: The amount to scale the die by after it's been created. Defaults to 1.0 (no scaling).
        #   die_scale: The amount to scale the die mesh model before embossing occurs. Defaults to 1.0 (no scaling).
        #   font_scale: The amount to scale the glyphs by before embossing them. Defaults to 1.0 (no scaling).
        #   font_offset: A pair of x,y coordinates specifying how much to offset the glyph in each direction
        #                respectively. Defaults to [0,0] (no offsetting). This is mostly used for dice like the
        #                tetrahedral D4 whereglyphs shouldn't be face-centered.
        #   transform: A custom transformation that is applied to the die after generation. Defaults to no transform.
        def create_instance(font:, type:, group: nil, scale: 1.0, die_scale: 1.0, font_scale: 1.0, font_offset: [0,0],
                            transform: Util::NO_TRANSFORM)
            # If no group was provided, create a new top-level group for the die.
            if (group.nil?())
                group = Util::MAIN_MODEL.entities().add_group()
            end

            # Start a new operation so that creating the die can be undone/aborted if necessary.
            Util::MAIN_MODEL.start_operation('Create ' + self.class.name.split('::').last(), true)

            # Create an instance of the die model within the enclosing group.
            # We have to make 2 instances so that 'make_unique' works correctly. If only one instance exists,
            # make_unique does nothing, since it's already unique, and hence changes to the die affect the definition
            # when it shouldn't. By making a fake_instance first, when we call make_unique on the second instance, it
            # will actually create a new underlying definition for it, preventing any changes to the die from leaking
            # through to the definition.
            fake_instance = group.entities().add_instance(@definition, Util::NO_TRANSFORM)
            instance = group.entities().add_instance(@definition, Util::NO_TRANSFORM).make_unique()
            fake_instance.erase!()

            die_def = instance.definition()
            die_mesh = die_def.entities()
            # Scale the die mesh model by the specified amount.
            die_mesh.transform_entities(Geom::Transformation.scaling(die_scale), die_mesh.to_a())

            # Create a separate group for placing glyphs into.
            glyph_group = group.entities().add_group()
            glyph_mesh = glyph_group.entities()

            # Place the glyphs onto the die in preperation for embossing by calling the provided function.
            unless font.nil?()
                place_glyphs(font: font, mesh: glyph_mesh, type: type, die_scale: die_scale, font_scale: font_scale,
                             font_offset: font_offset)
            end

            # Force Sketchup to recalculate the bounds of all the groups so that the intersection works properly.
            die_def.invalidate_bounds()
            glyph_group.definition().invalidate_bounds()

            # Emboss the glyphs onto the faces of the die, then delete the glyphs.
            die_mesh.intersect_with(false, Util::NO_TRANSFORM, die_mesh, Util::NO_TRANSFORM, true, glyph_mesh.to_a())
            glyph_group.erase!()

            # Combine the scaling transformation with the provided external transform and apply them both to the die.
            die_mesh.transform_entities(transform * Geom::Transformation.scaling(scale), die_mesh.to_a())

            # Commit the operation to signal to Sketchup that the die has been created.
            Util::MAIN_MODEL.commit_operation()
        end

        # Creates and places glyphs onto the faces of the die. This default implementation iterates through each face
        # and places the corresponding number on it, but subclasses can override this method for custom glyph placement.
        #   font: The font to create the glyphs in.
        #   mesh: The collection of entities where glyphs should be generated into.
        #   type: The type of die that the glyphs are being placed for. This is ignored in the default implementation,
        #   but can be checked for custom behavior. Standard values are "D4", "D6", "D8", "D10", "D%", "D12", and "D20".
        #   die_scale: The amount that the die was scaled by before embossing. This doesn't include the pre-scaling
        #              that was done on the definition, but only the local scaling done while creating an instance.
        #   font_scale: The amount to scale the glyphs by before embossing them. Defaults to 1.0 (no scaling).
        #   font_offset: A pair of x,y coordinates specifying how much to offset the glyph in each direction
        #                respectively. Defaults to [0,0] (no offsetting). This is mostly used for dice like the
        #                tetrahedral D4 where glyphs shouldn't be face-centered.
        def place_glyphs(font:, mesh:, type:, die_scale: 1.0, font_scale: 1.0, font_offset: [0,0])
            # Iterate through each face in order and generate the corresponding number on it.
            @face_transforms.each_with_index() do |face_transform, i|
                # First scale the glyph by font_scale, before performing the face-local coordinate transformation.
                full_transform = face_transform * Geom::Transformation.scaling(font_scale)
                # Then, translate the glyph by the specified offset (in face-local coordinates), plus a z-offset
                # that ensures the glyph and face are coplanar, even if the die has been scaled up.
                offset_vector = Util.scale_vector(face_transform.xaxis, font_offset[0]) + \
                                Util.scale_vector(face_transform.yaxis, font_offset[1]) + \
                                Util.scale_vector(face_transform.origin - Geom::Point3d::new(), (die_scale - 1.0))
                full_transform = Geom::Transformation.translation(offset_vector) * full_transform

                font.instance.create_glyph(name: (i+1).to_s(), entities: mesh, transform: full_transform)
            end
        end
    end

    # Helper method that just forwards to the 'create_instance' method of the specified die model.
    def create_die(model:, font:, type:, group: nil, scale: 1.0, die_scale: 1.0, font_scale: 1.0, font_offset: [0,0],
                   transform: Util::NO_TRANSFORM)
        model.instance.create_instance(font: font, type: type, group: group, scale: scale, die_scale: die_scale,
                                       font_scale: font_scale, font_offset: font_offset, transform: transform)
    end

end
end

# Import all the fonts that we've created so far.
puts "===== Loading Fonts ====="
require_relative "Fonts.rb"
# Import all the die model that we've created so far.
puts "===== Loading Dice ====="
require_relative "Dice.rb"

# These lines just make life easier when typing things into IRB, by making it so we don't have to explicitely state the
# modules for the 'DiceGen', 'Dice', and 'Fonts' namespaces.
include DiceGen
include Dice
include Fonts
