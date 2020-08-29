
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

                super(definition: definition, faces: faces)
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
                faces[1] = die_mesh.add_face([p101, p001, p000, p100])
                faces[2] = die_mesh.add_face([p001, p011, p010, p000])
                faces[3] = die_mesh.add_face([p111, p101, p100, p110])
                faces[4] = die_mesh.add_face([p011, p111, p110, p010])
                faces[5] = die_mesh.add_face([p000, p100, p110, p010])

                super(definition: definition, faces: faces)
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
                faces[1] = mesh.add_face([nx, py, nz])
                faces[2] = mesh.add_face([nx, py, pz])
                faces[3] = mesh.add_face([px, py, nz])
                faces[4] = mesh.add_face([nx, ny, pz])
                faces[5] = mesh.add_face([px, ny, nz])
                faces[6] = mesh.add_face([px, ny, pz])
                faces[7] = mesh.add_face([nx, ny, nz])

                super(definition: definition, faces: faces)
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

                super(definition: definition, faces: faces)

                # Rotate each of the face transforms by TODO
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

                super(definition: definition, faces: faces)
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

                super(definition: definition, faces: faces)
            end
        end
    end

end
