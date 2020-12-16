
module DiceGen
module Dice
module Definitions

    # This class defines the mesh model for a triakis tetrahedron (non-standard D12).
    class TriakisTetrahedron < DieModel
        # Lays out the geometry for the die in a new ComponentDefinition and adds it to the main DefinitionList.
        #   def_name: The name of this definition. Every ComponentDefinition can be referenced with a unique name that
        #             is computed by appending this value to the name of the die model (separated by an underscore).
        #   kleepoint_scale: This value controls how much the triakis points protrude from the tetrahedral faces. A
        #                    value of 0 means they don't protrude at all (it reduces this shape to a tetrahedron), and
        #                    a value of 1 expands this shape into a hexahedron.
        def initialize(def_name:, kleepoint_scale:)
            # Create a new definition for the die.
            definition = $MAIN_MODEL.definitions.add("#{self.class.name}_#{def_name}")
            mesh = definition.entities()

            c0 = ((9.0 * Math.sqrt(2)) / 20.0) * ((10.0 * kleepoint_scale + 5.0) / 9.0)
            c1 = ((3.0 * Math.sqrt(2)) /  4.0)
            # Define all the points that make up the vertices of the die.
            v0 = Geom::Point3d::new(-c0,  c0,  c0)
            v1 = Geom::Point3d::new( c0, -c0,  c0)
            v2 = Geom::Point3d::new( c0,  c0, -c0)
            v3 = Geom::Point3d::new(-c0, -c0, -c0)
            v4 = Geom::Point3d::new( c1,  c1,  c1)
            v5 = Geom::Point3d::new( c1, -c1, -c1)
            v6 = Geom::Point3d::new(-c1,  c1, -c1)
            v7 = Geom::Point3d::new(-c1, -c1,  c1)

            # Create the faces of the die by joining the vertices with edges. #TODO FIX THIS
            faces = Array::new(12)
            faces[0]  = mesh.add_face([v1, v4, v7])
            faces[1]  = mesh.add_face([v1, v7, v5])
            faces[2]  = mesh.add_face([v1, v5, v4])
            faces[3]  = mesh.add_face([v2, v4, v5])
            faces[4]  = mesh.add_face([v2, v5, v6])
            faces[5]  = mesh.add_face([v2, v6, v4])
            faces[6]  = mesh.add_face([v0, v4, v6])
            faces[7]  = mesh.add_face([v0, v6, v7])
            faces[8]  = mesh.add_face([v0, v7, v4])
            faces[9]  = mesh.add_face([v3, v5, v7])
            faces[10] = mesh.add_face([v3, v7, v6])
            faces[11] = mesh.add_face([v3, v6, v5])

            #TODO MAKE THE SCALES!
            super(die_size: 1.0, die_scale: 1.0, font_size: 1.0, definition: definition, faces: faces)
        end

        # A triakis tetrahedron with standard dimensions.
        STANDARD = TriakisTetrahedron::new(def_name: "Standard", kleepoint_scale: 0.4)
        # A triakis tetrahedron that has been reduced into a tetrahedron.
        REDUCED = TriakisTetrahedron::new(def_name: "Reduced", kleepoint_scale: 0.0)
        # A triakis tetrahedron that has been expanded into a hexahedron.
        EXPANDED = TriakisTetrahedron::new(def_name: "Expanded", kleepoint_scale: 1.0)

    end

end
end
end
