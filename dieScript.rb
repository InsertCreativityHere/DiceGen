
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
                    filename = File.basename(file, ".html")
                    meshes[filename] = Util.import_definition(file: file)
                    puts "    Loaded '#{filename}.dae'"
                end
            else
                mesh_names.each() do |mesh|
                    # Get the absolute path of the mesh file to import.
                    file = "#{font_folder}/meshes/#{mesh}.dae"
                    if (File.exists?(file))
                        meshes[mesh] = Util.import_definition(file: file)
                        puts "    Loaded '#{filename}.dae'"
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
        # enclosing group, and this group is placed into the provided group (instead of placing the glyph directly).
        #   name: The name of the glyph to create, usually this is the text the glyph represents.
        #   group: The group to place the glyph's group into, and hence the glyph itself.
        #   transform: A custom transformation that is applied to the glyph after placement. Defaults to no transform.
        #   return: The group that immediately components the glyph's mesh.
        def create_glyph(name:, group:, transform: Util::DUMMY_TRANSFORM)
            return group.entities().add_instance(@glyphs[name], transform)
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
            super(name, folder)
            @padding = padding;
        end

        # Creates and returns an instance of the specified glyph as a 2D model. The glyph is always created in it's own
        # enclosing group, and this group is placed into the provided group (instead of placing the glyph directly).
        # This method delegates to the base implementation, but just makes sure to generate the requested glyph via
        # splicing if it hasn't been created yet. After the check (and possible splicing), the base method is called.
        #   name: The name of the glyph to create, usually this is the text the glyph represents.
        #   group: The group to place the glyph's group into, and hence the glyph itself.
        #   transform: A custom transformation that is applied to the glyph after placement. Defaults to no transform.
        #   return: The group that immediately components the glyph's mesh.
        def create_glyph(name:, group:, transform: Util::DUMMY_TRANSFORM)
            # Lazily create the requested glyph via splicing if it doesn't already have a definition.
            unless @glyphs.key?(name)
                @glyphs[name] = FontUtil.splice_glyphs(glyphs: name.chars(), padding: padding);
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
        # Array of groups that are centered and aligned to the faces of the die. These groups have their axes oriented
        # to be coplanar with the faces, and to have their origin lie at the geometric center of the face. The ordering
        # of these groups matches the numbering of the die faces, and it's with these faces that numbers are added.
        attr_reader :face_groups

        #TODO
        def initialize(definition:, faces:)
            #TODO
        end

        #TODO
        def create_die(font:, group:, transform: Util::DUMMY_TRANSFORM)
            #TODO
        end
    end



    # Module containing all the sharp-edged standard dice definitions.
    module SharpEdgedStandard

        # This class defines the mesh model for a sharp-edged standard D4 die (a tetrahedron).
        class D4 < Die
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
        class D6 < Die
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
        class D8 < Die
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
        class D10 < Die
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
        class D12 < Die
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
        class D20 < Die
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
        MADIFONT_2 = SplicedFont(name: "madifont 2", folder: "/Users/austin/3DPrinting/DiceStuff/Resources/VectorFonts/MadiFont2", padding: 1)
        MADIFONT_2.set_offsets({})
        MADIFONT_2.set_scales({})

        GRAFFITI   = SplicedFont(name: "graffiti", folder: "/Users/austin/3DPrinting/DiceStuff/Resources/VectorFonts/MadiGraffitiFont", padding: 1)
        GRAFFITI.set_offsets({})
        GRAFFITI.set_scales({})
    end

end
