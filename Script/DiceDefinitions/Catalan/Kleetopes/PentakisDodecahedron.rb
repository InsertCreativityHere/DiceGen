
module DiceGen::Dice
    # This class defines the mesh model for a pentakis dodecahedron (non-standard D60).
    class PentakisDodecahedron < DieModel
        # Lays out the geometry for the die in a new ComponentDefinition and adds it to the main DefinitionList.
        #   def_name: The name of this definition. Every ComponentDefinition can be referenced with a unique name that
        #             is computed by appending this value to the name of the die model (separated by an underscore).
        #   kleepoint_scale: This value controls how much the pentakis points protrude from the dodecahedral faces. A
        #                    value of 0 means they don't protrude at all (it reduces this shape to a dodecahedron), and
        #                    a value of 1 expands this shape into a rhombic triacontahedron.
        def initialize(def_name:, kleepoint_scale:)
            # Create a new definition for the die.
            definition = Util::MAIN_MODEL.definitions.add("#{self.class.name}_#{def_name}")
            mesh = definition.entities()

            ca = Math.sqrt(5.0)
            cb = ((20 + 2 * ca) + kleepoint_scale * (25 - 7 * ca)) / 30
            c0 = 0.0
            c1 = 1.5
            c2 =  (3.0  * ca +  3.0) /  4.0
            c3 =  (3.0  * ca -  3.0) /  4.0
            c4 = ((9.0  * ca + 81.0) / 76.0) * cb
            c5 = ((45.0 * ca + 63.0) / 76.0) * cb

            # Define all the points that make up the vertices of the die.
            v0  = Geom::Point3d::new( c0,  c3,  c2)
            v1  = Geom::Point3d::new( c0,  c3, -c2)
            v2  = Geom::Point3d::new( c0, -c3,  c2)
            v3  = Geom::Point3d::new( c0, -c3, -c2)
            v4  = Geom::Point3d::new( c2,  c0,  c3)
            v5  = Geom::Point3d::new( c2,  c0, -c3)
            v6  = Geom::Point3d::new(-c2,  c0,  c3)
            v7  = Geom::Point3d::new(-c2,  c0, -c3)
            v8  = Geom::Point3d::new( c3,  c2,  c0)
            v9  = Geom::Point3d::new( c3, -c2,  c0)
            v10 = Geom::Point3d::new(-c3,  c2,  c0)
            v11 = Geom::Point3d::new(-c3, -c2,  c0)
            v12 = Geom::Point3d::new( c0,  c5,  c4)
            v13 = Geom::Point3d::new( c0,  c5, -c4)
            v14 = Geom::Point3d::new( c0, -c5,  c4)
            v15 = Geom::Point3d::new( c0, -c5, -c4)
            v16 = Geom::Point3d::new( c4,  c0,  c5)
            v17 = Geom::Point3d::new( c4,  c0, -c5)
            v18 = Geom::Point3d::new(-c4,  c0,  c5)
            v19 = Geom::Point3d::new(-c4,  c0, -c5)
            v20 = Geom::Point3d::new( c5,  c4,  c0)
            v21 = Geom::Point3d::new( c5, -c4,  c0)
            v22 = Geom::Point3d::new(-c5,  c4,  c0)
            v23 = Geom::Point3d::new(-c5, -c4,  c0)
            v24 = Geom::Point3d::new( c1,  c1,  c1)
            v25 = Geom::Point3d::new( c1,  c1, -c1)
            v26 = Geom::Point3d::new( c1, -c1,  c1)
            v27 = Geom::Point3d::new( c1, -c1, -c1)
            v28 = Geom::Point3d::new(-c1,  c1,  c1)
            v29 = Geom::Point3d::new(-c1,  c1, -c1)
            v30 = Geom::Point3d::new(-c1, -c1,  c1)
            v31 = Geom::Point3d::new(-c1, -c1, -c1)

            # Create the faces of the die by joining the vertices with edges. #TODO FIX THIS
            faces = Array::new(60)
            faces[0]  = mesh.add_face([v16,  v0,  v2])
            faces[1]  = mesh.add_face([v16,  v2, v26])
            faces[2]  = mesh.add_face([v16, v26,  v4])
            faces[3]  = mesh.add_face([v16,  v4, v24])
            faces[4]  = mesh.add_face([v16, v24,  v0])
            faces[5]  = mesh.add_face([v17,  v3,  v1])
            faces[6]  = mesh.add_face([v17,  v1, v25])
            faces[7]  = mesh.add_face([v17, v25,  v5])
            faces[8]  = mesh.add_face([v17,  v5, v27])
            faces[9]  = mesh.add_face([v17, v27,  v3])
            faces[10] = mesh.add_face([v18,  v2,  v0])
            faces[11] = mesh.add_face([v18,  v0, v28])
            faces[12] = mesh.add_face([v18, v28,  v6])
            faces[13] = mesh.add_face([v18,  v6, v30])
            faces[14] = mesh.add_face([v18, v30,  v2])
            faces[15] = mesh.add_face([v19,  v1,  v3])
            faces[16] = mesh.add_face([v19,  v3, v31])
            faces[17] = mesh.add_face([v19, v31,  v7])
            faces[18] = mesh.add_face([v19,  v7, v29])
            faces[19] = mesh.add_face([v19, v29,  v1])
            faces[20] = mesh.add_face([v20,  v4,  v5])
            faces[21] = mesh.add_face([v20,  v5, v25])
            faces[22] = mesh.add_face([v20, v25,  v8])
            faces[23] = mesh.add_face([v20,  v8, v24])
            faces[24] = mesh.add_face([v20, v24,  v4])
            faces[25] = mesh.add_face([v21,  v5,  v4])
            faces[26] = mesh.add_face([v21,  v4, v26])
            faces[27] = mesh.add_face([v21, v26,  v9])
            faces[28] = mesh.add_face([v21,  v9, v27])
            faces[29] = mesh.add_face([v21, v27,  v5])
            faces[30] = mesh.add_face([v22,  v7,  v6])
            faces[31] = mesh.add_face([v22,  v6, v28])
            faces[32] = mesh.add_face([v22, v28, v10])
            faces[33] = mesh.add_face([v22, v10, v29])
            faces[34] = mesh.add_face([v22, v29,  v7])
            faces[35] = mesh.add_face([v23,  v6,  v7])
            faces[36] = mesh.add_face([v23,  v7, v31])
            faces[37] = mesh.add_face([v23, v31, v11])
            faces[38] = mesh.add_face([v23, v11, v30])
            faces[39] = mesh.add_face([v23, v30,  v6])
            faces[40] = mesh.add_face([v12,  v8, v10])
            faces[41] = mesh.add_face([v12, v10, v28])
            faces[42] = mesh.add_face([v12, v28,  v0])
            faces[43] = mesh.add_face([v12,  v0, v24])
            faces[44] = mesh.add_face([v12, v24,  v8])
            faces[45] = mesh.add_face([v13, v10,  v8])
            faces[46] = mesh.add_face([v13,  v8, v25])
            faces[47] = mesh.add_face([v13, v25,  v1])
            faces[48] = mesh.add_face([v13,  v1, v29])
            faces[49] = mesh.add_face([v13, v29, v10])
            faces[50] = mesh.add_face([v14, v11,  v9])
            faces[51] = mesh.add_face([v14,  v9, v26])
            faces[52] = mesh.add_face([v14, v26,  v2])
            faces[53] = mesh.add_face([v14,  v2, v30])
            faces[54] = mesh.add_face([v14, v30, v11])
            faces[55] = mesh.add_face([v15,  v9, v11])
            faces[56] = mesh.add_face([v15, v11, v31])
            faces[57] = mesh.add_face([v15, v31,  v3])
            faces[58] = mesh.add_face([v15,  v3, v27])
            faces[59] = mesh.add_face([v15, v27,  v9])

            #TODO MAKE THE SCALES!
            super(definition: definition, faces: faces)
        end
    end

    # A pentakis dodecahedron with standard dimensions.
    STANDARD = PentakisDodecahedron::new(def_name: "Standard", kleepoint_scale: ((9.0 + Math.sqrt(5.0)) / 19.0)))
    # A pentakis dodecahedron that has been reduced into a dodecahedron.
    REDUCED = PentakisDodecahedron::new(def_name: "Reduced", kleepoint_scale: 0.0)
    # A pentakis dodecahedron that has been expanded into a rhombic triacontahedron.
    EXPANDED = PentakisDodecahedron::new(def_name: "Expanded", kleepoint_scale: 1.0)

end
