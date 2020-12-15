
module DiceGen
module Fonts
module Definitions

    # This class defines the Arial font family.
    class Arial < SystemFont
        # Creates a new instance of an Arial style font.
        #   italic: Whether the font should be italicized (defaults to false).
        #   bold: Whether the font should be bolded (defaults to false).
        def initialize(italic: false, bold: false)
            super(name: "Arial", system_font: "Arial", italic: italic, bold: bold)
            @glyphs["*"] = VECTOR_IMAGES["lotuslogo"]
        end

        # List of all the supported fonts in the Arial family.
        STANDARD = Arial::new()
        ITALIC = Arial::new(italic: true)
        BOLD = Arial::new(bold: true)
        BOTH = Arial::new(italic: true, bold: true)
    end

end
end
end
