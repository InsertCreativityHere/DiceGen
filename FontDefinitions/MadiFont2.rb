
module DiceGen
module Fonts

    # This class defines the MadiFont2 font family.
    class MadiFont2 < SplicedFont
        # The default padding matrix for MadiFont2 fonts.
        PADDING = {

        }

        # Creates a new instance of a MadiFont2 style font.
        #   padding_matrix: Hash specifying the amount of padding to place between specific pairs of glyphs.
        #   default_padding: The amount of padding to place between glyphs not specified in the padding matrix.
        def initialize(padding_matrix: PADDING, default_padding: 0.1)
            super(name: "MadiFont 2", folder: "#{FONT_DIR}/MadiFont2", padding_matrix: padding_matrix, default_padding: default_padding)
            @glyphs["*"] = VECTOR_IMAGES["lotuslogo"]
        end

        # List of all the supported fonts in the MadiFont2 family.
        STANDARD = MadiFont2::new()
    end

end
end
