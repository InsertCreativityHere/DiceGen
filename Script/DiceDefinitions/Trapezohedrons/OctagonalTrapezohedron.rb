
module DiceGen::Dice
    # This class defines the mesh model for an octagonal trapezohedron (non-standard D16).
    class OctagonalTrapezohedron < DieModel
        # Lays out the geometry for the die in a new ComponentDefinition and adds it to the main DefinitionList.
        #   def_name: The name of this definition. Every ComponentDefinition can be referenced with a unique name that
        #             is computed by appending this value to the name of the die model (separated by an underscore).
        #   vertex_scale: This value controls how much the vertexes of the trapezohedron protrude from the midline. A
        #                 value of 0 means they don't protrude at all (it reduces this shape to a hexadecagon), and a
        #                 value of 1 produces a standard octagonal trapezohedron.
        def initialize(def_name:, vertex_scale:)
            # Create a new definition for the die.
            definition = Util::MAIN_MODEL.definitions.add("#{self.class.name}_#{def_name}")
            mesh = definition.entities()

            ca = Math.sqrt(2.0)
            c0 = 0.0
            c1 = Math.sqrt(2.0 * (2.0 + ca)) / 2.0
            c2 = Math.sqrt(      (2.0 + ca)) / 2.0
            c3 =                 (1.0 + ca)  / 2.0
            c4 = 0.5
            c5 = (Math.sqrt(2.0 *  (3.0 * Math.sqrt(2.0 *           (2.0 + ca)) -  2.0 -  4.0 * ca)) / 4.0) * vertex_scale
            c6 = (Math.sqrt(2.0 *  (      Math.sqrt(2.0 * (850.0 + 601.0 * ca)) + 30.0 + 20.0 * ca)) / 4.0) * vertex_scale
            # Define all the points that make up the vertices of the die.
            v0  = Geom::Point3d::new( c0,  c0,  c6)
            v1  = Geom::Point3d::new( c0,  c0, -c6)
            v2  = Geom::Point3d::new( c1,  c0,  c5)
            v3  = Geom::Point3d::new(-c1,  c0,  c5)
            v4  = Geom::Point3d::new( c0,  c1,  c5)
            v5  = Geom::Point3d::new( c0, -c1,  c5)
            v6  = Geom::Point3d::new( c2,  c2,  c5)
            v7  = Geom::Point3d::new( c2, -c2,  c5)
            v8  = Geom::Point3d::new(-c2,  c2,  c5)
            v9  = Geom::Point3d::new(-c2, -c2,  c5)
            v10 = Geom::Point3d::new( c3,  c4, -c5)
            v11 = Geom::Point3d::new( c3, -c4, -c5)
            v12 = Geom::Point3d::new(-c3,  c4, -c5)
            v13 = Geom::Point3d::new(-c3, -c4, -c5)
            v14 = Geom::Point3d::new( c4,  c3, -c5)
            v15 = Geom::Point3d::new( c4, -c3, -c5)
            v16 = Geom::Point3d::new(-c4,  c3, -c5)
            v17 = Geom::Point3d::new(-c4, -c3, -c5)

            # Create the faces of the die by joining the vertices with edges. #TODO FIX THIS
            faces = Array::new(16)
            faces[0]  = mesh.add_face([v0,  v2, v10,  v6])
            faces[1]  = mesh.add_face([v0,  v6, v14,  v4])
            faces[2]  = mesh.add_face([v0,  v4, v16,  v8])
            faces[3]  = mesh.add_face([v0,  v8, v12,  v3])
            faces[4]  = mesh.add_face([v0,  v3, v13,  v9])
            faces[5]  = mesh.add_face([v0,  v9, v17,  v5])
            faces[6]  = mesh.add_face([v0,  v5, v15,  v7])
            faces[7]  = mesh.add_face([v0,  v7, v11,  v2])
            faces[8]  = mesh.add_face([v1, v10,  v2, v11])
            faces[9]  = mesh.add_face([v1, v11,  v7, v15])
            faces[10] = mesh.add_face([v1, v15,  v5, v17])
            faces[11] = mesh.add_face([v1, v17,  v9, v13])
            faces[12] = mesh.add_face([v1, v13,  v3, v12])
            faces[13] = mesh.add_face([v1, v12,  v8, v16])
            faces[14] = mesh.add_face([v1, v16,  v4, v14])
            faces[15] = mesh.add_face([v1, v14,  v6, v10])

            #TODO MAKE THE SCALES!
            super(die_size: 1.0, die_scale: 1.0, font_size: 1.0, definition: definition, faces: faces)
        end

        # A octagonal trapezohedron with standard dimensions.
        STANDARD = OctagonalTrapezohedron::new(def_name: "Standard", vertex_scale: 1.0)
        # A octagonal trapezohedron that has been flattened into a hexadecagon.
        FLAT = OctagonalTrapezohedron::new(def_name: "Flat", vertex_scale: 0.0)

    end
end
