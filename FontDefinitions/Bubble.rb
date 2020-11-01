
module DiceGen::Fonts

    # Define the common arguments for bubble fonts in a centralized location.
    BUBBLE_ARGS = {:name => "bubble", :folder => "#{FONT_DIR}/Bubble", :default_padding => 0.1, :padding_matrix => {

    }}

    Bubble = SplicedFont::new(**BUBBLE_ARGS)

    Bubble_Lotus = SplicedFont::new(**BUBBLE_ARGS)
    Bubble_Lotus.set_glyphs({"20" => VECTOR_IMAGES["flowa3"]})

end
