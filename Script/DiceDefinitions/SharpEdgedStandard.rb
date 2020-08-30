
module DiceGen

    # Module containing all the model definitions for the sharp-edged standard dice set.
    module SharpEdgedStandard

        # This class defines the mesh model for a sharp-edged standard D4 die (a tetrahedron).
        class D4 < Die
            # Lays out the geometry for the die in a new ComponentDefinition and adds it to the main DefinitionList.
            def initialize()
                # Create a new definition for the die.
                definition = Util::MAIN_MODEL.definitions.add(self.class.name)
                mesh = definition.entities()

                # Define all the points that make up the vertices of the die.
                p111 = Geom::Point3d::new( 1,  1,  1)
                p001 = Geom::Point3d::new(-1, -1,  1)
                p010 = Geom::Point3d::new(-1,  1, -1)
                p100 = Geom::Point3d::new( 1, -1, -1)

                # Create the faces of the die by joining the vertices with edges.
                faces = Array::new(4)
                faces[0] = mesh.add_face([p010, p001, p111])
                faces[1] = mesh.add_face([p100, p010, p001])
                faces[2] = mesh.add_face([p010, p111, p100])
                faces[3] = mesh.add_face([p001, p111, p100])

                # The distance between a vertex and it's diametric face is 2.3094" in the base model, and standard D4
                # dice have a diametric distance of 18mm, so the model must be scaled by a factor of
                # 18mm / (2.3094")(25.4mm/") = 0.30686
                # Which is further scaled by 1000, since we treat mm as m in the model, to get 306.86
                #
                # Glyph models are always 8mm tall when imported, and the glyphs on a D4 are 6mm tall, so glyphs must
                # be scaled by a factor of 6mm/8mm = 0.75
                super(definition: definition, faces: faces, die_scale: 306.86, font_scale: 0.75)
            end

            # TODO
            def place_glyphs(font:, mesh:, type:)
                if (type == "D4")
                    raise "Incompatible die type: a D4 model cannot be used to generate #{type.to_s()} dice."
                end
                #TODO
            end
        end

        # This class defines the mesh model for a sharp-edged standard D6 die (a hexhedron (fancy word for cube)).
        class D6 < Die
            # Lays out the geometry for the die in a new ComponentDefinition and adds it to the main DefinitionList.
            def initialize()
                # Create a new definition for the die.
                definition = Util::MAIN_MODEL.definitions.add(self.class.name)
                die_mesh = definition.entities()

                # Define all the points that make up the vertices of the die.
                p000 = Geom::Point3d::new(-1, -1, -1)
                p001 = Geom::Point3d::new(-1, -1,  1)
                p010 = Geom::Point3d::new(-1,  1, -1)
                p100 = Geom::Point3d::new( 1, -1, -1)
                p011 = Geom::Point3d::new(-1,  1,  1)
                p101 = Geom::Point3d::new( 1, -1,  1)
                p110 = Geom::Point3d::new( 1,  1, -1)
                p111 = Geom::Point3d::new( 1,  1,  1)

                # Create the faces of the die by joining the vertices with edges.
                faces = Array::new(6)
                faces[0] = die_mesh.add_face([p111, p011, p001, p101])
                faces[1] = die_mesh.add_face([p001, p000, p100, p101])
                faces[2] = die_mesh.add_face([p000, p001, p011, p010])
                faces[3] = die_mesh.add_face([p110, p111, p101, p100])
                faces[4] = die_mesh.add_face([p111, p110, p010, p011])
                faces[5] = die_mesh.add_face([p000, p100, p110, p010])

                # The distance between two diametric faces is 2" in the base model, and standard D6 dice have a
                # diametric distance of 15mm, so the model must be scaled by a factor of
                # 15mm / (2")(25.4mm/") = 0.29528
                # Which is further scaled by 1000, since we treat mm as m in the model, to get 295.28
                #
                # Glyph models are always 8mm tall when imported, and the glyphs on a D6 are 8mm tall, so no scaling is
                # necessary.
                super(definition: definition, faces: faces, die_scale: 295.28)
            end

            # Delegates to the default implemenation after checking that the die type is a D6.
            def place_glyphs(font:, mesh:, type:)
                if (type != "D6")
                    raise "Incompatible die type: a D6 model cannot be used to generate #{type.to_s()} dice."
                end
                super
            end
        end

        # This class defines the mesh model for a sharp-edged standard D8 die (an equilateral octohedron).
        class D8 < Die
            # Lays out the geometry for the die in a new ComponentDefinition and adds it to the main DefinitionList.
            def initialize()
                # Create a new definition for the die.
                definition = Util::MAIN_MODEL.definitions.add(self.class.name)
                mesh = definition.entities()

                # Define all the points that make up the vertices of the die.
                px = Geom::Point3d::new( 1,  0,  0)
                nx = Geom::Point3d::new(-1,  0,  0)
                py = Geom::Point3d::new( 0,  1,  0)
                ny = Geom::Point3d::new( 0, -1,  0)
                pz = Geom::Point3d::new( 0,  0,  1)
                nz = Geom::Point3d::new( 0,  0, -1)

                # Create the faces of the die by joining the vertices with edges.
                faces = Array::new(8)
                faces[0] = mesh.add_face([px, py, pz])
                faces[1] = mesh.add_face([px, ny, nz])
                faces[2] = mesh.add_face([px, ny, pz])
                faces[3] = mesh.add_face([px, py, nz])
                faces[4] = mesh.add_face([nx, ny, pz])
                faces[5] = mesh.add_face([nx, py, nz])
                faces[6] = mesh.add_face([nx, py, pz])
                faces[7] = mesh.add_face([nx, ny, nz])

                # The distance between two diametric faces is 1.1547" in the base model, and standard D8 dice have a
                # diametric distance of 15mm, so the model must be scaled by a factor of
                # 15mm / (1.1547")(25.4mm/") = 0.51143
                # Which is further scaled by 1000, since we treat mm as m in the model, to get 511.43
                #
                # Glyph models are always 8mm tall when imported, and the glyphs on a D8 are 7mm tall, so glyphs must
                # be scaled by a factor of 7mm/8mm = 0.875
                super(definition: definition, faces: faces, die_scale: 511.43, font_scale: 0.875)
            end

            # Delegates to the default implemenation after checking that the die type is a D8.
            def place_glyphs(font:, mesh:, type:)
                if (type != "D8")
                    raise "Incompatible die type: a D8 model cannot be used to generate #{type.to_s()} dice."
                end
                super
            end
        end

        # This class defines the mesh model for a sharp-edged standard D10 die (a pentagonal trapezohedron).
        class D10 < Die
            # Lays out the geometry for the die in a new ComponentDefinition and adds it to the main DefinitionList.
            def initialize()
                # Create a new definition for the die.
                definition = Util::MAIN_MODEL.definitions.add(self.class.name)
                mesh = definition.entities()

                # Define all the points that make up the vertices of the die.
                #TODO

                # Create the faces of the die by joining the vertices with edges.
                faces = Array::new(10)
                #TODO

                #TODO MAKE THE DIE SCALE!
                # Glyph models are always 8mm tall when imported, and the glyphs on a D10 are 7mm tall, so glyphs must
                # be scaled by a factor of 7mm/8mm = 0.875
                super(definition: definition, faces: faces, font_scale: 0.875)

                # Rotate each of the face transforms by TODO
                #TODO MAKE THIS WORK FOR BOTH D10 and D%
            end

            # TODO
            def place_glyphs(font:, mesh:, type:)
                if (type == "D%")
                    #TODO
                elsif (type == "D10")
                    super
                else
                    raise "Incompatible die type: a D10 model cannot be used to generate #{type.to_s()} dice."
                end
            end
        end

        # This class defines the mesh model for a sharp-edged standard D12 die (a dodecahedron).
        class D12 < Die
            # Lays out the geometry for the die in a new ComponentDefinition and adds it to the main DefinitionList.
            def initialize()
                # Create a new definition for the die.
                definition = Util::MAIN_MODEL.definitions.add(self.class.name)
                mesh = definition.entities()

                # Define all the points that make up the vertices of the die.
                #TODO

                # Create the faces of the die by joining the vertices with edges.
                faces = Array::new(12)
                #TODO

                #TODO MAKE THE DIE SCALE!
                # Glyph models are always 8mm tall when imported, and the glyphs on a D12 are 6mm tall, so glyphs must
                # be scaled by a factor of 6mm/8mm = 0.75
                super(definition: definition, faces: faces, font_scale: 0.75)
            end

            # Delegates to the default implemenation after checking that the die type is a D12.
            def place_glyphs(font:, mesh:, type:)
                if (type != "D12")
                    raise "Incompatible die type: a D12 model cannot be used to generate #{type.to_s()} dice."
                end
                super
            end
        end

        # This class defines the mesh model for a sharp-edged standard D20 die (an icosahedron).
        class D20 < Die
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

end
