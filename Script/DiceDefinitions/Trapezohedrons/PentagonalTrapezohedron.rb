
module DiceGen::Dice
    # This class defines the mesh model for a pentagonal trapezohedron (non-standard D10).
    class PentagonalTrapezohedron < Die
        # This constant controls how much the vertexes of the trapezohedron protrude from the midline. A value of 0
        # means they don't protrude at all (it reduces this shape to an octagon), and a value of 1 produces a standard
        # pentagonal trapezohedron.
        VERTEX_SCALE = 1.0

        # Lays out the geometry for the die in a new ComponentDefinition and adds it to the main DefinitionList.
        def initialize()
            # Create a new definition for the die.
            definition = Util::MAIN_MODEL.definitions.add(self.class.name)
            mesh = definition.entities()

            c0 = 0.0
            c1 = 0.5
            c2 = (Math.sqrt(5.0) - 1.0) / 4.0
            c3 = (Math.sqrt(5.0) + 1.0) / 4.0
            c4 = (Math.sqrt(5.0) + 3.0) / 4.0
            # Define all the points that make up the vertices of the die.
            D1 = Math.sqrt((5 - 2 * Math.sqrt(5)) / 20.0)
            D2 = Math.sqrt((5 -     Math.sqrt(5)) / 40.0)
            D3 = Math.sqrt((Math.sqrt(5.0) - 2.0) / Math.sqrt(80.0))
            D4 = Math.sqrt((Math.sqrt(5.0) + 2.0) / Math.sqrt(80.0))
            D5 = (Math.sqrt(25.0 + 11.0 * Math.sqrt(5.0)) + Math.sqrt(5.0 + Math.sqrt(5.0))) / Math.sqrt(40.0)
            D6 =  Math.sqrt((5.0 +  Math.sqrt(5.0)) / 10.0)
            D7 = -Math.sqrt((5.0 - Math.sqrt(20.0)) / Math.sqrt(20.0)))

            v0  = Geom::Point3d::new( c0,  c2,  c3)    ->    ( D1,  D2,  c3)
            v1  = Geom::Point3d::new( c0,  c2, -c3)    ->    ( D1,  D2, -c3)
            v2  = Geom::Point3d::new( c0, -c2,  c3)    ->    (-D1, -D2,  c3)
            v3  = Geom::Point3d::new( c0, -c2, -c3)    ->    (-D1, -D2, -c3)
            v4  = Geom::Point3d::new( c1,  c1,  c1)    ->    ( D3,  D4,  c1)
            v5  = Geom::Point3d::new( c1,  c1, -c1)    ->    ( D3,  D4, -c1)
            v6  = Geom::Point3d::new(-c1, -c1,  c1)    ->    (-D3, -D4,  c1)
            v7  = Geom::Point3d::new(-c1, -c1, -c1)    ->    (-D3, -D4, -c1)
            v8  = Geom::Point3d::new( c4, -c3,  c0)    ->    ( D5,   0,  c0)
            v9  = Geom::Point3d::new(-c4,  c3,  c0)    ->    (-D5,   0,  c0)
            v10 = Geom::Point3d::new( c2,  c3,  c0)    ->    ( D6,  D7,  c0)
            v11 = Geom::Point3d::new(-c2, -c3,  c0)    ->    (-D6, -D7,  c0)



            ((Math.sqrt(5.0) + 3.0) / 4.0)^2   +    ((Math.sqrt(5.0) + 1.0) / 4.0)^2
            (5 + 9 + 6sqrt(5)) / 16            +    (5 + 1 + 2sqrt(5)) / 16
            (14 + 6sqrt(5)) / 16            +    (6 + 2sqrt(5)) / 16
            (20 + 8sqrt(5)) / 16
            (5 + 2sqrt(5)) / 4
----
            ((Math.sqrt(5.0) + 1.0) / Math.sqrt(5.0 + 2.0 * Math.sqrt(5.0))) / 2.0
            (Math.sqrt(6 + 2.0 * Math.sqrt(5.0)) / Math.sqrt(5.0 + 2.0 * Math.sqrt(5.0))) / 2.0
            Math.sqrt(6.0 + 2.0 * Math.sqrt(5.0) / (5.0 + 2.0 * Math.sqrt(5.0))) / 2.0


            6 + 2*sqrt(5) = (5 + 2*sqrt(5))(a + b*sqrt(5))

            6 = 5a + 10b
            2 = 2a + 5b

            2 = a

            -4 = 10b

            -4 = 10b
            b = -0.4

            Math.sqrt(2 - 0.4 * Math.sqrt(5)) / 2.0
            Math.sqrt(0.5 - 0.1 * Math.sqrt(5))
