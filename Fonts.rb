
module DiceGen
module Fonts

    # Module containing font specific utility code.
    module FontUtil
        module_function

        # Imports all the mesh definitions that make up a font.
        #   font_folder: The absolute path of the base font folder. This is NOT the folder immediately containing
        #                the mesh files, but the one above it; This function expects our custom directory scheme to be
        #                followed, and so it's the actual font folder that it expects to get.
        #   mesh_names:  Array listing the names of the meshes that should be imported (without file extensions). When
        #                specified, only these meshes are loaded, and a warning message is issued if any names aren't
        #                loaded. When set to 'nil', all meshes are loaded instead. Defaults to 'nil'
        #   return: A hash of mesh definitions whose keys are the names of each imported file (without their extensions)
        #           and each value is the ComponentDefinition for the mesh that was imported from that file.
        def import_meshes(font_folder:, mesh_names: nil)
            # Check the provided font folder exists.
            unless File.exists?(font_folder)
                raise "Folder '#{font_folder}' does not exist or is inaccessible."
            end
            # And that it has a "finished" subdirectory.
            unless File.exists?(font_folder + "/finished")
                raise "Folder '#{font_folder}' does not contain a 'finished' subdirectory."
            end

            meshes = Hash::new()
            puts "Importing meshes from '#{font_folder}/finished':"

            # If no meshes were explicitely listed, try to import every mesh file for the font.
            # Otherwise, only attempt to import the specified mesh files.
            if (mesh_names.nil?())
                (Dir["#{font_folder}/finished/*.dae"]).each() do |file|
                    # Get the file name on it's own, and without it's extension.
                    filename = File.basename(file, ".dae")

                    meshes[filename] = Util.import_definition(file)
                end
            else
                mesh_names.each() do |mesh|
                    meshes[mesh] = Util.import_definition("#{font_folder}/finished/#{mesh}.dae")
                end
            end

            return meshes
        end

        # Combines 2 glyphs together into a composite glyph, with the glyphs placed to the left and right of each other.
        #   glyphs: Array of ComponentDefinitions containing the glyphs to be spliced together. The original glyphs are
        #           in no way altered by this function.
        #   chars: The plain text names of the glyphs that are being spliced. This corresponds to the text represented
        #          by the provided glyph array.
        #   padding_matrix: Hash containing the amount of horizontal padding space to leave between specific pairs of
        #                   glyphs. Each key is an ordered pair of glyphs (like "79"), and the corresponding value is
        #                   how much padding should be placed between them during splicing.
        #   default_padding: The default amount of padding to leave between glyphs when no value is specified in the
        #                    padding_matrix.
        #   return: The ComponentDefinition of the new composite glyph.
        def splice_glyphs(glyphs:, chars:, padding_matrix:, default_padding:)
            # The new glyph's definition name is formed by concatenating the component glyph's names with underscores.
            name = ""
            # Calculate the total width of the combined glyphs and the padding in between them.
            total_width = 0.0
            # Array for storing the padding values between each pair of glyphs.
            padding = []

            # Temporarily stores the previous glyph we iterated over for computing the padding between pairs.
            previousGlyph = nil
            glyphs.each_with_index() do |glyph, i|
                # Concatenate the name of the current glyph onto the compound glyph's name with an underscore.
                name += ('_' + glyph.name())
                # Add the glyph's width to the total width.
                total_width += glyph.bounds().width()

                # Compute the padding that should be placed between this pair of glyphs.
                unless previousGlyph.nil?()
                    pair_padding = (padding_matrix[chars[(i-1)..i]] || default_padding)
                    padding[i - 1] = pair_padding
                    total_width += pair_padding
                end
                previousGlyph = glyph
            end
            # Remove the trailing underscore from the compound name.
            name = name[0..-2]
            # Add a final padding value of 0 so that no padding is added to the end of the compound glyph.
            padding.push(0.0)

            # Create a new definition to splice the glyphs into.
            definition = $MAIN_MODEL.definitions.add(name)
            entities = definition.entities()

            # Keep a running tally of the current x position, starting at the leftmost point.
            xPos = -total_width / 2.0

            # Create instances of the component glyphs in the new definition.
            glyphs.each_with_index() do |glyph, i|
                # Calculate the x position to place the glyph at so the new spliced glyph is still centered.
                bounds = glyph.bounds()
                offset = Geom::Point3d::new(xPos + (bounds.width() / 2.0) - bounds.center().x, 0.0, 0.0)
                # Create an instance of the component glyph to splice it into the definition.
                (entities.add_instance(glyph, Geom::Transformation.translation(offset)).make_unique()).explode()
                # Increment the position by the width of the glyph we just placed, plus the padding between glyphs.
                xPos += bounds.width() + padding[i]
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
            @glyphs.merge!(glyphs)
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
        #            a pair of offsets specifying how much to translate the glyph in each direction (x and y) in mm.
        def set_offsets(offsets)
            offsets.each() do |name, offset|
                entities = @glyphs[name].entities()
                vectorOffset = Geom::Vector3d::new(Util::MTOI * offset[0], Util::MTOI * offset[1], 0)
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
            return entities.add_instance(@glyphs[name.to_s()], transform).make_unique()
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
            name = name.to_s()
            # Lazily create the requested glyph via the 3D text tool if we haven't already created and cached it before.
            unless @glyphs.key?(name)
                # Create a new definition to draw the text into.
                definition = $MAIN_MODEL.definitions.add(@name + '_' + name)
                def_entitites = definition.entities()

                # Draw the 3D text centered with the correct attributes and a letter-height of 8mm.
                def_entitites.add_3d_text(name, TextAlignCenter, system_font, is_bold, is_italic, (8 * Util::MTOI))

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
        # Hash that specified the amount of padding to place between specific pairs of glyphs. Each key should be the
        # names of two glyphs, and the corresponding value indicates how much padding space should be left between the
        # two glyphs when being spliced in that order. '{"13" => 0.2}' indicates 0.2mm should be left between a 1 and 3
        # when they are spliced together. Note that the keys are order dependent. "13" and "31" will and should have
        # different padding values.
        attr_reader :padding_matrix
        # The default amount of padding space to leave between glyphs when splicing if no padding is specified for them
        # in the padding matrix.
        attr_reader :default_padding

        # Create a new spliced font with the specified font, and whose base glyphs are defined by meshes stored in DAE
        # files. Every mesh in the font folder is loaded, and afterwards, composite glyphs are generated as needed.
        #   name: The plain-text name of the font.
        #   folder: The absolute path of the base font folder. This is NOT the folder immediately containing the mesh
        #         files, but the one above it; This function expects our custom directory scheme to be followed, and so
        #         it's the actual font folder that it expects to get.
        #   padding_matrix: Hash containing the amount of horizontal padding space to leave between specific pairs of
        #                   glyphs. Each key is an ordered pair of glyphs (like "79"), and the corresponding value is
        #                   how much padding should be placed between them during splicing. Defaults to an empty hash.
        #   default_padding: The default amount of padding to leave between glyphs when no value is specified in the
        #                    padding_matrix. Defaults to 0.1mm.
        def initialize(name:, folder:, padding_matrix: {}, default_padding: 0.1)
            super(name: name, folder: folder)
            # Convert the paddings from mm to inches (except that we actually use meters in place of mm in the model).
            @padding_matrix = Hash[padding_matrix.map{ |k,v| [k, v * Util::MTOI]}]
            @default_padding = default_padding * Util::MTOI
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
            name = name.to_s()
            # Lazily create the requested glyph via splicing if it doesn't already have a definition.
            unless @glyphs.key?(name)
                char_glyphs = name.chars().map{ |char| @glyphs[char] }
                @glyphs[name] = FontUtil.splice_glyphs(glyphs: char_glyphs, chars: name, padding_matrix: @padding_matrix, default_padding: @default_padding)
            end
            return super
        end
    end

end
end
