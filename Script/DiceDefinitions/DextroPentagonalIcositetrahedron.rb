
module DiceGen
    # This class defines the mesh model for a dextro-pentagonal icositetrahedron (non-standard D24).
    class DextroPentagonalIcositetrahedron < Die
        # Lays out the geometry for the die in a new ComponentDefinition and adds it to the main DefinitionList.
        def initialize()
            # Create a new definition for the die.
            definition = Util::MAIN_MODEL.definitions.add(self.class.name)
            mesh = definition.entities()

            CA = Math.sqrt(33)
            C0 = 0.0
            C1 = Math.sqrt(6 * (Math.cbrt(6 * (   9 +      CA)) + Math.cbrt(6 * (   9 -      CA)) -  6)) / 12
            C2 = Math.sqrt(6 * (Math.cbrt(6 * (   9 +      CA)) + Math.cbrt(6 * (   9 -      CA)) +  6)) / 12
            C3 = Math.sqrt(6 * (Math.cbrt(6 * (   9 +      CA)) + Math.cbrt(6 * (   9 -      CA)) + 18)) / 12
            C4 = Math.sqrt(6 * (Math.cbrt(2 * (1777 + 33 * CA)) + Math.cbrt(2 * (1777 - 33 * CA)) + 14)) / 12
            # Define all the points that make up the vertices of the die.
            V0  = Geom::Point3d::new( C4,  C0,  C0)
            V1  = Geom::Point3d::new(-C4,  C0,  C0)
            V2  = Geom::Point3d::new( C0,  C4,  C0)
            V3  = Geom::Point3d::new( C0, -C4,  C0)
            V4  = Geom::Point3d::new( C0,  C0,  C4)
            V5  = Geom::Point3d::new( C0,  C0, -C4)
            V6  = Geom::Point3d::new(-C3, -C2, -C1)
            V7  = Geom::Point3d::new(-C3,  C2,  C1)
            V8  = Geom::Point3d::new( C3, -C2,  C1)
            V9  = Geom::Point3d::new( C3,  C2, -C1)
            V10 = Geom::Point3d::new(-C2, -C1, -C3)
            V11 = Geom::Point3d::new(-C2,  C1,  C3)
            V12 = Geom::Point3d::new( C2, -C1,  C3)
            V13 = Geom::Point3d::new( C2,  C1, -C3)
            V14 = Geom::Point3d::new(-C1, -C3, -C2)
            V15 = Geom::Point3d::new(-C1,  C3,  C2)
            V16 = Geom::Point3d::new( C1, -C3,  C2)
            V17 = Geom::Point3d::new( C1,  C3, -C2)
            V18 = Geom::Point3d::new( C1,  C2,  C3)
            V19 = Geom::Point3d::new( C1, -C2, -C3)
            V20 = Geom::Point3d::new(-C1,  C2, -C3)
            V21 = Geom::Point3d::new(-C1, -C2,  C3)
            V22 = Geom::Point3d::new( C2,  C3,  C1)
            V23 = Geom::Point3d::new( C2, -C3, -C1)
            V24 = Geom::Point3d::new(-C2,  C3, -C1)
            V25 = Geom::Point3d::new(-C2, -C3,  C1)
            V26 = Geom::Point3d::new( C3,  C1,  C2)
            V27 = Geom::Point3d::new( C3, -C1, -C2)
            V28 = Geom::Point3d::new(-C3,  C1, -C2)
            V29 = Geom::Point3d::new(-C3, -C1,  C2)
            V30 = Geom::Point3d::new( C2,  C2,  C2)
            V31 = Geom::Point3d::new( C2,  C2, -C2)
            V32 = Geom::Point3d::new( C2, -C2,  C2)
            V33 = Geom::Point3d::new( C2, -C2, -C2)
            V34 = Geom::Point3d::new(-C2,  C2,  C2)
            V35 = Geom::Point3d::new(-C2,  C2, -C2)
            V36 = Geom::Point3d::new(-C2, -C2,  C2)
            V37 = Geom::Point3d::new(-C2, -C2, -C2)

            # Create the faces of the die by joining the vertices with edges. #TODO FIX THIS
            faces = Array::new(24)
            faces[0]  = mesh.add_face([V4, V12, V26, V30, V18])
            faces[1]  = mesh.add_face([V4, V18, V15, V34, V11])
            faces[2]  = mesh.add_face([V4, V11, V29, V36, V21])
            faces[3]  = mesh.add_face([V4, V21, V16, V32, V12])
            faces[4]  = mesh.add_face([V5, V13, V27, V33, V19])
            faces[5]  = mesh.add_face([V5, V19, V14, V37, V10])
            faces[6]  = mesh.add_face([V5, V10, V28, V35, V20])
            faces[7]  = mesh.add_face([V5, V20, V17, V31, V13])
            faces[8]  = mesh.add_face([V0,  V8, V23, V33, V27])
            faces[9]  = mesh.add_face([V0, V27, V13, V31,  V9])
            faces[10] = mesh.add_face([V0,  V9, V22, V30, V26])
            faces[11] = mesh.add_face([V0, V26, V12, V32,  V8])
            faces[12] = mesh.add_face([V1,  V7, V24, V35, V28])
            faces[13] = mesh.add_face([V1, V28, V10, V37,  V6])
            faces[14] = mesh.add_face([V1,  V6, V25, V36, V29])
            faces[15] = mesh.add_face([V1, V29, V11, V34,  V7])
            faces[16] = mesh.add_face([V2, V17, V20, V35, V24])
            faces[17] = mesh.add_face([V2, V24,  V7, V34, V15])
            faces[18] = mesh.add_face([V2, V15, V18, V30, V22])
            faces[19] = mesh.add_face([V2, V22,  V9, V31, V17])
            faces[20] = mesh.add_face([V3, V16, V21, V36, V25])
            faces[21] = mesh.add_face([V3, V25,  V6, V37, V14])
            faces[22] = mesh.add_face([V3, V14, V19, V33, V23])
            faces[23] = mesh.add_face([V3, V23,  V8, V32, V16])

            #TODO MAKE THE SCALES!
            super(definition: definition, faces: faces)

            # TODO ROTATE EACH OF THE FACE TRANSFORMS!
        end

        # Delegates to the default implemenation after checking that the die type is a D24.
        def place_glyphs(font:, mesh:, type:)
            if (type != "D24")
                raise "Incompatible die type: a D24 model cannot be used to generate #{type.to_s()} dice."
            end
            super
        end
    end
end
