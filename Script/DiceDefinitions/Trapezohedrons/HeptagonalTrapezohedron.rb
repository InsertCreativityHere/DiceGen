
module DiceGen::Dice
    # This class defines the mesh model for a heptagonal trapezohedron (non-standard D14).
    class HeptagonalTrapezohedron < DieModel
        # Lays out the geometry for the die in a new ComponentDefinition and adds it to the main DefinitionList.
        #   def_name: The name of this definition. Every ComponentDefinition can be referenced with a unique name that
        #             is computed by appending this value to the name of the die model (separated by an underscore).
        #   vertex_scale: This value controls how much the vertexes of the trapezohedron protrude from the midline. A
        #                 value of 0 means they don't protrude at all (it reduces this shape to a tetradecagon), and a
        #                 value of 1 produces a standard heptagonal trapezohedron.
        def initialize(def_name:, vertex_scale:)
            # Create a new definition for the die.
            definition = Util::MAIN_MODEL.definitions.add("#{self.class.name}_#{def_name}")
            mesh = definition.entities()

            ca = Math.sin(Math::PI /  7.0)
            cb = Math.cos(Math::PI /  7.0)
            cc = Math.sin(Math::PI / 14.0)
            cd = Math.cos(Math::PI / 14.0)
            c0 = 0.0
            c1 = 1.0 / (4.0 * cc)
            c2 = 1.0 / (4.0 * cd)
            c3 =  cb
            c4 = (1.0 + cb) / Math.sqrt(7.0)
            c5 = 0.5
            c6 =  cb / (2.0 * ca)
            c7 = 1.0 / (2.0 * ca)
            c8 = Math.sqrt( (16.0 * (cb * cb) + 7.0 * cb - 2.0) /  2.0) * vertex_scale
            c9 = Math.sqrt(-(18.0 * (cc * cc) + 8.0 * cc - 3.0) / 14.0) * vertex_scale
            # Define all the points that make up the vertices of the die.
            v0  = Geom::Point3d::new( c0,  c0,  c8)
            v1  = Geom::Point3d::new( c0,  c0, -c8)
            v2  = Geom::Point3d::new( c1,  c2,  c9)
            v3  = Geom::Point3d::new( c1, -c2, -c9)
            v4  = Geom::Point3d::new(-c1,  c2,  c9)
            v5  = Geom::Point3d::new(-c1, -c2, -c9)
            v6  = Geom::Point3d::new( c3, -c4,  c9)
            v7  = Geom::Point3d::new( c3,  c4, -c9)
            v8  = Geom::Point3d::new(-c3, -c4,  c9)
            v9  = Geom::Point3d::new(-c3,  c4, -c9)
            v10 = Geom::Point3d::new( c5,  c6,  c9)
            v11 = Geom::Point3d::new( c5, -c6, -c9)
            v12 = Geom::Point3d::new(-c5,  c6,  c9)
            v13 = Geom::Point3d::new(-c5, -c6, -c9)
            v14 = Geom::Point3d::new( c0, -c7,  c9)
            v15 = Geom::Point3d::new( c0,  c7, -c9)

            # Create the faces of the die by joining the vertices with edges. #TODO FIX THIS
            faces = Array::new(14)
            faces[0]  = mesh.add_face([v0,  v2,  v7, v10])
            faces[1]  = mesh.add_face([v0, v10, v15, v12])
            faces[2]  = mesh.add_face([v0, v12,  v9,  v4])
            faces[3]  = mesh.add_face([v0,  v4,  v5,  v8])
            faces[4]  = mesh.add_face([v0,  v8, v13, v14])
            faces[5]  = mesh.add_face([v0, v14, v11,  v6])
            faces[6]  = mesh.add_face([v0,  v6,  v3,  v2])
            faces[7]  = mesh.add_face([v1,  v3,  v6, v11])
            faces[8]  = mesh.add_face([v1, v11, v14, v13])
            faces[9]  = mesh.add_face([v1, v13,  v8,  v5])
            faces[10] = mesh.add_face([v1,  v5,  v4,  v9])
            faces[11] = mesh.add_face([v1,  v9, v12, v15])
            faces[12] = mesh.add_face([v1, v15, v10,  v7])
            faces[13] = mesh.add_face([v1,  v7,  v2,  v3])

            #TODO MAKE THE SCALES!
            super(die_size: 1.0, die_scale: 1.0, font_size: 1.0, definition: definition, faces: faces)
        end

        # A heptagonal trapezohedron with standard dimensions.
        STANDARD = HeptagonalTrapezohedron::new(def_name: "Standard", vertex_scale: 1.0)
        # A heptagonal trapezohedron that has been flattened into a tetradecagon.
        FLAT = HeptagonalTrapezohedron::new(def_name: "Flat", vertex_scale: 0.0)

    end
end
