# include required libraries
include("../phase 1/read_stsp.jl")
include("../phase 4/RSL_module.jl")
include("../phase 4/LK_module.jl")
include("shredder-julia/bin/tools.jl")
const PROJECT_PATH = "/Users/flore/Desktop/Cours/MTH6412B/Projet/mth6412b-starter-code/projet"
filename = "marlet2-radio-board"
#ARGS[2]
picture = load(PROJECT_PATH * "/phase 5/shredder-julia/images/shuffled/$(filename).png")

####### LK PARAM ###################################
const TOUR_ALGO = "HK"#ARGS[1]
const READ = "pre"
const STEP = [1.0, 30.0]
const ADAPT = true
const RAND_ROOT = true
const TL = 300
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

# # create the object
# g = Graph{Int}(filename, Vector{Node}(), Vector{Edge}())

# for i in 1:size(picture, 2)
#     add_node!(g, Node(string(i), i))
# end

# if TOUR_ALGO == "HK"
#     # add –fake– node as a source
#     add_node!(g, Node("s", 0))

#     # considers each column as a node
#     for i in 1:size(picture, 2)
#         # add the zero weight from the -fake- source to each node
#         add_edge!(g, Edge((get_node(g, "s"), get_node(g, string(i))), 0.0))

#         # the the edge to between other nodes
#         for j in i:size(picture, 2)
#             # compute the weight of the edge and add the edge
#             # as the matrix is symmetric, then skip the lower triangular matrix as well as the diagonal
#             computed_weight = convert(Float64,compare_columns(picture[:,i], picture[:,j]))
#                 # add the edge
#             add_edge!(g, Edge((get_node(g,string(i) ), get_node(g, string(j))), computed_weight))
#         end
#     end
# end

g = build_graph(PROJECT_PATH * "/phase 5/shredder-julia/tsp/instances/$(filename).tsp")
# ------------------------------------------------------------------ #
# ------------------------ compute the tour ------------------------ #
# ------------------------------------------------------------------ #
###### using RSL ########
if TOUR_ALGO == "RSL"

    println("Checking ineg")
    trig_ineg = has_triang_ineg(g)
    @show trig_ineg
    if trig_ineg
        root = nodes(g)[rand(1:nb_nodes(g))]
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

    tour_lk, cost_lk, is_tour_lk, time_lk , tour_comp_lk, graph_modified_weight = lk(g, ALGO, get_node(g,"1"), 1000, TL, STEP, ADAPT, RAND_ROOT)
    if !is_tour_lk
        if READ == "pre"
            tour_nodes = parcours_preordre!(tour_lk, get_node(tour_lk, "1"))
        end
        tour_lk_array =  parse.(Int, name.(tour_nodes)) .-1
        # i = findall(x -> x == 601, tour_lk_array)
        # deleteat!(tour_lk_array, i)
        @show length(tour_lk_array)
    else
        tour_lk_array = Vector{Int}()
        neigh = get_all_neighbours(tour_lk, get_node(g, "1"))
        tour_lk_array = parcours_cycle(tour_comp_lk, neigh[1])
    end

    #our_weight = get_weight_of(g, tour_lk_array)
    #@show tour_weight
    
    # export the tour
    write_tour(PROJECT_PATH * "/phase 5/shredder-julia/tsp/tours/$(filename)_lk_$(STEP)_$(ADAPT)_$(ALGO)_$(READ)_$(TL)_$(RAND_ROOT).tour", tour_lk_array, score_picture(PROJECT_PATH * "/phase 5/shredder-julia/images/original/$(filename).png"))
   # PROJECT_PATH * "/phase 5/shredder-julia/images/reconstructed/$(filename)_lk_$(STEP)_$(ADAPT)_$(ALGO)_$(READ)_$(TL)_$(RAND_ROOT).png"; view = true)))
    # create the reconstructed image from the tour
    reconstruct_picture(PROJECT_PATH * "/phase 5/shredder-julia/tsp/tours/$(filename)_lk_$(STEP)_$(ADAPT)_$(ALGO)_$(READ)_$(TL)_$(RAND_ROOT).tour", PROJECT_PATH * "/phase 5/shredder-julia/images/shuffled/$(filename).png",
    PROJECT_PATH * "/phase 5/shredder-julia/images/reconstructed/$(filename)_lk_$(STEP)_$(ADAPT)_$(ALGO)_$(READ)_$(TL)_$(RAND_ROOT).png"; view = true)
end