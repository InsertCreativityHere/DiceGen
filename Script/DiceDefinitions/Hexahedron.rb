
module DiceGen
    # This class defines the mesh model for a sharp-edged standard D6 die (a hexhedron (fancy word for cube)).
    class Hexahedron < Die
        # Lays out the geometry for the die in a new ComponentDefinition and adds it to the main DefinitionList.
        def initialize()
            # Create a new definition for the die.
            definition = Util::MAIN_MODEL.definitions.add(self.class.name)
            die_mesh = definition.entities()

            # Define all the points that make up the vertices of the die.
            p000 = Geom::Point3d::new(-1, -1, -1)
            p001 = Geom::Point3d::new(-1, -1,  1)
            p010 = Geom::Point3d::new(-1,  1, -1)
            p100 = Geom::Point3d::new( 1, -1, -1)
            p011 = Geom::Point3d::new(-1,  1,  1)
            p101 = Geom::Point3d::new( 1, -1,  1)
            p110 = Geom::Point3d::new( 1,  1, -1)
            p111 = Geom::Point3d::new( 1,  1,  1)

            # Create the faces of the die by joining the vertices with edges.
            faces = Array::new(6)
            faces[0] = die_mesh.add_face([p111, p011, p001, p101])
            faces[1] = die_mesh.add_face([p001, p000, p100, p101])
            faces[2] = die_mesh.add_face([p000, p001, p011, p010])
            faces[3] = die_mesh.add_face([p110, p111, p101, p100])
            faces[4] = die_mesh.add_face([p111, p110, p010, p011])
            faces[5] = die_mesh.add_face([p000, p100, p110, p010])

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
