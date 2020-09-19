
module DiceGen::Dice

    puts "===== Loading Dice ====="
    # Import all the ruby files in the 'DiceDefinitions' diretory; Each of these defines a single mesh model for a die.
    (Dir["#{__dir__}/DiceDefinitions/**/*.rb"]).each() do |file|
        require file
        model_name = File.basename(file, ".rb")
        puts "    Loaded #{model_name}#{' ' * (50 - model_name.length())}=>    #{(Class.const_get(model_name)).constants()}"
    end

end
