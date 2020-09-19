
module DiceGen::Dice
    # This class defines the mesh model for a triakis octahedron (non-standard D24).
    class TriakisOctahedron < DieModel
        # Lays out the geometry for the die in a new ComponentDefinition and adds it to the main DefinitionList.
        #   def_name: The name of this definition. Every ComponentDefinition can be referenced with a unique name that
        #             is computed by appending this value to the name of the die model (separated by an underscore).
        #   kleepoint_scale: This value controls how much the triakis points protrude from the octahedral faces. A
        #                    value of 0 means they don't protrude at all (it reduces this shape to an octahedron), and
        #                    a value of 1 expands this shape into a rhombic dodecahedron.
        def initialize(def_name:, kleepoint_scale:)
            # Create a new definition for the die.
            definition = Util::MAIN_MODEL.definitions.add("#{self.class.name}_#{def_name}")
            mesh = definition.entities()

            c0 = 0.0
            c1 = 1.0 + Math.sqrt(2.0)
            c2 = 1.0 * (c1 / (3.0 - kleepoint_scale))
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
            faces[0]  = mesh.add_face([ v6,  v4,  v0])
            faces[1]  = mesh.add_face([ v6,  v0,  v2])
            faces[2]  = mesh.add_face([ v6,  v2,  v4])
            faces[3]  = mesh.add_face([ v7,  v5,  v2])
            faces[4]  = mesh.add_face([ v7,  v2,  v0])
            faces[5]  = mesh.add_face([ v7,  v0,  v5])
            faces[6]  = mesh.add_face([ v8,  v4,  v3])
            faces[7]  = mesh.add_face([ v8,  v3,  v0])
            faces[8]  = mesh.add_face([ v8,  v0,  v4])
            faces[9]  = mesh.add_face([ v9,  v5,  v0])
            faces[10] = mesh.add_face([ v9,  v0,  v3])
            faces[11] = mesh.add_face([ v9,  v3,  v5])
            faces[12] = mesh.add_face([v10,  v4,  v2])
            faces[13] = mesh.add_face([v10,  v2,  v1])
            faces[14] = mesh.add_face([v10,  v1,  v4])
            faces[15] = mesh.add_face([v11,  v5,  v1])
            faces[16] = mesh.add_face([v11,  v1,  v2])
            faces[17] = mesh.add_face([v11,  v2,  v5])
            faces[18] = mesh.add_face([v12,  v4,  v1])
            faces[19] = mesh.add_face([v12,  v1,  v3])
            faces[20] = mesh.add_face([v12,  v3,  v4])
            faces[21] = mesh.add_face([v13,  v5,  v3])
            faces[22] = mesh.add_face([v13,  v3,  v1])
            faces[23] = mesh.add_face([v13,  v1,  v5])

            #TODO MAKE THE SCALES!
            super(definition: definition, faces: faces)
        end
    end

    # A triakis octahedron with standard dimensions.
    STANDARD = TriakisOctahedron::new(def_name: "Standard", kleepoint_scale: (2.0 - Math.sqrt(2.0)))
    # A triakis octahedron that has been reduced into an octahedron.
    REDUCED = TriakisOctahedron::new(def_name: "Reduced", kleepoint_scale: 0.0)
    # A triakis octahedron that has been expanded into a rhombic dodecahedron.
    EXPANDED = TriakisOctahedron::new(def_name: "Expanded", kleepoint_scale: 1.0)

end
