
module DiceGen
module Fonts

    # This class defines the Graffiti font family.
    class Graffiti < SplicedFont
        # The default padding matrix for Graffiti fonts.
        PADDING = {
            "15" => -0.25, "18" => -0.1,"19" => -0.2
        }

        # Creates a new instance of a Graffiti style font.
        #   padding_matrix: Hash specifying the amount of padding to place between specific pairs of glyphs.
        #   default_padding: The amount of padding to place between glyphs not specified in the padding matrix.
        def initialize(padding_matrix: PADDING, default_padding: 0.1)
            super(name: "Graffiti", folder: "#{FONT_DIR}/Graffiti", padding_matrix: padding_matrix, default_padding: default_padding)
            @glyphs["*"] = VECTOR_IMAGES["lotuslogo"]
        end

        # List of all the supported fonts in the Graffiti family.
        STANDARD = Graffiti::new()
    end

end
end
