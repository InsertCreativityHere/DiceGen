
module DiceGen
    # This class defines the mesh model for a rhombic triacontahedron (non-standard D30).
    class RhombicTriacontahedron < Die
        # Lays out the geometry for the die in a new ComponentDefinition and adds it to the main DefinitionList.
        def initialize()
            # Create a new definition for the die.
            definition = Util::MAIN_MODEL.definitions.add(self.class.name)
            mesh = definition.entities()

            C0 = 0.0
            C1 = (5 + 3 * Math.sqrt(5)) / 8
            C2 = Math.sqrt(5) / 4
            C3 = (5 + Math.sqrt(5)) / 8
            # Define all the points that make up the vertices of the die.
            V0  = Geom::Point3d( C0,  C1,  C3)
            V1  = Geom::Point3d( C0,  C1, -C3)
            V2  = Geom::Point3d( C0, -C1,  C3)
            V3  = Geom::Point3d( C0, -C1, -C3)
            V4  = Geom::Point3d( C3,  C0,  C1)
            V5  = Geom::Point3d( C3,  C0, -C1)
            V6  = Geom::Point3d(-C3,  C0,  C1)
            V7  = Geom::Point3d(-C3,  C0, -C1)
            V8  = Geom::Point3d( C1,  C3,  C0)
            V9  = Geom::Point3d( C1, -C3,  C0)
            V10 = Geom::Point3d(-C1,  C3,  C0)
            V11 = Geom::Point3d(-C1, -C3,  C0)
            V12 = Geom::Point3d( C0,  C2,  C1)
            V13 = Geom::Point3d( C0,  C2, -C1)
            V14 = Geom::Point3d( C0, -C2,  C1)
            V15 = Geom::Point3d( C0, -C2, -C1)
            V16 = Geom::Point3d( C1,  C0,  C2)
            V17 = Geom::Point3d( C1,  C0, -C2)
            V18 = Geom::Point3d(-C1,  C0,  C2)
            V19 = Geom::Point3d(-C1,  C0, -C2)
            V20 = Geom::Point3d( C2,  C1,  C0)
            V21 = Geom::Point3d( C2, -C1,  C0)
            V22 = Geom::Point3d(-C2,  C1,  C0)
            V23 = Geom::Point3d(-C2, -C1,  C0)
            V24 = Geom::Point3d( C3,  C3,  C3)
            V25 = Geom::Point3d( C3,  C3, -C3)
            V26 = Geom::Point3d( C3, -C3,  C3)
            V27 = Geom::Point3d( C3, -C3, -C3)
            V28 = Geom::Point3d(-C3,  C3,  C3)
            V29 = Geom::Point3d(-C3,  C3, -C3)
            V30 = Geom::Point3d(-C3, -C3,  C3)
            V31 = Geom::Point3d(-C3, -C3, -C3)

            # Create the faces of the die by joining the vertices with edges. #TODO FIX THIS
            faces = Array::new(30)
            faces[0]  = mesh.add_face([ V4, V12,  V6, V14])
            faces[1]  = mesh.add_face([ V4, V14,  V2, V26])
            faces[2]  = mesh.add_face([ V4, V26,  V9, V16])
            faces[3]  = mesh.add_face([ V5, V13,  V1, V25])
            faces[4]  = mesh.add_face([ V5, V25,  V8, V17])
            faces[5]  = mesh.add_face([ V5, V17,  V9, V27])
            faces[6]  = mesh.add_face([ V6, V28, V10, V18])
            faces[7]  = mesh.add_face([ V6, V18, V11, V30])
            faces[8]  = mesh.add_face([ V6, V30,  V2, V14])
            faces[9]  = mesh.add_face([ V7, V19, V10, V29])
            faces[10] = mesh.add_face([ V7, V29,  V1, V13])
            faces[11] = mesh.add_face([ V7, V13,  V5, V15])
            faces[12] = mesh.add_face([ V8, V20,  V0, V24])
            faces[13] = mesh.add_face([ V8, V24,  V4, V16])
            faces[14] = mesh.add_face([ V8, V16,  V9, V17])
            faces[15] = mesh.add_face([V11, V18, V10, V19])
            faces[16] = mesh.add_face([V11, V19,  V7, V31])
            faces[17] = mesh.add_face([V11, V31,  V3, V23])
            faces[18] = mesh.add_face([ V0, V22, V10, V28])
            faces[19] = mesh.add_face([ V0, V28,  V6, V12])
            faces[20] = mesh.add_face([ V0, V12,  V4, V24])
            faces[21] = mesh.add_face([ V1, V29, V10, V22])
            faces[22] = mesh.add_face([ V1, V22,  V0, V20])
            faces[23] = mesh.add_face([ V1, V20,  V8, V25])
            faces[24] = mesh.add_face([ V2, V30, V11, V23])
            faces[25] = mesh.add_face([ V2, V23,  V3, V21])
            faces[26] = mesh.add_face([ V2, V21,  V9, V26])
            faces[27] = mesh.add_face([ V3, V31,  V7, V15])
            faces[28] = mesh.add_face([ V3, V15,  V5, V27])
            faces[29] = mesh.add_face([ V3, V27,  V9, V21])

            #TODO MAKE THE SCALES!
            super(definition: definition, faces: faces)

            # TODO ROTATE EACH OF THE FACE TRANSFORMS!
        end

        # Delegates to the default implemenation after checking that the die type is a D30.
        def place_glyphs(font:, mesh:, type:)
            if (type != "D30")
                raise "Incompatible die type: a D30 model cannot be used to generate #{type.to_s()} dice."
            end
            super
        end
    end
end
