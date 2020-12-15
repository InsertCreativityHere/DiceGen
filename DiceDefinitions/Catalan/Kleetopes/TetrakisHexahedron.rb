
module DiceGen
module Dice
module Definitions

    # This class defines the mesh model for a tetrakis hexahedron (non-standard D24).
    class TetrakisHexahedron < DieModel
        # Lays out the geometry for the die in a new ComponentDefinition and adds it to the main DefinitionList.
        #   def_name: The name of this definition. Every ComponentDefinition can be referenced with a unique name that
        #             is computed by appending this value to the name of the die model (separated by an underscore).
        #   kleepoint_scale: This value controls how much the tetrakis points protrude from the hexahedral faces. A
        #                    value of 0 means they don't protrude at all (it reduces this shape to a hexahedron), and
        #                    a value of 1 expands this shape into a rhombic dodecahedron.
        def initialize(def_name:, kleepoint_scale:)
            # Create a new definition for the die.
            definition = Util::MAIN_MODEL.definitions.add("#{self.class.name}_#{def_name}")
            mesh = definition.entities()

            c0 = 0.0
            c1 = ((9.0 * Math.sqrt(2.0)) / 8.0) * ((2.0 + (2.0 * kleepoint_scale)) / 3.0)
            c2 = ((3.0 * Math.sqrt(2.0)) / 4.0)
            # Define all the points that make up the vertices of the die.
            v0  = Geom::Point3d::new( c1,  c0,  c0)
            v1  = Geom::Point3d::new(-c1,  c0,  c0)
            v2  = Geom::Point3d::new( c0,  c1,  c0)
            v3  = Geom::Point3d::new( c0, -c1,  c0)
            v4  = Geom::Point3d::new( c0,  c0,  c1)
            v5  = Geom::Point3d::new( c0,  c0, -c1)
            v6  = Geom::Point3d::new( c2,  c2,  c2)
            v7  = Geom::Point3d::new( c2,  c2, -c2)
            v8  = Geom::Point3d::new( c2, -c2,  c2)
            v9  = Geom::Point3d::new( c2, -c2, -c2)
            v10 = Geom::Point3d::new(-c2,  c2,  c2)
            v11 = Geom::Point3d::new(-c2,  c2, -c2)
            v12 = Geom::Point3d::new(-c2, -c2,  c2)
            v13 = Geom::Point3d::new(-c2, -c2, -c2)

            # Create the faces of the die by joining the vertices with edges. #TODO FIX THIS
            faces = Array::new(24)
            faces[0]  = mesh.add_face([v4,  v6, v10])
            faces[1]  = mesh.add_face([v4, v10, v12])
            faces[2]  = mesh.add_face([v4, v12,  v8])
            faces[3]  = mesh.add_face([v4,  v8,  v6])
            faces[4]  = mesh.add_face([v5,  v7,  v9])
            faces[5]  = mesh.add_face([v5,  v9, v13])
            faces[6]  = mesh.add_face([v5, v13, v11])
            faces[7]  = mesh.add_face([v5, v11,  v7])
            faces[8]  = mesh.add_face([v0,  v6,  v8])
            faces[9]  = mesh.add_face([v0,  v8,  v9])
            faces[10] = mesh.add_face([v0,  v9,  v7])
            faces[11] = mesh.add_face([v0,  v7,  v6])
            faces[12] = mesh.add_face([v1, v10, v11])
            faces[13] = mesh.add_face([v1, v11, v13])
            faces[14] = mesh.add_face([v1, v13, v12])
            faces[15] = mesh.add_face([v1, v12, v10])
            faces[16] = mesh.add_face([v2,  v6,  v7])
            faces[17] = mesh.add_face([v2,  v7, v11])
            faces[18] = mesh.add_face([v2, v11, v10])
            faces[19] = mesh.add_face([v2, v10,  v6])
            faces[20] = mesh.add_face([v3,  v8, v12])
            faces[21] = mesh.add_face([v3, v12, v13])
            faces[22] = mesh.add_face([v3, v13,  v9])
            faces[23] = mesh.add_face([v3,  v9,  v8])

            #TODO MAKE THE SCALES!
            super(die_size: 1.0, die_scale: 1.0, font_size: 1.0, definition: definition, faces: faces)
        end

        # A tetrakis hexahedron with standard dimensions.
        STANDARD = TetrakisHexahedron::new(def_name: "Standard", kleepoint_scale: 0.5)
        # A tetrakis hexahedron that has been reduced into a hexahedron.
        REDUCED = TetrakisHexahedron::new(def_name: "Reduced", kleepoint_scale: 0.0)
        # A tetrakis hexahedron that has been expanded into a rhombic dodecahedron.
        EXPANDED = TetrakisHexahedron::new(def_name: "Expanded", kleepoint_scale: 1.0)

    end

end
end
end
