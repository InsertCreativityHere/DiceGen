
module DiceGen
module Dice

    include DiceGen

    #  Module containing dice specific utility code.
    module DiceUtil
        module_function

        # Computes the center-point of an edge by averaging the vertices at it's ends.
        #   edge: The edge segment to find the middle of.
        #   return: A Point3d holding the coordinates of the edge's middle.
        def find_edge_center(edge)
            return Geom::Point3d.linear_combination(0.5, edge.start.position(), 0.5, edge.end.position())
        end

        # Computes the geometric center-point of a face by average all it's vertices.
        #   face: The face to find the center of.
        #   return: A Point3d holding the coordinates of the face's geometric center.
        def find_face_center(face)
            x = 0; y = 0; z = 0;

            # Iterate through each of the vertices of the face and add them onto the totals.
            face.vertices().each() do |vertex|
                pos = vertex.position()
                x += pos.x(); y += pos.y(); z += pos.z();
            end

            # Compute the average position by dividing through by the total number of vertices.
            count = face.vertices().length()
            return Geom::Point3d::new(x / count, y / count, z / count)
        end

        # Computes and returns a transformation that maps the global coordinate system to a face local one where the
        # origin is at the center of the face, and the x,y plane is coplanar to the face, with the z axis pointing out.
        # All axes are, of course, an orthonormal basis when taken together.
        #   face: The face to compute the transform for.
        #   return: The transformation as described above.
        def get_face_transform(face)
            # Get the normal vector that's pointing out from the face. This is going to become the new '+z' direction.
            normal = face.normal()

            # Compute the center point of the face and the center it's bottom edge.
            face_center = find_face_center(face)
            edge_center = find_edge_center(face.edges()[0])

            # Compute the positive y axes by subtracting the centers and normalizing. By subtracting the face center
            # from the edge center we ensure that it's pointing up.
            y_vector = Geom::Vector3d::new((face_center - edge_center).to_a()).normalize()
            # Compute the positive x axis by crossing the y and z axes vectors, again minding the order.
            x_vector = y_vector.cross(normal)

            return Geom::Transformation.axes(face_center, x_vector, y_vector, normal)
        end

        # Computes a new array containing all the providing elements sorted by their containment heirarchy. If the bounds of
        # element1 strictly contain the bounds of element2, then element1 will appear before element2 in the sorted array.
        # The algorithm this method computes the opposite and reverses the list at the end.
        #   elements: The array of elements to be sorted. This array isn't altered by the method.
        #   return: An array with all the elements sorted by their containment heirarchy.
        def sort_by_bounds(elements)
            sorted_elements = Array::new()

            # Iterate through the provided elements.
            elements.each() do |element|
                # Iterate through every element already in the list. If the current element is contained by any of these, we
                # insert the current element immediately before it's container. If no element contains the current element, this
                # flag remains unset, and the current element is appended at the end (indicating it's a top-level container).
                is_toplevel = true

                sorted_elements.each_with_index() do |test_element, i|
                    # Check if the current element is contained by the test_element.
                    if (test_element.bounds().contains?(element.bounds()))
                        sorted_elements.insert(i, element)
                        is_toplevel = false
                        break
                    end
                end

                if (is_toplevel)
                    sorted_elements.push(element)
                end
            end

            # Reverse the list and return it.
            sorted_elements.reverse!()
            return sorted_elements
        end

        # Removes and returns the outer-most loop from an array of loops.
        # If none of the loops are marked as an outer-most loop, this raises an exception.
        #   loops: Array of loops to search for the outer-most loop.
        #   return: A reference to the outer-most loop, or an exception if none were found.
        def get_outer_loop(loops)
            loops.each() do |loop|
                if (loop.outer?())
                    loops.delete(loop)
                    return loop
                end
            end
            raise "No outermost loop was found."
        end

        # Transforms an array of points. This doesn't transform the provided array in place,
        # and instead returns a new array that contains the transformed points.
        #   points: Array of points that should be transformed.
        #   transform: The transform to apply to each of the points.
        #   return: An array containing the resulting points after they've been transformed.
        def transform_points(points:, transform:)
            # Convert any vertices into points.
            results = Array::new(points.length())
            points.each_with_index() do |point, i|
                if (point.is_a?(Sketchup::Vertex))
                    results[i] = point.position()
                else
                    results[i] = point
                end
            end

            results.each() do |point|
                point.transform!(transform)
            end
            return results
        end
    end

    # Abstract base class for all die models.
    class DieModel
        # The ComponentDefinition that defines the die's mesh model.
        attr_reader :definition
        # The size of the die in mm, calculated by measuring the distance between two diametric faces, or a face and the
        # vertex diametrically opposed to it if necessary (such as for a tetrahedron (D4)).
        attr_accessor :die_size
        # The height of the glyphs on the die in mm.
        attr_accessor :font_size
        # An array of transformations used to place glyphs onto the faces of this die model. Each entry is a coordinate
        # transformation that maps the standard world coordinates to a face-local system with it's origin at the
        # geometric center of the face, and it's axes rotated to be coplanar to the face (with +z pointing out).
        # Each face has it's respective transformation, and they're ordered in the same way faces are numbered by.
        attr_reader :face_transforms
        # A hash of glyph mappings keyed by their names. Each glyph mapping is made up of 2 arrays. The first specifies
        # what glyph should be placed on a face, and the second array specifies the angle that the glyph should be
        # rotated by prior to embossing. The arrays follow the same order as the faces, so the 'i'th entry in each
        # array will be used for the 'i'th face of the die.
        attr_reader :glyph_mappings

        # Super constructor for all dice models that stores the die's model definition, and computes a set of
        # transformations from the die's faces that can be used to easily add glyphs to the die later on.
        #   definition: The ComponentDefinition that holds the die's mesh definition.
        #   faces: Array of all the die's faces, in the same order the face's should be numbered by.
        #   die_size: The distance between two diametrically opposed faces of the die (in mm), or between a face
        #             and the vertex diametric to it if no diametric face exists (such as a tetrahedron (D4)).
        #   die_scale: The amount to scale the die model by to make it 'die_size' mm large. This scaling is applied
        #              before any glyphs are placed onto the die.
        #   font_size: The height to scale the glyphs to before embossing them onto the die (in mm).
        def initialize(definition:, faces:, die_size:, die_scale:, font_size:)
            @definition = definition
            @die_size = die_size
            @font_size = font_size
            entities = @definition.entities()
            entities.transform_entities(Geom::Transformation.scaling(die_scale), entities.to_a())

            # Glyphs are nominally 8mm high, so the font_scale factor can be computed by dividing the font_size by 8.
            font_scale = font_size / 8.0

            # Allocate an array for storing all the face transforms.
            face_count = faces.length()
            @face_transforms = Array::new(face_count)

            # Iterate through each face of the die and compute their face-local coordinate transformations.
            faces.each_with_index() do |face, i|
                @face_transforms[i] = DiceUtil.get_face_transform(face) * Geom::Transformation.scaling(font_scale)
            end

            # Create a hash to hold the glyph mappings and add the default mapping into it.
            @glyph_mappings = {"default" => [(1..face_count).to_a(), ([0.0] * face_count)]}
        end

        # Sets how much each glyph should be offset in the x and y direction relative to the face it's being placed on.
        # Calling this function a second time will not remove the previous glyph offsets, and instead will combine the
        # two offsets togther. It is advised that this method should only be called once.
        #   x_offset: The distance to offset the glyph in the horizontal direction (in mm).
        #   y_offset: The distance to offset the glyph in the vertical direction (in mm).
        def set_glyph_offsets(x_offset, y_offset)
            @face_transforms.each() do |face_transform|
                # Add an extra translation transformsion that offsets the glyphs in face-local coordinates.
                offset_vector = Util.scale_vector(face_transform.xaxis, Util::MTOI * x_offset) +
                                Util.scale_vector(face_transform.yaxis, Util::MTOI * y_offset)
                @face_transform = Geom::Transformation.translation(offset_vector) * @face_transform
            end
        end

        # Looks up the provided glyph mapping (or uses the default glyph mapping if none was provided) and returns the
        # arrays specifying which glyph to emboss on which face and what angle they should be rotated by.
        #   glyph_mapping: The name of the glyph mapping that should be resolved, or nil to use the default mapping.
        #   returns: The array components of the glyph mapping. The first array specifies the name of the glyph that
        #            should be embossed on each face (the ith entry is the glyph that should be used on the ith face),
        #            and the second array specifies what angle each glyph should be rotated by.
        def resolve_glyph_mapping(glyph_mapping)
            # If no glyph_mapping was provided, use the default mapping.
            glyph_mapping ||= "default"
            glyph_names = []
            glyph_angles = []
            # Look up the glyph mapping by name.
            if @glyph_mappings.key?(glyph_mapping)
                return @glyph_mappings[glyph_mapping]
            else
                model_name = self.class().name().split("::").last()
                raise "Specified glyph mapping: '#{glyph_mapping}' isn't defined for the #{model_name} die model."
            end
        end

        # Creates a new instance of this die with the specified type and font, amoungst other arguments.
        #   font: The font to use for generating glyphs on the die. If set to nil, no glyphs will be embossed onto the
        #         die. Defaults to nil.
        #   type: Either the stringified name for the type of die being created, or the maximum number to count up to.
        #         When specified as a number, it must divide the number of glyph faces on the die. If the type number
        #         is the same as the number of faces, the die will be numbered 'standardly', otherwise the glyphs are
        #         simply repeated. For example, creating a D20 with a type of 5, will cause each number to be repeated
        #         4 times. There are also special types of die that can only be used for some models, for example 'D4'
        #         will only work with a Tetrahedron, and places glyphs in the corners instead of the face. The following
        #         list contains every special type of die: "D4", "D%". If set as nil, the type will be set to the number
        #         of faces on the die, producing a die with no repeated glyphs. Defaults to nil.
        #   group: The group to generate the die into. If left 'nil' then a new top-level group is created for it.
        #          In practice, the die is always created within it's own die group, and the die group is what's placed
        #          into the provided group. Defaults to nil.
        #   scale: The amount to scale the die by after it's been created. Defaults to 1.0 (no scaling).
        #   depth: The depth to emboss the glyphs into the die by in mm. Defaults to 0mm (no embossing).
        #   die_size: The size to make the die in mm. Specifically this sets the distance between two diametric faces,
        #             or a face and the vertex diametrically opposite to it if necessary (like for tetrahedrons (D4)).
        #             If left as nil, it uses the default size for the die. Defaults to nil.
        #   font_size: The height to make the glyphs on the die, in mm. If nil, it uses the default glyph size for the
        #              die. Defaults to nil.
        #   glyph_mapping: String representing which glyph mapping to use. If left as nil, the default mapping is used
        #                  where no rotating is performed, and each face is embossed with a glyph corresponding to it's
        #                  numerical index.
        #   transform: A custom transformation that is applied to the die after generation. Defaults to no transform.
        def create_instance(font: nil, type: nil, group: nil, scale: 1.0, depth: 0.0, die_size: nil, font_size: nil, glyph_mapping: nil, transform: IDENTITY)
            # If no group was provided, create a new top-level group for the die.
            group ||= $MAIN_MODEL.entities().add_group()

            # Start a new operation so that creating the die can be undone/aborted if necessary.
            $MAIN_MODEL.start_operation('Create ' + self.class.name.split('::').last(), true)

            # Create an instance of the die model within the enclosing group.
            # We have to make 2 instances so that 'make_unique' works correctly. If only one instance exists,
            # make_unique does nothing, since it's already unique, and hence changes to the die affect the definition
            # when it shouldn't. By making a fake_instance first, when we call make_unique on the second instance, it
            # will actually create a new underlying definition for it, preventing any changes to the die from leaking
            # through to the definition.
            fake_instance = group.entities().add_instance(@definition, IDENTITY)
            instance = group.entities().add_instance(@definition, IDENTITY).make_unique()
            fake_instance.erase!()

            die_def = instance.definition()
            die_mesh = die_def.entities()
            # Scale the die mesh model to the specified size.
            unless die_size.nil?()
                die_mesh.transform_entities(Geom::Transformation.scaling(die_size.to_f() / @die_size), die_mesh.to_a())
            end

            # Create a separate group for temporarily placing glyphs into.
            glyph_group = group.entities().add_group()
            glyph_mesh = glyph_group.entities()

            unless font.nil?()
                # Get the array containing each of the glyph definitions.
                glyph_array = get_glyphs(font: font, mesh: glyph_mesh, type: type, font_size: font_size, glyph_mapping: glyph_mapping)
                # Emboss the glyphs onto the die.
                emboss_glyphs(die_mesh: die_mesh, glyphs: glyph_array, die_size: die_size, depth: depth)
            end

            # Delete the temporary glyph group.
            glyph_group.erase!()
            # Force Sketchup to recalculate the bounds of the die so future operations function correctly.
            die_def.invalidate_bounds()

            # Combine the scaling transformation with the provided external transform and apply them both to the die.
            die_mesh.transform_entities(transform * Geom::Transformation.scaling(scale), die_mesh.to_a())

            # Commit the operation to signal to Sketchup that the die has been created.
            $MAIN_MODEL.commit_operation()
        end

        # TODO
        def get_glyphs(font:, mesh:, type: nil, font_size: nil, glyph_mapping: nil)
            # If no type was provided, set it the number of faces on the die.
            type ||= @face_transforms.length()

            # First ensure that the die model is compatible with the provided type.
            unless (@face_transforms.length() % type == 0)
                face_count = @face_transforms.length()
                raise "Incompatible die type: a D#{face_count} model cannot be used to generate D#{type} dice."
            end

            # Resolve the glyph mapping to an array of glyphs and the angles to rotate them by.
            glyph_names, glyph_angles = resolve_glyph_mapping(glyph_mapping)

            # Calculate the scale factor for the font.
            font_scale = (font_size.nil?()? 1.0 : (font_size.to_f() / @font_size))

            # Create an array for storing the glyphs in.
            glyph_instances = Array::new(@face_transforms.length())
            # Iterate through each face in order and generate the corresponding number on it.
            @face_transforms.each_with_index() do |face_transform, i|
                # Calculate the transformation to scale and rotate the glyphs.
                glyph_rotation = Geom::Transformation.rotation(ORIGIN, Z_AXIS, (glyph_angles[i] * Util::DTOR))
                full_transform = glyph_rotation * Geom::Transformation.scaling(font_scale)

                glyph_name = glyph_names[i % type].to_s()
                instance = font.create_glyph(name: glyph_name, entities: mesh, transform: full_transform)
                glyph_instances[i] = instance
            end
            return glyph_instances
        end

        # TODO
        def emboss_glyphs(die_mesh:, glyphs:, die_size: nil, depth: 0.0)
            glyphs.each_with_index() do |glyph, i|
                # Get all the faces that make up the current glyphs.
                faces = glyph.definition.entities().grep(Sketchup::Face)
                glyph_transform = glyph.transformation()

                # Calculate the die's scale factor.
                die_scale = (die_size.nil?()? 1.0 : (die_size.to_f() / @die_size))
                # Calculate the full face transform that accounts for die scaling.
                offset_vector = Util.scale_vector(@face_transforms[i].origin - ORIGIN, (die_scale - 1.0))
                full_transform = Geom::Transformation.translation(offset_vector) * @face_transforms[i] * glyph_transform

                # Sort the faces by containment order and emboss them onto the die in order.
                (DiceUtil.sort_by_bounds(faces)).each() do |face|
                    # Get the loops that bound the face.
                    loops = face.loops()

                    # Remove the outer-most loop from the array so we can handle it first.
                    outer_loop = DiceUtil.get_outer_loop(loops)
                    # Create the main face by placing the outer loop onto the die.
                    main_face = die_mesh.add_face(DiceUtil.transform_points(points: outer_loop.vertices(), transform: full_transform))

                    # Create the inner faces on the die from their loops afterwards.
                    loops.each() do |loop|
                        die_mesh.add_face(DiceUtil.transform_points(points: loop.vertices(), transform: full_transform))
                    end

                    # Emboss the face by pushing it into the die.
                    unless (depth == 0.0)
                        main_face.pushpull(-depth * Util::MTOI)
                    end
                end
            end
        end
    end

end
end
