
module DiceGen

    ##### UTILITIES #####

    # Module containing general use utility code.
    module Util
        module_function

        # Stores the currently active Sketchup model.
        MAIN_MODEL = Sketchup::active_model

        # Dummy transformation that represents the transformation of doing nothing.
        DUMMY_TRANSFORM = Geom::Transformation::new()

        # Flag for whether the system Sketchup is running on is Windows or Unix like.
        @@is_windows = (Sketchup::platform == :platform_win rescue RUBY_PLATFORM !~ /darwin/i)
        if @@is_windows
            require "win32ole"
        end

        # Triggers an <ESC> key-press
        def send_escape()
            if @@is_windows
                WIN32OLE::new('WScript.Shell').SendKeys('{ESC}')
            else
                Sketchup.send_action('cancelOperation:')
            end
        end

        # Imports a file and returns a reference to the imported definition. Note that this function will cause the
        # imported definition to appear at the mouse cursor in the UI, this is a limitation of the API. Hitting <ESC>
        # Will get rid of the extra instance.
        #   file: The absolute path of the file to import from.
        #   return: A ComponentDefinition corresponding to the imported definition.
        def import_definition(file:)
            # Check if the file exists and is reachable.
            if !File.exist?(file)
                raise "Failed to locate the file '#{file}'"
            end

            # Try to import the file's model and check if it was successful.
            result = Util::MAIN_MODEL.import(file)
            if !result
                raise "Failed to import model from the file '#{file}'"
            end

            # Press the <ESC> key to prevent an instance from being placed at the mouse cursor.
            # send_escape() TODO ENABLE THIS WHEN WE MAKE A REAL SCRIPT INSTEAD OF USING THE RUBY CONSOLE.

            # Return the most recently created definition, ie: the one we just imported.
            return Util::MAIN_MODEL.definitions[-1]
        end
    end



    ##### FONTS #####

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
                    meshes[filename] = Util.import_definition(file: file)
                    puts "    Loaded '#{filename}.dae'"
                end
            else
                mesh_names.each() do |mesh|
                    # Get the absolute path of the mesh file to import.
                    file = "#{font_folder}/meshes/#{mesh}.dae"
                    if (File.exists?(file))
                        meshes[mesh] = Util.import_definition(file: file)
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
            definition = Util::MAIN_MODEL.definitions.add(name)
            entities = definition.entities()

            # Keep a running tally of the current x position, starting at the rightmost point.
            xPos = total_width / 2

            # Create instances of the component glyphs in the new definition.
            glyphs.each() do |glyph|
                # Calculate the x position to place the glyph at so the new spliced glyph is still centered.
                width = glyph.bounds().width()
                offset = Geom::Point3d::new(xPos - (width / 2), 0, 0)
                # Create an instance of the component glyph to splice it into the definition.
                entities.add_instance(glyph, Geom::Transformation.translation(offset))
                # Increment the width by the width of the glyph we just placed, plus the padding between glyphs.
                xPos -= width + padding
            end

            return definition
        end

        # Transforms the provided value to a first place percentile (percentile for the digits place) by subtracting 1.
        # Value must a string that represents an integer, calling this with anything else will raise an error.
        # value: The integer value to convert to a first place percentile, passed as a string.
        # return: The converted value.
        def convertForPercentile0(value:)
            return String(Integer(value) - 1)
        end

        # Transforms the provided value to a second place percentile (percentile for the tens place) by subtracting 1
        # and concatenating a '0' on the end. Value must a string that represents an integer, calling this with anything
        # else will raise an error.
        # value: The integer value to convert to a second place percentile, passed as a string.
        # return: The converted value.
        def convertForPercentile00(value:)
            return String(Integer(value) - 1) + '0'
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
        def set_glyphs(glyphs:)
            @glyphs.merge(glyphs);
        end

        # Scales the glyphs by a hash of scale factors.
        #   scales: A hash of scale factors; Keys must correspond to the name of a glyph in this font, and it's value is
        #           the factor to scale the glyphs definition by. A factor of 1 will have no effect on the glyph.
        def set_scales(scales:)
            scales.each() do |name, scale|
                entities = @glyphs[name].entities()
                entities.transform_entities(Geom::Transformation.scaling(scale), entities.to_a())
            end
        end

        # Translate the glyphs by a hash of (x,y) offset pairs.
        #   offsets: A hash of offset pairs; Keys must correspond to the name of a glyph in this font, and it's value is
        #            a pair of offsets specifying how much to translate the glyph in each direction (x and y).
        def set_offsets(offsets:)
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
        def create_glyph(name:, entities:, transform: Util::DUMMY_TRANSFORM)
            return entities.add_instance(@glyphs[name], transform).make_unique()
        end
    end


    # A font where every glyph is defined by it's own unique mesh model, and no combining of glyphs is performed.
    class RawFont < Font
        # The absolute path of the base folder that contains all the data for this font.
        attr_reader :folder

        # Create a new raw font with the specified name, and whose glyphs are defined by meshes stored in DAE files.
        # name: The plain-text name of the font.
        # folder: The absolute path of the base font folder. This is NOT the folder immediately containing the mesh
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
        # name: The plain-text name of the font.
        # folder: The absolute path of the base font folder. This is NOT the folder immediately containing the mesh
        #         files, but the one above it; This function expects our custom directory scheme to be followed, and so
        #         it's the actual font folder that it expects to get.
        # padding: The amount of horizontal space to leave in between glyphs when splicing them together.
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
        def create_glyph(name:, entities:, transform: Util::DUMMY_TRANSFORM)
            # Lazily create the requested glyph via splicing if it doesn't already have a definition.
            unless @glyphs.key?(name)
                @glyphs[name] = FontUtil.splice_glyphs(glyphs: name.chars().map{ |char| @glyphs[char] }, padding: padding); #TODO
            end
            return super
        end
    end



    ##### DICE #####

    require 'singleton'

    #  Module containing dice specific utility code.
    module DiceUtil
        # The mathematical constant known as the "golden ratio".
        $PHI = (1.0 + Math::sqrt(5)) / 2.0

        # The reciprocal of phi.
        $IHP = 1.0 / $PHI
    end


    # Abstract base class for all dice.
    class Die
        # Limits this class (and it's subclasses) to only ever having a single instance which is globally available.
        # We use the singleton pattern here because we only want to create the definition of each die once, and these
        # classes represent the die definitions, and not their component instances, of which there can be multiple.
        include Singleton

        # The ComponentDefinition that defines the die's mesh model.
        attr_reader :definition
        # An array of transformations used to place glyphs onto the faces of this die. Each entry is a coordinate
        # transformation that maps the standard world coordinates to a face-local system with it's origin at the
        # geometric center of the face, and it's axes rotated to be coplanar to the face (with +z pointing out).
        # Each face has it's respective transformation, and they're ordered in the same way faces are numbered by.
        attr_reader :face_transforms

        # Super constructor for all dice that stores the die's definition, and computes a set of transformations from
        # the die's faces that can be used to easily add glyphs to the die later on.
        # definition: The ComponentDefinition that holds the die's mesh definition.
        # faces: Array of all the die's faces, in the same order the face's should be numbered by.
        def initialize(definition:, faces:)
            @definition = definition

            @face_transforms = Array::new(faces.length())
            # Iterate over each of the faces and compute their transformations via translation and rotation.
            faces.each_with_index() do |face, i|
                @face_transforms [i]= Util::DUMMY_TRANSFORM
            end
        end

        #TODO FORREAL
        def self.create_die(font:, group:, scale: 1.0, transform: Util::DUMMY_TRANSFORM)
            # Start a new operation so that creating the die can be undone/aborted if necessary.
            Util::MAIN_MODEL.start_operation('Create Die', true)

            # Create an instance of the die model within the enclosing group.
            instance = group.entities().add_instance(self.instance.definition, Util::DUMMY_TRANSFORM).make_unique()
            die_def = instance.definition()
            die_mesh = die_def.entities()

            # Create a separate group for placing glyphs into.
            glyph_group = group.entities().add_group()
            glyph_mesh = glyph_group.entities()

            # Create glyphs for each face of the die and align them in preperation for embossing.
            self.instance.face_transforms.each_with_index() do |face_transform, i|
                font.create_glyph(name: (i+1).to_s(), entities: glyph_mesh, transform: face_transform)
            end

            # Force Sketchup to recalculate the bounds of all the groups so that the intersection works properly.
            die_def.invalidate_bounds()
            glyph_group.definition().invalidate_bounds()

            # Emboss the glyphs onto the faces of the die, then delete the glyphs.
            die_mesh.intersect_with(false, Util::DUMMY_TRANSFORM, die_mesh, Util::DUMMY_TRANSFORM, true, glyph_mesh.to_a()) #TODO
            #glyph_group.erase!()

            # Combine the scaling transformation with the provided external transform and apply them both to the die.
            die_mesh.transform_entities(Geom::Transformation.scaling(scale) * transform, die_mesh.to_a())

            # Commit the operation to signal to Sketchup that the die has been created.
            Util::MAIN_MODEL.commit_operation()

            return instance
        end
    end


    # Abstract base class for all D4 dice.
    class D4Die < Die
        #TODO
    end


    # Abstract base class for all D6 dice.
    class D6Die < Die
        #TODO
    end


    # Abstract base class for all D6 dice.
    class D8Die < Die
        #TODO
    end


    # Abstract base class for all D6 dice.
    class D10Die < Die
        #TODO
    end


    # Abstract base class for all D6 dice.
    class D100Die < Die
        #TODO
    end


    # Abstract base class for all D6 dice.
    class D12Die < Die
        #TODO
    end


    # Abstract base class for all D6 dice.
    class D20Die < Die
        #TODO
    end


    # Module containing all the sharp-edged standard dice definitions.
    module SharpEdgedStandard

        # This class defines the mesh model for a sharp-edged standard D4 die (a tetrahedron).
        class D4 < D4Die
            # Lays out the geometry for the die in a new ComponentDefinition and adds it to the main DefinitionList.
            def initialize()
                # Create a new definition for the die.
                definition = Util::MAIN_MODEL.definitions.add(self.class.name)
                mesh = definition.entities()

                # Define all the points that make up the vertices of the die.
                p111 = Geom::Point3d::new( 1,  1,  1)
                p001 = Geom::Point3d::new(-1, -1,  1)
                p010 = Geom::Point3d::new(-1,  1, -1)
                p100 = Geom::Point3d::new( 1, -1, -1)

                # Create the faces of the die by joining the vertices with edges.
                faces = Array::new(4)
                faces[0] = mesh.add_face([p010, p001, p111])
                faces[1] = mesh.add_face([p100, p010, p001])
                faces[2] = mesh.add_face([p010, p111, p100])
                faces[3] = mesh.add_face([p001, p111, p100])

                super(definition: definition, faces: faces)
            end
        end

        # This class defines the mesh model for a sharp-edged standard D6 die (a hexhedron (fancy word for cube)).
        class D6 < D6Die
            # Lays out the geometry for the die in a new ComponentDefinition and adds it to the main DefinitionList.
            def initialize()
                # Create a new definition for the die.
                definition = Util::MAIN_MODEL.definitions.add(self.class.name)
                die_mesh = definition.entities()

                # Define all the points that make up the vertices of the die.
                p000 = Geom::Point3d::new(-1, -1, -1)
                p001 = Geom::Point3d::new(-1, -1,  1)
                p010 = Geom::Point3d::new(-1,  1, -1)
                p100 = Geom::Point3d::new( 1, -1, -1)
                p011 = Geom::Point3d::new(-1,  1,  1)
                p101 = Geom::Point3d::new( 1, -1,  1)
                p110 = Geom::Point3d::new( 1,  1, -1)
                p111 = Geom::Point3d::new( 1,  1,  1)

                # Create the faces of the die by joining the vertices with edges.
                faces = Array::new(6)
                faces[0] = die_mesh.add_face([p111, p011, p001, p101])
                faces[1] = die_mesh.add_face([p101, p001, p000, p100])
                faces[2] = die_mesh.add_face([p001, p011, p010, p000])
                faces[3] = die_mesh.add_face([p111, p101, p100, p110])
                faces[4] = die_mesh.add_face([p011, p111, p110, p010])
                faces[5] = die_mesh.add_face([p000, p100, p110, p010])

                super(definition: definition, faces: faces)
            end
        end

        # This class defines the mesh model for a sharp-edged standard D8 die (an equilateral octohedron).
        class D8 < D8Die
            # Lays out the geometry for the die in a new ComponentDefinition and adds it to the main DefinitionList.
            def initialize()
                # Create a new definition for the die.
                definition = Util::MAIN_MODEL.definitions.add(self.class.name)
                mesh = definition.entities()

                # Define all the points that make up the vertices of the die.
                px = Geom::Point3d::new( 1,  0,  0)
                nx = Geom::Point3d::new(-1,  0,  0)
                py = Geom::Point3d::new( 0,  1,  0)
                ny = Geom::Point3d::new( 0, -1,  0)
                pz = Geom::Point3d::new( 0,  0,  1)
                nz = Geom::Point3d::new( 0,  0, -1)

                # Create the faces of the die by joining the vertices with edges.
                faces = Array::new(8)
                faces[0] = mesh.add_face([px, py, pz])
                faces[1] = mesh.add_face([nx, py, nz])
                faces[2] = mesh.add_face([nx, py, pz])
                faces[3] = mesh.add_face([px, py, nz])
                faces[4] = mesh.add_face([nx, ny, pz])
                faces[5] = mesh.add_face([px, ny, nz])
                faces[6] = mesh.add_face([px, ny, pz])
                faces[7] = mesh.add_face([nx, ny, nz])

                super(definition: definition, faces: faces)
            end
        end

        # This class defines the mesh model for a sharp-edged standard D10 die (a pentagonal trapezohedron).
        class D10 < D10Die
            # Lays out the geometry for the die in a new ComponentDefinition and adds it to the main DefinitionList.
            def initialize()
                # Create a new definition for the die.
                definition = Util::MAIN_MODEL.definitions.add(self.class.name)
                mesh = definition.entities()

                # Define all the points that make up the vertices of the die.
                #TODO

                # Create the faces of the die by joining the vertices with edges.
                faces = Array::new(10)
                #TODO

                super(definition: definition, faces: faces)
            end
        end

        # This class defines the mesh model for a sharp-edged standard D12 die (a dodecahedron).
        class D12 < D12Die
            # Lays out the geometry for the die in a new ComponentDefinition and adds it to the main DefinitionList.
            def initialize()
                # Create a new definition for the die.
                definition = Util::MAIN_MODEL.definitions.add(self.class.name)
                mesh = definition.entities()

                # Define all the points that make up the vertices of the die.
                #TODO

                # Create the faces of the die by joining the vertices with edges.
                faces = Array::new(12)
                #TODO

                super(definition: definition, faces: faces)
            end
        end

        # This class defines the mesh model for a sharp-edged standard D20 die (an icosahedron).
        class D20 < D20Die
            # Lays out the geometry for the die in a new ComponentDefinition and adds it to the main DefinitionList.
            def initialize()
                # Create a new definition for the die.
                definition = Util::MAIN_MODEL.definitions.add(self.class.name)
                mesh = definition.entities()

                # Define all the points that make up the vertices of the die.
                pzp = Geom::Point3d::new(    0,     1,  $PHI)
                nzp = Geom::Point3d::new(    0,     1, -$PHI)
                pzn = Geom::Point3d::new(    0,    -1,  $PHI)
                nzn = Geom::Point3d::new(    0,    -1, -$PHI)
                pyp = Geom::Point3d::new(    1,  $PHI,     0)
                nyp = Geom::Point3d::new(    1, -$PHI,     0)
                pyn = Geom::Point3d::new(   -1,  $PHI,     0)
                nyn = Geom::Point3d::new(   -1, -$PHI,     0)
                pxp = Geom::Point3d::new( $PHI,     0,     1)
                nxp = Geom::Point3d::new(-$PHI,     0,     1)
                pxn = Geom::Point3d::new( $PHI,     0,    -1)
                nxn = Geom::Point3d::new(-$PHI,     0,    -1)

                # Create the faces of the die by joining the vertices with edges.
                faces = Array::new(20)
                #TODO I should re-arrange these to be in order.
                faces[5]  = mesh.add_face([pxn, pyp, pxp])
                faces[8]  = mesh.add_face([nyp, pxp, pxn])
                faces[11] = mesh.add_face([pyn, nxn, nxp])
                faces[14] = mesh.add_face([nxp, nyn, nxn])
                faces[2]  = mesh.add_face([pzn, pxp, pzp])
                faces[16] = mesh.add_face([pzn, nxp, pzp])
                faces[3]  = mesh.add_face([nzp, pxn, nzn])
                faces[17] = mesh.add_face([nzp, nxn, nzn])
                faces[7]  = mesh.add_face([pyp, pyn, pzp])
                faces[19] = mesh.add_face([pyp, pyn, nzp])
                faces[0]  = mesh.add_face([nyn, nyp, pzn])
                faces[12] = mesh.add_face([nyn, nyp, nzn])
                faces[15] = mesh.add_face([pzp, pyp, pxp])
                faces[18] = mesh.add_face([pzn, nyp, pxp])
                faces[13] = mesh.add_face([nzp, pyp, pxn])
                faces[10] = mesh.add_face([nzn, nyp, pxn])
                faces[9]  = mesh.add_face([pzp, pyn, nxp])
                faces[8]  = mesh.add_face([pzn, nyn, nxp])
                faces[1]  = mesh.add_face([nzp, pyn, nxn])
                faces[4]  = mesh.add_face([nzn, nyn, nxn])

                super(definition: definition, faces: faces)
            end
        end
    end



    ##### FONT INSTANCES #####

    # Module for storing all the font instances we've created in one easy to access central location.
    module Fonts
        MADIFONT_2 = SplicedFont::new(name: "madifont 2", folder: "/Users/austin/3DPrinting/DiceStuff/Resources/VectorFonts/MadiFont2", padding: 1)
        MADIFONT_2.set_offsets(offsets: {})
        MADIFONT_2.set_scales(scales: {})

        GRAFFITI   = SplicedFont::new(name: "graffiti", folder: "/Users/austin/3DPrinting/DiceStuff/Resources/VectorFonts/MadiGraffitiFont", padding: 1)
        GRAFFITI.set_offsets(offsets: {})
        GRAFFITI.set_scales(scales: {})
    end

