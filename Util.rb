
module DiceGen

# Module containing general use utility code.
module Util
    module_function

    # Stores the currently active Sketchup model.
    $MAIN_MODEL = Sketchup::active_model

    # Path the base directory of the script.
    RESOURCE_DIR = "/Users/austin/DiceStuff/Resources"
    SCRIPT_DIR = "/Users/austin/DiceStuff/Script"

    # Conversion factor for converting from meters to inches
    MTOI = (1000.0 / 25.4)
    # Conversion factor for converting from inches to meters
    ITOM = (25.4 / 1000.0)

    # Conversion factor for converting from degrees to radians
    DTOR = (Math::PI / 180.0)
    # Conversion factor for converting from radians to degrees
    RTOD = (180.0 / Math::PI)

    # Hash that stores the definitions for everything we import to prevent reloading the same defintion twice.
    # Values are the stringified name of the ComponentDefinition, and keys are the filenames that the definitions were
    # imported from.
    @@import_cache = Hash::new()

    # Imports a file and returns a reference to the imported definition. Note that this function will cause the
    # imported definition to appear at the mouse cursor in the UI, this is a limitation of the API. Hitting <ESC>
    # Will get rid of the extra instance.
    #   file: The absolute path of the file to import from.
    #   return: A ComponentDefinition corresponding to the imported definition.
    def import_definition(file)
        # Check if we've already imported the file, and if so, return the cached definition.
        if @@import_cache.key?(file)
            return $MAIN_MODEL.definitions[@@import_cache[file]]
        end

        # Check if the file exists and is reachable.
        unless File.exist?(file)
            raise "Failed to locate the file '#{file}'"
        end

        # Try to import the file's model and check if it was successful.
        result = $MAIN_MODEL.import(file)
        unless result
            raise "Failed to import model from the file '#{file}'"
        end
        puts "    Loaded '#{File.basename(file, ".dae")}.dae'"

        # Cache and return the most recently created definition; ie: the one we just imported.
        definition = $MAIN_MODEL.definitions[-1]
        @@import_cache[file] = definition.guid()
        return definition
    end

    # Scales a vector by the provided scale factor like 'vector * scale' would normally.
    #   vector: The vector to scale. Note that this vector isn't altered by the function, instead it's components
    #           components are copied into a new vector and that is scaled and returned.
    #   scale: The scale factor to scale the vector by.
    #   return: A new vector with the same components as the provided vector, but scaled by 'scale_factor'.
    def scale_vector(vector, scale)
        return Geom::Vector3d::new(vector.x * scale, vector.y * scale, vector.z * scale)
    end

    # Manually reloads all the dice and font definitions by manually deleting their definitions from the current Ruby
    # session, and then re-requiring them. This might be dangerous, but it seems to work so far *shrugs*.
    # This really helps when editing dice definitions on the fly in Sketchup, since IRB never needs to be restarted.
    def reload_script()
        # First we manually delete any of the classes or modules that we've loaded from the definition scripts,
        # We assume that all these files are in one of the 'Definitions' modules. *crosses fingers*

        puts "Unloading and deleting imported definitions..."
        Fonts::Definitions.constants().each() do |obj|
            puts "    Unloading Font definition: '#{obj}'"
            Fonts::Definitions.send(:remove_const, obj)
        end
        Dice::Definitions.constants().each() do |obj|
            puts "    Unloading Die definition: '#{obj}'"
            Dice::Definitions.send(:remove_const, obj)
        end

        # All the files that have been imported into the current ruby session are stored in a variable named $"
        # We manually remove any files relating to die or font defitions from this list to 'un-require' them, so that
        # we when 'require' them in the next step, Ruby will load a fresh copy of the file.
        $".delete_if{|file| file.start_with?("#{SCRIPT_DIR}/DiceDefinitions/") || file == "#{SCRIPT_DIR}/DieLoader.rb"}
        $".delete_if{|file| file.start_with?("#{SCRIPT_DIR}/FontDefinitions/") || file == "#{SCRIPT_DIR}/FontLoader.rb"}

        # Clear the import cache, so that any old definitions will get re-imported from scratch.
        @@import_cache = Hash::new()

        # Purge any unused ComponentDefinitions, to minimize naming conflicts while re-importing the model definitions.
        # Then reset the MAIN_MODEL to whatever the active model in Sketchup currently is.
        $MAIN_MODEL.definitions.purge_unused()
        $MAIN_MODEL = Sketchup::active_model

        # Re-require the font and dice definition files.
        puts "Reloading definitions..."
        require_relative "FontLoader.rb"
        require_relative "DieLoader.rb"
    end
end

end
