
module DiceGen::Fonts

    # Define the padding matrix for splicing the Bubble glyphs together.
    BUBBLE_MATRIX = {

    }

    Bubble = SplicedFont::new(name: "Bubble", folder: "#{FONT_DIR}/Bubble", padding_matrix: BUBBLE_MATRIX)
    Bubble.set_glyphs({"*" => VECTOR_IMAGES["lotuslogo"]})

end
