# include required libraries
include("../phase 1/graph.jl")
include("../phase 4/RSL_module.jl")
include("../phase 4/LK_module.jl")
include("shredder-julia/bin/tools.jl")
const PROJECT_PATH = "/Users/luisrojo/Library/CloudStorage/OneDrive-usach.cl/PhD/Courses_Polymtl/OR Algorithms/Laboratory/mth6412b-starter-code/projet"
filename = "lower-kananaskis-lake"#ARGS[2]
picture = load(PROJECT_PATH * "/phase 5/shredder-julia/images/shuffled/$(filename).png")

####### LK PARAM ###################################
const TOUR_ALGO = "HK"#ARGS[1]
const READ = "pre"
const STEP = [1.0, 1.0]
const ADAPT = true
const RAND_ROOT = true
const TL = 600
const ALGO = kruskal
####################################################
println("Parametres: ")
@show TOUR_ALGO
if TOUR_ALGO == "HK"
    @show STEP
    @show ADAPT
    @show RAND_ROOT
end
@show TL
@show ALGO
@show filename

# create the object
g = Graph{Int}(filename, Vector{Node}(), Vector{Edge}())

for i in 1:size(picture, 2)
    add_node!(g, Node(string(i), i))
end

if TOUR_ALGO == "HK"
    # add –fake– node as a source
    add_node!(g, Node("s", 0))

    # considers each column as a node
    for i in 1:size(picture, 2)
        # add the zero weight from the -fake- source to each node
        add_edge!(g, Edge((get_node(g, "s"), get_node(g, string(i))), 0.0))

        # the the edge to between other nodes
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
end

# # get the optimal tour

# using TravelingSalesmanExact, GLPK

# set_default_optimizer!(GLPK.Optimizer)
# cities = [100*rand(2) for _ in 1:length(nodes(g))]

# cost_matrix = zeros(length(nodes(g)), length(nodes(g)))

# for edge in edges(g)
#     n1, n2 = ends(edge)
#     if data(n1) == data(n2)
#         cost_matrix[data(n1) + 1, data(n2) + 1]
#     else
#         cost_matrix[data(n1) + 1, data(n2) + 1] = weight(edge)
#         cost_matrix[data(n2) + 1, data(n1) + 1] = weight(edge)
#     end
# end

# tour, cost = get_optimal_tour(cost_matrix, verbose = true)

# tour = tour .- 1

# write_tour(PROJECT_PATH * "/phase 5/shredder-julia/tsp/tours/$(filename)_optimal.tour", tour, score_picture(PROJECT_PATH * "/phase 5/shredder-julia/images/shuffled/$(filename).png"))
# reconstruct_picture(PROJECT_PATH * "/phase 5/shredder-julia/tsp/tours/$(filename)_optimal.tour", PROJECT_PATH * "/phase 5/shredder-julia/images/shuffled/$(filename).png",
#     PROJECT_PATH * "/phase 5/shredder-julia/images/reconstructed/$(filename)_optimal.png"; view = true)

# ------------------------------------------------------------------ #
# ------------------------ compute the tour ------------------------ #
# ------------------------------------------------------------------ #
###### using RSL ########
if TOUR_ALGO == "RSL"

    println("Checking ineg")
    trig_ineg = has_triang_ineg(g)
    @show trig_ineg
    if trig_ineg
        root = nodes(g)[rand(nb_nodes(g))]
        tour_rsl, cost_rsl, time_rsl = rsl(g, root , ALGO, trig_ineg; TL = TL)
        tour_nodes = parcours_postordre!(tour_rsl, root)
        @show data.(tour_nodes)
        tour_rsl_array =  data.( tour_nodes)

    # export the tour
        write_tour(PROJECT_PATH * "/phase 5/shredder-julia/tsp/tours/$(filename)_rsl_$(ALGO)_$(TL).tour", tour_rsl_array, score_picture(PROJECT_PATH * "/phase 5/shredder-julia/images/shuffled/$(filename).png"))

    # create the reconstructed image from the tour
        reconstruct_picture(PROJECT_PATH * "/phase 5/shredder-julia/tsp/tours/$(filename)_rsl_$(ALGO)_$(TL).tour", PROJECT_PATH * "/phase 5/shredder-julia/images/shuffled/$(filename).png",
        PROJECT_PATH * "/phase 5/shredder-julia/images/reconstructed/$(filename)_rsl_$(ALGO)_$(TL).png"; view = true)
    end
    ######## using LK ########
elseif TOUR_ALGO == "HK"
    println("starting HK")

    tour_lk, cost_lk, is_tour_lk, time_lk , tour_comp_lk, graph_modified_weight = lin_kernighan(g, ALGO, get_node(g,"s"), 1000000000, TL, STEP, ADAPT, RAND_ROOT)

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
        # @show data.(tour_nodes)
        tour_lk_array =  data.( tour_nodes)
    else
        tour_lk_array = Vector{Int}()
        neigh = get_all_neighbours(tour_lk, get_node(g, "s"))
        tour_lk_array = [get_node(g, "s"), parcours_cycle(tour_comp_lk, neigh[1])]
    end
    # export the tour
    write_tour(PROJECT_PATH * "/phase 5/shredder-julia/tsp/tours/$(filename)_lk_$(STEP)_$(ADAPT)_$(ALGO)_$(READ)_$(TL)_$(RAND_ROOT).tour", tour_lk_array, score_picture(PROJECT_PATH * "/phase 5/shredder-julia/images/shuffled/$(filename).png"))

    # create the reconstructed image from the tour
    reconstruct_picture(PROJECT_PATH * "/phase 5/shredder-julia/tsp/tours/$(filename)_lk_$(STEP)_$(ADAPT)_$(ALGO)_$(READ)_$(TL)_$(RAND_ROOT).tour", PROJECT_PATH * "/phase 5/shredder-julia/images/shuffled/$(filename).png",
    PROJECT_PATH * "/phase 5/shredder-julia/images/reconstructed/$(filename)_lk_$(STEP)_$(ADAPT)_$(ALGO)_$(READ)_$(TL)_$(RAND_ROOT).png"; view = true)
end