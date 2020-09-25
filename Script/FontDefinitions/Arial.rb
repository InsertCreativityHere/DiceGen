
module DiceGen::Fonts

    # Define the common arguments for arial fonts in a centralized location.
    ARIAL_ARGS = {:name => "Arial", :system_font => "Arial"}

    Arial = SystemFont::new(**ARIAL_ARGS)

    Arial_Lotus = SystemFont::new(**ARIAL_ARGS)
    Arial_Lotus.set_glyphs({"20" => VECTOR_IMAGES["flowa3"]})

end
