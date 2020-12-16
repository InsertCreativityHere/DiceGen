
module DiceGen
module Dice
module Definitions

    # This class defines the mesh model for a square dipyramid (non-standard D8).
    # Technically this shape is just a scaled version of the octahedron, so this is capable of being a standard die,
    # but since this doesn't necessarily have to contain equalateral triangles, it's kept as a separate solid.
    class SquareDipyramid < DieModel
        # Lays out the geometry for the die in a new ComponentDefinition and adds it to the main DefinitionList.
        #   def_name: The name of this definition. Every ComponentDefinition can be referenced with a unique name that
        #             is computed by appending this value to the name of the die model (separated by an underscore).
        #   vertex_scale: This value controls how much the vertexes of the pyramids protrude from the base. A value of 0
        #                 means they don't protrude at all (it reduces this shape to a square), and a value of 1 makes
        #                 the height of the pyramids equal to their side lengths.
        def initialize(def_name:, vertex_scale:)
            # Create a new definition for the die.
            definition = $MAIN_MODEL.definitions.add("#{self.class.name}_#{def_name}")
            mesh = definition.entities()

            c0 = 0.0
            c1 = 1.0
            c2 = Math.sqrt(2.0) * vertex_scale
            # Define all the points that make up the vertices of the die.
            v0 = Geom::Point3d::new( c1,  c0,  c0)
            v1 = Geom::Point3d::new(-c1,  c0,  c0)
            v2 = Geom::Point3d::new( c0,  c1,  c0)
            v3 = Geom::Point3d::new( c0, -c1,  c0)
            v4 = Geom::Point3d::new( c0,  c0,  c2)
            v5 = Geom::Point3d::new( c0,  c0, -c2)

            # Create the faces of the die by joining the vertices with edges. #TODO FIX THIS
            faces = Array::new(8)
            faces[0] = mesh.add_face([v4, v0, v2])
            faces[1] = mesh.add_face([v4, v2, v1])
            faces[2] = mesh.add_face([v4, v1, v3])
            faces[3] = mesh.add_face([v4, v3, v0])
            faces[4] = mesh.add_face([v5, v0, v3])
            faces[5] = mesh.add_face([v5, v3, v1])
            faces[6] = mesh.add_face([v5, v1, v2])
            faces[7] = mesh.add_face([v5, v2, v0])

            #TODO MAKE THE SCALES!
            super(die_size: 1.0, die_scale: 1.0, font_size: 1.0, definition: definition, faces: faces)
        end

        # A square dipyramid with standard dimensions. This model is entirely composed of equalateral sides, and is
        # equivalent to an octahedron.
        STANDARD = SquareDipyramid::new(def_name: "Standard", vertex_scale: 1.0 / Math.sqrt(2.0))
        # A square dipyramid that has been flattened into a square.
        FLAT = SquareDipyramid::new(def_name: "Flat", vertex_scale: 0.0)
        # A square dipyramid where each pyramid's height is equal to their side length.
        BALANCED = SquareDipyramid::new(def_name: "Balanced", vertex_scale: 1.0)
        # A square dipyramid composed entirely of equalateral faces.
        # Note: The standard model already has equalateral faces, so this model is also equivalent to the standard model.
        EQUALATERAL = SquareDipyramid::new(def_name: "Equalateral", vertex_scale: 1.0 / Math.sqrt(2.0))

    end

end
end
end
