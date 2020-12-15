
module DiceGen
module Dice
module Definitions

    # This class defines the mesh model for a rhombic dodecahedron (non-standard D12).
    class RhombicDodecahedron < DieModel
        # Lays out the geometry for the die in a new ComponentDefinition and adds it to the main DefinitionList.
        #   def_name: The name of this definition. Every ComponentDefinition can be referenced with a unique name that
        #             is computed by appending this value to the name of the die model (separated by an underscore).
        def initialize(def_name:)
            # Create a new definition for the die.
            definition = Util::MAIN_MODEL.definitions.add("#{self.class.name}_#{def_name}")
            mesh = definition.entities()

            c0 = 0.0
            c1 = 3.0 * Math.sqrt(2.0) / 4.0
            c2 = 3.0 * Math.sqrt(2.0) / 8.0
            # Define all the points that make up the vertices of the die.
            v0  = Geom::Point3d::new( c1,  c0,  c0)
            v1  = Geom::Point3d::new(-c1,  c0,  c0)
            v2  = Geom::Point3d::new( c0,  c1,  c0)
            v3  = Geom::Point3d::new( c0, -c1,  c0)
            v4  = Geom::Point3d::new( c0,  c0,  c1)
            v5  = Geom::Point3d::new( c0,  c0, -c1)
            v6  = Geom::Point3d::new( c2,  c2,  c2)
            v7  = Geom::Point3d::new( c2,  c2, -c2)
            v8  = Geom::Point3d::new( c2, -c2,  c2)
            v9  = Geom::Point3d::new( c2, -c2, -c2)
            v10 = Geom::Point3d::new(-c2,  c2,  c2)
            v11 = Geom::Point3d::new(-c2,  c2, -c2)
            v12 = Geom::Point3d::new(-c2, -c2,  c2)
            v13 = Geom::Point3d::new(-c2, -c2, -c2)

            # Create the faces of the die by joining the vertices with edges. #TODO FIX THIS
            faces = Array::new(12)
            faces[0]  = mesh.add_face([v0,  v6,  v4,  v8])
            faces[1]  = mesh.add_face([v2,  v6,  v0,  v7])
            faces[2]  = mesh.add_face([v4,  v6,  v2, v10])
            faces[3]  = mesh.add_face([v0,  v9,  v5,  v7])
            faces[4]  = mesh.add_face([v3,  v9,  v0,  v8])
            faces[5]  = mesh.add_face([v5,  v9,  v3, v13])
            faces[6]  = mesh.add_face([v1, v11,  v5, v13])
            faces[7]  = mesh.add_face([v2, v11,  v1, v10])
            faces[8]  = mesh.add_face([v5, v11,  v2,  v7])
            faces[9]  = mesh.add_face([v1, v12,  v4, v10])
            faces[10] = mesh.add_face([v3, v12,  v1, v13])
            faces[11] = mesh.add_face([v4, v12,  v3,  v8])

            # The distance between two diametric faces is 1.5" in the base model, and this looks best with a
            # diametric distance of 17mm, so the model must be scaled by a factor of
            # 17mm / (1.5")(25.4mm/") = 0.446194
            # Which is further scaled by 1000, since we treat mm as m in the model, to get 446.194
            super(die_size: 17.0, die_scale: 446.194, font_size: 6.0, definition: definition, faces: faces)

            # Rotate each of the face transforms so that the glyphs are aligned between the top and the bottom vertices
            # of the rhombus, instead of being aligned with an edge as they normally are.
            angle = -Math::atan(Math.sqrt(2.0) * c2 / c1)
            @face_transforms.each_with_index() do |face_transform, i|
                rotation = Geom::Transformation.rotation(face_transform.origin, face_transform.zaxis, angle)
                @face_transforms[i] = rotation * face_transform
            end
        end

        # A rhombic dodecahedron with standard dimensions.
        STANDARD = RhombicDodecahedron::new(def_name: "Standard")

    end

end
end
end
