# the the lin kernighan function

# loading libraries
#using Pkg # how to do this optional?
#Pkg.add("DataFrames")
using DataFrames
#Pkg.add("StatsPlots")
using StatsPlots

include("tree.jl")

# create the graph
#graph = build_graph("swiss42.tsp")

graph = Graph{Char}()
for i in 1:9
    n = Node(string('a' + i-1), 'a' + i-1)
    add_node!(graph, n)
end
add_edge!(graph, Edge((get_node(graph, "a"), get_node(graph, "b")), 4.0))
add_edge!(graph, Edge( (get_node(graph, "a"), get_node(graph, "h")), 8.0))
add_edge!(graph, Edge((get_node(graph, "b"), get_node(graph, "h")), 11.0))
add_edge!(graph, Edge((get_node(graph, "b"), get_node(graph, "c")), 8.0))
add_edge!(graph, Edge((get_node(graph, "h"), get_node(graph, "i")), 7.0))
add_edge!(graph, Edge((get_node(graph, "g"), get_node(graph, "h")), 1.0))
add_edge!(graph, Edge((get_node(graph, "i"), get_node(graph, "g")), 6.0))
add_edge!(graph, Edge((get_node(graph, "i"), get_node(graph, "c")), 2.0))
add_edge!(graph, Edge((get_node(graph, "g"), get_node(graph, "f")), 2.0))
add_edge!(graph, Edge((get_node(graph, "c"), get_node(graph, "f")), 4.0))
add_edge!(graph, Edge((get_node(graph, "c"), get_node(graph, "d")), 7.0))
add_edge!(graph, Edge((get_node(graph, "d"), get_node(graph, "f")), 14.0))
add_edge!(graph, Edge((get_node(graph, "d"), get_node(graph, "e")), 9.0))
add_edge!(graph, Edge((get_node(graph, "f"), get_node(graph, "e")), 10.0))

# clocks the time
starting_time = time()
elapsed_time = time() - starting_time
OneTree = Graph{Vector{Float64}}("onetree", Vector{Node}(), Vector{Edge}())
tree_degree = zeros(Int, nb_nodes(graph))
TreeCost = 0
dual_cost = 0
graph_degree = zeros(Int, nb_nodes(graph))

# create a dictionary with the original weights
og_weights = Dict{Edge, Float64}()
for e in edges(graph)
    og_weights[e] = weight(e)
end

# create PI vector which will have an element for each node
dict_pi = Dict{Node, Float64}()
for n in nodes(graph)
    dict_pi[n] = 0.0
end

# tracks the improvement over the cost function
incumbent = -Inf # starting lower bound

# initial step size
step = 0.1

# initialize the counter for the iterations
iter = 1

# the tour indicador is set to be false
Tour = false

# set the seed for the random number generator
# srand(12345)

while iter <= 10 #&& elapsed_time <= 60000000

    println("-----------------------------------------------------------------------------------------------------------")
    println("--- Iteration: $(iter) | Elapsed time (s): $(round(elapsed_time; digits = 4)) | Incumbent: $(incumbent) ---")
    println("-----------------------------------------------------------------------------------------------------------")

    # changes the weights in the graph
    for edge in edges(graph)
        # get the ends of the edge
        n1, n2 = ends(edge)

        ####################################################################################
        ###################################### CHANGE ######################################
        ################################### the + instead o - ##############################
        ####################################################################################

        #set_weight!(edge, og_weights[edge] + dict_pi[n1] + dict_pi[n2])
        set_weight!(edge, weight(edge) + dict_pi[n1] + dict_pi[n2])
    end

    # construct the 1-tree and the degree of the nodes
    global OneTree, tree_degree = one_tree(graph, prim, nodes(graph)[1])
    
    # erase this break afterwards, just for debugging
    break

    # compute the total cost of the 1-tree
    global TreeCost = sum(weight.(edges(OneTree)))

    # compute the lagrangian
    global dual_cost = TreeCost - 2*sum(values(dict_pi))

    # update the incumbent
    global incumbent = max(incumbent, dual_cost)

    # getting the difference with a degree of 2
    global graph_degree = [degree(tree_degree, n) - 2 for n in nodes(graph)]

    # break

    # check for a tour
    if all(graph_degree .== 0)
            
        # here we should get the original weights in the tree
        for edge in edges(OneTree)

            # replace the weights
            set_weight!(edge, og_weights[edge])
        end

        # update the 1-tree cost
        global TreeCost = sum(weight.(edges(OneTree)))
        println("---------------------------------------------")
        println("----- A Hamiltonian tour has been found -----")
        println("---- The tour found has cost $(TreeCost) ----")
        println("---------------------------------------------")
        # indicator to check whether the solution is a tour
        global Tour = true

        # updates the time
        global elapsed_time = time() - starting_time

        # return OneTree, TreeCost, Tour, elapsed_time
        break
    end

    # update the step size
    global step = step*rand()

    # Update reduced costs
    for n in nodes(graph)
        dict_pi[n] = dict_pi[n] + step * (degree(tree_degree, n) - 2)
    end

    # increase the counter
    global iter = iter + 1

    # updates the time
    global elapsed_time = time() - starting_time
