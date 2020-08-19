
require 'singleton';

module DiceGen

    ##### UTILITIES #####

    # Module for grouping together general use utility code.
    module Util
        extend self;

        # Stores the currently active Sketchup model.
        $main_model = Sketchup::active_model;

        # Flag for whether the system Sketchup is running on is Windows or Unix based.
        @@is_windows = (Sketchup::platform == :platform_win rescue RUBY_PLATFORM !~ /darwin/i);
        if @@is_windows
            require "win32ole"
        end

        # Triggers an <ESC> key-press
        def send_escape()
            if @@is_windows
                WIN32OLE::new('WScript.Shell').SendKeys('{ESC}')
            else
                Sketchup::send_action('cancelOperation:')
            end
        end

        # Imports a file and returns a reference to the imported definition.
        def import_definition(file)
            # Check if the file exists and is reachable.
            if !File.exist?(file)
                raise "Failed to locate the file '#{file}'";
            end

            # Try to import the file's model and check if it was successful.
            result = $main_model.import(file);
            if !result
                raise "Failed to import model from the file '#{file}'";
            end

            # Press the <ESC> key to prevent an instance from being placed at the mouse cursor.
            # send_escape(); TODO ENABLE THIS WHEN WE MAKE A REAL SCRIPT INSTEAD OF USING THE RUBY CONSOLE.

            # Return the most recently created definition; ie: the one we just imported.
            return $main_model.definitions[-1];
        end

        def get_digits(number, base = 10)
            result = [];
            temp = number;

            # Divide the number by 10 and check the remainder until there's nothing left to divide (it reaches 0).
            while (temp > 0)
                quotient, remainder = temp.divmod(base);
                result.push(remainder);
                temp = quotient;
            end

            return result;
        end
    end



    ##### FONTS #####

    # Module for grouping together any font specific utility code.
    module FontUtil
        extend self;

        # The maximum numerical glyph we ever expect to need. This is just used for a default value in some places.
        $glyph_max = 20;

        #TODO
        def import_meshes(fontFolder, meshNames)
            # Check the provided font folder exists.
            unless File.exists?(fontFolder)
                raise "Folder '#{fontFolder}' does not exist or is inaccessible."
            end
            # And that it has a "meshes" subdirectory.
            unless File.exists?(fontFolder + "/meshes")
                raise "Folder '#{fontFolder}' does not contain a 'meshes' subdirectory."
            end

            # Load any mesh files from the "meshes" subdirectory that correspond to a glyph index.
            meshes = Array.new(meshNames.count());
            meshNames.each_with_index() do |name, i|
                file = fontFolder + "/meshes/" + name.to_s() + ".dae";
                if File.exists?(file)
                    meshes[i] = Util.import_definition(file); 
                    puts "    Loaded definition from '#{file}'."
                end
            end

            return meshes;
        end

        #TODO
        def splice_glyphs(glyphs, padding)
            # The new glyph's definition name is formed by concatenating the names of the component glyphs.
            name = "";
            # Calculate the total width of the combined glyphs.
            totalWidth = padding * (glyphs.count() - 1);
            glyphs.each() do |glyph|
                name += glyph.name();
                totalWidth += glyph.bounds().width();
            end

            # Create a new definition to splice the glyphs into.
            definition = $main_model.definitions.add(name);
            entities = definition.entities();

            # Keep a running tally of the current x position, starting at the leftmost point.
            xPos = -(totalWidth / 2);

            # Create instances of the component glyphs in the new definition.
            glyphs.each() do |glyph|
                # Calculate the x position to place the glyph at so the new spliced glyph is still centered.
                width = glyph.bounds().width();
                offset = Geom::Point3d.new(xPos + (width / 2), 0, 0);
                # Create an instance of the component glyph to splice it into the definition.
                entities.add_instance(glyph, Geom::Transformation.translation(offset));
                # Increment the width by the width of the glyph we just placed, plus the padding between glyphs.
                xPos += width + padding;
            end
        end
    end


    # A bare-bones font class that generates glyphs from pre-made ComponentDefinition objects, and the base class for all fonts.
    class Font
        # Create a new font with the specified name and whose glyphs are defined by an array of ComponentDefinitions.
        # name: The plain-text name of the font.
        # definitions: An array of ComponentDefinitions that store the 2D glyph mesh models making up the font.
        def initialize(name, definitions)
            @name = name;
            @glyphs = definitions;
            @count = definitions.count();
        end

        # Sets the definition for a specific glyph.
        # index: The index of the glyph to replace.
        # definition: The new definition for the glyph.
        def setGlyph(index, definition)
            @glyphs[index] = definition;
        end

        # Scales the font's glyphs according to an array of scale factors.
        # scales: An array of scale factors which the glyphs are scaled by respectively. The length of the array must
        #         match the number of glyphs in the font.
        def setScales(scales)
            scales.each_with_index() do |scale, i|
                entities = @glyphs[i].entities();
                entities.transform_entities(Geom::Transformation.scaling(scale), entities.to_a());
            end
        end

        # Translates the font's glyphs according to an array of (x,y) offset pairs.
        # offsets: An array of (x,y) coordinate pairs specifying how much to translate each glyph by in each direction.
        #          The length of the array must match the number of glyphs in the font.
        def setOffsets(offsets)
            offsets.each_with_index() do |offset, i|
                entities = @glyphs[i].entities();
                vectorOffset = Geom::Vector3d.new(offset[0], offset[1], 0);
                entities.transform_entities(Geom::Transformation.translation(vectorOffset), entities.to_a());
            end
        end

        # Creates and returns an instance of the specified glyph as a 2D model with the specified transformations applied to it.
        # The glyph is created in an enclosing group, and it is the enclosing group which is returned.
        # index: The numerical index of the glyph to create. Usually this is the actual number to create.
        # group: The group to place the glyph's model into.
        # transform: The external transformation to apply to the glyph after instantiating it.
        def createGlyph(index, group, transform)
            glyph_group = group.entities().add_group();
            glyph_group.entities().add_instance(@glyphs[index], transform);
            return glyph_group;
        end
    end


    # Class that represents a font whose glyphs are made of 2D mesh models, and where each glyph has it's own unique
    # mesh model. This is in contrast to SplicedCustomFont, where each glyph is made by combining glyphs for each digit.
    class RawCustomFont < Font
        # Create a new font with the specified name and whose glyphs are stored as DAE mesh files in the provided font folder.
        # name: The plain-text name of the font.
        # folder: The folder where all the glyph meshes are contained. This script expects our made up directory structure
        #         to exist, where all the mesh files are stored in a "meshes" subdirectory. Hence you have to pass in the
        #         parent font folder, and not the directory that immediately contains the mesh files.
        #         It loads any mesh files whose filename is just a number between 0 and the maxIndex.
        # maxIndex: The maximum index glyph to load. the constructor will only loads glyphs up to this number, starting at
        #           the glyph "0.dae". Defaults to$glyph_max".
        def initialize(name, folder, maxIndex = $glyph_max)
            @folder = folder;
            # Construct the base Font object using the imported mesh definitions.
            super(name, FontUtil.import_meshes(@folder, (0..maxIndex).to_a()));
        end
    end


    # Class that represents a font whose glyphs are made of combinations of 2D mesh models, where each mesh represents a
    # single digit, and then all the glyphs are made by composing the digits together. This is in contrast to RawCustomFont
    # where each glyph has it's own unique mesh model.
    class SplicedCustomFont < Font
        #TODO
        def initialize(name, folder, digitOffset, maxIndex = $glyph_max)
            @folder = folder;

            # Load in definitions for the glyphs '0' through '9' (or the maxIndex if it's less than 9).
            definitions = FontUtil.import_meshes(@folder, (0..[9, maxIndex].min()).to_a());

            # Iterate through the remaining glyphs that need definitions and generate them by splicing together the
            # glyphs that represent their individual digits.
            (10..maxIndex).each() do |i|
                definitions[i] = FontUtil.splice_glyphs(Util::get_digits(i).map{ |j| definitions[j] }, digitOffset);
            end

            # Construct the base Font.
            super(name, definitions);
        end
    end


    #TODO
    class SplicedCustomPercentileFont < SplicedCustomFont
        #TODO
        def initialize(name, folder, digitOffset, maxIndex = @@glyphMax)
            # Splice together the font normally by calling the superclass's constructor.
            super(name, folder, digitOffset, maxIndex);

            # Load the definition for '0' again. I don't know how to clone a ComponentDefinition, and since we're
            # modifying the original definition of '0' to be '00', we need a separate definition of '0' to use.
            zero_def = FontUtil.import_meshes(@folder, ['0']);

            # Append an extra '0' to the end of every glyph to make them percentiles.
            @glyphs.each() do |glyph|
                glyph = FontUtil.splice_glyphs([glyph, zero_def], digitOffset);
            end
        end
    end



    ##### DICE #####

    module DiceUtil
        extend self;

        # Dummy transformation that represents the transformation of doing nothing.
        # This is defined purely for convenience and to avoid making multiple copies of the same transformation.
        $Dummy_Transformation = Geom::Transformation.new();

        # The mathematical constant known as the "golden ratio".
        $PHI = (1.0 + Math::sqrt(5)) / 2.0;

        # The reciprocal of phi.
        $IHP = 1.0 / $PHI;
    end


    # Abstract base class for all dice.
    class Die
        # Limits this class (and it's subclasses) to only ever having a single instance which is globally available.
        # We use the singleton pattern here because we only have to create the definition for the die once, and this
        # class represents the definition, not the component instantiations, of which there can be multiple.
        include Singleton;

        #TODO
    end


    # Class representing the geometry of a standard D4 die (tetrahedron).
    class D4 < Die
        # Creates the component definition for a D4 die and adds it into the models DefinitionList.
        # This constructor is only called once, as it should since this represents a ComponentDefinition, not a ComponentInstance.
        def initialize()
            # Create a new definition to create the die in.
            definition = $main_model.definitions.add("D4DIE");
            die_mesh = definition.entities();

            # Define all the points that make up the vertices of the die.
            p111 = Geom::Point3d.new( 1,  1,  1);
            p001 = Geom::Point3d.new(-1, -1,  1);
            p010 = Geom::Point3d.new(-1,  1, -1);
            p100 = Geom::Point3d.new( 1, -1, -1);

            # Create the faces of the die by joining the vertices with edges.
            @faces = Array.new(4);
            @faces[0] = die_mesh.add_face([p010, p001, p111]);
            @faces[1] = die_mesh.add_face([p100, p010, p001]);
            @faces[2] = die_mesh.add_face([p010, p111, p100]);
            @faces[3] = die_mesh.add_face([p001, p111, p100]);

            # Create groups that are parallel and centered to each face for placing the glyphs into.
            @faceGroups = Array.new(4);
        end
    end


    # Class representing the geometry of a standard D6 die (square hexhedron (fancy word for cube)).
    class D6 < Die
        # Creates the component definition for a D6 die and adds it into the models DefinitionList.
        # This constructor is only called once, as it should since this represents a ComponentDefinition, not a ComponentInstance.
        def initialize()
            # Create a new definition to create the die in.
            @definition = $main_model.definitions.add("D6DIE");
            die_mesh = @definition.entities();

            # Define all the points that make up the vertices of the die.
            p000 = Geom::Point3d.new(-1, -1, -1);
            p001 = Geom::Point3d.new(-1, -1,  1);
            p010 = Geom::Point3d.new(-1,  1, -1);
            p100 = Geom::Point3d.new( 1, -1, -1);
            p011 = Geom::Point3d.new(-1,  1,  1);
            p101 = Geom::Point3d.new( 1, -1,  1);
            p110 = Geom::Point3d.new( 1,  1, -1);
            p111 = Geom::Point3d.new( 1,  1,  1);

            # Create the faces of the die by joining the vertices with edges.
            @faces = Array.new(6);
            @faces[0] = die_mesh.add_face([p111, p011, p001, p101]);
            @faces[1] = die_mesh.add_face([p101, p001, p000, p100]);
            @faces[2] = die_mesh.add_face([p001, p011, p010, p000]);
            @faces[3] = die_mesh.add_face([p111, p101, p100, p110]);
            @faces[4] = die_mesh.add_face([p011, p111, p110, p010]);
            @faces[5] = die_mesh.add_face([p000, p100, p110, p010]);

            # Create groups that are parallel and centered to each face for placing the glyphs into.
            @faceGroups = Array.new(6);
        end
    end


    # Class representing the geometry of a standard D8 die (equilateral octohedron).
    class D8 < Die
        # Creates the component definition for a D8 die and adds it into the models DefinitionList.
        # This constructor is only called once, as it should since this represents a ComponentDefinition, not a ComponentInstance.
        def initialize()
            # Create a new definition to create the die in.
            @definition = $main_model.definitions.add("D8DIE");
            die_mesh = @definition.entities();

            # Define all the points that make up the vertices of the die.
            px = Geom::Point3d.new( 1,  0,  0);
            nx = Geom::Point3d.new(-1,  0,  0);
            py = Geom::Point3d.new( 0,  1,  0);
            ny = Geom::Point3d.new( 0, -1,  0);
            pz = Geom::Point3d.new( 0,  0,  1);
            nz = Geom::Point3d.new( 0,  0, -1);

            # Create the faces of the die by joining the vertices with edges.
            @faces = Array.new(8);
            @faces[0] = die_mesh.add_face([px, py, pz]);
            @faces[1] = die_mesh.add_face([nx, py, nz]);
            @faces[2] = die_mesh.add_face([nx, py, pz]);
            @faces[3] = die_mesh.add_face([px, py, nz]);
            @faces[4] = die_mesh.add_face([nx, ny, pz]);
            @faces[5] = die_mesh.add_face([px, ny, nz]);
            @faces[6] = die_mesh.add_face([px, ny, pz]);
            @faces[7] = die_mesh.add_face([nx, ny, nz]);

            # Create groups that are parallel and centered to each face for placing the glyphs into.
            @faceGroups = Array.new(8);
        end

        def createInstance(parent, font, transform)
            parent.entities().add_instance(@definition, transform);
        end
    end


    # Class representing the geometry of a standard D10 die (pentagonal trapezohedron).
    class D10 < Die
        # Creates the component definition for a D10 die and adds it into the models DefinitionList.
        # This constructor is only called once, as it should since this represents a ComponentDefinition, not a ComponentInstance.
        def initialize()
            # Create a new definition to create the die in.
            @definition = $main_model.definitions.add("D10DIE");
            die_mesh = @definition.entities();

            # Define all the points that make up the vertices of the die.
            #TODO

            # Create the faces of the die by joining the vertices with edges.
            @faces = Array.new(10);
            #TODO

            # Create groups that are parallel and centered to each face for placing the glyphs into.
            @faceGroups = Array.new(10);
        end
    end


    # Class representing the geometry of a standard D12 die (dodecahedron).
    class D12 < Die
        # Creates the component definition for a D12 die and adds it into the models DefinitionList.
        # This constructor is only called once, as it should since this represents a ComponentDefinition, not a ComponentInstance.
        def initialize()
            # Create a new definition to create the die in.
            @definition = $main_model.definitions.add("D12DIE");
            die_mesh = @definition.entities();

            # Define all the points that make up the vertices of the die.
            #TODO

            # Create the faces of the die by joining the vertices with edges.
            @faces = Array.new(12);
            #TODO

            # Create groups that are parallel and centered to each face for placing the glyphs into.
            @faceGroups = Array.new(12);
        end
    end


    # Class representing the geometry of a standard D20 die (icosahedron).
    class D20 < Die
        # Creates the component definition for a D20 die and adds it into the models DefinitionList.
        # This constructor is only called once, as it should since this represents a ComponentDefinition, not a ComponentInstance.
        def initialize()
            # Create a new definition to create the die in.
            @definition = $main_model.definitions.add("D20DIE");
            die_mesh = @definition.entities();

            # Define all the points that make up the vertices of the die.
            pzp = Geom::Point3d.new(    0,     1,  $PHI);
            nzp = Geom::Point3d.new(    0,     1, -$PHI);
            pzn = Geom::Point3d.new(    0,    -1,  $PHI);
            nzn = Geom::Point3d.new(    0,    -1, -$PHI);
            pyp = Geom::Point3d.new(    1,  $PHI,     0);
            nyp = Geom::Point3d.new(    1, -$PHI,     0);
            pyn = Geom::Point3d.new(   -1,  $PHI,     0);
            nyn = Geom::Point3d.new(   -1, -$PHI,     0);
            pxp = Geom::Point3d.new( $PHI,     0,     1);
            nxp = Geom::Point3d.new(-$PHI,     0,     1);
            pxn = Geom::Point3d.new( $PHI,     0,    -1);
            nxn = Geom::Point3d.new(-$PHI,     0,    -1);

            # Create the faces of the die by joining the vertices with edges.
            @faces = Array.new(20);
            #TODO I should re-arrange these to be in order.
            @faces[5] = die_mesh.add_face([pxn, pyp, pxp]);
            @faces[8] = die_mesh.add_face([nyp, pxp, pxn]);
            @faces[11] = die_mesh.add_face([pyn, nxn, nxp]);
            @faces[14] = die_mesh.add_face([nxp, nyn, nxn]);
            @faces[2] = die_mesh.add_face([pzn, pxp, pzp]);
            @faces[16] = die_mesh.add_face([pzn, nxp, pzp]);
            @faces[3] = die_mesh.add_face([nzp, pxn, nzn]);
            @faces[17] = die_mesh.add_face([nzp, nxn, nzn]);
            @faces[7] = die_mesh.add_face([pyp, pyn, pzp]);
            @faces[19] = die_mesh.add_face([pyp, pyn, nzp]);
            @faces[0] = die_mesh.add_face([nyn, nyp, pzn]);
            @faces[12] = die_mesh.add_face([nyn, nyp, nzn]);
            @faces[15] = die_mesh.add_face([pzp, pyp, pxp]);
            @faces[18] = die_mesh.add_face([pzn, nyp, pxp]);
            @faces[13] = die_mesh.add_face([nzp, pyp, pxn]);
            @faces[10] = die_mesh.add_face([nzn, nyp, pxn]);
            @faces[9] = die_mesh.add_face([pzp, pyn, nxp]);
            @faces[8] = die_mesh.add_face([pzn, nyn, nxp]);
            @faces[1] = die_mesh.add_face([nzp, pyn, nxn]);
            @faces[4] = die_mesh.add_face([nzn, nyn, nxn]);

            # Create groups that are parallel and centered to each face for placing the glyphs into.
            @faceGroups = Array.new(20);
        end
    end

