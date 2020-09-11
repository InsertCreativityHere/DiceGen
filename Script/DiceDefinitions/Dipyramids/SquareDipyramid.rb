
module DiceGen::Dice
    # This class defines the mesh model for a square dipyramid (non-standard D8).
    # Technically this shape is just a scaled version of the octahedron, so this is capable of being a standard die,
    # but since this doesn't necessarily have to contain equalateral triangles, it's kept as a separate solid.
    class SquareDipyramid < Die
        # This constant controls how much the vertexes of the pyramids protrude from the base. A value of 0 means they
        # don't protrude at all (it reduces this shape to a square), and a value of 1 makes the height of the pyramids
        # equal to their side lengths. Setting it to '1.0 / Math.sqrt(2.0)' produces a standard square dipyramid,
        # with all it's faces being equalateral triangles, consequently making the solid into an octohedron.
        VERTEX_SCALE = 1.0 / Math.sqrt(2.0)

        # Lays out the geometry for the die in a new ComponentDefinition and adds it to the main DefinitionList.
        def initialize()
            # Create a new definition for the die.
            definition = Util::MAIN_MODEL.definitions.add(self.class.name)
            mesh = definition.entities()

            c0 = 0.0
            c1 = 1.0
            c2 = Math.sqrt(2.0) * VERTEX_SCALE
            # Define all the points that make up the vertices of the die.
            v0 = Geom::Point3d::new( c1,  c0,  c0)
            v1 = Geom::Point3d::new(-c1,  c0,  c0)
            v2 = Geom::Point3d::new( c0,  c1,  c0)
            v3 = Geom::Point3d::new( c0, -c1,  c0)
            v4 = Geom::Point3d::new( c0,  c0,  c2)
            v5 = Geom::Point3d::new( c0,  c0, -c2)

            # Create the faces of the die by joining the vertices with edges. #TODO FIX THIS
            faces = Array::new(8)
            faces[0] = mesh.add_face([v4, v0, v2])
            faces[1] = mesh.add_face([v4, v2, v1])
            faces[2] = mesh.add_face([v4, v1, v3])
            faces[3] = mesh.add_face([v4, v3, v0])
            faces[4] = mesh.add_face([v5, v0, v3])
            faces[5] = mesh.add_face([v5, v3, v1])
            faces[6] = mesh.add_face([v5, v1, v2])
            faces[7] = mesh.add_face([v5, v2, v0])

            #TODO MAKE THE SCALES!
            super(definition: definition, faces: faces)
        end
    end
end