end

# These lines just make life easier when typing things into IRB, by making it so we don't have to explicitely state the
# modules for the 'DiceGen' and 'Fonts' namespaces.
include DiceGen
include Fonts


# ===== TODO =====
# Split up the create_die stuff so that the D4 and D10 can override behavior effectively.
# Try to figure out why there's still coupling of definition edits?
# Finish making the numbers appear where they should be.
# Make a class for SystemFont again!

# We should separate out the shapes, from the dice themselves. So we should have a DieMesh base class, and a Die base class.
# The mesh will make the actual shapes, and then the Die class will take a font, a mesh, and a group, and I guess optionally a transform, and combine them all together.





















#=======================================================================================================================
class ImageFontHolder
    def initialize(fontName, folder, numberScale, offsets, tunedOffsets)
        self.font_name = fontName;
        self.folder = folder;
        self.number_scale = numberScale;
        self.inter_number_offset = internumberOffset;
        self.offsets = offsets;
        self.tuned_offsets = tunedOffsets;
    end
end



herculanum = FontHolder.new("Herculanum", false, false, 0.75, 0.2, 
                            [[0,0], [0,-0.1], [-0.05,-0.05], [0,-0.11], [+0.03,-0.18]]                                                          //D4
                            [[0,0], [0,-0.1], [0,-0.1], [0,-0.15], [0,-0.12], [0,-0.18], [0,-0.1]]                                              //D6
                            [[0,0], [0,-0.1], [-0.03,-0.05], [0,-0.1], [0,-0.12], [0,-0.12], [0.02,-0.05], [0,0], [0,-0.075]]                   //D8
                            [[0,0], [0,-0.1], [-0.03,-0.05], [0,-0.1], [0,-0.12], [0,-0.12], [0.02,-0.05], [0,0], [0,-0.075], [0,0]]            //D10 TODO
                            [[0,0], [0,-0.1], [-0.03,-0.05], [0,-0.1], [0,-0.12], [0,-0.12], [0.02,-0.05], [0,0], [0,-0.075], [0,0]]            //D12 TODO
                            [[0,0], [0,-0.1], [-0.03,-0.05], [0,-0.1], [0,-0.12], [0,-0.12], [0.02,-0.05], [0,0], [0,-0.075], [0,0]]            //D20 TODO
                           )


