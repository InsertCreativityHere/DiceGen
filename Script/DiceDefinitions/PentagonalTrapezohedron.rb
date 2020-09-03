
module DiceGen
    # This class defines the mesh model for a sharp-edged standard D10 die (a pentagonal trapezohedron).
    class PentagonalTrapezohedron < Die
        # Lays out the geometry for the die in a new ComponentDefinition and adds it to the main DefinitionList.
        def initialize()
            # Create a new definition for the die.
            definition = Util::MAIN_MODEL.definitions.add(self.class.name)
            mesh = definition.entities()

            # Define all the points that make up the vertices of the die.
            #TODO

            # Create the faces of the die by joining the vertices with edges.
            faces = Array::new(10)
            #TODO

            #TODO MAKE THE DIE SCALE!
            # Glyph models are always 8mm tall when imported, and the glyphs on a D10 are 7mm tall, so glyphs must
            # be scaled by a factor of 7mm/8mm = 0.875
            super(definition: definition, faces: faces, font_scale: 0.875)

            # Rotate each of the face transforms by TODO
            #TODO MAKE THIS WORK FOR BOTH D10 and D%
        end

        # TODO
        def place_glyphs(font:, mesh:, type: "D10", font_scale: 1.0, font_offset: [0,0])
            if (type == "D%")
                #TODO
            elsif (type == "D10")
                super
            else
                raise "Incompatible die type: a D10 model cannot be used to generate #{type.to_s()} dice."
            end
        end
    end
end
