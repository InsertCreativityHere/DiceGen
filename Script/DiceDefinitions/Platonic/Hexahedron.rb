
module DiceGen::Dice
    # This class defines the mesh model for a sharp-edged standard D6 die (a hexhedron (fancy word for cube)).
    class Hexahedron < DieModel
        # Lays out the geometry for the die in a new ComponentDefinition and adds it to the main DefinitionList.
        #   def_name: The name of this definition. Every ComponentDefinition can be referenced with a unique name that
        #             is computed by appending this value to the name of the die model (separated by an underscore).
        def initialize(def_name:)
            # Create a new definition for the die.
            definition = Util::MAIN_MODEL.definitions.add("#{self.class.name}_#{def_name}")
            mesh = definition.entities()

            c0 = 0.5
            # Define all the points that make up the vertices of the die.
            v0 = Geom::Point3d::new( c0,  c0,  c0)
            v1 = Geom::Point3d::new( c0,  c0, -c0)
            v2 = Geom::Point3d::new( c0, -c0,  c0)
            v3 = Geom::Point3d::new( c0, -c0, -c0)
            v4 = Geom::Point3d::new(-c0,  c0,  c0)
            v5 = Geom::Point3d::new(-c0,  c0, -c0)
            v6 = Geom::Point3d::new(-c0, -c0,  c0)
            v7 = Geom::Point3d::new(-c0, -c0, -c0)

            # Create the faces of the die by joining the vertices with edges. #TODO FIX THIS
            faces = Array::new(6)
            faces[0] = mesh.add_face([v0, v1, v5, v4])
            faces[1] = mesh.add_face([v0, v4, v6, v2])
            faces[2] = mesh.add_face([v0, v2, v3, v1])
            faces[3] = mesh.add_face([v7, v3, v2, v6])
            faces[4] = mesh.add_face([v7, v6, v4, v5])
            faces[5] = mesh.add_face([v7, v5, v1, v3])

            # The distance between two diametric faces is 1" in the base model, and standard D6 dice have a
            # diametric distance of 15mm, so the model must be scaled by a factor of
            # 15mm / (1")(25.4mm/") = 0.590551
            # Which is further scaled by 1000, since we treat mm as m in the model, to get 590.551
            #
            # Glyph models are always 8mm tall when imported, and the glyphs on a D6 are 8mm tall, so no scaling is
            # necessary.
            super(die_size: 1.0, die_scale: 1.0, font_size: 1.0, font_scale: 1.0, definition: definition, faces: faces)
        end

        # A hexahedron with standard dimensions.
        STANDARD = Hexahedron::new(def_name: "Standard")

    end
end
