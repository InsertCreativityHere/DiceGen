
module DiceGen::Dice
    # This class defines the mesh model for a triangular dipyramid (non-standard D6).
    class TriangularDipyramid < Die
        # This constant controls how much the vertexes of the pyramids protrude from the base. A value of 0 means they
        # don't protrude at all (it reduces this shape to a triangle), and a value of 1 makes the faces equalateral
        # triangles. Setting it to '1.0 / Math.sqrt(6.0)' produces a standard triangular dipyramid.
        VERTEX_SCALE = 1.0 / Math.sqrt(6.0)

        # Lays out the geometry for the die in a new ComponentDefinition and adds it to the main DefinitionList.
        def initialize()
            # Create a new definition for the die.
            definition = Util::MAIN_MODEL.definitions.add(self.class.name)
            mesh = definition.entities()

            c0 = 0.0
            c1 = 1.0
            c2 =        Math.sqrt(3.0) / 3.0
            c3 = (2.0 * Math.sqrt(6.0) / 3.0) * VERTEX_SCALE
            c4 =  2.0 * Math.sqrt(3.0) / 3.0
            # Define all the points that make up the vertices of the die.
            v0 = Geom::Point3d::new( c0,  c0,  c3)
            v1 = Geom::Point3d::new( c0,  c0, -c3)
            v2 = Geom::Point3d::new( c1,  c2,  c0)
            v3 = Geom::Point3d::new(-c1,  c2,  c0)
            v4 = Geom::Point3d::new( c0, -c4,  c0)

            # Create the faces of the die by joining the vertices with edges. #TODO FIX THIS
            faces = Array::new(6)
            faces[0] = mesh.add_face([v0, v2, v3])
            faces[1] = mesh.add_face([v0, v3, v4])
            faces[2] = mesh.add_face([v0, v4, v2])
            faces[3] = mesh.add_face([v1, v2, v4])
            faces[4] = mesh.add_face([v1, v4, v3])
            faces[5] = mesh.add_face([v1, v3, v2])

            #TODO MAKE THE SCALES!
            super(definition: definition, faces: faces)
        end
    end
end
