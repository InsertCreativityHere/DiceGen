
module DiceGen
module Dice
module Definitions

    # This class defines the mesh model for a deltoidal hexecontahedron (non-standard D60).
    class DeltoidalHexecontahedron < DieModel
        # Lays out the geometry for the die in a new ComponentDefinition and adds it to the main DefinitionList.
        #   def_name: The name of this definition. Every ComponentDefinition can be referenced with a unique name that
        #             is computed by appending this value to the name of the die model (separated by an underscore).
        def initialize(def_name:)
            # Create a new definition for the die.
            definition = $MAIN_MODEL.definitions.add("#{self.class.name}_#{def_name}")
            mesh = definition.entities()

            c0 = 0.0
            c1 = Math.sqrt(5.0)
            c2 = (5.0 - Math.sqrt(5.0)) / 4.0
            c3 =        Math.sqrt(5.0)  / 2.0
            c4 = (5.0 + Math.sqrt(5.0)) / 4.0
            c5 = (15.0 +       Math.sqrt(5.0)) / 22.0
            c6 = (25.0 + 9.0 * Math.sqrt(5.0)) / 22.0
            c7 = ( 5.0 +       Math.sqrt(5.0)) / 6.0
            c8 = ( 5.0 + 3.0 * Math.sqrt(5.0)) / 6.0
            c9 = ( 5.0 + 4.0 * Math.sqrt(5.0)) / 11.0
            # Define all the points that make up the vertices of the die.
            v0  = Geom::Point3d::new( c0,  c0,  c1)
            v1  = Geom::Point3d::new( c0,  c0, -c1)
            v2  = Geom::Point3d::new( c1,  c0,  c0)
            v3  = Geom::Point3d::new(-c1,  c0,  c0)
            v4  = Geom::Point3d::new( c0,  c1,  c0)
            v5  = Geom::Point3d::new( c0, -c1,  c0)
            v6  = Geom::Point3d::new( c2,  c3,  c4)
            v7  = Geom::Point3d::new( c2,  c3, -c4)
            v8  = Geom::Point3d::new( c2, -c3,  c4)
            v9  = Geom::Point3d::new( c2, -c3, -c4)
            v10 = Geom::Point3d::new(-c2,  c3,  c4)
            v11 = Geom::Point3d::new(-c2,  c3, -c4)
            v12 = Geom::Point3d::new(-c2, -c3,  c4)
            v13 = Geom::Point3d::new(-c2, -c3, -c4)
            v14 = Geom::Point3d::new( c4,  c2,  c3)
            v15 = Geom::Point3d::new( c4,  c2, -c3)
            v16 = Geom::Point3d::new( c4, -c2,  c3)
            v17 = Geom::Point3d::new( c4, -c2, -c3)
            v18 = Geom::Point3d::new(-c4,  c2,  c3)
            v19 = Geom::Point3d::new(-c4,  c2, -c3)
            v20 = Geom::Point3d::new(-c4, -c2,  c3)
            v21 = Geom::Point3d::new(-c4, -c2, -c3)
            v22 = Geom::Point3d::new( c3,  c4,  c2)
            v23 = Geom::Point3d::new( c3,  c4, -c2)
            v24 = Geom::Point3d::new( c3, -c4,  c2)
            v25 = Geom::Point3d::new( c3, -c4, -c2)
            v26 = Geom::Point3d::new(-c3,  c4,  c2)
            v27 = Geom::Point3d::new(-c3,  c4, -c2)
            v28 = Geom::Point3d::new(-c3, -c4,  c2)
            v29 = Geom::Point3d::new(-c3, -c4, -c2)
            v30 = Geom::Point3d::new( c0,  c5,  c6)
            v31 = Geom::Point3d::new( c0,  c5, -c6)
            v32 = Geom::Point3d::new( c0, -c5,  c6)
            v33 = Geom::Point3d::new( c0, -c5, -c6)
            v34 = Geom::Point3d::new( c6,  c0,  c5)
            v35 = Geom::Point3d::new( c6,  c0, -c5)
            v36 = Geom::Point3d::new(-c6,  c0,  c5)
            v37 = Geom::Point3d::new(-c6,  c0, -c5)
            v38 = Geom::Point3d::new( c5,  c6,  c0)
            v39 = Geom::Point3d::new( c5, -c6,  c0)
            v40 = Geom::Point3d::new(-c5,  c6,  c0)
            v41 = Geom::Point3d::new(-c5, -c6,  c0)
            v42 = Geom::Point3d::new( c7,  c0,  c8)
            v43 = Geom::Point3d::new( c7,  c0, -c8)
            v44 = Geom::Point3d::new(-c7,  c0,  c8)
            v45 = Geom::Point3d::new(-c7,  c0, -c8)
            v46 = Geom::Point3d::new( c8,  c7,  c0)
            v47 = Geom::Point3d::new( c8, -c7,  c0)
            v48 = Geom::Point3d::new(-c8,  c7,  c0)
            v49 = Geom::Point3d::new(-c8, -c7,  c0)
            v50 = Geom::Point3d::new( c0,  c8,  c7)
            v51 = Geom::Point3d::new( c0,  c8, -c7)
            v52 = Geom::Point3d::new( c0, -c8,  c7)
            v53 = Geom::Point3d::new( c0, -c8, -c7)
            v54 = Geom::Point3d::new( c9,  c9,  c9)
            v55 = Geom::Point3d::new( c9,  c9, -c9)
            v56 = Geom::Point3d::new( c9, -c9,  c9)
            v57 = Geom::Point3d::new( c9, -c9, -c9)
            v58 = Geom::Point3d::new(-c9,  c9,  c9)
            v59 = Geom::Point3d::new(-c9,  c9, -c9)
            v60 = Geom::Point3d::new(-c9, -c9,  c9)
            v61 = Geom::Point3d::new(-c9, -c9, -c9)

            # Create the faces of the die by joining the vertices with edges. #TODO FIX THIS
            faces = Array::new(60)
            faces[0]  = mesh.add_face([v42,  v0, v32,  v8])
            faces[1]  = mesh.add_face([v42,  v8, v56, v16])
            faces[2]  = mesh.add_face([v42, v16, v34, v14])
            faces[3]  = mesh.add_face([v42, v14, v54,  v6])
            faces[4]  = mesh.add_face([v42,  v6, v30,  v0])
            faces[5]  = mesh.add_face([v43,  v1, v31,  v7])
            faces[6]  = mesh.add_face([v43,  v7, v55, v15])
            faces[7]  = mesh.add_face([v43, v15, v35, v17])
            faces[8]  = mesh.add_face([v43, v17, v57,  v9])
            faces[9]  = mesh.add_face([v43,  v9, v33,  v1])
            faces[10] = mesh.add_face([v44,  v0, v30, v10])
            faces[11] = mesh.add_face([v44, v10, v58, v18])
            faces[12] = mesh.add_face([v44, v18, v36, v20])
            faces[13] = mesh.add_face([v44, v20, v60, v12])
            faces[14] = mesh.add_face([v44, v12, v32,  v0])
            faces[15] = mesh.add_face([v45,  v1, v33, v13])
            faces[16] = mesh.add_face([v45, v13, v61, v21])
            faces[17] = mesh.add_face([v45, v21, v37, v19])
            faces[18] = mesh.add_face([v45, v19, v59, v11])
            faces[19] = mesh.add_face([v45, v11, v31,  v1])
            faces[20] = mesh.add_face([v46,  v2, v35, v15])
            faces[21] = mesh.add_face([v46, v15, v55, v23])
            faces[22] = mesh.add_face([v46, v23, v38, v22])
            faces[23] = mesh.add_face([v46, v22, v54, v14])
            faces[24] = mesh.add_face([v46, v14, v34,  v2])
            faces[25] = mesh.add_face([v47,  v2, v34, v16])
            faces[26] = mesh.add_face([v47, v16, v56, v24])
            faces[27] = mesh.add_face([v47, v24, v39, v25])
            faces[28] = mesh.add_face([v47, v25, v57, v17])
            faces[29] = mesh.add_face([v47, v17, v35,  v2])
            faces[30] = mesh.add_face([v48,  v3, v36, v18])
            faces[31] = mesh.add_face([v48, v18, v58, v26])
            faces[32] = mesh.add_face([v48, v26, v40, v27])
            faces[33] = mesh.add_face([v48, v27, v59, v19])
            faces[34] = mesh.add_face([v48, v19, v37,  v3])
            faces[35] = mesh.add_face([v49,  v3, v37, v21])
            faces[36] = mesh.add_face([v49, v21, v61, v29])
            faces[37] = mesh.add_face([v49, v29, v41, v28])
            faces[38] = mesh.add_face([v49, v28, v60, v20])
            faces[39] = mesh.add_face([v49, v20, v36,  v3])
            faces[40] = mesh.add_face([v50,  v4, v40, v26])
            faces[41] = mesh.add_face([v50, v26, v58, v10])
            faces[42] = mesh.add_face([v50, v10, v30,  v6])
            faces[43] = mesh.add_face([v50,  v6, v54, v22])
            faces[44] = mesh.add_face([v50, v22, v38,  v4])
            faces[45] = mesh.add_face([v51,  v4, v38, v23])
            faces[46] = mesh.add_face([v51, v23, v55,  v7])
            faces[47] = mesh.add_face([v51,  v7, v31, v11])
            faces[48] = mesh.add_face([v51, v11, v59, v27])
            faces[49] = mesh.add_face([v51, v27, v40,  v4])
            faces[50] = mesh.add_face([v52,  v5, v39, v24])
            faces[51] = mesh.add_face([v52, v24, v56,  v8])
            faces[52] = mesh.add_face([v52,  v8, v32, v12])
            faces[53] = mesh.add_face([v52, v12, v60, v28])
            faces[54] = mesh.add_face([v52, v28, v41,  v5])
            faces[55] = mesh.add_face([v53,  v5, v41, v29])
            faces[56] = mesh.add_face([v53, v29, v61, v13])
            faces[57] = mesh.add_face([v53, v13, v33,  v9])
            faces[58] = mesh.add_face([v53,  v9, v57, v25])
            faces[59] = mesh.add_face([v53, v25, v39,  v5])

            # Compute the angle to rotate the glyphs by so they align with the axis of symmetry.
            angle = -Math.atan((v0 - v8).length() / (2.0 * (DiceUtil::find_face_center(faces[0]) - v42).length()))

            # The distance between two diametric faces is 4.241982" in the base model, and this looks best with a
            # diametric distance of 24mm, so the model must be scaled by a factor of
            # 24mm / (4.241982")(25.4mm/") = 0.222745
            # Which is further scaled by 1000, since we treat mm as m in the model, to get 222.745
            super(die_size: 24.0, die_scale: 222.745, font_size: 4.5, definition: definition, faces: faces)

            # Rotate each of the face transforms so that the glyphs are aligned between the top and the bottom vertices
            # of the rhombus, instead of being aligned with an edge as they normally are.
            @face_transforms.each_with_index() do |face_transform, i|
                rotation = Geom::Transformation.rotation(face_transform.origin, face_transform.zaxis, angle)
                @face_transforms[i] = rotation * face_transform
            end
        end

        # A deltoidal hexecontahedron with standard dimensions.
        STANDARD = DeltoidalHexecontahedron::new(def_name: "Standard")

    end

end
end
end
