
module DiceGen::Fonts

    # Define the common arguments for swirl fonts in a centralized location.
    SWIRL_ARGS = {:name => "swirl", :folder => "#{FONT_DIR}/Swirl", :default_padding => 0.1, :padding_matrix => {

    }}

    Swirl = SplicedFont::new(**SWIRL_ARGS)

    Swirl_Lotus = SplicedFont::new(**SWIRL_ARGS)
    Swirl_Lotus.set_glyphs({"20" => VECTOR_IMAGES["lotuslogo"]})

end