end


























    ##### FONTS #####

    # Abstract base class for all fonts.
    class Font
        # Initializes the fields common to all fonts.
        # fontName: The plain-text name of the font.
        # fontScales: Array of floats corresponding to the scale factors for each glyph.
        #             Defaults to an array of"1"s that is "$glyphMax" elements long, so that no scaling is performed.
        # fontOffsets: Array of (x,y) double pairs indicating how much to offset each glyph in the x and y directions.
        #              Defaults to an array of "(0,0)"s that is "$glyphMax" elements long, so that the glyphs aren't offset.
        def initialize(fontName, fontScales = Array.new$glyph_max, 1), fontOffsets = Array.new$glyph_max, (0,0)))
            @name = fontName;
            @scales = fontScales;
            @offsets = fontOffsets;
            
            # Pre-generate transformations to perform the scaling and offsetting.
            @glyph_transforms = Array.new$glyph_max);
            ()
        end

        # Creates and returns a 2D model of a glyph inside the provided group, and applies any font-specified scaling and offsets.
        # This method must be implemented in each subclass of Font.
        # index: The numerical index of the glyph to create. Usually this is the actual number to create.
        # parentGroup: The group to place the glyph's model into.
        # transform: TODO
        def createGlyph(index, parentGroup, transform)
            raise "Cannot invoke 'createGlyph' method on abstract type 'Font'.";
        end
    end


    # Class for custom fonts whose glyphs are composed of 2d mesh models.
    class CustomFont < Font
        # Creates a new custom font whose glyphs are defined by 'dae' files in a folder.
        # fontName: The plain-text name of the font.
        # fontFolder: The folder where all the glyphs are contained. This expects everything to follow our made up directory
        #             structure, where fonts have all their meshes stored in a "meshes" subdirectory. Hence you have to
        #             make sure to pass in the parent font directory, and not the dirctory that immediately containes the 'dae's.
        #             The constructor loads any files matching '<n>.dae' from the meshes directory where "0 <= n <= $glyphMax".
        # fontScales: Array of floats corresponding to the scale factors for each glyph.
        #             Defaults to an array of"1"s that is "$glyphMax" elements long, so that no scaling is performed.
        # fontOffsets: Array of (x,y) double pairs indicating how much to offset each glyph in the x and y directions.
        #              Defaults to an array of "(0,0)"s that is "$glyphMax" elements long, so that the glyphs aren't offset.
        def initialize(fontName, fontFolder, fontScales, fontOffsets)
            super.initialize(fontName, fontScales, fontOffsets);
            @folder = fontFolder;
            @glyphs = Array.new$glyph_max);

            # Check the provided font folder exists.
            unless File.exists?(@folder)
                raise "Folder '#{@folder}' does not exist or is inaccessible."
            end
            # And that it has a "meshes" subdirectory.
            unless File.exists?(@folder + "/meshes")
                raise "Folder '#{@folder}' does not contain a 'meshes' subdirectory."
            end

            # Load any mesh files from the subdirectory that correspond to glyphs.
            (0.$glyph_max).each() do |i|
                file = @folder + "/meshes/" + i + ".dae";
                if File.exists?(file)
                   @glyphs[i] = import_definition(file); 
                   puts "    Loaded definition from '#{file}'."
                end
            end
        end

        # Creates and returns an instance of the specified glyph mesh inside the provided group,
        # with any font-specified scaling and offsets already applied.
        # index: The numerical index of the glyph to create. Usually this is the actual number to create.
        # parentGroup: The group to place the glyph's model into.
        # transform: TODO
        def createGlyph(index, parentGroup, transform)
            glyph_group = parentGroup.entities().add_group();
            glyph_entities = glyph_group.entities();

            # Compose the font's transformations with the external die transformation.
            glyph_transform = TODO;

            return glyph_entities.add_instance(@glyphs[index], glyph_transform);
        end
    end


