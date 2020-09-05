
module DiceGen::Fonts
    # This class defines the glyphs that comprise the Graffiti font, but with a lotus in place of the number 20.
    class LotusGraffiti < Graffiti

        def initialize()
            super
            @glyphs["20"] = VECTOR_IMAGES.glyphs["flowa3"]
        end

    end
end
