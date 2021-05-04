
module DiceForge
module Models

    # This class defines the model for a sharp-edged standard D20 die.
    # By default this model has a size of 20mm, and a font height of 4.5mm.
    class Icosahedron < Model
        def initialize()
            # Specify all the model's variables in a hash.
            variables = Hash.new()
            variables[:die_size] = Variable.new(default: 20, min: 0)

            # Define all the constants and lambda expressions that will be used in specifying the model's vertices.
            c0 = (1.0 + Math.sqrt(5.0)) / 4.0

            e0  = lambda { |vars|                    0.0}
            e1p = lambda { |vars| +vars[:die_size] * 0.5}
            e1n = lambda { |vars| -vars[:die_size] * 0.5}
            e2p = lambda { |vars| +vars[:die_size] *  c0}
            e2n = lambda { |vars| -vars[:die_size] *  c0}

            # Specify all the model's vertices and store them in an array.
            # Each vertex is represented by a Vertex object, which holds 3 lambda expressions that can be used to
            # compute the concrete values of the vertex's x, y, and z components for a given set of model variables.
            vertices = Array.new(12)
            vertices[0]  = Vertex.new( e0, e2p, e1p)
            vertices[1]  = Vertex.new( e0, e2p, e1n)
            vertices[2]  = Vertex.new( e0, e2n, e1p)
            vertices[3]  = Vertex.new( e0, e2n, e1n)
            vertices[4]  = Vertex.new(e1p,  e0, e2p)
            vertices[5]  = Vertex.new(e1p,  e0, e2n)
            vertices[6]  = Vertex.new(e1n,  e0, e2p)
            vertices[7]  = Vertex.new(e1n,  e0, e2n)
            vertices[8]  = Vertex.new(e2p, e1p,  e0)
            vertices[9]  = Vertex.new(e2p, e1n,  e0)
            vertices[10] = Vertex.new(e2n, e1p,  e0)
            vertices[11] = Vertex.new(e2n, e1n,  e0)

            # Specify all the model's faces and store them in an array.
            # Each face is represented by an array of vertex indices. Faces are created by connecting the vertices
            # together, in order, to form a loop, and filling the area enclosed by the loop.
            faces = Array.new(20)
            faces[0]  = [4,  6,  2]
            faces[1]  = [4,  2,  9]
            faces[2]  = [4,  9,  8]
            faces[3]  = [4,  8,  0]
            faces[4]  = [4,  0,  6]
            faces[5]  = [7,  5,  3]
            faces[6]  = [7,  3, 11]
            faces[7]  = [7, 11, 10]
            faces[8]  = [7, 10,  1]
            faces[9]  = [7,  1,  5]
            faces[10] = [6, 10, 11]
            faces[11] = [6, 11,  2]
            faces[12] = [2, 11,  3]
            faces[13] = [2,  3,  9]
            faces[14] = [9,  3,  5]
            faces[15] = [9,  5,  8]
            faces[16] = [8,  5,  1]
            faces[17] = [8,  1,  0]
            faces[18] = [0,  1, 10]
            faces[19] = [0, 10,  6]

            # Initialize the die's model by calling it's super constructor.
            super(
                name: "Icosahedron",
                description: "Standard D20 die",
                model_type: :face,
                variables: variables,
                vertices: vertices,
                faces: faces,
                glyph_indices: nil, #Let the base class automatically compute these.
                default_font_height: 4.5,
            )

            # Compute all the possible angles a glyph could be rotated by, for convenience.
            a0 = (120 * 0); a1 = (120 * 1); a2 = (120 * 2);

            # Specify the model's built-in glyph mappings.
            add_glyph_mapping(GlyphMapping.new(
                name: "Chessex",
                glyphs: [ '1',  '7', '15',  '5', '13',  '8', '16',  '6', '14', '20',  '9', '19',  '3', '17', '10', '12',  '2', '18',  '4', '11'],
                angles: [  a0,   a0,   a0,   a2,   a2,   a0,   a0,   a2,   a2,   a2,   a2,   a2,   a0,   a2,   a1,   a1,   a1,   a0,   a1,   a2],
            ))
        end
    end

end
end
