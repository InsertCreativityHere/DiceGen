
module DiceGen
    # Module for storing all the font instances we've created in one easy to access central location.
    module Fonts

        class MadiFont2 < SplicedFont
            def initialize()
                super(name: "madifont 2", folder: "/Users/austin/DiceStuff/Resources/VectorFonts/MadiFont2", padding: 0.1)
            end
        end

        class Graffiti < SplicedFont
            def initialize()
                super(name: "graffiti", folder: "/Users/austin/DiceStuff/Resources/VectorFonts/MadiGraffitiFont", padding: 0.1)
            end
        end

    end
end
