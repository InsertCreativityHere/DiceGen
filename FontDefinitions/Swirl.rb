
module DiceGen
module Fonts
module Definitions

    # This class defines the Swirl font family.
    class Swirl < SplicedFont
        # The default padding matrix for Swirl fonts.
        PADDING = {

        }

        # Creates a new instance of a Swirl style font.
        #   padding_matrix: Hash specifying the amount of padding to place between specific pairs of glyphs.
        #   default_padding: The amount of padding to place between glyphs not specified in the padding matrix.
        def initialize(padding_matrix: PADDING, default_padding: 0.1)
            super(name: "Swirl", folder: "#{FONT_DIR}/Swirl", padding_matrix: padding_matrix, default_padding: default_padding)
            @glyphs["*"] = VECTOR_IMAGES["lotuslogo"]
        end

        # List of all the supported fonts in the Swirl family.
        STANDARD = Swirl::new()
    end

end
end
end
