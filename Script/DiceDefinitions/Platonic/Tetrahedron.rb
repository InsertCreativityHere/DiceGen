
module DiceGen::Dice
    # This class defines the mesh model for a sharp-edged standard D4 die (a tetrahedron).
    class Tetrahedron < DieModel
        # Stores the order that numbers should be placed onto the faces of a D4 with. Each entry starts with the number
        # corresponding to a respective face, then lists the numbers for each remaining vertex in clockwise order.
        @@D4_NUMBERING = [[1, 2, 3], [2, 4, 3], [3, 4, 1], [4, 2, 1]]

        # An array of transformations used to place glyphs onto the vertexes of this die model. Normally, glyphs are
        # placed at the center of each face but for 'D4' type dice, the glyphs are placed at the tips of the faces next
        # to the vertexes. Each entry is a coordinate transformation like 'face_transforms', but rotated and scaled to
        # place the die in the corners instead of the center.
        # The transforms are stored in a 4x3 array, where vertex_transforms[i][j] is the transform for the jth vertex of
        # the ith face. Each transform is computed by translating up the y-axis, then rotating by either 0, 120, or 240
        # degrees depending on which corner the transform is for.
        attr_accessor :vertex_transforms

        # Lays out the geometry for the die in a new ComponentDefinition and adds it to the main DefinitionList.
        #   def_name: The name of this definition. Every ComponentDefinition can be referenced with a unique name that
        #             is computed by appending this value to the name of the die model (separated by an underscore).
        #   glyph_vertex_offset: The distance to offset each glyph from the center by for 'D4' type dice.
        def initialize(def_name:, glyph_vertex_offset:)
            # Create a new definition for the die.
            definition = Util::MAIN_MODEL.definitions.add("#{self.class.name}_#{def_name}")
            mesh = definition.entities()

            c0 = Math.sqrt(2.0) / 4.0
            # Define all the points that make up the vertices of the die.
            v0 = Geom::Point3d::new(-c0, -c0, -c0)
            v1 = Geom::Point3d::new(-c0,  c0,  c0)
            v2 = Geom::Point3d::new( c0, -c0,  c0)
            v3 = Geom::Point3d::new( c0,  c0, -c0)

            # Create the faces of the die by joining the vertices with edges. TODO FIX THIS!
            faces = Array::new(4)
            faces[0] = mesh.add_face([v2, v3, v1])
            faces[1] = mesh.add_face([v3, v2, v0])
            faces[2] = mesh.add_face([v1, v0, v2])
            faces[3] = mesh.add_face([v0, v1, v3])

            # The distance between a vertex and it's diametric face is 0.816497" in the base model, and standard D4
            # dice have a diametric distance of 18mm, so the model must be scaled by a factor of
            # 18mm / (0.816497")(25.4mm/") = 0.867929
            # Which is further scaled by 1000, since we treat mm as m in the model, to get 867.929
            super(die_size: 18.0, die_scale: 867.929, font_size: 6.0, definition: definition, faces: faces)

            # Create an array for storing the computed vertex transforms.
            @vertex_transforms = Array::new(4)
            # 120 degrees clockwise in radians. The angle between any two vertices of a face.
            angle = -120 * Util::DTOR
            # The distance to offset each glyph from the center for the vertex transforms.
            offset = 1000 * glyph_vertex_offset / 25.4

            # Iterate through each of the already calculated face transforms and compute a vertex transform for each of
            # the corners of the respective face.
            @face_transforms.each_with_index() do |face_transform, i|
                # Calculate the translation component by offseting the glyph in the local y-direction.
                translation = Geom::Transformation.translation(Util.scale_vector(face_transform.yaxis, offset))
                vertex_transforms[i] = Array::new(3)
                # Iterate through each of the 3 vertices to calculate the rotation component.
                (0..2).each() do |j|
                    # Rotate the glyph around the local z-axis and the center of the face by 120*j degrees clockwise.
                    rotation = Geom::Transformation.rotation(face_transform.origin, face_transform.zaxis, angle * j)
                    vertex_transforms[i][j] = rotation * translation * face_transform
                end
            end
        end

        # TODO
        def place_glyphs(font:, mesh:, type: nil, die_size: nil, font_size: nil, glyph_mapping: nil)
            # If the type is anything other than "D4", delegate to the default implementation.
            unless (type == "D4")
                return super
            end

            # If no glyph_mapping was provided, use the default mapping.
            glyph_mapping ||= "default"
            glyph_names = []
            glyph_angles = []
            # Look up the glyph mapping by name.
            if @glyph_mappings.key?(glyph_mapping)
                glyph_names, glyph_angles = @glyph_mappings[glyph_mapping]
            else
                model_name = self.class().name().split("::").last()
                raise "Specified glyph mapping: '#{glyph_mapping}' isn't defined for the #{model_name} die model."
            end

            # Calcaulte the scale factors for the die and the font.
            die_scale = (die_size.nil?()? 1.0 : (die_size.to_f() / @die_size))
            font_scale = (font_size.nil?()? 1.0 : (font_size.to_f() / @font_size))

            # Iterate through each face and generate glyphs at the vertices of the face.
            @vertex_transforms.each_with_index() do |vertex_transform, i|
                vertex_transform.each_with_index() do |transform, j|
                    # First scale and rotate the glyph, then perform the face-local coordinate transformation.
                    glyph_rotation = Geom::Transformation.rotation(ORIGIN, Z_AXIS, (glyph_angles[i] * Util::DTOR))
                    full_transform = transform * glyph_rotation * Geom::Transformation.scaling(font_scale)
                    # Then, translate the glyph by a z-offset that ensures the glyph and face are coplanar, even if the die
                    # has been scaled up.
                    offset_vector = Util.scale_vector(@face_transforms[i].origin - ORIGIN, (die_scale - 1.0))
                    full_transform = Geom::Transformation.translation(offset_vector) * full_transform

                    # Place the glyph at the jth vertex of the ith face.
                    glyph_name = glyph_names[@@D4_NUMBERING[i][j] - 1].to_s()
                    font.create_glyph(name: glyph_name, entities: mesh, transform: full_transform)
                end
            end
        end

        # A tetrahedron with standard dimensions.
        STANDARD = Tetrahedron::new(def_name: "Standard", glyph_vertex_offset: 6.25)

    end
end
