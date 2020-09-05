
module DiceGen::Fonts
    # This class defines the glyphs that comprise the Madifont_2 font, but with a lotus in place of the number 20.
    class LotusMadiFont2 < MadiFont2

        def initialize()
            super
            @glyphs["20"] = VECTOR_IMAGES.glyphs["flowa3"]
        end

    end
end
