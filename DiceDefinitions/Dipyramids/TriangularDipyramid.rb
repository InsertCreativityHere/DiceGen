
module DiceGen
module Dice
module Definitions

    # This class defines the mesh model for a triangular dipyramid (non-standard D6).
    class TriangularDipyramid < DieModel
        # Lays out the geometry for the die in a new ComponentDefinition and adds it to the main DefinitionList.
        #   def_name: The name of this definition. Every ComponentDefinition can be referenced with a unique name that
        #             is computed by appending this value to the name of the die model (separated by an underscore).
        #   vertex_scale: This value controls how much the vertexes of the pyramids protrude from the base. A value of 0
        #                 means they don't protrude at all (it reduces this shape to a triangle), and a value of 1 makes
        #                 the height of the pyramids equal to their side lengths.
        def initialize(def_name:, vertex_scale:)
            # Create a new definition for the die.
            definition = Util::MAIN_MODEL.definitions.add("#{self.class.name}_#{def_name}")
            mesh = definition.entities()

            c0 = 0.0
            c1 = 1.0
            c2 =        Math.sqrt(3.0) / 3.0
            c3 =  2.0 * vertex_scale
            c4 =  2.0 * Math.sqrt(3.0) / 3.0
            # Define all the points that make up the vertices of the die.
            v0 = Geom::Point3d::new( c0,  c0,  c3)
            v1 = Geom::Point3d::new( c0,  c0, -c3)
            v2 = Geom::Point3d::new( c1,  c2,  c0)
            v3 = Geom::Point3d::new(-c1,  c2,  c0)
            v4 = Geom::Point3d::new( c0, -c4,  c0)

            # Create the faces of the die by joining the vertices with edges. #TODO FIX THIS
            faces = Array::new(6)
            faces[0] = mesh.add_face([v0, v2, v3])
            faces[1] = mesh.add_face([v0, v3, v4])
            faces[2] = mesh.add_face([v0, v4, v2])
            faces[3] = mesh.add_face([v1, v2, v4])
            faces[4] = mesh.add_face([v1, v4, v3])
            faces[5] = mesh.add_face([v1, v3, v2])

            #TODO MAKE THE SCALES!
            super(die_size: 1.0, die_scale: 1.0, font_size: 1.0, definition: definition, faces: faces)
        end

        # A triangular dipyramid with standard dimensions.
        STANDARD = TriangularDipyramid::new(def_name: "Standard", vertex_scale: (1.0 / 3.0))
        # A triangular dipyramid that has been flattened into a triangle.
        FLAT = TriangularDipyramid::new(def_name: "Flat", vertex_scale: 0.0)
        # A triangular dipyramid where each pyramid's height is equal to their side length.
        BALANCED = TriangularDipyramid::new(def_name: "Balanced", vertex_scale: 1.0)
        # A triangular dipyramid composed entirely of equalateral faces.
        EQUALATERAL = TriangularDipyramid::new(def_name: "Equalateral", vertex_scale: (Math.sqrt(6.0) / 3.0))

    end

end
end
end
