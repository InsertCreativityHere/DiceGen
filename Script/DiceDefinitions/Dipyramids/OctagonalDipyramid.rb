
module DiceGen::Dice
    # This class defines the mesh model for a octagonal dipyramid (non-standard D16).
    class OctagonalDipyramid < Die
        # This constant controls how much the vertexes of the pyramids protrude from the base. A value of 0 means they
        # don't protrude at all (it reduces this shape to a octagon), and a value of 1 makes the height of the pyramids
        # equal to their side lengths. Setting it to 'Math.sqrt(5 + 3.5 * Math.sqrt(2))' produces a standard octagonal
        # dipyramid. It is impossible for the faces of a octagonal dipyramid to be equalateral triangles.
        VERTEX_SCALE = Math.sqrt(5 + 3.5 * Math.sqrt(2))

        # Lays out the geometry for the die in a new ComponentDefinition and adds it to the main DefinitionList.
        def initialize()
            # Create a new definition for the die.
            definition = Util::MAIN_MODEL.definitions.add(self.class.name)
            mesh = definition.entities()

            c0 = 0.0
            c1 = 1.0
            c2 = Math.sqrt(2.0)
            c3 = Math.sqrt(4.0 - 2.0 * Math.sqrt(2.0)) * VERTEX_SCALE
            # Define all the points that make up the vertices of the die.
            v0 = Geom::Point3d::new( c0,  c0,  c3)
            v1 = Geom::Point3d::new( c0,  c0, -c3)
            v2 = Geom::Point3d::new( c2,  c0,  c0)
            v3 = Geom::Point3d::new(-c2,  c0,  c0)
            v4 = Geom::Point3d::new( c0,  c2,  c0)
            v5 = Geom::Point3d::new( c0, -c2,  c0)
            v6 = Geom::Point3d::new( c1,  c1,  c0)
            v7 = Geom::Point3d::new( c1, -c1,  c0)
            v8 = Geom::Point3d::new(-c1,  c1,  c0)
            v9 = Geom::Point3d::new(-c1, -c1,  c0)

            # Create the faces of the die by joining the vertices with edges. #TODO FIX THIS
            faces = Array::new(16)
            faces[0]  = mesh.add_face([v0, v2, v6])
            faces[1]  = mesh.add_face([v0, v6, v4])
            faces[2]  = mesh.add_face([v0, v4, v8])
            faces[3]  = mesh.add_face([v0, v8, v3])
            faces[4]  = mesh.add_face([v0, v3, v9])
            faces[5]  = mesh.add_face([v0, v9, v5])
            faces[6]  = mesh.add_face([v0, v5, v7])
            faces[7]  = mesh.add_face([v0, v7, v2])
            faces[8]  = mesh.add_face([v1, v2, v7])
            faces[9]  = mesh.add_face([v1, v7, v5])
            faces[10] = mesh.add_face([v1, v5, v9])
            faces[11] = mesh.add_face([v1, v9, v3])
            faces[12] = mesh.add_face([v1, v3, v8])
            faces[13] = mesh.add_face([v1, v8, v4])
            faces[14] = mesh.add_face([v1, v4, v6])
            faces[15] = mesh.add_face([v1, v6, v2])

            #TODO MAKE THE SCALES!
            super(definition: definition, faces: faces)
        end
    end
end
