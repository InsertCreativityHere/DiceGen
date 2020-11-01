
module DiceGen::Fonts

    # Define the common arguments for madifont2 fonts in a centralized location.
    MADIFONT2_ARGS = {:name => "madifont 2", :folder => "#{FONT_DIR}/MadiFont2", :default_padding => 0.1, :padding_matrix => {

    }}

    MadiFont2 = SplicedFont::new(**MADIFONT2_ARGS)

    MadiFont2_Lotus = SplicedFont::new(**MADIFONT2_ARGS)
    MadiFont2_Lotus.set_glyphs({"20" => VECTOR_IMAGES["flowa3"]})

end
