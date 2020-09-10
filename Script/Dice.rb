
module DiceGen::Dice

    puts "===== Loading Dice ====="
    # Import all the ruby files in the 'DiceDefinitions' diretory; Each of these defines a single mesh model for a die.
    (Dir["#{__dir__}/DiceDefinitions/**/*.rb"]).each() do |file|
        require file
        puts "    Loaded #{File.basename(file, ".rb")}"
    end

end
