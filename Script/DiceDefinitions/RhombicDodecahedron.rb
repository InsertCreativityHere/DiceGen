
module DiceGen
    # This class defines the mesh model for a rhombic dodecahedron (non-standard D12).
    class RhombicDodecahedron < Die
        # Lays out the geometry for the die in a new ComponentDefinition and adds it to the main DefinitionList.
        def initialize()
            # Create a new definition for the die.
            definition = Util::MAIN_MODEL.definitions.add(self.class.name)
            mesh = definition.entities()

            C0 = 0.0
            C1 = 3 * Math.sqrt(2) / 4
            C2 = 3 * Math.sqrt(2) / 8
            # Define all the points that make up the vertices of the die.
            V0  = Geom::Point3d::new( C1,  C0,  C0)
            V1  = Geom::Point3d::new(-C1,  C0,  C0)
            V2  = Geom::Point3d::new( C0,  C1,  C0)
            V3  = Geom::Point3d::new( C0, -C1,  C0)
            V4  = Geom::Point3d::new( C0,  C0,  C1)
            V5  = Geom::Point3d::new( C0,  C0, -C1)
            V6  = Geom::Point3d::new( C2,  C2,  C2)
            V7  = Geom::Point3d::new( C2,  C2, -C2)
            V8  = Geom::Point3d::new( C2, -C2,  C2)
            V9  = Geom::Point3d::new( C2, -C2, -C2)
            V10 = Geom::Point3d::new(-C2,  C2,  C2)
            V11 = Geom::Point3d::new(-C2,  C2, -C2)
            V12 = Geom::Point3d::new(-C2, -C2,  C2)
            V13 = Geom::Point3d::new(-C2, -C2, -C2)

            # Create the faces of the die by joining the vertices with edges. #TODO FIX THIS
            faces = Array::new(12)
            faces[0]  = mesh.add_face([ V6,  V4,  V8,  V0])
            faces[1]  = mesh.add_face([ V6,  V0,  V7,  V2])
            faces[2]  = mesh.add_face([ V6,  V2, V10,  V4])
            faces[3]  = mesh.add_face([ V9,  V5,  V7,  V0])
            faces[4]  = mesh.add_face([ V9,  V0,  V8,  V3])
            faces[5]  = mesh.add_face([ V9,  V3, V13,  V5])
            faces[6]  = mesh.add_face([V11,  V5, V13,  V1])
            faces[7]  = mesh.add_face([V11,  V1, V10,  V2])
            faces[8]  = mesh.add_face([V11,  V2,  V7,  V5])
            faces[9]  = mesh.add_face([V12,  V4, V10,  V1])
            faces[10] = mesh.add_face([V12,  V1, V13,  V3])
            faces[11] = mesh.add_face([V12,  V3,  V8,  V4])

            #TODO MAKE THE SCALES!
            super(definition: definition, faces: faces)

            # TODO ROTATE EACH OF THE FACE TRANSFORMS!
        end

        # Delegates to the default implemenation after checking that the die type is a D12.
        def place_glyphs(font:, mesh:, type:)
            if (type != "D12")
                raise "Incompatible die type: a D12 model cannot be used to generate #{type.to_s()} dice."
            end
            super
        end
    end
end
