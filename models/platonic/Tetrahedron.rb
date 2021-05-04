
module DiceForge
module Models

    # This class defines the model for a sharp-edged standard D4 die.
    # By default this model has a size of 18mm, and a font height of 6mm.
    class Tetrahedron < Model
        def initialize()
            # Specify all the model's variables in a hash.
            variables = Hash.new()
            variables[:die_size] = Variable.new(default: 18, min: 0)

            # Define all the constants and lambda expressions that will be used in specifying the model's vertices.
            c0 = Math.sqrt(2.0) / 4.0

            ep = lambda { |vars| +vars[:die_size] * c0 }
            en = lambda { |vars| -vars[:die_size] * c0 }

            # Specify all the model's vertices and store them in an array.
            # Each vertex is represented by a Vertex object, which holds 3 lambda expressions that can be used to
            # compute the concrete values of the vertex's x, y, and z components for a given set of model variables.
            vertices = Array.new(4)
            vertices[0] = Vertex.new(en, en, en)
            vertices[1] = Vertex.new(en, ep, ep)
            vertices[2] = Vertex.new(ep, en, ep)
            vertices[3] = Vertex.new(ep, ep, en)

            # Specify all the model's faces and store them in an array.
            # Each face is represented by an array of vertex indices. Faces are created by connecting the vertices
            # together, in order, to form a loop, and filling the area enclosed by the loop.
            faces = Array.new(4)
            faces[0] = [2, 3, 1]
            faces[1] = [3, 2, 0]
            faces[2] = [1, 0, 2]
            faces[3] = [0, 1, 3]

            # Initialize the die's model by calling it's super constructor.
            super(
                name: "Tetrahedron",
                desc: "Standard D4 die",
                model_type: :vertex,
                variables: variables,
                vertices: vertices,
                faces: faces,
                glyph_indices: nil, #Let the base class automatically compute these.
                default_font_height: 8,
            )

            # Compute all the possible angles a glyph could be rotated by, for convenience.
            a0 = (120 * 0); a1 = (120 * 1); a2 = (120 * 2);

            # Specify the model's built-in glyph mappings.
            add_glyph_mapping(GlyphMapping.new(
                name: "Chessex",
                glyphs: ['1', '2', '3', '4'],#TODO THIS ISNT RIGHT PROBABLY!!!
                angles: [ a1,  a2,  a0,  a1],#TODO THIS ISNT RIGHT PROBABLY!!!
            ))
        end
    end

end
end
