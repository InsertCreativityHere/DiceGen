
module DiceGen::Dice
    # This class defines the mesh model for a pentagonal dipyramid (non-standard D10).
    class PentagonalDipyramid < Die
        # This constant controls how much the vertexes of the pyramids protrude from the base. A value of 0 means they
        # don't protrude at all (it reduces this shape to a pentagon), and a value of 1 makes the faces equalateral
        # triangles. Setting it to 'Math.sqrt(2.0 / (25.0 - 11.0 * Math.sqrt(5.0)))' produces a standard pentagonal
        # dipyramid.
        VERTEX_SCALE = Math.sqrt(2.0 / (25.0 - 11.0 * Math.sqrt(5.0)))

        # Lays out the geometry for the die in a new ComponentDefinition and adds it to the main DefinitionList.
        def initialize()
            # Create a new definition for the die.
            definition = Util::MAIN_MODEL.definitions.add(self.class.name)
            mesh = definition.entities()

            c0 = 0.0
            c1 = 1.0
            c2 = (1.0 + (Math.sqrt(5.0) / 5.0)) * Math.sqrt((25.0 - 11.0 * Math.sqrt(5.0)) / 2.0) * VERTEX_SCALE
            c3 = Math.sqrt((5.0 - 2.0 * Math.sqrt(5.0)) /  5.0)
            c4 = Math.sqrt((5.0 +       Math.sqrt(5.0)) / 10.0)
            c5 = Math.sqrt((5.0 -       Math.sqrt(5.0)) /  2.5)
            c6 = (Math.sqrt(5.0) - 1.0) / 2.0
            # Define all the points that make up the vertices of the die.
            v0 = Geom::Point3d::new( c0,  c0,  c2)
            v1 = Geom::Point3d::new( c0,  c0, -c2)
            v2 = Geom::Point3d::new( c1, -c3,  c0)
            v3 = Geom::Point3d::new(-c1, -c3,  c0)
            v4 = Geom::Point3d::new( c6,  c4,  c0)
            v5 = Geom::Point3d::new(-c6,  c4,  c0)
            v6 = Geom::Point3d::new( c0, -c5,  c0)

            # Create the faces of the die by joining the vertices with edges. #TODO FIX THIS
            faces = Array::new(10)
            faces[0] = mesh.add_face([v0, v2, v4])
            faces[1] = mesh.add_face([v0, v4, v5])
            faces[2] = mesh.add_face([v0, v5, v3])
            faces[3] = mesh.add_face([v0, v3, v6])
            faces[4] = mesh.add_face([v0, v6, v2])
            faces[5] = mesh.add_face([v1, v2, v6])
            faces[6] = mesh.add_face([v1, v6, v3])
            faces[7] = mesh.add_face([v1, v3, v5])
            faces[8] = mesh.add_face([v1, v5, v4])
            faces[9] = mesh.add_face([v1, v4, v2])

            #TODO MAKE THE SCALES!
            super(definition: definition, faces: faces)
        end
    end
end
