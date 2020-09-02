
module DiceGen
    # This class defines the mesh model for a sharp-edged standard D12 die (a dodecahedron).
    class Dodecahedron < Die
        # Lays out the geometry for the die in a new ComponentDefinition and adds it to the main DefinitionList.
        def initialize()
            # Create a new definition for the die.
            definition = Util::MAIN_MODEL.definitions.add(self.class.name)
            mesh = definition.entities()

            # Define all the points that make up the vertices of the die.
            #TODO

            # Create the faces of the die by joining the vertices with edges.
            faces = Array::new(12)
            #TODO

            #TODO MAKE THE DIE SCALE!
            # Glyph models are always 8mm tall when imported, and the glyphs on a D12 are 6mm tall, so glyphs must
            # be scaled by a factor of 6mm/8mm = 0.75
            super(definition: definition, faces: faces, font_scale: 0.75)
        end

        # Delegates to the default implemenation after checking that the die type is a D12.
        def place_glyphs(font:, mesh:, type:)
            if (type != "D12")
                raise "Incompatible die type: a D12 model cannot be used to generate #{type.to_s()} dice."
            end
            super
        end
    end
end
