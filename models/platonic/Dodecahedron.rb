
module DiceForge
module Models

    # This class defines the model for a sharp-edged standard D12 die.
    # By default this model has a size of 18.5mm, and a font height of 6mm.
    class Dodecahedron < Model
        def initialize()
            # Specify all the model's variables in a hash.
            variables = Hash.new()
            variables[:die_size] = Variable.new(default: 18.5, min: 0)

            # Define all the constants and lambda expressions that will be used in specifying the model's vertices.
            c0 = (1.0 + Math.sqrt(5.0)) / 4.0
            c1 = (3.0 + Math.sqrt(5.0)) / 4.0

            e0  = lambda { |vars|                    0.0 }
            e1p = lambda { |vars| +vars[:die_size] * 0.5 }
            e1n = lambda { |vars| -vars[:die_size] * 0.5 }
            e2p = lambda { |vars| +vars[:die_size] *  c0 }
            e2n = lambda { |vars| -vars[:die_size] *  c0 }
            e3p = lambda { |vars| +vars[:die_size] *  c1 }
            e3n = lambda { |vars| -vars[:die_size] *  c1 }

            # Specify all the model's vertices and store them in an array.
            # Each vertex is represented by a Vertex object, which holds 3 lambda expressions that can be used to
            # compute the concrete values of the vertex's x, y, and z components for a given set of model variables.
            vertices = Array.new(20)
            vertices[0]  = Vertex.new( e0, e1p, e3p)
            vertices[1]  = Vertex.new( e0, e1p, e3n)
            vertices[2]  = Vertex.new( e0, e1n, e3p)
            vertices[3]  = Vertex.new( e0, e1n, e3n)
            vertices[4]  = Vertex.new(e3p,  e0, e1p)
            vertices[5]  = Vertex.new(e3p,  e0, e1n)
            vertices[6]  = Vertex.new(e3n,  e0, e1p)
            vertices[7]  = Vertex.new(e3n,  e0, e1n)
            vertices[8]  = Vertex.new(e1p, e3p,  e0)
            vertices[9]  = Vertex.new(e1p, e3n,  e0)
            vertices[10] = Vertex.new(e1n, e3p,  e0)
            vertices[11] = Vertex.new(e1n, e3n,  e0)
            vertices[12] = Vertex.new(e2p, e2p, e2p)
            vertices[13] = Vertex.new(e2p, e2p, e2n)
            vertices[14] = Vertex.new(e2p, e2n, e2p)
            vertices[15] = Vertex.new(e2p, e2n, e2n)
            vertices[16] = Vertex.new(e2n, e2p, e2p)
            vertices[17] = Vertex.new(e2n, e2p, e2n)
            vertices[18] = Vertex.new(e2n, e2n, e2p)
            vertices[19] = Vertex.new(e2n, e2n, e2n)

            # Specify all the model's faces and store them in an array.
            # Each face is represented by an array of vertex indices. Faces are created by connecting the vertices
            # together, in order, to form a loop, and filling the area enclosed by the loop.
            faces = Array.new(12)
            faces[0]  = [ 0,  2, 14,  4, 12]
            faces[1]  = [ 0, 12,  8, 10, 16]
            faces[2]  = [ 0, 16,  6, 18,  2]
            faces[3]  = [ 7,  6, 16, 10, 17]
            faces[4]  = [ 7, 17,  1,  3, 19]
            faces[5]  = [ 7, 19, 11, 18,  6]
            faces[6]  = [ 9, 11, 19,  3, 15]
            faces[7]  = [ 9, 15,  5,  4, 14]
            faces[8]  = [ 9, 14,  2, 18, 11]
            faces[9]  = [13,  1, 17, 10,  8]
            faces[10] = [13,  8, 12,  4,  5]
            faces[11] = [13,  5, 15,  3,  1]

            # Initialize the die's model by calling it's super constructor.
            super(
                name: "Dodecahedron",
                description: "Standard D12 die",
                model_type: :face,
                variables: variables,
                vertices: vertices,
                faces: faces,
                glyph_indices: nil, #Let the base class automatically compute these.
                default_font_height: 6,
            )

            # Compute all the possible angles a glyph could be rotated by, for convenience.
            a0 = (72 * 0); a1 = (72 * 1); a2 = (72 * 2); a3 = (72 * 3); a4 = (72 * 4);

            # Specify the model's built-in glyph mappings.
            add_glyph_mapping(GlyphMapping.new(
                name: "Chessex",
                glyphs: ['10', '9', '5', '11', '3', '6', '4', '2', '1', '12', '7', '8'],
                angles: [  a1,  a2,  a3,   a3,  a1,  a2,  a0,  a4,  a4,   a3,  a0,  a4],
            ))
        end
    end

end
end