def scalePoint(point, scale)
    point.x *= scale
    point.y *= scale
    point.z *= scale
    return point
end

def findFaceCenter(vertices)
    # Create point for storing the sum of all the vertice's positions.
    temp = Geom::Point3d.new
    count = vertices.length()

    # Iterate through each vertex and add it's sum to 'temp'.
    vertices.each do |vertex|
        temp += vertex.position.to_a
    end
    # Compute the average position by dividing through by the total number of vertices.
    return Geom::Point3d.new(temp.x / count, temp.y / count, temp.z / count)
end

def findEdgeCenter(edge)
    # Compute the sum of the start and end positions.
    temp = edge.start.position + edge.end.position.to_a
    # Compute the average of the endpoints by dividing by 2.
    return Geom::Point3d.new(temp.x / 2, temp.y / 2, temp.z / 2)
end

def getLetterPlanePlace(face, offsetX, offsetY, angle, edgeIndex)
    # Get the normal vector that's pointing out from the face, and the edges comprising the face.
    normal = face.normal().reverse()
    edges = face.edges()
    # find the center of the face, and the midpoint of the top-edge.
    faceCenter = findFaceCenter(face.vertices)
    edgeCenter = findEdgeCenter(edges[edgeIndex])

    # Compute the x and y unit vectors. The Y axis points from the center of the face to the midpoint of the top-edge.
    # And the X axis points along the cross product of the Y and Z (normal) axes.
    upVector = (edgeCenter - faceCenter).normalize()
    sideVector = normal.cross(upVector)

    # Compute the distance to offset the new center by to ensure that the text is centered correctly.
    centerOffset = Geom::Vector3d.new((sideVector.x * offsetX) + (upVector.x * offsetY), (sideVector.y * offsetX) + (upVector.y * offsetY), (sideVector.z * offsetX) + (upVector.z * offsetY))
    letterCenter = faceCenter - centerOffset

    # Create and return the actual transformations for adjusting the axes to be parallel and centered on the face, along with any
    # rotation within the plane of the face for special dice that need it.
    axesTransform = Geom::Transformation.axes(letterCenter, sideVector, upVector, normal)
    rotationTransform = Geom::Transformation.rotation(Geom::Point3d.new(offsetX, offsetY, 0), Z_AXIS, angle * Math::PI / 180.0)
    return axesTransform * rotationTransform
