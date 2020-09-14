
module DiceGen::Dice
    # This class defines the mesh model for a pentagonal trapezohedron (non-standard D10).
    class PentagonalTrapezohedron < Die
        # This constant controls how much the vertexes of the trapezohedron protrude from the midline. A value of 0
        # means they don't protrude at all (it reduces this shape to an decagon), and a value of 1 produces a standard
        # pentagonal trapezohedron.
        VERTEX_SCALE = 1.0

        # Lays out the geometry for the die in a new ComponentDefinition and adds it to the main DefinitionList.
        def initialize()
            # Create a new definition for the die.
            definition = Util::MAIN_MODEL.definitions.add(self.class.name)
            mesh = definition.entities()

            c0 = 0.0
            c1 = 0.5
            c2 = (Math.sqrt(5.0) + 1.0) / 4.0
            c3 = Math.sqrt((5.0 + 2.0 * Math.sqrt(5.0)) / 20.0)
            c4 = Math.sqrt((5.0 - 2.0 * Math.sqrt(5.0)) / 20.0) * VERTEX_SCALE
            c5 = Math.sqrt((5.0 -       Math.sqrt(5.0)) / 40.0)
            c6 = Math.sqrt((5.0 +       Math.sqrt(5.0)) / 10.0)
            c7 = ((Math.sqrt(25.0 + 11.0 * Math.sqrt(5.0)) + Math.sqrt(10.0) * c6) / Math.sqrt(40.0)) * VERTEX_SCALE
            # Define all the points that make up the vertices of the die.
            v0  = Geom::Point3d::new( c1,  c3,  c4)
            v1  = Geom::Point3d::new(-c1,  c3,  c4)
            v2  = Geom::Point3d::new( c1, -c3, -c4)
            v3  = Geom::Point3d::new(-c1, -c3, -c4)
            v4  = Geom::Point3d::new( c2,  c5, -c4)
            v5  = Geom::Point3d::new(-c2,  c5, -c4)
            v6  = Geom::Point3d::new( c2, -c5,  c4)
            v7  = Geom::Point3d::new(-c2, -c5,  c4)
            v8  = Geom::Point3d::new( c0,  c6, -c4)
            v9  = Geom::Point3d::new( c0, -c6,  c4)
            v10 = Geom::Point3d::new( c0,  c0,  c7)
            v11 = Geom::Point3d::new( c0,  c0, -c7)

            # Create the faces of the die by joining the vertices with edges. #TODO FIX THIS
            faces = Array::new(10)
            faces[0] = mesh.add_face([v10, v9, v2, v6])
            faces[1] = mesh.add_face([v10, v7, v3, v9])
            faces[2] = mesh.add_face([v10, v1, v5, v7])
            faces[3] = mesh.add_face([v10, v0, v8, v1])
            faces[4] = mesh.add_face([v10, v6, v4, v0])
            faces[5] = mesh.add_face([v11, v8, v0, v4])
            faces[6] = mesh.add_face([v11, v5, v1, v8])
            faces[7] = mesh.add_face([v11, v3, v7, v5])
            faces[8] = mesh.add_face([v11, v2, v9, v3])
            faces[9] = mesh.add_face([v11, v4, v6, v2])

            #TODO MAKE THE DIE SCALE!
            # TODO CHECK IF THIS IS EVEN STILL RIGHT NOW THAT IM REDOING EVERYTHING!
            # Glyph models are always 8mm tall when imported, and the glyphs on a D10 are 7mm tall, so glyphs must
            # be scaled by a factor of 7mm/8mm = 0.875
            super(definition: definition, faces: faces, font_scale: 0.875)

            # Rotate each of the face transforms by TODO
            #TODO MAKE THIS WORK FOR BOTH D10 and D%
        end

        # TODO
        def place_glyphs(font:, mesh:, type:, die_scale: 1.0, font_scale: 1.0, font_offset: [0,0], font_angle: 0.0,
                         glyph_mapping: nil)
            if (type == "D%")
                #TODO
            else
                super
            end
        end
    end
end