end

#### now it actually print out according to the progress and not when going out of the loop
if !Tour
    println("-------------------------------------------------")
    println("----- A Hamiltonian tour has not been found -----")
end

# # here we have a function like
# function LinKernighan(g::Graph{T}, algorithm::Function, root::Node{T}, max_iterations::Int64, max_time::Int64, step::Float64, adaptive::Bool) where T
#     ################################
#     ###### initial parameters ######
#     ################################

#     # this gets the number of nodes in the graph
#     # V = length(Nodes)
#     V = nb_nodes(g)

#     # set the starting PI vector
#     #PI = Int[0 for i in range(1, length = V)]
    
#     ################################

#     #####################################
#     ##### here starts the algorithm #####
#     #####################################

#     # tracks the improvement over the cost function
#     incumbent = 0 # starting lower bound

#     # initialize the counter for the iterations
#     iter = 1

#     # clocks the time
#     starting_time = time()
#     elapsed_time = time()-starting_time
#     OneTree = Graph{T}()
#     graph_degree= zeros(Int, nb_nodes(g))

#     og_weights = Dict{Edge{T}, Float64}()
#     for e in edges(g)
#         og_weights[e] = weight(e)
#     end

#     dict_pi = Dict{Node{T}, Float64}()
#     for n in nodes(g)
#         dict_pi[n] = 0.0
#     end
#     while iter <= max_iterations && elapsed_time <= max_time

       
#         # print out the progress so far
#         println("-----------------------------------------------------------------------------------------------------------")
#         println("--- Iteration: $(iter) | Elapsed time (s): $(round(elapsed_time; digits = 4)) | Incumbent: $(incumbent) ---")
#         println("-----------------------------------------------------------------------------------------------------------")

#         ##################################################################
#         ################## STEP 2: Construct the 1-tree ##################
#         ##################################################################
#         # if we do this way, we are going to modify the weights each time
#         # and hence the obtained tour 1-tree will not have the 'rea' weights
#         # therefore we might change them again to the original ones.
        
#         # g_dual = copy(g)
#         # @show weight(edges(g_dual)[2])
      
#         # changes the weights in the graph
#         for edge in edges(g)
#             # get the ends of the edge
#             n1, n2 = ends(edge)
        
#             # LUIS: I think we are not actually replacing the edge
#             # replace the weight
#             #set_weight!(edge, edge.weight - PI[data(n1)] - PI[data(n2)])
           
           
#             set_weight!(edge, max(0,og_weights[edge] - dict_pi[n1] - dict_pi[n2]))
 
#         end
#         @show og_weights[edges(g)[11]]
#         @show weight(edges(g)[11])
#         # construct the 1-tree
#         OneTree, TreeDegree = one_tree(g, algorithm, root)
#         @show degrees(TreeDegree)
#         #################################################################
#         ################## STEP 3: Update the cost ######################
#         #################################################################
#         # compute the total cost of the 1-tree
#         TreeCost = sum(weight.(edges(OneTree)))
#         # update the cost
#         @show dict_pi
#         @show values(dict_pi)
#         @show 2*sum(values(dict_pi))
#         dual_cost = TreeCost - 2*sum(values(dict_pi))
#         @show dual_cost
#         #################################################################
#         ############# STEP 4: Get the current incumbent #################
#         #################################################################
#         incumbent = max(incumbent, dual_cost)
   
     

