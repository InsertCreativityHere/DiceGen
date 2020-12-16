
module DiceGen
module Dice
module Definitions

    # This class defines the mesh model for a deltoidal icositetrahedron (non-standard D24).
    class DeltoidalIcositetrahedron < DieModel
        # Lays out the geometry for the die in a new ComponentDefinition and adds it to the main DefinitionList.
        #   def_name: The name of this definition. Every ComponentDefinition can be referenced with a unique name that
        #             is computed by appending this value to the name of the die model (separated by an underscore).
        def initialize(def_name:)
            # Create a new definition for the die.
            definition = $MAIN_MODEL.definitions.add("#{self.class.name}_#{def_name}")
            mesh = definition.entities()

            c0 = 0.0
            c1 = 1.0
            c2 = Math.sqrt(2.0)
            c3 = (4.0 + Math.sqrt(2.0)) / 7.0
            # Define all the points that make up the vertices of the die.
            v0  = Geom::Point3d::new( c0,  c1,  c1)
            v1  = Geom::Point3d::new( c0,  c1, -c1)
            v2  = Geom::Point3d::new( c0, -c1,  c1)
            v3  = Geom::Point3d::new( c0, -c1, -c1)
            v4  = Geom::Point3d::new( c1,  c0,  c1)
            v5  = Geom::Point3d::new( c1,  c0, -c1)
            v6  = Geom::Point3d::new(-c1,  c0,  c1)
            v7  = Geom::Point3d::new(-c1,  c0, -c1)
            v8  = Geom::Point3d::new( c1,  c1,  c0)
            v9  = Geom::Point3d::new( c1, -c1,  c0)
            v10 = Geom::Point3d::new(-c1,  c1,  c0)
            v11 = Geom::Point3d::new(-c1, -c1,  c0)
            v12 = Geom::Point3d::new( c2,  c0,  c0)
            v13 = Geom::Point3d::new(-c2,  c0,  c0)
            v14 = Geom::Point3d::new( c0,  c2,  c0)
            v15 = Geom::Point3d::new( c0, -c2,  c0)
            v16 = Geom::Point3d::new( c0,  c0,  c2)
            v17 = Geom::Point3d::new( c0,  c0, -c2)
            v18 = Geom::Point3d::new( c3,  c3,  c3)
            v19 = Geom::Point3d::new( c3,  c3, -c3)
            v20 = Geom::Point3d::new( c3, -c3,  c3)
            v21 = Geom::Point3d::new( c3, -c3, -c3)
            v22 = Geom::Point3d::new(-c3,  c3,  c3)
            v23 = Geom::Point3d::new(-c3,  c3, -c3)
            v24 = Geom::Point3d::new(-c3, -c3,  c3)
            v25 = Geom::Point3d::new(-c3, -c3, -c3)

            # Create the faces of the die by joining the vertices with edges. #TODO FIX THIS
            faces = Array::new(24)
            faces[0]  = mesh.add_face([v16,  v4, v18,  v0])
            faces[1]  = mesh.add_face([v16,  v0, v22,  v6])
            faces[2]  = mesh.add_face([v16,  v6, v24,  v2])
            faces[3]  = mesh.add_face([v16,  v2, v20,  v4])
            faces[4]  = mesh.add_face([v17,  v7, v23,  v1])
            faces[5]  = mesh.add_face([v17,  v1, v19,  v5])
            faces[6]  = mesh.add_face([v17,  v5, v21,  v3])
            faces[7]  = mesh.add_face([v17,  v3, v25,  v7])
            faces[8]  = mesh.add_face([v12,  v5, v19,  v8])
            faces[9]  = mesh.add_face([v12,  v8, v18,  v4])
            faces[10] = mesh.add_face([v12,  v4, v20,  v9])
            faces[11] = mesh.add_face([v12,  v9, v21,  v5])
            faces[12] = mesh.add_face([v13,  v6, v22, v10])
            faces[13] = mesh.add_face([v13, v10, v23,  v7])
            faces[14] = mesh.add_face([v13,  v7, v25, v11])
            faces[15] = mesh.add_face([v13, v11, v24,  v6])
            faces[16] = mesh.add_face([v14,  v8, v19,  v1])
            faces[17] = mesh.add_face([v14,  v1, v23, v10])
            faces[18] = mesh.add_face([v14, v10, v22,  v0])
            faces[19] = mesh.add_face([v14,  v0, v18,  v8])
            faces[20] = mesh.add_face([v15,  v9, v20,  v2])
            faces[21] = mesh.add_face([v15,  v2, v24, v11])
            faces[22] = mesh.add_face([v15, v11, v25,  v3])
            faces[23] = mesh.add_face([v15,  v3, v21,  v9])

            # Compute the angle to rotate the glyphs by so they align with the axis of symmetry.
            angle = -Math.atan((v0 - v4).length() / (2.0 * (DiceUtil::find_face_center(faces[0]) - v16).length()))

            # The distance between two diametric faces is 2.440526" in the base model, and this looks best with a
            # diametric distance of 22mm, so the model must be scaled by a factor of
            # 22mm / (2.440526")(25.4mm/") = 0.354900
            # Which is further scaled by 1000, since we treat mm as m in the model, to get 354.900
            super(die_size: 22.0, die_scale: 354.900, font_size: 5, definition: definition, faces: faces)

            # Rotate each of the face transforms so that the glyphs are aligned between the top and the bottom vertices
            # of the rhombus, instead of being aligned with an edge as they normally are.
            @face_transforms.each_with_index() do |face_transform, i|
                rotation = Geom::Transformation.rotation(face_transform.origin, face_transform.zaxis, angle)
                @face_transforms[i] = rotation * face_transform
            end
        end

        # A deltoidal icositetrahedron with standard dimensions.
        STANDARD = DeltoidalIcositetrahedron::new(def_name: "Standard")

    end

end
end
end