end

def createNumberDigits(numbers_group, face, number, offsetX, offsetY, angle, edgeIndex)
    digits = number.to_s().chars()
    if(digits.length() == 1)
        number_group = numbers_group.entities().add_group()
        number_entities = number_group.entities()
        index = digits[0].to_i()
        number_entities.add_3d_text(digits[0], TextAlignCenter, $currentFont.fontName, $currentFont.isBold, $currentFont.isItalic, $currentFont.letterHeight)
        number_bounds = number_group.bounds()
        number_entities.transform_entities(getLetterPlanePlace(face, (number_bounds.width / 2) + $fontOffsets[index][0] + offsetX, (number_bounds.height / 2) + $fontOffsets[index][1] + offsetY, angle, edgeIndex), number_entities.to_a())
    elsif(digits.length() == 2)
        number_group = numbers_group.entities().add_group()
        number_entities = number_group.entities()
        index = digits[0].to_i()
        number_entities.add_3d_text(digits[0], TextAlignCenter, $currentFont.fontName, $currentFont.isBold, $currentFont.isItalic, $currentFont.letterHeight)
        number_bounds = number_group.bounds()
        number_entities.transform_entities(getLetterPlanePlace(face, (number_bounds.width / 2) + $fontOffsets[index][0] + offsetX + $currentFont.doubleDigitOffset, (number_bounds.height / 2) + $fontOffsets[index][1] + offsetY, angle, edgeIndex), number_entities.to_a())

        number_group = numbers_group.entities().add_group()
        number_entities = number_group.entities()
        index = digits[1].to_i()
        number_entities.add_3d_text(digits[1], TextAlignCenter, $currentFont.fontName, $currentFont.isBold, $currentFont.isItalic, $currentFont.letterHeight)
        number_bounds = number_group.bounds()
        number_entities.transform_entities(getLetterPlanePlace(face, (number_bounds.width / 2) + $fontOffsets[index][0] + offsetX - $currentFont.doubleDigitOffset, (number_bounds.height / 2) + $fontOffsets[index][1] + offsetY, angle, edgeIndex), number_entities.to_a())
    else
        raise "Number has less than 1 or more than 2 characters are we can't handle that."
    end       
