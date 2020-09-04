
module DiceGen
    # This class defines the mesh model for a laevo-pentagonal icositetrahedron (non-standard D24).
    class LaevoPentagonalIcositetrahedron < Die
        # Lays out the geometry for the die in a new ComponentDefinition and adds it to the main DefinitionList.
        def initialize()
            # Create a new definition for the die.
            definition = Util::MAIN_MODEL.definitions.add(self.class.name)
            mesh = definition.entities()

            ca = Math.sqrt(33)
            c0 = 0.0
            c1 = Math.sqrt(6 * (Math.cbrt(6 * (   9 +      ca)) + Math.cbrt(6 * (   9 -      ca)) -  6)) / 12
            c2 = Math.sqrt(6 * (Math.cbrt(6 * (   9 +      ca)) + Math.cbrt(6 * (   9 -      ca)) +  6)) / 12
            c3 = Math.sqrt(6 * (Math.cbrt(6 * (   9 +      ca)) + Math.cbrt(6 * (   9 -      ca)) + 18)) / 12
            c4 = Math.sqrt(6 * (Math.cbrt(2 * (1777 + 33 * ca)) + Math.cbrt(2 * (1777 - 33 * ca)) + 14)) / 12
            # Define all the points that make up the vertices of the die.
            v0  = Geom::Point3d::new( c4,  c0,  c0)
            v1  = Geom::Point3d::new(-c4,  c0,  c0)
            v2  = Geom::Point3d::new( c0,  c4,  c0)
            v3  = Geom::Point3d::new( c0, -c4,  c0)
            v4  = Geom::Point3d::new( c0,  c0,  c4)
            v5  = Geom::Point3d::new( c0,  c0, -c4)
            v6  = Geom::Point3d::new( c3,  c2,  c1)
            v7  = Geom::Point3d::new( c3, -c2, -c1)
            v8  = Geom::Point3d::new(-c3,  c2, -c1)
            v9  = Geom::Point3d::new(-c3, -c2,  c1)
            v10 = Geom::Point3d::new( c2,  c1,  c3)
            v11 = Geom::Point3d::new( c2, -c1, -c3)
            v12 = Geom::Point3d::new(-c2,  c1, -c3)
            v13 = Geom::Point3d::new(-c2, -c1,  c3)
            v14 = Geom::Point3d::new( c1,  c3,  c2)
            v15 = Geom::Point3d::new( c1, -c3, -c2)
            v16 = Geom::Point3d::new(-c1,  c3, -c2)
            v17 = Geom::Point3d::new(-c1, -c3,  c2)
            v18 = Geom::Point3d::new(-c1, -c2, -c3)
            v19 = Geom::Point3d::new(-c1,  c2,  c3)
            v20 = Geom::Point3d::new( c1, -c2,  c3)
            v21 = Geom::Point3d::new( c1,  c2, -c3)
            v22 = Geom::Point3d::new(-c2, -c3, -c1)
            v23 = Geom::Point3d::new(-c2,  c3,  c1)
            v24 = Geom::Point3d::new( c2, -c3,  c1)
            v25 = Geom::Point3d::new( c2,  c3, -c1)
            v26 = Geom::Point3d::new(-c3, -c1, -c2)
            v27 = Geom::Point3d::new(-c3,  c1,  c2)
            v28 = Geom::Point3d::new( c3, -c1,  c2)
            v29 = Geom::Point3d::new( c3,  c1, -c2)
            v30 = Geom::Point3d::new( c2,  c2,  c2)
            v31 = Geom::Point3d::new( c2,  c2, -c2)
            v32 = Geom::Point3d::new( c2, -c2,  c2)
            v33 = Geom::Point3d::new( c2, -c2, -c2)
            v34 = Geom::Point3d::new(-c2,  c2,  c2)
            v35 = Geom::Point3d::new(-c2,  c2, -c2)
            v36 = Geom::Point3d::new(-c2, -c2,  c2)
            v37 = Geom::Point3d::new(-c2, -c2, -c2)

            # Create the faces of the die by joining the vertices with edges. #TODO FIX THIS
            faces = Array::new(24)
            faces[0]  = mesh.add_face([v5, v18, v37, v26, v12])
            faces[1]  = mesh.add_face([v5, v11, v33, v15, v18])
            faces[2]  = mesh.add_face([v5, v21, v31, v29, v11])
            faces[3]  = mesh.add_face([v5, v12, v35, v16, v21])
            faces[4]  = mesh.add_face([v4, v19, v34, v27, v13])
            faces[5]  = mesh.add_face([v4, v10, v30, v14, v19])
            faces[6]  = mesh.add_face([v4, v20, v32, v28, v10])
            faces[7]  = mesh.add_face([v4, v13, v36, v17, v20])
            faces[8]  = mesh.add_face([v1, v27, v34, v23,  v8])
            faces[9]  = mesh.add_face([v1,  v9, v36, v13, v27])
            faces[10] = mesh.add_face([v1, v26, v37, v22,  v9])
            faces[11] = mesh.add_face([v1,  v8, v35, v12, v26])
            faces[12] = mesh.add_face([v0, v28, v32, v24,  v7])
            faces[13] = mesh.add_face([v0,  v6, v30, v10, v28])
            faces[14] = mesh.add_face([v0, v29, v31, v25,  v6])
            faces[15] = mesh.add_face([v0,  v7, v33, v11, v29])
            faces[16] = mesh.add_face([v3, v24, v32, v20, v17])
            faces[17] = mesh.add_face([v3, v15, v33,  v7, v24])
            faces[18] = mesh.add_face([v3, v22, v37, v18, v15])
            faces[19] = mesh.add_face([v3, v17, v36,  v9, v22])
            faces[20] = mesh.add_face([v2, v25, v31, v21, v16])
            faces[21] = mesh.add_face([v2, v14, v30,  v6, v25])
            faces[22] = mesh.add_face([v2, v23, v34, v19, v14])
            faces[23] = mesh.add_face([v2, v16, v35,  v8, v23])

            #TODO MAKE THE SCALES!
            super(definition: definition, faces: faces)

            # TODO ROTATE EACH OF THE FACE TRANSFORMS!
        end

        # Delegates to the default implemenation after checking that the die type is a D24.
        def place_glyphs(font:, mesh:, type: "D24", font_scale: 1.0, font_offset: [0,0])
            if (type != "D24")
                raise "Incompatible die type: a D24 model cannot be used to generate #{type.to_s()} dice."
            end
            super
        end
    end
end
