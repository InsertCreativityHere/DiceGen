
module DiceGen::Fonts
    # This class defines the glyphs that comprise the Graffit font.
    class Graffiti < SplicedFont

        def initialize()
            super(name: "graffiti", folder: "/Users/austin/DiceStuff/Resources/VectorFonts/MadiGraffitiFont",
                  padding: 0.1)
            @glyphs["20"] = VECTOR_IMAGES.glyphs["flowa3"]
        end

    end
end
