
module DiceGen::Dice

    puts "===== Loading Dice ====="
    # Import all the ruby files in the 'DiceDefinitions' diretory; Each of these defines a single mesh model for a die.
    (Dir["#{__dir__}/DiceDefinitions/**/*.rb"]).each() do |file|
        require file
        model_name = File.basename(file, ".rb")
        variants = "#{(Class.const_get(model_name)).constants()}".gsub(":", "")
        mappings = "#{(Class.const_get(model_name))::STANDARD.glyph_mappings.keys()}".gsub("\"", "")
        puts "    Loaded #{model_name}#{' ' * (36 - model_name.length())}#{variants}#{' ' * (42 - variants.length())}#{mappings}"
    end

end