#=======================================================================================================================


# Abstract base class for all fonts.
class Font

    # Generates a mesh object corresponding to the requested glyph at the
    # specified scale. This method must be overridden by subclasses.
    def getGlyph(entityGroup, number, transform)
        raise 
    end

end


# Class that encapsulates a system font. It uses the built-in system font files
# with Sketchup's 3D Text tool to generate the glyph meshes.
class SystemFont < Font

    def initialize(fontName, isBold, isItalic, digitOffset)
        @font_name = fontName;
        @is_bold = isBold;
        @is_italic = isItalic;
        @digit_offset = digitOffset;
    end

    def getGlyph(entityGroup, number, transform)
        TODO
    end

end

# Class that encapsulates a custom font. It generates glyphs from custom-drawn
# glyph meshes that are directly loaded into Sketchup. This class performs no
# splicing and requires every glyph to be separately created.
class CustomFont < Font

    def initialize(fontFolder)
        @font_folder = fontFolder;
        @font_images = Array.new$glyph_max);
    end

    def setGlyph(number, glyphImage)
        TODO
    end

    def getGlyph(entityGroup, number, transform)
        TODO
    end

end

# Class that encapsulates a custom font. It generates glyphs from custom-drawn
# glyph meshes that are directly loaded into Sketchup. This class only requires
# glyphs to be made for the numbers 0~9 and will automatically generate composite
# glyphs with more than one number from them.
class SplicedCustomFont < CustomFont

    def initialize(fontFolder, digitOffset)
        # Initialize the base CustomFont object.
        super.initialize(fontFolder);

        # Generate the remaining glyphs by splicing together the glyphs for 0
        # through 9 that were loaded from the font folder.
        TODO
    end

end



##### FONT INSTANCES #####



##### DICE #####

# Abstract base class for all dice.
class Dice

end



##### EXECUTION ####
