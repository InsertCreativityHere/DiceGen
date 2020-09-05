
module DiceGen::Fonts

    # Class for storing all the vector images as a font so that other fonts can access them.
    # We do this before loading any of the other fonts, since any of them might reference these glyphs.
    class VECTOR_IMAGES < RawFont
        def initialize()
            super(name: "", folder: "/Users/austin/DiceStuff/Resources/VectorImages")
        end
    end
    puts "    Loaded VECTOR_IMAGES"

    # Import all the ruby files in the 'FontDefinitions' diretory; Each of these defines a single font.
    (Dir["#{__dir__}/FontDefinitions/*.rb"]).each() do |file|
        require file
        puts "    Loaded #{File.basename(file, ".rb")}"
    end

end
