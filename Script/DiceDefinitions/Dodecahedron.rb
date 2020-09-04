
module DiceGen
    # This class defines the mesh model for a sharp-edged standard D12 die (a dodecahedron).
    class Dodecahedron < Die
        # Lays out the geometry for the die in a new ComponentDefinition and adds it to the main DefinitionList.
        def initialize()
            # Create a new definition for the die.
            definition = Util::MAIN_MODEL.definitions.add(self.class.name)
            mesh = definition.entities()

            c0 = 0.0
            c1 = 0.5
            c2 = (1 + Math.sqrt(5)) / 4
            c3 = (3 + Math.sqrt(5)) / 4
            # Define all the points that make up the vertices of the die.
            v0  = Geom::Point3d::new( c0,  c1,  c3)
            v1  = Geom::Point3d::new( c0,  c1, -c3)
            v2  = Geom::Point3d::new( c0, -c1,  c3)
            v3  = Geom::Point3d::new( c0, -c1, -c3)
            v4  = Geom::Point3d::new( c3,  c0,  c1)
            v5  = Geom::Point3d::new( c3,  c0, -c1)
            v6  = Geom::Point3d::new(-c3,  c0,  c1)
            v7  = Geom::Point3d::new(-c3,  c0, -c1)
            v8  = Geom::Point3d::new( c1,  c3,  c0)
            v9  = Geom::Point3d::new( c1, -c3,  c0)
            v10 = Geom::Point3d::new(-c1,  c3,  c0)
            v11 = Geom::Point3d::new(-c1, -c3,  c0)
            v12 = Geom::Point3d::new( c2,  c2,  c2)
            v13 = Geom::Point3d::new( c2,  c2, -c2)
            v14 = Geom::Point3d::new( c2, -c2,  c2)
            v15 = Geom::Point3d::new( c2, -c2, -c2)
            v16 = Geom::Point3d::new(-c2,  c2,  c2)
            v17 = Geom::Point3d::new(-c2,  c2, -c2)
            v18 = Geom::Point3d::new(-c2, -c2,  c2)
            v19 = Geom::Point3d::new(-c2, -c2, -c2)

            # Create the faces of the die by joining the vertices with edges. #TODO FIX THIS
            faces = Array::new(12)
            faces[0]  = mesh.add_face([ v0,  v2, v14,  v4, v12])
            faces[1]  = mesh.add_face([ v0, v12,  v8, v10, v16])
            faces[2]  = mesh.add_face([ v0, v16,  v6, v18,  v2])
            faces[3]  = mesh.add_face([ v7,  v6, v16, v10, v17])
            faces[4]  = mesh.add_face([ v7, v17,  v1,  v3, v19])
            faces[5]  = mesh.add_face([ v7, v19, v11, v18,  v6])
            faces[6]  = mesh.add_face([ v9, v11, v19,  v3, v15])
            faces[7]  = mesh.add_face([ v9, v15,  v5,  v4, v14])
            faces[8]  = mesh.add_face([ v9, v14,  v2, v18, v11])
            faces[9]  = mesh.add_face([v13,  v1, v17, v10,  v8])
            faces[10] = mesh.add_face([v13,  v8, v12,  v4,  v5])
            faces[11] = mesh.add_face([v13,  v5, v15,  v3,  v1])

            #TODO MAKE THE DIE SCALE!
            # Glyph models are always 8mm tall when imported, and the glyphs on a D12 are 6mm tall, so glyphs must
            # be scaled by a factor of 6mm/8mm = 0.75
            super(definition: definition, faces: faces, font_scale: 0.75)
        end

        # Delegates to the default implemenation after checking that the die type is a D12.
        def place_glyphs(font:, mesh:, type: "D12", font_scale: 1.0, font_offset: [0,0])
            if (type != "D12")
                raise "Incompatible die type: a D12 model cannot be used to generate #{type.to_s()} dice."
            end
            super
        end
    end
end
