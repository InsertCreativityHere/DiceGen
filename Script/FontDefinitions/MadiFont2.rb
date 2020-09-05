
module DiceGen::Fonts
    # This class defines the glyphs that comprise the Madifont_2 font.
    class MadiFont2 < SplicedFont

        def initialize()
            super(name: "madifont 2", folder: "/Users/austin/DiceStuff/Resources/VectorFonts/MadiFont2", padding: 0.1)
            @glyphs["20"] = VECTOR_IMAGES.glyphs["flowa3"]
        end

    end
end
