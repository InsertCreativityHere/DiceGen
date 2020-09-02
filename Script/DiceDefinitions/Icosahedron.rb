
module DiceGen
    # This class defines the mesh model for a sharp-edged standard D20 die (an icosahedron).
    class Icosahedron < Die
        # Lays out the geometry for the die in a new ComponentDefinition and adds it to the main DefinitionList.
        def initialize()
            # Create a new definition for the die.
            definition = Util::MAIN_MODEL.definitions.add(self.class.name)
            mesh = definition.entities()

            C0 = 0.0
            C1 = 0.5
            C2 = (1 + Math.sqrt(5)) / 4
            # Define all the points that make up the vertices of the die.
            V0  = Geom::Point3d::new( C0,  C2,  C1)
            V1  = Geom::Point3d::new( C0,  C2, -C1)
            V2  = Geom::Point3d::new( C0, -C2,  C1)
            V3  = Geom::Point3d::new( C0, -C2, -C1)
            V4  = Geom::Point3d::new( C1,  C0,  C2)
            V5  = Geom::Point3d::new( C1,  C0, -C2)
            V6  = Geom::Point3d::new(-C1,  C0,  C2)
            V7  = Geom::Point3d::new(-C1,  C0, -C2)
            V8  = Geom::Point3d::new( C2,  C1,  C0)
            V9  = Geom::Point3d::new( C2, -C1,  C0)
            V10 = Geom::Point3d::new(-C2,  C1,  C0)
            V11 = Geom::Point3d::new(-C2, -C1,  C0)

            # Create the faces of the die by joining the vertices with edges. #TODO FIX THIS
            faces = Array::new(20)
            faces[0]  = mesh.add_face([V4,  V6,  V2])
            faces[1]  = mesh.add_face([V4,  V2,  V9])
            faces[2]  = mesh.add_face([V4,  V9,  V8])
            faces[3]  = mesh.add_face([V4,  V8,  V0])
            faces[4]  = mesh.add_face([V4,  V0,  V6])
            faces[5]  = mesh.add_face([V7,  V5,  V3])
            faces[6]  = mesh.add_face([V7,  V3, V11])
            faces[7]  = mesh.add_face([V7, V11, V10])
            faces[8]  = mesh.add_face([V7, V10,  V1])
            faces[9]  = mesh.add_face([V7,  V1,  V5])
            faces[10] = mesh.add_face([V6, V10, V11])
            faces[11] = mesh.add_face([V6, V11,  V2])
            faces[12] = mesh.add_face([V2, V11,  V3])
            faces[13] = mesh.add_face([V2,  V3,  V9])
            faces[14] = mesh.add_face([V9,  V3,  V5])
            faces[15] = mesh.add_face([V9,  V5,  V8])
            faces[16] = mesh.add_face([V8,  V5,  V1])
            faces[17] = mesh.add_face([V8,  V1,  V0])
            faces[18] = mesh.add_face([V0,  V1, V10])
            faces[19] = mesh.add_face([V0, V10,  V6])

            # The distance between two diametric faces is 3.0230" in the base model, and standard D20 dice have a
            # diametric distance of 20mm, so the model must be scaled by a factor of
            # 20mm / (3.0230")(25.4mm/") = 0.26047
            # Which is further scaled by 1000, since we treat mm as m in the model, to get 260.47
            #
            # Glyph models are always 8mm tall when imported, and the glyphs on a D20 are 4.5mm tall, so glyphs must
            # be scaled by a factor of 4.5mm/8mm = 0.5625
            super(definition: definition, faces: faces, die_scale: 260.47, font_scale: 0.5625)
        end

        # Delegates to the default implemenation after checking that the die type is a D20.
        def place_glyphs(font:, mesh:, type:)
            if (type != "D20")
                raise "Incompatible die type: a D20 model cannot be used to generate #{type.to_s()} dice."
            end
            super
        end
    end
end
