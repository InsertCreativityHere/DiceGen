
module DiceGen::Fonts
    # This class defines the glyphs that comprise the Graffiti custom font, but with a lotus in place of the number 20.
    class Graffiti_L < SplicedFont

        def initialize()
            super(name: "graffiti", folder: "#{Util::RESOURCE_DIR}/VectorFonts/MadiGraffitiFont", padding: 0.1)
            @glyphs["20"] = VECTOR_IMAGES.glyphs["flowa3"]
        end

    end
end
