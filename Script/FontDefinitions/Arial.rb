
module DiceGen::Fonts
    # This class defines the glyphs that comprise the Arial system font.
    class Arial < SystemFont

        def initialize()
            super(name: "Arial", system_font: "Arial")
        end

    end
end
