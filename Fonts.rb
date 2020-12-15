
module DiceGen
module Fonts
module Definitions

    puts "===== Loading Images ====="
    # Create a 'font' for loading in and storing all the vector images, so that other fonts can access them.
    # We do this before loading any of the other real fonts, since any of them might reference these glyphs.
    VECTOR_IMAGES_FONT = RawFont::new(name: "Vector Images Font", folder: "#{DiceGen::Util::RESOURCE_DIR}/VectorImages")
    # Create a constant that references the actual images, for convenience's sake.
    VECTOR_IMAGES = VECTOR_IMAGES_FONT.glyphs

    # Define a constant that stores the path to the root font directory, again for convenience's sake.
    FONT_DIR = "#{DiceGen::Util::RESOURCE_DIR}/VectorFonts"

    # Import all the ruby files in the 'FontDefinitions' directory; Each of these defines a font family.
    puts "===== Loading Glyphs ====="
    (Dir["#{__dir__}/FontDefinitions/**/*.rb"]).each() do |file|
        require file
    end

    # List all the fonts that were imported.
    puts "===== Loading Fonts ====="
    ((Definitions.constants().map{|c| Definitions.const_get(c)}).select{|c| c.instance_of? Class}).each() do |font|
        family_name = font.name.split('::').last()
        variants = font.constants().select{|c| font.const_get(c).is_a? Font}
        variants = "#{variants}".gsub(":", "")

        puts "    Loaded #{family_name}#{' ' * (20 - family_name.length())}#{variants}"
    end

end
end
end
