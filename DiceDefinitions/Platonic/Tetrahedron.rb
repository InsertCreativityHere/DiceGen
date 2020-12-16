
module DiceGen
module Dice
module Definitions

    # This class defines the mesh model for a sharp-edged standard D4 die (a tetrahedron).
    # By default this model has a size of 18mm, and a font size of 6mm.
    class Tetrahedron < DieModel
        # Dictionary that stores the order that numbers should be placed onto the faces of a D4 with for each glyph
        # mapping. Each value is a 2D array that stores which glyph should be placed on the jth vertex of the ith face.
        attr_accessor :d4_numbering

        # An array of transformations used to place glyphs onto the vertexes of this die model. Normally, glyphs are
        # placed at the center of each face but for 'D4' type dice, the glyphs are placed at the tips of the faces next
        # to the vertexes. These transforms offset the glyph from the center, then rotate them by 0, 120, or 240 degrees
        # depending on which corner the glyph is being placed into.
        attr_accessor :vertex_transforms

        # Lays out the geometry for the die in a new ComponentDefinition and adds it to the main DefinitionList.
        #   def_name: The name of this definition. Every ComponentDefinition can be referenced with a unique name that
        #             is computed by appending this value to the name of the die model (separated by an underscore).
        #   glyph_vertex_offset: The distance to offset each glyph from the center by for 'D4' type dice.
        def initialize(def_name:, glyph_vertex_offset:)
            # Create a new definition for the die.
            definition = $MAIN_MODEL.definitions.add("#{self.class.name}_#{def_name}")
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

            @d4_numbering = {"default" => [[1, 2, 3], [2, 4, 3], [3, 4, 1], [4, 2, 1]]}
            # Add the additional glyph mappings supported by this model.
            a0 = 0.0; a1 = 120.0; a2 = 240.0;
            @glyph_mappings["chessex"]   = [[1, 4, 2, 3], [a2, a0, a0, a2]]
            @d4_numbering["chessex"]     = [[1, 2, 3], [2, 4, 3], [3, 4, 1], [4, 2, 1]]
            @glyph_mappings["rybonator"] = [[1, 4, 2, 3], [a2, a0, a0, a2]]
            @d4_numbering["rybonator"]   = [[1, 2, 3], [2, 4, 3], [3, 4, 1], [4, 2, 1]]

            # 120 degrees clockwise in radians. The angle between any two vertices of a face.
            angle = -120 * Util::DTOR
            # Compute the distance to offset each glyph from the center for the vertex transforms.
            offset = glyph_vertex_offset * Util::MTOI
            translation = Geom::Transformation.translation(Geom::Vector3d::new(0, offset, 0))

            # Compute the vertex transforms. These are applied before the face transforms and are for moving and
            # aligning glyphs into the corners of each face of the D4.
            @vertex_transforms = Array::new(3)
            (0..2).each() do |i|
                # Rotate the glyph around the z-axis and the origin by 120*j degrees clockwise.
                rotation = Geom::Transformation.rotation(ORIGIN, Z_AXIS, angle * i)
                @vertex_transforms[i] = rotation * translation
            end
        end

        #TODO
        def get_glyphs(font:, mesh:, type: nil, font_size: nil, glyph_mapping: nil)
            # If the type is anything other than "D4", delegate to the default implementation.
            unless (type == "D4")
                return super
            end

            # Resolve the glyph mapping to an array of glyphs and the angles to rotate them by.
            glyph_names, glyph_angles = resolve_glyph_mapping(glyph_mapping)

            # Calculate the scale factor for the font.
            font_scale = (font_size.nil?()? 1.0 : (font_size.to_f() / @font_size))

            # Create an array for storing the glyphs in.
            glyph_instances = Array::new(@face_transforms.length())
            # Iterate through each face in order and generate the corresponding numbers on it.
            @face_transforms.each_with_index() do |face_transform, i|
                # Create a group for placing the multiple glyphs into and add it into the instances list.
                glyph_group = mesh.add_group()
                glyph_instances[i] = glyph_group
                glyph_mesh = glyph_group.entities()

                # Iterate through each vertex and create a glyph in it.
                @vertex_transforms.each_with_index() do |transform, j|
                    # Calculate the transformations to scale and rotate the glyphs.
                    glyph_rotation = Geom::Transformation.rotation(ORIGIN, Z_AXIS, (glyph_angles[i] * Util::DTOR))
                    full_transform = glyph_rotation * transform * Geom::Transformation.scaling(font_scale)

                    # Place and explode the glyph at the jth vertex of the ith face in the group's mesh.
                    # We explode it to prevent having more than 1 layer of nesting, which messes up the embossing.
                    glyph_name = @d4_numbering[glyph_mapping][glyph_names[i] - 1][j].to_s()
                    font.create_glyph(name: glyph_name, entities: glyph_mesh, transform: full_transform).explode()
                end
            end
            return glyph_instances
        end

        # A tetrahedron with standard dimensions.
        STANDARD = Tetrahedron::new(def_name: "Standard", glyph_vertex_offset: 6.25)

    end

end
end
end
