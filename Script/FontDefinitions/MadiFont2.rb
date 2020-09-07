
module DiceGen::Fonts
    # This class defines the glyphs that comprise the Madifont_2 custom font.
    class MadiFont2 < SplicedFont

        def initialize()
            super(name: "madifont 2", folder: "#{Util::RESOURCE_DIR}/VectorFonts/MadiFont2", padding: 0.1)
        end

    end
end
