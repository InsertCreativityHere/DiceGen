
module DiceGen::Fonts

    # Define the padding matrix for splicing the graffiti glyphs together.
    GRAFFITI_MATRIX = {
        "15" => -0.25, "18" => -0.1,"19" => -0.2
    }

    Graffiti = SplicedFont::new(name: "Graffiti", folder: "#{FONT_DIR}/Graffiti", padding_matrix = GRAFFITI_MATRIX)
    Graffiti.set_glyphs({"*" => VECTOR_IMAGES["lotuslogo"]})

end
