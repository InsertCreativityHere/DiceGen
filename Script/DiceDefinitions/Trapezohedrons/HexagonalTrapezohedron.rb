
module DiceGen::Dice
    # This class defines the mesh model for a hexagonal trapezohedron (non-standard D12).
    class HexagonalTrapezohedron < DieModel
        # Lays out the geometry for the die in a new ComponentDefinition and adds it to the main DefinitionList.
        #   def_name: The name of this definition. Every ComponentDefinition can be referenced with a unique name that
        #             is computed by appending this value to the name of the die model (separated by an underscore).
        #   vertex_scale: This value controls how much the vertexes of the trapezohedron protrude from the midline. A
        #                 value of 0 means they don't protrude at all (it reduces this shape to a dodecagon), and a
        #                 value of 1 produces a standard hexagonal trapezohedron.
        def initialize(def_name:, vertex_scale:)
            # Create a new definition for the die.
            definition = Util::MAIN_MODEL.definitions.add("#{self.class.name}_#{def_name}")
            mesh = definition.entities()

            c0 = 0.0
            c1 = 1.0
            c2 = 0.5
            c3 = Math.sqrt(3.0) / 2.0
            c4 = (Math.sqrt(2.0 * ( 3.0 * Math.sqrt(3.0) -  5.0)) / 4.0) * vertex_scale
            c5 = (Math.sqrt(2.0 * (11.0 * Math.sqrt(3.0) + 19.0)) / 4.0) * vertex_scale
            # Define all the points that make up the vertices of the die.
            v0  = Geom::Point3d::new( c0,  c0,  c5)
            v1  = Geom::Point3d::new( c0,  c0, -c5)
            v2  = Geom::Point3d::new( c0,  c1,  c4)
            v3  = Geom::Point3d::new( c0, -c1,  c4)
            v4  = Geom::Point3d::new( c1,  c0, -c4)
            v5  = Geom::Point3d::new(-c1,  c0, -c4)
            v6  = Geom::Point3d::new( c3,  c2,  c4)
            v7  = Geom::Point3d::new( c3, -c2,  c4)
            v8  = Geom::Point3d::new(-c3,  c2,  c4)
            v9  = Geom::Point3d::new(-c3, -c2,  c4)
            v10 = Geom::Point3d::new( c2,  c3, -c4)
            v11 = Geom::Point3d::new( c2, -c3, -c4)
            v12 = Geom::Point3d::new(-c2,  c3, -c4)
            v13 = Geom::Point3d::new(-c2, -c3, -c4)

            # Create the faces of the die by joining the vertices with edges. #TODO FIX THIS
            faces = Array::new(12)
            faces[0] = mesh.add_face([v0,  v2, v12,  v8])
            faces[1] = mesh.add_face([v0,  v8,  v5,  v9])
            faces[2] = mesh.add_face([v0,  v9, v13,  v3])
            faces[3] = mesh.add_face([v0,  v3, v11,  v7])
            faces[4] = mesh.add_face([v0,  v7,  v4,  v6])
            faces[5] = mesh.add_face([v0,  v6, v10,  v2])
            faces[6] = mesh.add_face([v1,  v4,  v7, v11])
            faces[7] = mesh.add_face([v1, v11,  v3, v13])
            faces[8] = mesh.add_face([v1, v13,  v9,  v5])
            faces[9] = mesh.add_face([v1,  v5,  v8, v12])
            faces[10] = mesh.add_face([v1, v12,  v2, v10])
            faces[11] = mesh.add_face([v1, v10,  v6,  v4])

            #TODO MAKE THE SCALES!
            super(definition: definition, faces: faces)
        end

        # A hexagonal trapezohedron with standard dimensions.
        STANDARD = HexagonalTrapezohedron::new(def_name: "Standard", vertex_scale: 1.0)
        # A hexagonal trapezohedron that has been flattened into a dodecagon.
        FLAT = HexagonalTrapezohedron::new(def_name: "Flat", vertex_scale: 0.0)

    end
end
