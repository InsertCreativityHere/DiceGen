
module DiceGen
module Dice
module Definitions

    # This class defines the mesh model for a trigonal trapezohedron (non-standard D6).
    class TrigonalTrapezohedron < DieModel
        # Lays out the geometry for the die in a new ComponentDefinition and adds it to the main DefinitionList.
        #   def_name: The name of this definition. Every ComponentDefinition can be referenced with a unique name that
        #             is computed by appending this value to the name of the die model (separated by an underscore).
        #   vertex_scale: This value controls how much the vertexes of the trapezohedron protrude from the midline. A
        #                 value of 0 means they don't protrude at all (it reduces this shape to a hexagon), and a value
        #                 of 1 produces a standard trigonal trapezohedron.
        def initialize(def_name:, vertex_scale:)
            # Create a new definition for the die.
            definition = $MAIN_MODEL.definitions.add("#{self.class.name}_#{def_name}")
            mesh = definition.entities()

            c0 = 0.0
            c1 = 0.5
            c2 = 1.0 / Math.sqrt( 3.0)
            c3 = 1.0 / Math.sqrt(12.0)
            c4 = 1.0 / Math.sqrt(24.0) * vertex_scale
            c5 = Math.sqrt(3.0 / 8.0)  * vertex_scale
            # Define all the points that make up the vertices of the die.
            v0 = Geom::Point3d::new( c0,  c0,  c5)
            v1 = Geom::Point3d::new( c0, -c0, -c5)
            v2 = Geom::Point3d::new( c0,  c2,  c4)
            v3 = Geom::Point3d::new( c0, -c2, -c4)
            v4 = Geom::Point3d::new( c1,  c3, -c4)
            v5 = Geom::Point3d::new( c1, -c3,  c4)
            v6 = Geom::Point3d::new(-c1,  c3, -c4)
            v7 = Geom::Point3d::new(-c1, -c3,  c4)

            # Create the faces of the die by joining the vertices with edges. #TODO FIX THIS
            faces = Array::new(6)
            faces[0] = mesh.add_face([v0, v2, v6, v7])
            faces[1] = mesh.add_face([v0, v7, v3, v5])
            faces[2] = mesh.add_face([v0, v5, v4, v2])
            faces[3] = mesh.add_face([v1, v4, v5, v3])
            faces[4] = mesh.add_face([v1, v3, v7, v6])
            faces[5] = mesh.add_face([v1, v6, v2, v4])

            #TODO MAKE THE SCALES!
            super(die_size: 1.0, die_scale: 1.0, font_size: 1.0, definition: definition, faces: faces)
        end

        # A trigonal trapezohedron with standard dimensions.
        STANDARD = TrigonalTrapezohedron::new(def_name: "Standard", vertex_scale: 1.0)
        # A trigonal trapezohedron that has been flattened into a hexagon.
        FLAT = TrigonalTrapezohedron::new(def_name: "Flat", vertex_scale: 0.0)

    end

end
end
end
