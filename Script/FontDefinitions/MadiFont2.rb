
module DiceGen::Fonts

    MadiFont2 = SplicedFont::new(name: "madifont 2", folder: "#{FONT_DIR}/MadiFont2", padding: 0.1)

    MadiFont2_Lotus = SplicedFont::new(name: "madifont 2", folder: "#{FONT_DIR}/MadiFont2", padding: 0.1)
    MadiFont2_Lotus.set_glyphs({"20" => "flowa3"})

end