-------
            ((Math.sqrt(5.0) + 3.0) / 4.0) / (Math.sqrt(5.0 + 2.0 * Math.sqrt(5.0)) / 2.0)
            ((Math.sqrt(5.0) + 3.0) / (Math.sqrt(5.0 + 2.0 * Math.sqrt(5.0)))) / 2.0
            (Math.sqrt(14 + 6 * Math.sqrt(5.0)) / Math.sqrt(5.0 + 2.0 * Math.sqrt(5.0))) / 2.0
            Math.sqrt((14 + 6 * Math.sqrt(5.0)) / (5.0 + 2.0 * Math.sqrt(5.0))) / 2.0

            (14 + 6 * Math.sqrt(5.0)) / (5.0 + 2.0 * Math.sqrt(5.0))
            (14 + 6sqrt(5)) = (5 + 2sqrt(5))(a + bsqrt(5))

            14 = 5a + 10b
            12 = 4a + 10b

            2 = a

            14 = 10 + 10b
            12 = 8 + 10b
            b = 0.4

            Math.sqrt(0.5 + 0.1 * Math.sqrt(5.0))
            



            hypotenuse:
            Math.sqrt(5.0 + 2.0 * Math.sqrt(5.0)) / 2.0

            short leg (opposite)
            (Math.sqrt(5.0) + 1.0) / 4.0

            long leg (adjacent)
            (Math.sqrt(5.0) + 3.0) / 4.0


            sin(theta) = sqrt(0.5 - 0.1 * sqrt(5))              SS
            cos(theta) = sqrt(0.5 + 0.1 * sqrt(5))              CC
            tan(theta) = (sqrt(5) - 1)/2

            X = XCOS - YSIN
            Y = XSIN + YCOS


            c2 = (Math.sqrt(5.0) - 1.0) / 4.0
            c3 = (Math.sqrt(5.0) + 1.0) / 4.0
            c4 = (Math.sqrt(5.0) + 3.0) / 4.0
            v0  = Geom::Point3d::new(   0,   c2,   c3)      ->      (    -c2(SS),      c2(CC),  c3)         ->  (-CA,  CB,  c3)
            v1  = Geom::Point3d::new(   0,   c2,  -c3)      ->      (    -c2(SS),      c2(CC), -c3)         ->  (-CA,  CB, -c3)
            v2  = Geom::Point3d::new(   0,  -c2,   c3)      ->      (     c2(SS),     -c2(CC),  c3)         ->  ( CA, -CB,  c3)
            v3  = Geom::Point3d::new(   0,  -c2,  -c3)      ->      (     c2(SS),     -c2(CC), -c3)         ->  ( CA, -CB, -c3)
            v4  = Geom::Point3d::new( 0.5,  0.5,  0.5)      ->      ( 0.5(CC-SS),  0.5(SS+CC),  0.5)        ->  ( CC,  CD,  0.5)
            v5  = Geom::Point3d::new( 0.5,  0.5, -0.5)      ->      ( 0.5(CC-SS),  0.5(SS+CC), -0.5)        ->  ( CC,  CD, -0.5)
            v6  = Geom::Point3d::new(-0.5, -0.5,  0.5)      ->      (-0.5(CC-SS), -0.5(SS+CC),  0.5)        ->  (-CC, -CD,  0.5)
            v7  = Geom::Point3d::new(-0.5, -0.5, -0.5)      ->      (-0.5(CC-SS), -0.5(SS+CC), -0.5)        ->  (-CC, -CD, -0.5)
            v8  = Geom::Point3d::new(  c4,  -c3,    0)      ->      (c4(CC)+c3(SS), c4(SS)-c3(CC), 0)       ->  ()
            v9  = Geom::Point3d::new( -c4,   c3,    0)      ->      (-c4(CC)-c3(SS), -c4(SS)+c3(CC), 0)     ->  ()
            v10 = Geom::Point3d::new(  c2,   c3,    0)      ->      (c2(CC)-c3(SS), c2(SS)+c3(CC), 0)       ->  ()
            v11 = Geom::Point3d::new( -c2,  -c3,    0)      ->      (-c2(CC)+c3(SS), -c2(SS)-c3(CC), 0)     ->  ()

            CA = c2(SS)     =   
            CB = c2(CC)     =
            CC = 0.5(CC-SS) =
            CD = 0.5(CC+SS) =








            # Create the faces of the die by joining the vertices with edges. #TODO FIX THIS
            faces = Array::new(10)
            faces[0] = mesh.add_face([v8,  v2,  v6, v11])
            faces[1] = mesh.add_face([v8, v11,  v7,  v3])
            faces[2] = mesh.add_face([v8,  v3,  v1,  v5])
            faces[3] = mesh.add_face([v8,  v5, v10,  v4])
            faces[4] = mesh.add_face([v8,  v4,  v0,  v2])
            faces[5] = mesh.add_face([v9,  v0,  v4, v10])
            faces[6] = mesh.add_face([v9, v10,  v5,  v1])
            faces[7] = mesh.add_face([v9,  v1,  v3,  v7])
            faces[8] = mesh.add_face([v9,  v7, v11,  v6])
            faces[9] = mesh.add_face([v9,  v6,  v2,  v0])

            #TODO MAKE THE DIE SCALE!
            # TODO CHECK IF THIS IS EVEN STILL RIGHT NOW THAT IM REDOING EVERYTHING!
            # Glyph models are always 8mm tall when imported, and the glyphs on a D10 are 7mm tall, so glyphs must
            # be scaled by a factor of 7mm/8mm = 0.875
            super(definition: definition, faces: faces, font_scale: 0.875)

            # Rotate each of the face transforms by TODO
            #TODO MAKE THIS WORK FOR BOTH D10 and D%
        end

        # TODO
        def place_glyphs(font:, mesh:, type:, die_scale: 1.0, font_scale: 1.0, font_offset: [0,0], font_angle: 0.0,
                         glyph_mapping: nil)
            if (type == "D%")
                #TODO
            else
                super
            end
        end
    end
end
