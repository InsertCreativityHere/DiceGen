
module DiceGen::Fonts

    puts DiceGen::Util

    puts "===== Loading Images ====="
    # Class for storing all the vector images as a font so that other fonts can access them.
    # We do this before loading any of the other fonts, since any of them might reference these glyphs.
    class VectorImages < RawFont
        def initialize()
            # We need to explicitely reference the module here, since we haven't 'include'd the DiceGen module yet at
            # the bottom of 'DiceGen.rb'.
            super(name: "", folder: "#{DiceGen::Util::RESOURCE_DIR}/VectorImages")
        end
    end
    VECTOR_IMAGES = VectorImages.instance()

    puts "===== Loading Fonts ====="
    # Import all the ruby files in the 'FontDefinitions' directory; Each of these defines a single font.
    (Dir["#{__dir__}/FontDefinitions/*.rb"]).each() do |file|
        require file
        puts "    Loaded #{File.basename(file, ".rb")}"
    end

end
