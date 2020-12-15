
module DiceGen
module Dice
module Definitions

    # This class defines the mesh model for a sharp-edged standard D12 die (a dodecahedron).
    # By default this model has a size of 18.5mm, and a font size of 6mm.
    class Dodecahedron < DieModel
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
            c3 = (3.0 + Math.sqrt(5.0)) / 4.0
            # Define all the points that make up the vertices of the die.
            v0  = Geom::Point3d::new( c0,  c1,  c3)
            v1  = Geom::Point3d::new( c0,  c1, -c3)
            v2  = Geom::Point3d::new( c0, -c1,  c3)
            v3  = Geom::Point3d::new( c0, -c1, -c3)
            v4  = Geom::Point3d::new( c3,  c0,  c1)
            v5  = Geom::Point3d::new( c3,  c0, -c1)
            v6  = Geom::Point3d::new(-c3,  c0,  c1)
            v7  = Geom::Point3d::new(-c3,  c0, -c1)
            v8  = Geom::Point3d::new( c1,  c3,  c0)
            v9  = Geom::Point3d::new( c1, -c3,  c0)
            v10 = Geom::Point3d::new(-c1,  c3,  c0)
            v11 = Geom::Point3d::new(-c1, -c3,  c0)
            v12 = Geom::Point3d::new( c2,  c2,  c2)
            v13 = Geom::Point3d::new( c2,  c2, -c2)
            v14 = Geom::Point3d::new( c2, -c2,  c2)
            v15 = Geom::Point3d::new( c2, -c2, -c2)
            v16 = Geom::Point3d::new(-c2,  c2,  c2)
            v17 = Geom::Point3d::new(-c2,  c2, -c2)
            v18 = Geom::Point3d::new(-c2, -c2,  c2)
            v19 = Geom::Point3d::new(-c2, -c2, -c2)

            # Create the faces of the die by joining the vertices with edges. #TODO FIX THIS
            faces = Array::new(12)
            faces[0]  = mesh.add_face([ v0,  v2, v14,  v4, v12])
            faces[1]  = mesh.add_face([ v0, v12,  v8, v10, v16])
            faces[2]  = mesh.add_face([ v0, v16,  v6, v18,  v2])
            faces[3]  = mesh.add_face([ v7,  v6, v16, v10, v17])
            faces[4]  = mesh.add_face([ v7, v17,  v1,  v3, v19])
            faces[5]  = mesh.add_face([ v7, v19, v11, v18,  v6])
            faces[6]  = mesh.add_face([ v9, v11, v19,  v3, v15])
            faces[7]  = mesh.add_face([ v9, v15,  v5,  v4, v14])
            faces[8]  = mesh.add_face([ v9, v14,  v2, v18, v11])
            faces[9]  = mesh.add_face([v13,  v1, v17, v10,  v8])
            faces[10] = mesh.add_face([v13,  v8, v12,  v4,  v5])
            faces[11] = mesh.add_face([v13,  v5, v15,  v3,  v1])

            # The distance between two diametric faces is 2.227033" in the base model, and standard D12 dice have a
            # diametric distance of 18.5mm, so the model must be scaled by a factor of
            # 18.5mm / (2.227033")(25.4mm/") = 0.327048
            # Which is further scaled by 1000, since we treat mm as m in the model, to get 327.048
            super(die_size: 18.5, die_scale: 327.048, font_size: 6.0, definition: definition, faces: faces)

            # Add the additional glyph mappings supported by this model.
            a0 = 0.0; a1 = 72.0; a2 = 144.0; a3 = 216.0; a4 = 288.0;
            #                                 1               5                  10
            @glyph_mappings["chessex"]   = [[10,  9,  5, 11,  3,  6,  4,  2,  1, 12,  7,  8],
                                            [a1, a2, a3, a3, a1, a2, a0, a4, a4, a3, a0, a4]]
        end

        # A dodecahedron with standard dimensions.
        STANDARD = Dodecahedron::new(def_name: "Standard")

    end

end
end
end
