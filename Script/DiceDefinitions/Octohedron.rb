
module DiceGen
    # This class defines the mesh model for a sharp-edged standard D8 die (an equilateral octohedron).
    class Octohedron < Die
        # Lays out the geometry for the die in a new ComponentDefinition and adds it to the main DefinitionList.
        def initialize()
            # Create a new definition for the die.
            definition = Util::MAIN_MODEL.definitions.add(self.class.name)
            mesh = definition.entities()

            c0 = 0.0
            c1 = Math.sqrt(2) / 2
            # Define all the points that make up the vertices of the die.
            v0 = Geom::Point3d::new( c1,  c0,  c0)
            v1 = Geom::Point3d::new(-c1,  c0,  c0)
            v2 = Geom::Point3d::new( c0,  c1,  c0)
            v3 = Geom::Point3d::new( c0, -c1,  c0)
            v4 = Geom::Point3d::new( c0,  c0,  c1)
            v5 = Geom::Point3d::new( c0,  c0, -c1)

            # Create the faces of the die by joining the vertices with edges. #TODO FIX THIS
            faces = Array::new(8)
            faces[0] = mesh.add_face([v4, v0, v2])
            faces[1] = mesh.add_face([v4, v2, v1])
            faces[2] = mesh.add_face([v4, v1, v3])
            faces[3] = mesh.add_face([v4, v3, v0])
            faces[4] = mesh.add_face([v5, v0, v3])
            faces[5] = mesh.add_face([v5, v3, v1])
            faces[6] = mesh.add_face([v5, v1, v2])
            faces[7] = mesh.add_face([v5, v2, v0])

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
        def place_glyphs(font:, mesh:, type: "D8", font_scale: 1.0, font_offset: [0,0])
            if (type != "D8")
                raise "Incompatible die type: a D8 model cannot be used to generate #{type.to_s()} dice."
            end
            super
        end
    end
end
