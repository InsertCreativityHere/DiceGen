
module DiceGen::Dice
    # This class defines the mesh model for a sharp-edged standard D20 die (an icosahedron).
    class Icosahedron < DieModel
        # Lays out the geometry for the die in a new ComponentDefinition and adds it to the main DefinitionList.
        #   def_name: The name of this definition. Every ComponentDefinition can be referenced with a unique name that
        #             is computed by appending this value to the name of the die model (separated by an underscore).
        def initialize(def_name:)
            # Create a new definition for the die.
            definition = Util::MAIN_MODEL.definitions.add("#{self.class.name}_#{def_name}")
            mesh = definition.entities()

            c0 = 0.0
            c1 = 0.5
            c2 = (1.0 + Math.sqrt(5.0)) / 4.0
            # Define all the points that make up the vertices of the die.
            v0  = Geom::Point3d::new( c0,  c2,  c1)
            v1  = Geom::Point3d::new( c0,  c2, -c1)
            v2  = Geom::Point3d::new( c0, -c2,  c1)
            v3  = Geom::Point3d::new( c0, -c2, -c1)
            v4  = Geom::Point3d::new( c1,  c0,  c2)
            v5  = Geom::Point3d::new( c1,  c0, -c2)
            v6  = Geom::Point3d::new(-c1,  c0,  c2)
            v7  = Geom::Point3d::new(-c1,  c0, -c2)
            v8  = Geom::Point3d::new( c2,  c1,  c0)
            v9  = Geom::Point3d::new( c2, -c1,  c0)
            v10 = Geom::Point3d::new(-c2,  c1,  c0)
            v11 = Geom::Point3d::new(-c2, -c1,  c0)

            # Create the faces of the die by joining the vertices with edges. #TODO FIX THIS
            faces = Array::new(20)
            faces[0]  = mesh.add_face([v4,  v6,  v2])
            faces[1]  = mesh.add_face([v4,  v2,  v9])
            faces[2]  = mesh.add_face([v4,  v9,  v8])
            faces[3]  = mesh.add_face([v4,  v8,  v0])
            faces[4]  = mesh.add_face([v4,  v0,  v6])
            faces[5]  = mesh.add_face([v7,  v5,  v3])
            faces[6]  = mesh.add_face([v7,  v3, v11])
            faces[7]  = mesh.add_face([v7, v11, v10])
            faces[8]  = mesh.add_face([v7, v10,  v1])
            faces[9]  = mesh.add_face([v7,  v1,  v5])
            faces[10] = mesh.add_face([v6, v10, v11])
            faces[11] = mesh.add_face([v6, v11,  v2])
            faces[12] = mesh.add_face([v2, v11,  v3])
            faces[13] = mesh.add_face([v2,  v3,  v9])
            faces[14] = mesh.add_face([v9,  v3,  v5])
            faces[15] = mesh.add_face([v9,  v5,  v8])
            faces[16] = mesh.add_face([v8,  v5,  v1])
            faces[17] = mesh.add_face([v8,  v1,  v0])
            faces[18] = mesh.add_face([v0,  v1, v10])
            faces[19] = mesh.add_face([v0, v10,  v6])

            # The distance between two diametric faces is 1.511523" in the base model, and standard D20 dice have a
            # diametric distance of 20mm, so the model must be scaled by a factor of
            # 20mm / (1.511523")(25.4mm/") = 0.520933
            # Which is further scaled by 1000, since we treat mm as m in the model, to get 520.933
            #
            # Glyph models are always 8mm tall when imported, and the glyphs on a D20 are 4.5mm tall, so glyphs must
            # be scaled by a factor of 4.5mm/8mm = 0.5625
            super(die_size: 1.0, die_scale: 1.0, font_size: 1.0, font_scale: 1.0, definition: definition, faces: faces)
        end

        # An icosahedron with standard dimensions.
        STANDARD = Icosahedron::new(def_name: "Standard")

    end
end
