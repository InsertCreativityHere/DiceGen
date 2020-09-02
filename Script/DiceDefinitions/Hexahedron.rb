
module DiceGen
    # This class defines the mesh model for a sharp-edged standard D6 die (a hexhedron (fancy word for cube)).
    class Hexahedron < Die
        # Lays out the geometry for the die in a new ComponentDefinition and adds it to the main DefinitionList.
        def initialize()
            # Create a new definition for the die.
            definition = Util::MAIN_MODEL.definitions.add(self.class.name)
            die_mesh = definition.entities()

            C0 = 0.5
            # Define all the points that make up the vertices of the die.
            V0 = Geom::Point3d::new( C0,  C0,  C0)
            V1 = Geom::Point3d::new( C0,  C0, -C0)
            V2 = Geom::Point3d::new( C0, -C0,  C0)
            V3 = Geom::Point3d::new( C0, -C0, -C0)
            V4 = Geom::Point3d::new(-C0,  C0,  C0)
            V5 = Geom::Point3d::new(-C0,  C0, -C0)
            V6 = Geom::Point3d::new(-C0, -C0,  C0)
            V7 = Geom::Point3d::new(-C0, -C0, -C0)

            # Create the faces of the die by joining the vertices with edges. #TODO FIX THIS
            faces = Array::new(6)
            faces[0] = die_mesh.add_face([V0, V1, V5, V4])
            faces[1] = die_mesh.add_face([V0, V4, V6, V2])
            faces[2] = die_mesh.add_face([V0, V2, V3, V1])
            faces[3] = die_mesh.add_face([V7, V3, V2, V6])
            faces[4] = die_mesh.add_face([V7, V6, V4, V5])
            faces[5] = die_mesh.add_face([V7, V5, V1, V3])

            # The distance between two diametric faces is 2" in the base model, and standard D6 dice have a
            # diametric distance of 15mm, so the model must be scaled by a factor of
            # 15mm / (2")(25.4mm/") = 0.29528
            # Which is further scaled by 1000, since we treat mm as m in the model, to get 295.28
            #
            # Glyph models are always 8mm tall when imported, and the glyphs on a D6 are 8mm tall, so no scaling is
            # necessary.
            super(definition: definition, faces: faces, die_scale: 295.28)
        end

        # Delegates to the default implemenation after checking that the die type is a D6.
        def place_glyphs(font:, mesh:, type:)
            if (type != "D6")
                raise "Incompatible die type: a D6 model cannot be used to generate #{type.to_s()} dice."
            end
            super
        end
    end
end
