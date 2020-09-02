
module DiceGen

    # Import all the ruby files in the 'DiceDefinitions' diretory; Each of these defines a single mesh model for a die.
    (Dir["#{__dir__}/DiceDefinitions/*.rb"]).each() do |file|
        require file
        puts "    Loaded #{File.basename(file, ".rb")}"
    end

    # Module for storing all the pre-grouped dice sets we've created so far in one easy to access central location.
    module DiceSets
        #TODO
    end

end
