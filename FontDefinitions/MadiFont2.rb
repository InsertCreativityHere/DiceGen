
module DiceGen::Fonts

    # Define the padding matrix for splicing the MadiFont2 glyphs together.
    MADIFONT2_MATRIX = {

    }

    MadiFont2 = SplicedFont::new(name: "MadiFont 2", folder: "#{FONT_DIR}/MadiFont2", padding_matrix: MADIFONT2_MATRIX)
    MadiFont2.set_glyphs({"*" => VECTOR_IMAGES["lotuslogo"]})

end
