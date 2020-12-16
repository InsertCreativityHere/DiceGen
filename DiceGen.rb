
module DiceGen

    # Import the utility code first, since everything else uses it.
    require_relative "Util.rb"
    # Import the core code for die definitions.
    require_relative "Dice.rb"
    # Import the core code for font definitions.
    require_relative "Fonts.rb"
    # Import all the die model that we've created so far.
    require_relative "DieLoader.rb"
    # Import all the fonts that we've created so far.
    require_relative "FontLoader.rb"

    # Helper method that just forwards to the 'create_instance' method of the specified die model.
    def create_die(model:, font: nil, type: nil, group: nil, scale: 1.0, depth: 0.0, die_size: nil, font_size: nil, glyph_mapping: nil, transform: IDENTITY)
        # If no specific model instance was passed, use the standard instance for the specified model.
        if model.is_a?(Class)
            model = model::STANDARD
        end
        # Same for the font. Use the standard font of the family it none were specified.
        if font.is_a?(Class)
            font = font::STANDARD
        end
        model.create_instance(font: font, type: type, group: group, scale: scale, depth: depth, die_size: die_size, font_size: font_size, glyph_mapping: glyph_mapping, transform: transform)
    end

end

# These lines make life easier, by making it so we don't have to explicitly state module names when typing into IRB.
include DiceGen
include DiceGen::Dice
include DiceGen::Fonts
include DiceGen::Dice::Definitions
include DiceGen::Fonts::Definitions
