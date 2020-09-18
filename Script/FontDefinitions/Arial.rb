
module DiceGen::Fonts

    Arial = SystemFont::new(name: "Arial", system_font: "Arial")

    Arial_Lotus = SystemFont::new(name: "Arial", system_font: "Arial")
    Arial_Lotus.set_glyphs({"20" => VECTOR_IMAGES["flowa3"]})

end
