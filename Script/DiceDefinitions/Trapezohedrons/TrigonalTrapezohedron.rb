
module DiceGen::Dice
    # This class defines the mesh model for a trigonal trapezohedron (non-standard D6).
    class TrigonalTrapezohedron < Die
        # This constant controls how much the vertexes of the trapezohedrons protrude from the midline. A value of 0
        # means they don't protrude at all (it reduces this shape to a hexagon), and a value of 1 makes the height of
        # the trapezohedrons (from the midline) equal to the horizontal axis of the trapezoids. Setting it to
        # 'TODO' produces a standard trigonal trapezohedron.
        VERTEX_SCALE = 1.0

        # Lays out the geometry for the die in a new ComponentDefinition and adds it to the main DefinitionList.
        def initialize()
            # Create a new definition for the die.
            definition = Util::MAIN_MODEL.definitions.add(self.class.name)
            mesh = definition.entities()

            c0 = Math.sqrt(2.0) / 4.0
            # Define all the points that make up the vertices of the die.
            v0 = Geom::Point3d::new( c0,  c0,  c0)
            v1 = Geom::Point3d::new( c0,  c0, -c0)
            v2 = Geom::Point3d::new( c0, -c0,  c0)
            v3 = Geom::Point3d::new( c0, -c0, -c0)
            v4 = Geom::Point3d::new(-c0,  c0,  c0)
            v5 = Geom::Point3d::new(-c0,  c0, -c0)
            v6 = Geom::Point3d::new(-c0, -c0,  c0)
            v7 = Geom::Point3d::new(-c0, -c0, -c0)

            # Create the faces of the die by joining the vertices with edges. #TODO FIX THIS
            faces = Array::new(6)
            faces[0] = mesh.add_face([v0, v1, v5, v4])
            faces[1] = mesh.add_face([v0, v4, v6, v2])
            faces[2] = mesh.add_face([v0, v2, v3, v1])
            faces[3] = mesh.add_face([v7, v3, v2, v6])
            faces[4] = mesh.add_face([v7, v6, v4, v5])
            faces[5] = mesh.add_face([v7, v5, v1, v3])

            #TODO MAKE THE SCALES!
            super(definition: definition, faces: faces)
        end
    end
end
