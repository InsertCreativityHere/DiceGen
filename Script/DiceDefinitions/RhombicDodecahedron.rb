
module DiceGen::Dice
    # This class defines the mesh model for a rhombic dodecahedron (non-standard D12).
    class RhombicDodecahedron < Die
        # Lays out the geometry for the die in a new ComponentDefinition and adds it to the main DefinitionList.
        def initialize()
            # Create a new definition for the die.
            definition = DiceUtil::MAIN_MODEL.definitions.add(self.class.name)
            mesh = definition.entities()

            c0 = 0.0
            c1 = 3 * Math.sqrt(2) / 4
            c2 = 3 * Math.sqrt(2) / 8
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
            faces = Array::new(12)
            faces[0]  = mesh.add_face([ v6,  v4,  v8,  v0])
            faces[1]  = mesh.add_face([ v6,  v0,  v7,  v2])
            faces[2]  = mesh.add_face([ v6,  v2, v10,  v4])
            faces[3]  = mesh.add_face([ v9,  v5,  v7,  v0])
            faces[4]  = mesh.add_face([ v9,  v0,  v8,  v3])
            faces[5]  = mesh.add_face([ v9,  v3, v13,  v5])
            faces[6]  = mesh.add_face([v11,  v5, v13,  v1])
            faces[7]  = mesh.add_face([v11,  v1, v10,  v2])
            faces[8]  = mesh.add_face([v11,  v2,  v7,  v5])
            faces[9]  = mesh.add_face([v12,  v4, v10,  v1])
            faces[10] = mesh.add_face([v12,  v1, v13,  v3])
            faces[11] = mesh.add_face([v12,  v3,  v8,  v4])

            #TODO MAKE THE SCALES!
            super(definition: definition, faces: faces)

            # TODO ROTATE EACH OF THE FACE TRANSFORMS!
        end

        # Delegates to the default implemenation after checking that the die type is a D12.
        def place_glyphs(font:, mesh:, type: "D12", die_scale: 1.0, font_scale: 1.0, font_offset: [0,0])
            if (type != "D12")
                raise "Incompatible die type: a D12 model cannot be used to generate #{type.to_s()} dice."
            end
            super
        end
    end
end
