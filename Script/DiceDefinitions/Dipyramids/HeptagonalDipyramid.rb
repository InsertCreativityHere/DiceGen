
module DiceGen::Dice
    # This class defines the mesh model for a heptagonal dipyramid (non-standard D14).
    class HeptagonalDipyramid < DieModel
        CSIN = Math.sin(Math::PI / 7.0)
        CCOS = Math.cos(Math::PI / 7.0)

        # Lays out the geometry for the die in a new ComponentDefinition and adds it to the main DefinitionList.
        #   def_name: The name of this definition. Every ComponentDefinition can be referenced with a unique name that
        #             is computed by appending this value to the name of the die model (separated by an underscore).
        #   vertex_scale: This value controls how much the vertexes of the pyramids protrude from the base. A value of 0
        #                 0 means they don't protrude at all (it reduces this shape to a heptagon), and a value of 1
        #                 makes the height of the pyramids equal to their side lengths.
        def initialize(def_name:, vertex_scale:)
            # Create a new definition for the die.
            definition = Util::MAIN_MODEL.definitions.add("#{self.class.name}_#{def_name}")
            mesh = definition.entities()

            ca = Math.sin(2.0 * Math::PI / 7.0)
            cb = Math.cos(2.0 * Math::PI / 7.0)
            c0 = 0.0
            c1 = 1.0
            c2 =  cb / ca
            c3 = 1.0 / ca
            c4 = 2.0 * cb
            c5 = (1.0 / CCOS) * vertex_scale
            c6 = (1.0 / (2.0 * CSIN)) - (2.0 * CSIN)
            c7 = (1.0 / (2.0 * CSIN))
            c8 = (1.0 / (2.0 * CCOS))
            # Define all the points that make up the vertices of the die.
            v0 = Geom::Point3d::new( c0,  c0,  c5)
            v1 = Geom::Point3d::new( c0,  c0, -c5)
            v2 = Geom::Point3d::new( c4,  c6,  c0)
            v3 = Geom::Point3d::new(-c4,  c6,  c0)
            v4 = Geom::Point3d::new( c1, -c2,  c0)
            v5 = Geom::Point3d::new(-c1, -c2,  c0)
            v6 = Geom::Point3d::new( c8,  c7,  c0)
            v7 = Geom::Point3d::new(-c8,  c7,  c0)
            v8 = Geom::Point3d::new( c0, -c3,  c0)

            # Create the faces of the die by joining the vertices with edges. #TODO FIX THIS
            faces = Array::new(14)
            faces[0]  = mesh.add_face([v0, v2, v6])
            faces[1]  = mesh.add_face([v0, v6, v7])
            faces[2]  = mesh.add_face([v0, v7, v3])
            faces[3]  = mesh.add_face([v0, v3, v5])
            faces[4]  = mesh.add_face([v0, v5, v8])
            faces[5]  = mesh.add_face([v0, v8, v4])
            faces[6]  = mesh.add_face([v0, v4, v2])
            faces[7]  = mesh.add_face([v1, v2, v4])
            faces[8]  = mesh.add_face([v1, v4, v8])
            faces[9]  = mesh.add_face([v1, v8, v5])
            faces[10] = mesh.add_face([v1, v5, v3])
            faces[11] = mesh.add_face([v1, v3, v7])
            faces[12] = mesh.add_face([v1, v7, v6])
            faces[13] = mesh.add_face([v1, v6, v2])

            #TODO MAKE THE SCALES!
            super(definition: definition, faces: faces)
        end

        # A heptagonal dipyramid with standard dimensions.
        STANDARD = HeptagonalDipyramid::new(def_name: "Standard", vertex_scale: (CCOS / (2.0 * CSIN ** 2)))
        # A heptagonal dipyramid that has been flattened into a triangle.
        FLAT = HeptagonalDipyramid::new(def_name: "Flat", vertex_scale: 0.0)
        # A heptagonal dipyramid where each pyramid's height is equal to their side length.
        BALANCED = HeptagonalDipyramid::new(def_name: "Balanced", vertex_scale: 1.0)
        # It is impossible for the faces of an heptagonal dipyramid to be equalateral triangles.

    end
end
