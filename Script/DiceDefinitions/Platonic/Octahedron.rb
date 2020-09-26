
module DiceGen::Dice
    # This class defines the mesh model for a sharp-edged standard D8 die (an equilateral octahedron).
    # By default this model has a size of 15mm, and a font size of 7mm.
    class Octahedron < DieModel
        # Lays out the geometry for the die in a new ComponentDefinition and adds it to the main DefinitionList.
        #   def_name: The name of this definition. Every ComponentDefinition can be referenced with a unique name that
        #             is computed by appending this value to the name of the die model (separated by an underscore).
        def initialize(def_name:)
            # Create a new definition for the die.
            definition = Util::MAIN_MODEL.definitions.add("#{self.class.name}_#{def_name}")
            mesh = definition.entities()

            c0 = 0.0
            c1 = Math.sqrt(2.0) / 2.0
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

            # The distance between two diametric faces is 0.816497" in the base model, and standard D8 dice have a
            # diametric distance of 15mm, so the model must be scaled by a factor of
            # 15mm / (0.816497")(25.4mm/") = 0.723274
            # Which is further scaled by 1000, since we treat mm as m in the model, to get 723.274
            super(die_size: 15.0, die_scale: 723.274, font_size: 7.0, definition: definition, faces: faces)

            # Add the additional glyph mappings supported by this model.
            a0 = 0.0; a1 = 120.0; a2 = 240;
            @glyph_mappings["chessex"]   = [[1, 7, 5, 3, 2, 8, 6, 4], [a1] * 8]
            @glyph_mappings["rybonator"] = [[1, 3, 5, 7, 6, 8, 2, 4], [a1] * 8]
        end

        # An octahedron with standard dimensions.
        STANDARD = Octahedron::new(def_name: "Standard")

    end
end
