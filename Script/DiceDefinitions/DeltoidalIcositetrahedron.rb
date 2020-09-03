
module DiceGen
    # This class defines the mesh model for a deltoidal icositetrahedron (non-standard D24).
    class DeltoidalIcositetrahedron < Die
        # Lays out the geometry for the die in a new ComponentDefinition and adds it to the main DefinitionList.
        def initialize()
            # Create a new definition for the die.
            definition = Util::MAIN_MODEL.definitions.add(self.class.name)
            mesh = definition.entities()

            C0 = 0.0
            C1 = 1.0
            C2 = Math.sqrt(2)
            C3 = (4 + Math.sqrt(2)) / 7
            # Define all the points that make up the vertices of the die.
            V0  = Geom::Point3d::new( C0,  C1,  C1)
            V1  = Geom::Point3d::new( C0,  C1, -C1)
            V2  = Geom::Point3d::new( C0, -C1,  C1)
            V3  = Geom::Point3d::new( C0, -C1, -C1)
            V4  = Geom::Point3d::new( C1,  C0,  C1)
            V5  = Geom::Point3d::new( C1,  C0, -C1)
            V6  = Geom::Point3d::new(-C1,  C0,  C1)
            V7  = Geom::Point3d::new(-C1,  C0, -C1)
            V8  = Geom::Point3d::new( C1,  C1,  C0)
            V9  = Geom::Point3d::new( C1, -C1,  C0)
            V10 = Geom::Point3d::new(-C1,  C1,  C0)
            V11 = Geom::Point3d::new(-C1, -C1,  C0)
            V12 = Geom::Point3d::new( C2,  C0,  C0)
            V13 = Geom::Point3d::new(-C2,  C0,  C0)
            V14 = Geom::Point3d::new( C0,  C2,  C0)
            V15 = Geom::Point3d::new( C0, -C2,  C0)
            V16 = Geom::Point3d::new( C0,  C0,  C2)
            V17 = Geom::Point3d::new( C0,  C0, -C2)
            V16 = Geom::Point3d::new( C3,  C3,  C3)
            V19 = Geom::Point3d::new( C3,  C3, -C3)
            V20 = Geom::Point3d::new( C3, -C3,  C3)
            V21 = Geom::Point3d::new( C3, -C3, -C3)
            V22 = Geom::Point3d::new(-C3,  C3,  C3)
            V23 = Geom::Point3d::new(-C3,  C3, -C3)
            V24 = Geom::Point3d::new(-C3, -C3,  C3)
            V25 = Geom::Point3d::new(-C3, -C3, -C3)

            # Create the faces of the die by joining the vertices with edges. #TODO FIX THIS
            faces = Array::new(24)
            faces[0]  = mesh.add_face([V16,  V4, V18,  V0])
            faces[1]  = mesh.add_face([V16,  V0, V22,  V6])
            faces[2]  = mesh.add_face([V16,  V6, V24,  V2])
            faces[3]  = mesh.add_face([V16,  V2, V20,  V4])
            faces[4]  = mesh.add_face([V17,  V7, V23,  V1])
            faces[5]  = mesh.add_face([V17,  V1, V19,  V5])
            faces[6]  = mesh.add_face([V17,  V5, V21,  V3])
            faces[7]  = mesh.add_face([V17,  V3, V25,  V7])
            faces[8]  = mesh.add_face([V12,  V5, V19,  V8])
            faces[9]  = mesh.add_face([V12,  V8, V18,  V4])
            faces[10] = mesh.add_face([V12,  V4, V20,  V9])
            faces[11] = mesh.add_face([V12,  V9, V21,  V5])
            faces[12] = mesh.add_face([V13,  V6, V22, V10])
            faces[13] = mesh.add_face([V13, V10, V23,  V7])
            faces[14] = mesh.add_face([V13,  V7, V25, V11])
            faces[15] = mesh.add_face([V13, V11, V24,  V6])
            faces[16] = mesh.add_face([V14,  V8, V19,  V1])
            faces[17] = mesh.add_face([V14,  V1, V23, V10])
            faces[18] = mesh.add_face([V14, V10, V22,  V0])
            faces[19] = mesh.add_face([V14,  V0, V18,  V8])
            faces[20] = mesh.add_face([V15,  V9, V20,  V2])
            faces[21] = mesh.add_face([V15,  V2, V24, V11])
            faces[22] = mesh.add_face([V15, V11, V25,  V3])
            faces[23] = mesh.add_face([V15,  V3, V21,  V9])

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
