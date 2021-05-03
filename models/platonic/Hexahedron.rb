
module DiceForge
module Models

    # This class defines the model for a sharp-edged standard D6 die.
    # By default this model has a size of 15mm, and a font height of 8mm.
    class Hexahedron < Model
        def initialize()
            # Specify all the model's variables in a hash.
            variables = Hash.new()
            variables[:die_size] = Variable.new(default: 15, min: 0)

            # Define all the constants and lambda expressions that will be used in specifying the model's vertices.
            c0 = (1 / 2)
            ep = lambda { |vars| +vars[:die_size] * c0 }
            en = lambda { |vars| -vars[:die_size] * c0 }

            # Specify all the model's vertices and store them in an array.
            # Each vertex is represented by a Vertex object, which holds 3 lambda expressions that can be used to
            # compute the concrete values of the vertex's x, y, and z components for a given set of model variables.
            vertices = Array.new(8)
            vertices[0] = Vertex.new(ep, ep, ep)
            vertices[1] = Vertex.new(ep, ep, en)
            vertices[2] = Vertex.new(ep, en, ep)
            vertices[3] = Vertex.new(ep, en, en)
            vertices[4] = Vertex.new(en, ep, ep)
            vertices[5] = Vertex.new(en, ep, en)
            vertices[6] = Vertex.new(en, en, ep)
            vertices[7] = Vertex.new(en, en, en)

            # Specify all the model's faces and store them in an array.
            # Each face is represented by an array of vertex indices. Faces are created by connecting the vertices
            # together, in order, to form a loop, and filling the area enclosed by the loop.
            faces = Array.new(6)
            faces[0] = [0, 1, 5, 4]
            faces[1] = [0, 4, 6, 2]
            faces[2] = [0, 2, 3, 1]
            faces[3] = [7, 3, 2, 6]
            faces[4] = [7, 6, 4, 5]
            faces[5] = [7, 5, 1, 3]

            # Initialize the die's model by calling it's super constructor.
            super(
                name: "Hexahedron",
                description: "Standard D6 die",
                model_type: :face,
                variables: variables,
                vertices: vertices,
                faces: faces,
                glyph_indices: nil, #Let the base class automatically compute these.
                default_font_height: 8,
            )

            # Compute all the possible angles a glyph could be rotated by, for convenience.
            a0 = (90 * 0); a1 = (90 * 1); a2 = (90 * 2); a3 = (90 * 3);

            # Specify the model's built-in glyph mappings.
            add_glyph_mapping(GlyphMapping.new(
                name: "Chessex",
                glyphs: ['5', '1', '3', '2', '4', '6'],
                angles: [ a1,  a2,  a0,  a1,  a2,  a0],
            ))
            add_glyph_mapping(GlyphMapping.new(
                name: "Rybonator",
                glyphs: ['5', '1', '4', '2', '3', '6'],
                angles: [ a1,  a2,  a2,  a0,  a3,  a1],
            ))
        end
    end

end
end
