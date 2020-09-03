
module DiceGen
    # This class defines the mesh model for a sharp-edged standard D12 die (a dodecahedron).
    class Dodecahedron < Die
        # Lays out the geometry for the die in a new ComponentDefinition and adds it to the main DefinitionList.
        def initialize()
            # Create a new definition for the die.
            definition = Util::MAIN_MODEL.definitions.add(self.class.name)
            mesh = definition.entities()

            C0 = 0.0
            C1 = 0.5
            C2 = (1 + Math.sqrt(5)) / 4
            C3 = (3 + Math.sqrt(5)) / 4
            # Define all the points that make up the vertices of the die.
            V0  = Geom::Point3d::new( C0,  C1,  C3)
            V1  = Geom::Point3d::new( C0,  C1, -C3)
            V2  = Geom::Point3d::new( C0, -C1,  C3)
            V3  = Geom::Point3d::new( C0, -C1, -C3)
            V4  = Geom::Point3d::new( C3,  C0,  C1)
            V5  = Geom::Point3d::new( C3,  C0, -C1)
            V6  = Geom::Point3d::new(-C3,  C0,  C1)
            V7  = Geom::Point3d::new(-C3,  C0, -C1)
            V8  = Geom::Point3d::new( C1,  C3,  C0)
            V9  = Geom::Point3d::new( C1, -C3,  C0)
            V10 = Geom::Point3d::new(-C1,  C3,  C0)
            V11 = Geom::Point3d::new(-C1, -C3,  C0)
            V12 = Geom::Point3d::new( C2,  C2,  C2)
            V13 = Geom::Point3d::new( C2,  C2, -C2)
            V14 = Geom::Point3d::new( C2, -C2,  C2)
            V15 = Geom::Point3d::new( C2, -C2, -C2)
            V16 = Geom::Point3d::new(-C2,  C2,  C2)
            V17 = Geom::Point3d::new(-C2,  C2, -C2)
            V18 = Geom::Point3d::new(-C2, -C2,  C2)
            V19 = Geom::Point3d::new(-C2, -C2, -C2)

            # Create the faces of the die by joining the vertices with edges. #TODO FIX THIS
            faces = Array::new(12)
            faces[0]  = mesh.add_face([ V0,  V2, V14,  V4, V12])
            faces[1]  = mesh.add_face([ V0, V12,  V8, V10, V16])
            faces[2]  = mesh.add_face([ V0, V16,  V6, V18,  V2])
            faces[3]  = mesh.add_face([ V7,  V6, V16, V10, V17])
            faces[4]  = mesh.add_face([ V7, V17,  V1,  V3, V19])
            faces[5]  = mesh.add_face([ V7, V19, V11, V18,  V6])
            faces[6]  = mesh.add_face([ V9, V11, V19,  V3, V15])
            faces[7]  = mesh.add_face([ V9, V15,  V5,  V4, V14])
            faces[8]  = mesh.add_face([ V9, V14,  V2, V18, V11])
            faces[9]  = mesh.add_face([V13,  V1, V17, V10,  V8])
            faces[10] = mesh.add_face([V13,  V8, V12,  V4,  V5])
            faces[11] = mesh.add_face([V13,  V5, V15,  V3,  V1])

            #TODO MAKE THE DIE SCALE!
            # Glyph models are always 8mm tall when imported, and the glyphs on a D12 are 6mm tall, so glyphs must
            # be scaled by a factor of 6mm/8mm = 0.75
            super(definition: definition, faces: faces, font_scale: 0.75)
        end

        # Delegates to the default implemenation after checking that the die type is a D12.
        def place_glyphs(font:, mesh:, type: "D12", font_scale: 1.0, font_offset: [0,0])
            if (type != "D12")
                raise "Incompatible die type: a D12 model cannot be used to generate #{type.to_s()} dice."
            end
            super
        end
    end
end
