
module DiceGen
    # This class defines the mesh model for a sharp-edged standard D8 die (an equilateral octohedron).
    class Octohedron < Die
        # Lays out the geometry for the die in a new ComponentDefinition and adds it to the main DefinitionList.
        def initialize()
            # Create a new definition for the die.
            definition = Util::MAIN_MODEL.definitions.add(self.class.name)
            mesh = definition.entities()

            C0 = 0.0
            C1 = Math.sqrt(2) / 2
            # Define all the points that make up the vertices of the die.
            V0 = Geom::Point3d::new( C1,  C0,  C0)
            V1 = Geom::Point3d::new(-C1,  C0,  C0)
            V2 = Geom::Point3d::new( C0,  C1,  C0)
            V3 = Geom::Point3d::new( C0, -C1,  C0)
            V4 = Geom::Point3d::new( C0,  C0,  C1)
            V5 = Geom::Point3d::new( C0,  C0, -C1)

            # Create the faces of the die by joining the vertices with edges. #TODO FIX THIS
            faces = Array::new(8)
            faces[0] = mesh.add_face([V4, V0, V2])
            faces[1] = mesh.add_face([V4, V2, V1])
            faces[2] = mesh.add_face([V4, V1, V3])
            faces[3] = mesh.add_face([V4, V3, V0])
            faces[4] = mesh.add_face([V5, V0, V3])
            faces[5] = mesh.add_face([V5, V3, V1])
            faces[6] = mesh.add_face([V5, V1, V2])
            faces[7] = mesh.add_face([V5, V2, V0])

            # The distance between two diametric faces is 1.1547" in the base model, and standard D8 dice have a
            # diametric distance of 15mm, so the model must be scaled by a factor of
            # 15mm / (1.1547")(25.4mm/") = 0.51143
            # Which is further scaled by 1000, since we treat mm as m in the model, to get 511.43
            #
            # Glyph models are always 8mm tall when imported, and the glyphs on a D8 are 7mm tall, so glyphs must
            # be scaled by a factor of 7mm/8mm = 0.875
            super(definition: definition, faces: faces, die_scale: 511.43, font_scale: 0.875)
        end

        # Delegates to the default implemenation after checking that the die type is a D8.
        def place_glyphs(font:, mesh:, type:)
            if (type != "D8")
                raise "Incompatible die type: a D8 model cannot be used to generate #{type.to_s()} dice."
            end
            super
        end
    end
end
