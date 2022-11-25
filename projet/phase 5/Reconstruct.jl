# include required libraries
include("../phase 1/graph.jl")
include("../phase 4/RSL_module.jl")
include("../phase 4/LK_module.jl")
include("shredder-julia/bin/tools.jl")

filename = "nikos-cat.png"
picture = load("projet/phase 5/shredder-julia/images/shuffled/$(filename)")

# create the object
g = Graph{Int}(filename, Vector{Node}(), Vector{Edge}())

# add –fake– node as a source
add_node!(g, Node("s", 0))

# considers each column as a node
for i in 1:size(picture, 2)
    # add a node for each column
    
    add_node!(g, Node(string(i), i))

    # add the zero weight from the -fake- source to each node
    add_edge!(g, Edge((get_node(g, "s"), get_node(g, string(i))), 0.0))
end

# add the edges between the other nodes
for i in 1:size(picture, 2)
    for j in 1:size(picture, 2)
        # compute the weight of the edge and add the edge
        # as the matrix is symmetric, then skip the lower triangular matrix as well as the diagonal
        local weight = 0.0
        if i >= j
            continue
        else
            local weight = convert(Float64,compare_columns(picture[:,i], picture[:,j]))
            # add the edge
            add_edge!(g, Edge((get_node(g,string(i) ), get_node(g, string(j))), weight))
        end
    end
end

# ------------------------------------------------------------------ #
# ------------------------ compute the tour ------------------------ #
# ------------------------------------------------------------------ #

######## using RSL ########
trig_ineg = has_triang_ineg(g)
tour_rsl, cost_rsl, time_rsl = rsl(g, Node("s", 0), kruskal, trig_ineg)

# HERE WE NEED TO GET THE NODES PARSED ONTO AND ARRAY OF INTEGERS
# without considering the -fake- source node
tour_rsl_array = [data(node) for node in filter!(i -> i != Node("s", 0), nodes(tour_rsl))]

# export the tour
write_tour("shredder-julia/tsp/tours/$("RSL_" * filename)", tour_rsl_array, score_picture("projet/phase 5/shredder-julia/images/shuffled/$(filename)"))

# create the reconstructed image from the tour
reconstruct_picture("shredder-julia/tsp/tours/$("RSL_" * filename)", "projet/phase 5/shredder-julia/images/shuffled/$(filename)",
                    "shredder-julia/images/reconstructed/$("RSL_" * filename)"; true)

######## using LK ########
tour_lk, cost_lk, is_tour_lk, time_lk = lin_kernighan(g, kruskal, Node("s", 0), 1000, 60, [1.0, 2.0], true)

# HERE WE NEED TO GET THE NODES PARSED ONTO AND ARRAY OF INTEGERS
# without considering the -fake- source node
tour_lk_array = [data(node) for node in filter!(i -> i != Node("s", 0), nodes(tour_lk))]

# export the tour
write_tour("shredder-julia/tsp/tours/$("LK_" * filename)", tour_lk_array, score_picture("projet/phase 5/shredder-julia/images/shuffled/$(filename)"))

# create the reconstructed image from the tour
reconstruct_picture("shredder-julia/tsp/tours/$("LK_" * filename)", "projet/phase 5/shredder-julia/images/shuffled/$(filename)",
                    "shredder-julia/images/reconstructed/$("LK_" * filename)"; true)