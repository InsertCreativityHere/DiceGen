
module DiceGen
module Fonts
module Definitions

    # This class defines the Bubble font family.
    class Bubble < SplicedFont
        # The default padding matrix for Bubble fonts.
        PADDING = {

        }

        # Creates a new instance of a Bubble style font.
        #   padding_matrix: Hash specifying the amount of padding to place between specific pairs of glyphs.
        #   default_padding: The amount of padding to place between glyphs not specified in the padding matrix.
        def initialize(padding_matrix: PADDING, default_padding: 0.1)
            super(name: "Bubble", folder: "#{FONT_DIR}/Bubble", padding_matrix: padding_matrix, default_padding: default_padding)
            @glyphs["*"] = VECTOR_IMAGES["lotuslogo"]
        end

        # List of all the supported fonts in the Bubble family.
        STANDARD = Bubble::new()
    end

end
end
end
