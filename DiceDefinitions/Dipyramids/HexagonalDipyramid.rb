
module DiceGen
module Dice
module Definitions

    # This class defines the mesh model for a hexagonal dipyramid (non-standard D12).
    class HexagonalDipyramid < DieModel
        # Lays out the geometry for the die in a new ComponentDefinition and adds it to the main DefinitionList.
        #   def_name: The name of this definition. Every ComponentDefinition can be referenced with a unique name that
        #             is computed by appending this value to the name of the die model (separated by an underscore).
        #   vertex_scale: This value controls how much the vertexes of the pyramids protrude from the base. A value of 0
        #                 0 means they don't protrude at all (it reduces this shape to a hexagon), and a value of 1
        #                 makes the height of the pyramids equal to their side lengths.
        def initialize(def_name:, vertex_scale:)
            # Create a new definition for the die.
            definition = Util::MAIN_MODEL.definitions.add("#{self.class.name}_#{def_name}")
            mesh = definition.entities()

            c0 = 0.0
            c1 = 1.0
            c2 = (2.0 / Math.sqrt(3.0)) * vertex_scale
            c3 =     Math.sqrt(3.0) / 3.0
            c4 = 2 * Math.sqrt(3.0) / 3.0
            # Define all the points that make up the vertices of the die.
            v0 = Geom::Point3d::new( c0,  c0,  c2)
            v1 = Geom::Point3d::new( c0,  c0, -c2)
            v2 = Geom::Point3d::new( c1,  c3,  c0)
            v3 = Geom::Point3d::new( c1, -c3,  c0)
            v4 = Geom::Point3d::new(-c1,  c3,  c0)
            v5 = Geom::Point3d::new(-c1, -c3,  c0)
            v6 = Geom::Point3d::new( c0,  c4,  c0)
            v7 = Geom::Point3d::new( c0, -c4,  c0)

            # Create the faces of the die by joining the vertices with edges. #TODO FIX THIS
            faces = Array::new(12)
            faces[0]  = mesh.add_face([v0, v2, v6])
            faces[1]  = mesh.add_face([v0, v6, v4])
            faces[2]  = mesh.add_face([v0, v4, v5])
            faces[3]  = mesh.add_face([v0, v5, v7])
            faces[4]  = mesh.add_face([v0, v7, v3])
            faces[5]  = mesh.add_face([v0, v3, v2])
            faces[6]  = mesh.add_face([v1, v2, v3])
            faces[7]  = mesh.add_face([v1, v3, v7])
            faces[8]  = mesh.add_face([v1, v7, v5])
            faces[9]  = mesh.add_face([v1, v5, v4])
            faces[10] = mesh.add_face([v1, v4, v6])
            faces[11] = mesh.add_face([v1, v6, v2])

            #TODO MAKE THE SCALES!
            super(die_size: 1.0, die_scale: 1.0, font_size: 1.0, definition: definition, faces: faces)
        end

        # A hexagonal dipyramid with standard dimensions.
        STANDARD = HexagonalDipyramid::new(def_name: "Standard", vertex_scale: Math.sqrt(3.0))
        # A hexagonal dipyramid that has been flattened into a hexagon.
        FLAT = HexagonalDipyramid::new(def_name: "Flat", vertex_scale: 0.0)
        # A hexagonal dipyramid where each pyramid's height is equal to their side length.
        BALANCED = HexagonalDipyramid::new(def_name: "Balanced", vertex_scale: 1.0)
        # A hexagonal dipyramid composed entirely of equalateral faces. This model is equivalent to the 'Flat' model, since
        # hexagons are composed of 6 equalateral triangles internally.
        EQUALATERAL = HexagonalDipyramid::new(def_name: "Equalateral", vertex_scale: 0.0)

    end

end
end
end
