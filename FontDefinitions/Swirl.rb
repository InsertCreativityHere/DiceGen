
module DiceGen::Fonts

    # Define the padding matrix for splicing the Swirl glyphs together.
    SWIRL_MATRIX = {

    }

    Swirl = SplicedFont::new(name: "Swirl", folder: "#{FONT_DIR}/Swirl", padding_matrix: SWIRL_MATRIX)
    Swirl.set_glyphs({"*" => VECTOR_IMAGES["lotuslogo"]})

end
