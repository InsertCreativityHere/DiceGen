
module DiceGen
module Dice
module Definitions

    puts "===== Loading Dice ====="
    # Import all the ruby files in the 'DiceDefinitions' diretory; Each of these defines a single mesh model for a die.
    (Dir["#{__dir__}/DiceDefinitions/**/*.rb"]).each() do |file|
        require file

        model_name = File.basename(file, ".rb")
        model = Definitions.const_get(model_name)
        variants = model.constants().select{|c| model.const_get(c).is_a? DieModel}
        variants = "#{variants}".gsub(":", "")
        mappings = "#{model::STANDARD.glyph_mappings.keys()}".gsub("\"", "")

        puts "    Loaded #{model_name}#{' ' * (36 - model_name.length())}#{variants}#{' ' * (42 - variants.length())}#{mappings}"
    end

end
end
end
