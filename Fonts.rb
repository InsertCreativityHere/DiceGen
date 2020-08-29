
module DiceGen

    # Module for storing all the font instances we've created in one easy to access central location.
    module Fonts
        MADIFONT_2 = SplicedFont::new(name: "madifont 2", folder: "/Users/austin/3DPrinting/DiceStuff/Resources/VectorFonts/MadiFont2", padding: 0.1)
        MADIFONT_2.set_offsets({})
        MADIFONT_2.set_scales({})

        GRAFFITI   = SplicedFont::new(name: "graffiti", folder: "/Users/austin/3DPrinting/DiceStuff/Resources/VectorFonts/MadiGraffitiFont", padding: 0.1)
        GRAFFITI.set_offsets({})
        GRAFFITI.set_scales({})
    end

end