end



class D4
    def initialize()
        ...

        # Create the numbers to emboss on each face.
        numbers_group = model.active_entities.add_group()
        corner_numbers = [[1, 3, 2], [2, 3, 4], [4, 3, 1], [4, 1, 2]]
        [f1, f2, f3, f4].each_with_index do |face, index|
            3.times do |number_index|
                createNumberDigits(numbers_group, face, corner_numbers[index][number_index], 0, -0.5, 180, number_index)
            end
        end

        ...
    end
end

class D6
    def initialize()
        ...

        # Create the numbers to emboss on each face.
        numbers_group = model.active_entities.add_group()
        [f1, f2, f3, f4, f5, f6].each_with_index do |face, index|
            createNumberDigits(numbers_group, face, index + 1, 0, 0.1, 0, 0)
        end

        ...
    end
end

class D8
    def initialize()
        ...

        # Create the numbers to emboss on each face.
        numbers_group = model.active_entities.add_group()
        [f1, f2, f3, f4, f5, f6, f7, f8].each_with_index do |face, index|
            createNumberDigits(numbers_group, face, index + 1, 0, 0, 180, 0)
        end

        ...
    end
end

class D20
    def initialize()
        ...

        # Create the numbers to emboss on each face.
        numbers_group = model.active_entities.add_group()
        [f1, f2, f3, f4, f5, f6, f7, f8, f9, f10, f11, f12, f13, f14, f15, f16, f17, f18, f19, f20].each_with_index do |face, index|
            createNumberDigits(numbers_group, face, index + 1, 0, 0, 180, 0)
        end

        ...
    end
