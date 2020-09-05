
module DiceGen::Fonts

    # Import all the ruby files in the 'FontDefinitions' diretory; Each of these defines a single font.
    (Dir["#{__dir__}/FontDefinitions/*.rb"]).each() do |file|
        require file
        puts "    Loaded #{File.basename(file, ".rb")}"
    end

end
