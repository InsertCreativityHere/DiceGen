
module DiceGen::Fonts

    # Define the common arguments for graffiti fonts in a centralized location.
    GRAFFITI_ARGS = {:name => "graffiti", :folder => "#{FONT_DIR}/Graffiti", :default_padding => 0.1, :padding_matrix => {
        "15" => -0.25, "18" => -0.1,"19" => -0.2
    }}

    Graffiti = SplicedFont::new(**GRAFFITI_ARGS)

    Graffiti_Lotus = SplicedFont::new(**GRAFFITI_ARGS)
    Graffiti_Lotus.set_glyphs({"20" => VECTOR_IMAGES["lotuslogo"]})

end