end

def createSet()
    D4.new()
    D6.new()
    D8.new()
    D20.new()
end

































class D12
    def initialize()
        model = Sketchup.active_model()
        model.start_operation('Create D12', true)
        die_group = model.active_entities.add_group()
        die_mesh = die_group.entities()

        # Specify all the points making up the vertices of the shape.
        die_scale = $dieScale
        t000 = scalePoint(Geom::Point3d.new(-1, -1, -1), die_scale)
        t001 = scalePoint(Geom::Point3d.new(-1, -1,  1), die_scale)
        t010 = scalePoint(Geom::Point3d.new(-1,  1, -1), die_scale)
        t100 = scalePoint(Geom::Point3d.new( 1, -1, -1), die_scale)
        t011 = scalePoint(Geom::Point3d.new(-1,  1,  1), die_scale)
        t101 = scalePoint(Geom::Point3d.new( 1, -1,  1), die_scale)
        t110 = scalePoint(Geom::Point3d.new( 1,  1, -1), die_scale)
        t111 = scalePoint(Geom::Point3d.new( 1,  1,  1), die_scale)
        1pp = scalePoint(Geom::Point3d.new(    0,  $IPH,  $PHI), die_scale)
        1pn = scalePoint(Geom::Point3d.new(    0,  $IPH, -$PHI), die_scale)
        1np = scalePoint(Geom::Point3d.new(    0, -$IPH,  $PHI), die_scale)
        1nn = scalePoint(Geom::Point3d.new(    0, -$IPH, -$PHI), die_scale)
        2pp = scalePoint(Geom::Point3d.new( $IPH,  $PHI,     0), die_scale)
        2pn = scalePoint(Geom::Point3d.new( $IPH, -$PHI,     0), die_scale)
        2np = scalePoint(Geom::Point3d.new(-$IPH,  $PHI,     0), die_scale)
        2nn = scalePoint(Geom::Point3d.new(-$IPH, -$PHI,     0), die_scale)
        3pp = scalePoint(Geom::Point3d.new( $PHI,     0,  $IPH), die_scale)
        3pn = scalePoint(Geom::Point3d.new(-$PHI,     0,  $IPH), die_scale)
        3np = scalePoint(Geom::Point3d.new( $PHI,     0, -$IPH), die_scale)
        3nn = scalePoint(Geom::Point3d.new(-$PHI,     0, -$IPH), die_scale)

        # Create all the faces of the die.
        TODO

        # Create the numbers to emboss on each face.
        numbers_group = model.active_entities.add_group()
        [f1, f2, f3, f4, f5, f6, f7, f8, f9, f10, f11, f12].each_with_index do |face, index|
            createNumberDigits(numbers_group, face, index + 1, 0, 0, 0, 0)
        end

        ...
    end