#         #################################################################
#         ################ STEP 5: Get the graph degree ###################
#         #################################################################
#         # if the way is said not to be adaptive then
#         # both graph_degree are the same to save lines below
#         # otherwise, save the previous graph_degree and then 
#         # update it

#         graph_degree = [degree(TreeDegree, n) - 2 for n in nodes(g)]
#         # if !adaptive
#         #     graph_degree = [degree(TreeDegree, n) - 2 for n in nodes(g)]
#         #     graph_degree_prev =copy(graph_degree)
#         # else
#         #     if iter == 1
#         #         graph_degree = [degree(TreeDegree, n) - 2 for n in nodes(g)]
#         #         graph_degree_prev = copy(graph_degree)
#         #     else
#         #         graph_degree_prev = copy(graph_degree)
#         #         graph_degree = [degree(TreeDegree, n) - 2 for n in nodes(g)]
#         #     end
#         # end

#         #################################################################
#         ################## STEP 6: Check for a tour #####################
#         #################################################################
#         if all(graph_degree .== 0)
#             # here we should get the original weights in the tree
#             for edge in edges(OneTree)
#                 # get the ends of the edge
#                 n1, n2 = ends(edge)
        
#                 # LUIS: I think we are not actually replacing the edge
#                 # replace the weight of the edge in g whose ends are n1 and n2
#                 #set_weight!(edge, weight(get_edge(g, n1, n2)))
#                 set_weight!(get_edge(OneTree, n1, n2), weight(get_edge(g, n1, n2)))
#             end
#             # update the 1-tree cost
#             TreeCost = sum(weight.(edges(OneTree)))
#             println("---------------------------------------------")
#             println("----- A Hamiltonian tour has been found -----")
#             println("---- The tour found has cost $(TreeCost) ----")
#             println("---------------------------------------------")
#             # indicator to check whether the solution is a tour
#             Tour = false

#             # updates the time
#             elapsed_time = time()-starting_time

#             return OneTree, TreeCost, Tour, elapsed_time
#             break
#         end

#         #################################################################
#         ################ STEP 7: Update the step size ###################
#         #################################################################
#         # compute the norm
#         norm_degree = sqrt(sum(values(degrees(TreeDegree)) .^ 2))
#         @show norm_degree
#         # update the step size
#         @show step
#         @show incumbent
#         @show dual_cost
#        # step = (step) * (incumbent - dual_cost ) / norm_degree 
      
#         #################################################################
#         ################ STEP 8: Update reduced costs ###################
#         #################################################################
#         # if not adaptive graph_degree and graph_degree_prev are equal
#         @show graph_degree
#         # @show graph_degree_prev
#         for n in nodes(g)
            
#             # PI[k] = PI[k] + step*(0.7*graph_degree[k] + 0.3*graph_degree_prev[k])
#             #PI[k] = PI[k] + step*graph_degree[k]
#             # PI[k] = Int(round(PI[k])) # this will no longer be necessary if changing the structure of the edge
#             dict_pi[n] = dict_pi[n] - step * (degree(TreeDegree, n) - 2)
#         end
     
#         #################################################################
#         ################ STEP 8: Update reduced costs ###################
#         #################################################################
#         # increase the counter
#         iter = iter + 1

#         # updates the time
#         elapsed_time = time()- starting_time
#     end

#     println("---------------------------------------------")
#     println("--- A Hamiltonian tour could not be found ---")
#     println("---------------------------------------------")
#     # indicator to check whether the solution is a tour
#     Tour = false

#     # here we should get the original weights in the tree
#     for edge in edges(OneTree)
#         # get the ends of the edge
#         n1, n2 = ends(edge)

#         # LUIS: I think we are not actually replacing the edge
#         # replace the weight of the edge in g whose ends are n1 and n2
#         # set_weight!(edge, weight(get_edge(g, n1, n2)))
#         set_weight!(get_edge(OneTree, n1, n2), weight(get_edge(g, n1, n2)))
#     end
#     # update the 1-tree cost
#     TreeCost = sum(weight.(edges(OneTree)))

#     # updates the time
#     elapsed_time = time() - starting_time

#     return OneTree, TreeCost, Tour, elapsed_time

# end