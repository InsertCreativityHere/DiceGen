
module DiceGen::Fonts
    # This class defines the glyphs that comprise the Madifont_2 font, but with a lotus in place of the number 20.
    class LotusMadiFont2 < SplicedFont

        def initialize()
            super(name: "madifont 2", folder: "#{Util::RESOURCE_DIR}/VectorFonts/MadiFont2", padding: 0.1)
            @glyphs["20"] = VECTOR_IMAGES.glyphs["flowa3"]
        end

    end
end
