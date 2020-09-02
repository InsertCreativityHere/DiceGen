
module DiceGen
    # This class defines the mesh model for a sharp-edged standard D20 die (an icosahedron).
    class Icosahedron < Die
        # Lays out the geometry for the die in a new ComponentDefinition and adds it to the main DefinitionList.
        def initialize()
            # Create a new definition for the die.
            definition = Util::MAIN_MODEL.definitions.add(self.class.name)
            mesh = definition.entities()

            # Define all the points that make up the vertices of the die.
            pzp = Geom::Point3d::new(    0,     1,  $PHI)
            nzp = Geom::Point3d::new(    0,     1, -$PHI)
            pzn = Geom::Point3d::new(    0,    -1,  $PHI)
            nzn = Geom::Point3d::new(    0,    -1, -$PHI)
            pyp = Geom::Point3d::new(    1,  $PHI,     0)
            nyp = Geom::Point3d::new(    1, -$PHI,     0)
            pyn = Geom::Point3d::new(   -1,  $PHI,     0)
            nyn = Geom::Point3d::new(   -1, -$PHI,     0)
            pxp = Geom::Point3d::new( $PHI,     0,     1)
            nxp = Geom::Point3d::new(-$PHI,     0,     1)
            pxn = Geom::Point3d::new( $PHI,     0,    -1)
            nxn = Geom::Point3d::new(-$PHI,     0,    -1)

            # Create the faces of the die by joining the vertices with edges.
            faces = Array::new(20)
            faces[0]  = mesh.add_face([nyn, nyp, pzn])
            faces[1]  = mesh.add_face([pyn, nzp, nxn])
            faces[2]  = mesh.add_face([pzn, pxp, pzp])
            faces[3]  = mesh.add_face([nzp, pxn, nzn])
            faces[4]  = mesh.add_face([nzn, nyn, nxn])
            faces[5]  = mesh.add_face([pxn, pyp, pxp])
            faces[6]  = mesh.add_face([pzn, nyn, nxp])
            faces[7]  = mesh.add_face([pyp, pyn, pzp])
            faces[8]  = mesh.add_face([nyp, pxp, pxn])
            faces[9]  = mesh.add_face([pzp, pyn, nxp])
            faces[10] = mesh.add_face([nzn, nyp, pxn])
            faces[11] = mesh.add_face([nxn, pyn, nxp])
            faces[12] = mesh.add_face([nyn, nyp, nzn])
            faces[13] = mesh.add_face([nzp, pyp, pxn])
            faces[14] = mesh.add_face([nxp, nyn, nxn])
            faces[15] = mesh.add_face([pzp, pyp, pxp])
            faces[16] = mesh.add_face([pzn, nxp, pzp])
            faces[17] = mesh.add_face([nxn, nzp, nzn])
            faces[18] = mesh.add_face([pzn, nyp, pxp])
            faces[19] = mesh.add_face([pyp, pyn, nzp])

            # The distance between two diametric faces is 3.0230" in the base model, and standard D20 dice have a
            # diametric distance of 20mm, so the model must be scaled by a factor of
            # 20mm / (3.0230")(25.4mm/") = 0.26047
            # Which is further scaled by 1000, since we treat mm as m in the model, to get 260.47
            #
            # Glyph models are always 8mm tall when imported, and the glyphs on a D20 are 4.5mm tall, so glyphs must
            # be scaled by a factor of 4.5mm/8mm = 0.5625
            super(definition: definition, faces: faces, die_scale: 260.47, font_scale: 0.5625)
        end

        # Delegates to the default implemenation after checking that the die type is a D20.
        def place_glyphs(font:, mesh:, type:)
            if (type != "D20")
                raise "Incompatible die type: a D20 model cannot be used to generate #{type.to_s()} dice."
            end
            super
        end
    end
end
