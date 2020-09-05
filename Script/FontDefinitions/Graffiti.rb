
module DiceGen::Fonts
    # This class defines the glyphs that comprise the Graffiti font.
    class Graffiti < SplicedFont

        def initialize()
            super(name: "graffiti", folder: "#{Util::DICE_STUFF_DIR}/Resources/VectorFonts/MadiGraffitiFont",
                  padding: 0.1)
        end

    end
end
