
module DiceGen::Fonts

    puts "===== Loading Images ====="
    # Create a 'font' for loading in and storing all the vector images, so that other fonts can access them.
    # We do this before loading any of the other real fonts, since any of them might reference these glyphs.
    VECTOR_IMAGES_FONT = RawFont::new(name: "Vector Images Font", folder: "#{DiceGen::Util::RESOURCE_DIR}/VectorImages")
    # Create a constant that references the actual images, for convenience's sake.
    VECTOR_IMAGES = VECTOR_IMAGES_FONT.glyphs

    puts "===== Loading Fonts ====="
    # Define a constant that stores the path to the root font directory, again for convenience's sake.
    FONT_DIR = "#{DiceGen::Util::RESOURCE_DIR}/VectorFonts"

    # Import all the ruby files in the 'FontDefinitions' directory; Each of these defines a font family.
    load_message = ""
    (Dir["#{__dir__}/FontDefinitions/**/*.rb"]).each() do |file|
        require file
        load_message += "    Loaded #{File.basename(file, ".rb")}\n"
    end
    puts load_message

end
