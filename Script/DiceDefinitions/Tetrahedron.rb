
module DiceGen
    # This class defines the mesh model for a sharp-edged standard D4 die (a tetrahedron).
    class Tetrahedron < Die
        # Lays out the geometry for the die in a new ComponentDefinition and adds it to the main DefinitionList.
        def initialize()
            # Create a new definition for the die.
            definition = Util::MAIN_MODEL.definitions.add(self.class.name)
            mesh = definition.entities()

            C0 = Math.sqrt(2) / 4
            # Define all the points that make up the vertices of the die.
            V0 = Geom::Point3d::new(-C0, -C0, -C0)
            V1 = Geom::Point3d::new(-C0,  C0,  C0)
            V2 = Geom::Point3d::new( C0, -C0,  C0)
            V3 = Geom::Point3d::new( C0,  C0, -C0)

            # Create the faces of the die by joining the vertices with edges. TODO FIX THIS!
            faces = Array::new(4)
            faces[0] = mesh.add_face([V2, V3, V1])
            faces[1] = mesh.add_face([V3, V2, V0])
            faces[2] = mesh.add_face([V1, V0, V2])
            faces[3] = mesh.add_face([V0, V1, V3])

            # The distance between a vertex and it's diametric face is 2.3094" in the base model, and standard D4
            # dice have a diametric distance of 18mm, so the model must be scaled by a factor of
            # 18mm / (2.3094")(25.4mm/") = 0.30686
            # Which is further scaled by 1000, since we treat mm as m in the model, to get 306.86
            #
            # Glyph models are always 8mm tall when imported, and the glyphs on a D4 are 6mm tall, so glyphs must
            # be scaled by a factor of 6mm/8mm = 0.75
            super(definition: definition, faces: faces, die_scale: 306.86, font_scale: 0.75)

            # D4s are numbered at their vertices instead of at the center of their faces, so we need to compute
            # a special set of face transforms for it, split in a 2D array. The first index is the face index, and
            # the second index represents the jth vertex of that face.
            # To compute them we take the normal face transforms, translate it up on the y-axis (to make the glyph
            # in the corner instead of at the center), and rotate it for other vertices.

            # Create a 4x3 array, where vertex_transforms[i][j] is the transform for the jth vertex of the ith face.
            vertex_transforms = Array::new(4)
            # 120 degrees clockwise in radians. The angle between any two vertices of a face.
            angle = -120 * Math::PI / 180

            # Iterate through each of the alreay calculated face transforms and compute 3 vector transforms from it.
            @face_transforms.each_with_index() do |face_transform, i|
                # Calculate the translation component by offseting the glyph 6.25mm (246") in the local y-direction.
                translation = Geom::Transformation.translation(Util.scale_vector(face_transform.yaxis, 246))
                vertex_transforms[i] = Array::new(3)
                # Iterate through each of the 3 vertices to calculate the rotation component.
                (0..2).each() do |j|
                    # Rotate the glyph around the local z-axis and the center of the face by 120j degrees clockwise.
                    rotation = Geom::Transformation.rotation(face_transform.origin, face_transform.zaxis, angle * j)
                    vertex_transforms[i][j] = rotation * translation * face_transform
                end
            end
            @face_transforms = vertex_transforms
        end

        # TODO
        def place_glyphs(font:, mesh:, type: "D4", font_scale: 1.0, font_offset: [0,0])
            if (type != "D4")
                raise "Incompatible die type: a D4 model cannot be used to generate #{type.to_s()} dice."
            end

            # Iterate through each face and generate glyphs at the vertices of the face.
            @face_transforms.each_with_index() do |face_transform, i|
                face_transform.each_with_index() do |transform, j|
                    # Place the correct glyph at the jth vertex of the ith face.
                    font.create_glyph(name: DiceUtil::D4_NUMBERING[i][j], entities: mesh, transform: transform)
                end
            end
        end
    end
end