end






okay, so when I get home, first I'll check on the carpets, and start drying them if needed.
Then, I'll clean out the shop-vac in the garage, and once finished, I'll clean up the 3rd floor bathroom again, and the stairs.
I'll move the carpets back into the bathroom and blow-dry them to perfection.
After that we'll break open the AC unit, and we'll make a pass over it with the shop-vac to suck up as much crap as we can.
Then we'll take the blower port and use that to knock some crap off of the fins if possible.
We'll go at it with a brush to knock shit loose, while vacuuming of course.
Then one final pass of the blower and vacuum and we'll put it all back together and hopefully see some increased performance.
THE AIR CONDITIONER SHOULD BE OFF THE ENTIRE TIME!
If we finish all that in time, then we'll start on refurbishing the 2nd floor bathroom too!

class D10
    def initialize()
        model = Sketchup.active_model()
        model.start_operation('Create D10', true)
        die_group = model.active_entities.add_group()
        die_mesh = die_group.entities()

        # Specify all the points making up the vertices of the shape.
        # TODO

        # Create all the faces of the die.
        # TODO

        # Create the numbers to emboss on each face.
        numbers_group = model.active_entities.add_group()
        counter = 0
        maxCount = 10
        die_mesh.each_with_index do |face, index|
            if face.is_a? Sketchup::Face
                number_group = numbers_group.entities().add_group()
                number_entities = number_group.entities()
                number_entities.add_3d_text((index + 1).to_s(), TextAlignCenter, $fontName, $isBold, $isItalic, $letterHeight)
                number_bounds = number_group.bounds()
                # TODO CHANGE THE ANGLE OF THE TRANSFORMATION TO WHAT IT ACTUALLY SHOULD BE!!!
                number_entities.transform_entities(getLetterPlanePlace(face, (number_bounds.width / 2) + $fontOffsets[index][0], (number_bounds.height / 2) + $fontOffsets[index][1], 45), number_entities.to_a())
                counter += 1
                if counter == maxCount
                    break
                end
            end
        end

        ...
    end
end

