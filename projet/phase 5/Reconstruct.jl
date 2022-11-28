# include required libraries
include("../phase 1/graph.jl")
include("../phase 4/RSL_module.jl")
include("../phase 4/LK_module.jl")
include("shredder-julia/bin/tools.jl")
const PROJECT_PATH = "/Users/flore/Desktop/Cours/MTH6412B/Projet/mth6412b-starter-code/projet"
filename = "the-enchanted-garden"
picture = load(PROJECT_PATH * "/phase 5/shredder-julia/images/shuffled/$(filename).png")



####### LK PARAM ###################################
const READ = "pre"
const STEP = [20.0, 30.0]
const ADAPT = true
const TL = 120
const ALGO = kruskal


####################################################

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

###### using RSL ########
println("Checking ineg")
trig_ineg = has_triang_ineg(g)
@show trig_ineg
if trig_ineg
    tour_rsl, cost_rsl, time_rsl = rsl(g, Node("s", 0), kruskal, trig_ineg; TL = 60)

    tour_nodes = parcours_postordre!(tour_rsl, get_node(tour_rsl, "s"))
    @show data.(tour_nodes)
    position = findfirst(x -> name(x) == "s", tour_nodes)
    deleteat!(tour_nodes, position)
    tour_rsl_array =  data.( tour_nodes)

# export the tour
    write_tour(PROJECT_PATH * "/phase 5/shredder-julia/tsp/tours/$(filename)_rsl.tour", tour_rsl_array, score_picture(PROJECT_PATH * "/phase 5/shredder-julia/images/shuffled/$(filename).png"))

# create the reconstructed image from the tour
    reconstruct_picture(PROJECT_PATH * "/phase 5/shredder-julia/tsp/tours/$(filename)_rsl.tour", PROJECT_PATH * "/phase 5/shredder-julia/images/shuffled/$(filename).png",
    PROJECT_PATH * "/phase 5/shredder-julia/images/reconstructed/$(filename)_rsl.png"; view = true)
end
# ######## using LK ########
println("starting LK")

tour_lk, cost_lk, is_tour_lk, time_lk , tour_comp_lk, graph_modified_weight = lin_kernighan(g, ALGO, get_node(g,"s"), 1000, TL, STEP, ADAPT)

if !is_tour_lk
    to_remove = get_all_neighbours(tour_lk, get_node(tour_lk, "s"))
    index_to_remove_1 = get_edge_index_in_list(edges(tour_lk), get_node(tour_lk, "s"), to_remove[1])
    deleteat!(edges(tour_lk), index_to_remove_1)
    index_to_remove_2 = get_edge_index_in_list(edges(tour_lk), get_node(tour_lk, "s"), to_remove[2])
    deleteat!(edges(tour_lk), index_to_remove_2)
    deleteat!(nodes(tour_lk), findfirst(x -> name(x) == "s", nodes(tour_lk)))
    
    tour_nodes = parcours_postordre!(tour_lk, to_remove[1])
    if READ == "pre"
        tour_nodes = parcours_preordre!(tour_lk, to_remove[1])
    end
    @show data.(tour_nodes)
    tour_lk_array =  data.( tour_nodes)
else
    tour_lk_array = Vector{Int}()
    neigh = get_all_neighbours(tour_lk, get_node(g, "s"))
    tour_lk_array = [get_node(g, "s"), parcours_cycle(tour_comp_lk, neigh[1])]
end
# export the tour
write_tour(PROJECT_PATH * "/phase 5/shredder-julia/tsp/tours/$(filename)_lk_$(STEP)_$(ADAPT)_$(ALGO)_$(READ).tour", tour_lk_array, score_picture(PROJECT_PATH * "/phase 5/shredder-julia/images/shuffled/$(filename).png"))

# create the reconstructed image from the tour
reconstruct_picture(PROJECT_PATH * "/phase 5/shredder-julia/tsp/tours/$(filename)_lk_$(STEP)_$(ADAPT)_$(ALGO)_$(READ).tour", PROJECT_PATH * "/phase 5/shredder-julia/images/shuffled/$(filename).png",
PROJECT_PATH * "/phase 5/shredder-julia/images/reconstructed/$(filename)_lk_$(STEP)_$(ADAPT)_$(ALGO)_$(READ).png"; view = true)