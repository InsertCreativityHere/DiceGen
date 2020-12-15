
module DiceGen
module Dice
module Definitions

    # This class defines the mesh model for a tetragonal trapezohedron (non-standard D8).
    class TetragonalTrapezohedron < DieModel
        # Lays out the geometry for the die in a new ComponentDefinition and adds it to the main DefinitionList.
        #   def_name: The name of this definition. Every ComponentDefinition can be referenced with a unique name that
        #             is computed by appending this value to the name of the die model (separated by an underscore).
        #   vertex_scale: This value controls how much the vertexes of the trapezohedron protrude from the midline. A
        #                 value of 0 means they don't protrude at all (it reduces this shape to an octagon), and a value
        #                 of 1 produces a standard tetragonal trapezohedron.
        def initialize(def_name:, vertex_scale:)
            # Create a new definition for the die.
            definition = Util::MAIN_MODEL.definitions.add("#{self.class.name}_#{def_name}")
            mesh = definition.entities()

            c0 = 0.0
            c1 = 0.5
            c2 = (Math.sqrt(2.0 * (3.0 * Math.sqrt(2.0) + 4.0)) / 4.0) * vertex_scale
            c3 =  Math.sqrt(2.0                               ) / 2.0
            c4 = (Math.sqrt(2.0 * (3.0 * Math.sqrt(2.0) - 4.0)) / 4.0) * vertex_scale
            # Define all the points that make up the vertices of the die.
            v0 = Geom::Point3d::new( c0,  c0,  c2)
            v1 = Geom::Point3d::new( c0,  c0, -c2)
            v2 = Geom::Point3d::new( c3,  c0,  c4)
            v3 = Geom::Point3d::new(-c3,  c0,  c4)
            v4 = Geom::Point3d::new( c0,  c3,  c4)
            v5 = Geom::Point3d::new( c0, -c3,  c4)
            v6 = Geom::Point3d::new( c1,  c1, -c4)
            v7 = Geom::Point3d::new( c1, -c1, -c4)
            v8 = Geom::Point3d::new(-c1,  c1, -c4)
            v9 = Geom::Point3d::new(-c1, -c1, -c4)

            # Create the faces of the die by joining the vertices with edges. #TODO FIX THIS
            faces = Array::new(8)
            faces[0] = mesh.add_face([v0, v2, v6, v4])
            faces[1] = mesh.add_face([v0, v4, v8, v3])
            faces[2] = mesh.add_face([v0, v3, v9, v5])
            faces[3] = mesh.add_face([v0, v5, v7, v2])
            faces[4] = mesh.add_face([v1, v6, v2, v7])
            faces[5] = mesh.add_face([v1, v7, v5, v9])
            faces[6] = mesh.add_face([v1, v9, v3, v8])
            faces[7] = mesh.add_face([v1, v8, v4, v6])

            #TODO MAKE THE SCALES!
            super(die_size: 1.0, die_scale: 1.0, font_size: 1.0, definition: definition, faces: faces)
        end

        # A tetragonal trapezohedron with standard dimensions.
        STANDARD = TetragonalTrapezohedron::new(def_name: "Standard", vertex_scale: 1.0)
        # A tetragonal trapezohedron that has been flattened into an octagon.
        FLAT = TetragonalTrapezohedron::new(def_name: "Flat", vertex_scale: 0.0)

    end

end
end
end