class D12
    def initialize()
        model = Sketchup.active_model()
        model.start_operation('Create D20', true)
        die_group = model.active_entities.add_group()
        die_mesh = die_group.entities()

        # Specify all the points making up the vertices of the shape.
        t000 = Geom::Point3d.new(-1, -1, -1)
        t001 = Geom::Point3d.new(-1, -1,  1)
        t010 = Geom::Point3d.new(-1,  1, -1)
        t100 = Geom::Point3d.new( 1, -1, -1)
        t011 = Geom::Point3d.new(-1,  1,  1)
        t101 = Geom::Point3d.new( 1, -1,  1)
        t110 = Geom::Point3d.new( 1,  1, -1)
        t111 = Geom::Point3d.new( 1,  1,  1)
        1pp = Geom::Point3d.new(    0,  $IPH,  $PHI)
        1pn = Geom::Point3d.new(    0,  $IPH, -$PHI)
        1np = Geom::Point3d.new(    0, -$IPH,  $PHI)
        1nn = Geom::Point3d.new(    0, -$IPH, -$PHI)
        2pp = Geom::Point3d.new( $IPH,  $PHI,     0)
        2pn = Geom::Point3d.new( $IPH, -$PHI,     0)
        2np = Geom::Point3d.new(-$IPH,  $PHI,     0)
        2nn = Geom::Point3d.new(-$IPH, -$PHI,     0)
        3pp = Geom::Point3d.new( $PHI,     0,  $IPH)
        3pn = Geom::Point3d.new(-$PHI,     0,  $IPH)
        3np = Geom::Point3d.new( $PHI,     0, -$IPH)
        3nn = Geom::Point3d.new(-$PHI,     0, -$IPH)

        # Create all the faces of the die.
        TODO

        # Create the numbers to emboss on each face.
        numbers_group = model.active_entities.add_group()
        counter = 0
        maxCount = 20
        die_mesh.each_with_index do |face, index|
            if face.is_a? Sketchup::Face
                number_group = numbers_group.entities().add_group()
                number_entities = number_group.entities()
                number_entities.add_3d_text((index + 1).to_s(), TextAlignCenter, $fontName, $isBold, $isItalic, $letterHeight)
                number_bounds = number_group.bounds()
                number_entities.transform_entities(getLetterPlanePlace(face, (number_bounds.width / 2) + $fontOffsets[index][0], (number_bounds.height / 2) + $fontOffsets[index][1], 0), number_entities.to_a())
                counter += 1
                if counter == maxCount
                    break
                end
            end
        end

        ...
    end
end












# The first vertex on a face MUST be immediately to the left of the top vector of the text.

def create_d6
    p000 = Geom::Point3d.new((-0.5 * scale), (-0.5 * scale), (-0.5 * scale))
    p001 = Geom::Point3d.new((-0.5 * scale), (-0.5 * scale), ( 0.5 * scale))
    p010 = Geom::Point3d.new((-0.5 * scale), ( 0.5 * scale), (-0.5 * scale))
    p100 = Geom::Point3d.new(( 0.5 * scale), (-0.5 * scale), (-0.5 * scale))
    p011 = Geom::Point3d.new((-0.5 * scale), ( 0.5 * scale), ( 0.5 * scale))
    p101 = Geom::Point3d.new(( 0.5 * scale), (-0.5 * scale), ( 0.5 * scale))
    p110 = Geom::Point3d.new(( 0.5 * scale), ( 0.5 * scale), (-0.5 * scale))
    p111 = Geom::Point3d.new(( 0.5 * scale), ( 0.5 * scale), ( 0.5 * scale))

    f1 = d6_mesh.add_face([p011, p111, p110, p010])
    f2 = d6_mesh.add_face([p010, p110, p100, p000])
    f3 = d6_mesh.add_face([p011, p010, p000, p001])
    f4 = d6_mesh.add_face([p110, p111, p101, p100])
    f5 = d6_mesh.add_face([p111, p011, p001, p101])
    f6 = d6_mesh.add_face([p000, p100, p101, p001])

    tempNumberGroup = model.active_entities.add_group()
    faceCount = d6_mesh.length()
    counter = 1
    d6_mesh.first(faceCount).each do |face|
        if face.is_a? Sketchup::Face
            numberGroup = tempNumberGroup.entities.add_group()
            numberEntities = numberGroup.entities()
            numberEntities.add_3d_text(counter.to_s, TextAlignCenter, fontName, isBold, isItalic, letterHeight)
            numberBounds = numberGroup.bounds()
            numberEntities.transform_entities(getLetterPlanePlace(face, (numberBounds.width / 2) + fontOffsets[counter-1][0], (numberBounds.height / 2) + fontOffsets[counter-1][1], 0), numberEntities.to_a)
            counter += 1
        end
    end

end
