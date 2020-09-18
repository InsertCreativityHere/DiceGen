
module DiceGen::Fonts

    Graffiti = SplicedFont::new(name: "graffiti", folder: "#{FONT_DIR}/MadiGraffitiFont", padding: 0.1)

    Graffiti_Lotus = SplicedFont::new(name: "graffiti", folder: "#{FONT_DIR}/MadiGraffitiFont", padding: 0.1)
    Graffiti_Lotus.set_glyphs({"20" => "flowa3"})

end
