
module DiceForge
module Models

    # This class defines the model for a sharp-edged standard D8 die.
    # By default this model has a size of 15mm, and a font height of 7mm.
    class Octahedron < Model
        def initialize()
            # Specify all the model's variables in a hash.
            variables = Hash.new()
            variables[:die_size] = Variable.new(default: 15, min: 0)

            # Define all the constants and lambda expressions that will be used in specifying the model's vertices.
            c0 = Math.sqrt(2.0) / 2.0

            e0  = lambda { |vars|                    0.0 }
            e1p = lambda { |vars| +vars[:die_size] *  c0 }
            e1n = lambda { |vars| -vars[:die_size] *  c0 }

            # Specify all the model's vertices and store them in an array.
            # Each vertex is represented by a Vertex object, which holds 3 lambda expressions that can be used to
            # compute the concrete values of the vertex's x, y, and z components for a given set of model variables.
            vertices = Array.new(6)
            vertices[0] = Vertex.new(e1p,  e0,  e0)
            vertices[1] = Vertex.new(e1n,  e0,  e0)
            vertices[2] = Vertex.new( e0, e1p,  e0)
            vertices[3] = Vertex.new( e0, e1n,  e0)
            vertices[4] = Vertex.new( e0,  e0, e1p)
            vertices[5] = Vertex.new( e0,  e0, e1n)

            # Specify all the model's faces and store them in an array.
            # Each face is represented by an array of vertex indices. Faces are created by connecting the vertices
            # together, in order, to form a loop, and filling the area enclosed by the loop.
            faces = Array.new(8)
            faces[0] = [4, 0, 2]
            faces[1] = [4, 2, 1]
            faces[2] = [4, 1, 3]
            faces[3] = [4, 3, 0]
            faces[4] = [5, 0, 3]
            faces[5] = [5, 3, 1]
            faces[6] = [5, 1, 2]
            faces[7] = [5, 2, 0]

            # Initialize the die's model by calling it's super constructor.
            super(
                name: "Octahedron",
                description: "Standard D8 die",
                model_type: :face,
                variables: variables,
                vertices: vertices,
                faces: faces,
                glyph_indices: nil, #Let the base class automatically compute these.
                default_font_height: 7,
            )

            # Compute all the possible angles a glyph could be rotated by, for convenience.
            a0 = (120 * 0); a1 = (120 * 1); a2 = (120 * 2);

            # Specify the model's built-in glyph mappings.
            add_glyph_mapping(GlyphMapping.new(
                name: "Chessex",
                glyphs: ['1', '7', '5', '3', '2', '8', '6', '4'],
                angles: [ a1,  a1,  a1,  a1,  a1,  a1,  a1,  a1],
            ))
            add_glyph_mapping(GlyphMapping.new(
                name: "Rybonator",
                glyphs: ['1', '3', '5', '7', '6', '8', '2', '4'],
                angles: [ a1,  a1,  a1,  a1,  a1,  a1,  a1,  a1],
            ))
        end
    end

end
end
