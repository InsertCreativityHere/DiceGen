
module DiceGen::Dice
    # This class defines the mesh model for a rhombic triacontahedron (non-standard D30).
    class RhombicTriacontahedron < Die
        # Lays out the geometry for the die in a new ComponentDefinition and adds it to the main DefinitionList.
        def initialize()
            # Create a new definition for the die.
            definition = Util::MAIN_MODEL.definitions.add(self.class.name)
            mesh = definition.entities()

            c0 = 0.0
            c1 =              Math.sqrt(5.0)  / 4.0
            c2 = (5.0 + 3.0 * Math.sqrt(5.0)) / 8.0
            c3 = (5.0 +       Math.sqrt(5.0)) / 8.0
            # Define all the points that make up the vertices of the die.
            v0  = Geom::Point3d::new( c0,  c2,  c3)
            v1  = Geom::Point3d::new( c0,  c2, -c3)
            v2  = Geom::Point3d::new( c0, -c2,  c3)
            v3  = Geom::Point3d::new( c0, -c2, -c3)
            v4  = Geom::Point3d::new( c3,  c0,  c2)
            v5  = Geom::Point3d::new( c3,  c0, -c2)
            v6  = Geom::Point3d::new(-c3,  c0,  c2)
            v7  = Geom::Point3d::new(-c3,  c0, -c2)
            v8  = Geom::Point3d::new( c2,  c3,  c0)
            v9  = Geom::Point3d::new( c2, -c3,  c0)
            v10 = Geom::Point3d::new(-c2,  c3,  c0)
            v11 = Geom::Point3d::new(-c2, -c3,  c0)
            v12 = Geom::Point3d::new( c0,  c1,  c2)
            v13 = Geom::Point3d::new( c0,  c1, -c2)
            v14 = Geom::Point3d::new( c0, -c1,  c2)
            v15 = Geom::Point3d::new( c0, -c1, -c2)
            v16 = Geom::Point3d::new( c2,  c0,  c1)
            v17 = Geom::Point3d::new( c2,  c0, -c1)
            v18 = Geom::Point3d::new(-c2,  c0,  c1)
            v19 = Geom::Point3d::new(-c2,  c0, -c1)
            v20 = Geom::Point3d::new( c1,  c2,  c0)
            v21 = Geom::Point3d::new( c1, -c2,  c0)
            v22 = Geom::Point3d::new(-c1,  c2,  c0)
            v23 = Geom::Point3d::new(-c1, -c2,  c0)
            v24 = Geom::Point3d::new( c3,  c3,  c3)
            v25 = Geom::Point3d::new( c3,  c3, -c3)
            v26 = Geom::Point3d::new( c3, -c3,  c3)
            v27 = Geom::Point3d::new( c3, -c3, -c3)
            v28 = Geom::Point3d::new(-c3,  c3,  c3)
            v29 = Geom::Point3d::new(-c3,  c3, -c3)
            v30 = Geom::Point3d::new(-c3, -c3,  c3)
            v31 = Geom::Point3d::new(-c3, -c3, -c3)

            # Create the faces of the die by joining the vertices with edges. #TODO FIX THIS
            faces = Array::new(30)
            faces[0]  = mesh.add_face([ v4, v12,  v6, v14])
            faces[1]  = mesh.add_face([ v4, v14,  v2, v26])
            faces[2]  = mesh.add_face([ v4, v26,  v9, v16])
            faces[3]  = mesh.add_face([ v5, v13,  v1, v25])
            faces[4]  = mesh.add_face([ v5, v25,  v8, v17])
            faces[5]  = mesh.add_face([ v5, v17,  v9, v27])
            faces[6]  = mesh.add_face([ v6, v28, v10, v18])
            faces[7]  = mesh.add_face([ v6, v18, v11, v30])
            faces[8]  = mesh.add_face([ v6, v30,  v2, v14])
            faces[9]  = mesh.add_face([ v7, v19, v10, v29])
            faces[10] = mesh.add_face([ v7, v29,  v1, v13])
            faces[11] = mesh.add_face([ v7, v13,  v5, v15])
            faces[12] = mesh.add_face([ v8, v20,  v0, v24])
            faces[13] = mesh.add_face([ v8, v24,  v4, v16])
            faces[14] = mesh.add_face([ v8, v16,  v9, v17])
            faces[15] = mesh.add_face([v11, v18, v10, v19])
            faces[16] = mesh.add_face([v11, v19,  v7, v31])
            faces[17] = mesh.add_face([v11, v31,  v3, v23])
            faces[18] = mesh.add_face([ v0, v22, v10, v28])
            faces[19] = mesh.add_face([ v0, v28,  v6, v12])
            faces[20] = mesh.add_face([ v0, v12,  v4, v24])
            faces[21] = mesh.add_face([ v1, v29, v10, v22])
            faces[22] = mesh.add_face([ v1, v22,  v0, v20])
            faces[23] = mesh.add_face([ v1, v20,  v8, v25])
            faces[24] = mesh.add_face([ v2, v30, v11, v23])
            faces[25] = mesh.add_face([ v2, v23,  v3, v21])
            faces[26] = mesh.add_face([ v2, v21,  v9, v26])
            faces[27] = mesh.add_face([ v3, v31,  v7, v15])
            faces[28] = mesh.add_face([ v3, v15,  v5, v27])
            faces[29] = mesh.add_face([ v3, v27,  v9, v21])

            # The distance between two diametric faces is 2.927051" in the base model, and this looks best with a
            # diametric distance of 24mm, so the model must be scaled by a factor of
            # 24mm / (2.927051")(25.4mm/") = 0.322810
            # Which is further scaled by 1000, since we treat mm as m in the model, to get 322.810
            #
            # Glyph models are always 8mm tall when imported, and the glyphs on this look best at 4.5mm tall, so glyphs
            # must be scaled by a factor of 4.5mm/8mm = 0.5625
            super(definition: definition, faces: faces, die_scale: 322.810, font_scale: 0.5625)

            # TODO ROTATE EACH OF THE FACE TRANSFORMS!
        end
    end
end
