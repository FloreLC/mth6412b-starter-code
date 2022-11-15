module LK_module
include("./Comp_module.jl")
include("../phase 1/graph.jl")
using .Comp_module

export lin_kernighan

"""
Takes as parameters a graph, an algorithm for MST, a root , iteration limit, time limit, step size, adaptive
returns an Tour
"""
function lin_kernighan(g::Graph, algorithm::Function, root::Node, max_iterations::Int64, max_time::Int64, step::Float64, adaptive::Bool) where T

    #####################################
    ##### here starts the algorithm #####
    #####################################

    # tracks the improvement over the cost function
    incumbent = 0 # starting lower bound

    # initialize the counter for the iterations
    iter = 1

    # clocks the time
    starting_time = time()
    elapsed_time = time()-starting_time

    one_tree = Graph{T}()
    graph_degree= zeros(Int, nb_nodes(g))

    og_weights = Dict{Edge{T}, Float64}()
    for e in edges(g)
        og_weights[e] = weight(e)
    end

    dict_pi = Dict{Node{T}, Float64}()
    for n in nodes(g)
        dict_pi[n] = 0.0
    end
    while iter <= max_iterations && elapsed_time <= max_time

        # print out the progress so far
        println("-----------------------------------------------------------------------------------------------------------")
        println("--- Iteration: $(iter) | Elapsed time (s): $(round(elapsed_time; digits = 4)) | Incumbent: $(incumbent) ---")
        println("-----------------------------------------------------------------------------------------------------------")

        ##################################################################
        ################## STEP 2: Construct the 1-tree ##################
        ##################################################################

        # changes the weights in the graph
        for edge in edges(g)
            # get the ends of the edge
            n1, n2 = ends(edge)           
            set_weight!(edge, max(0,og_weights[edge] - dict_pi[n1] - dict_pi[n2]))
        end
       
        # constructs the 1-tree
 
        one_tree, tree_comp = one_tree(Graph{T}("", nodes(g), copy(edges(g))), algorithm, root)
  
        #################################################################
        ################## STEP 3: Update the cost ######################
        #################################################################
        # compute the total cost of the 1-tree
        tree_cost = sum(weight.(edges(one_tree)))

        # update the cost
        dual_cost = tree_cost - 2*sum(values(dict_pi))

        #################################################################
        ############# STEP 4: Get the current incumbent #################
        #################################################################
        incumbent = max(incumbent, dual_cost)
   
        #################################################################
        ################ STEP 5: Get the graph degree ###################
        #################################################################
        # if the way is said not to be adaptive then
        # both graph_degree are the same to save lines below
        # otherwise, save the previous graph_degree and then 
        # update it

        graph_degree = [degree(tree_comp, n) - 2 for n in nodes(g)]
        # if !adaptive
        #     graph_degree = [degree(TreeDegree, n) - 2 for n in nodes(g)]
        #     graph_degree_prev =copy(graph_degree)
        # else
        #     if iter == 1
        #         graph_degree = [degree(TreeDegree, n) - 2 for n in nodes(g)]
        #         graph_degree_prev = copy(graph_degree)
        #     else
        #         graph_degree_prev = copy(graph_degree)
        #         graph_degree = [degree(TreeDegree, n) - 2 for n in nodes(g)]
        #     end
        # end

        #################################################################
        ################## STEP 6: Check for a tour #####################
        #################################################################
        if all(graph_degree .== 0)
            # here we should get the original weights in the tree
            for edge in edges(one_tree)
                # get the ends of the edge
                n1, n2 = ends(edge)
                set_weight!(get_edge(one_tree, n1, n2), weight(get_edge(g, n1, n2)))
            end

            # update the 1-tree cost
            tree_cost = sum(weight.(edges(one_tree)))
            println("---------------------------------------------")
            println("----- A Hamiltonian tour has been found -----")
            println("---- The tour found has cost $(TreeCost) ----")
            println("---------------------------------------------")
            # indicator to check whether the solution is a tour
            is_tour = false

            # updates the time
            elapsed_time = time()-starting_time

            return one_tree, tree_cost, is_tour, elapsed_time
            break
        end

        #################################################################
        ################ STEP 7: Update the step size ###################
        #################################################################
        # compute the norm
        norm_degree = sqrt(sum(values(degrees(tree_comp)) .^ 2))
  
        # update the step size
        @show step
        @show incumbent
        @show dual_cost
        # if incumbent - dual_cost > 0
        #     step = (step) * (incumbent - dual_cost ) / norm_degree 
        # end
      
        #################################################################
        ################ STEP 8: Update reduced costs ###################
        #################################################################
        # if not adaptive graph_degree and graph_degree_prev are equal
    
  
        for n in nodes(g)
            dict_pi[n] = dict_pi[n] - step * (degree(tree_comp, n) - 2)
        end
        
        #################################################################
        ################ STEP 8: Update reduced costs ###################
        #################################################################
        # increase the counter
        iter = iter + 1

        # updates the time
        elapsed_time = time()- starting_time
    end

    println("---------------------------------------------")
    println("--- A Hamiltonian tour could not be found ---")
    println("---------------------------------------------")
    # indicator to check whether the solution is a tour
    is_tour = false

    # here we should get the original weights in the tree
    for edge in edges(one_tree)
        # get the ends of the edge
        n1, n2 = ends(edge)

        set_weight!(get_edge(one_tree, n1, n2), weight(get_edge(g, n1, n2)))
        
    end
    # update the 1-tree cost
    tree_cost = sum(weight.(edges(one_tree)))

    # updates the time
    elapsed_time = time() - starting_time
    
    return one_tree, tree_cost, is_tour, elapsed_time

end


"""
Take a graph, an algorithm and a root, and build a one-tree with this root. Returns the tree (a graph struct) and a component structure describing the tree.
"""
function one_tree(g::Graph{T}, algorithm::Function, root::Node{T}) where T
    # Lists the edges adjacents to the root
    to_remove = get_all_edges_with_node(g, root)

    # Creates a vector of all graph's node except the root 
    nodes_copy = nodes(g)[findall(x->name(x)!=name(root),nodes(g))]

   # Creates a vector of all graphs edges except the edges adjacent to the root 
    edges_copy = filter(x -> !(x in to_remove), edges(g))

    # Gets the MST tree and its corresponding connex component c for the subgraph g[V\{root}]
    tree , c = algorithm(Graph{T}("", nodes_copy, edges_copy))
 
    #Sorts the remaining edges by weight
    edge_sorted = sort(to_remove, by=weight)

    # Add the root and 2 cheapest arcs from the root to a leaf
    # Keep the component c updated
    # ATTENTION: from now on, because the tree is now a 1-tree, the component c does not contain the information for the edges touching root. 
    # We are keeping the degree dictionary updated
    add_node!(tree, root)
    for i in 1:2
        e = pop!(edge_sorted)
        add_edge!(tree, e)
        # If any of the 2 extremities is root, its degree wont be updated, because it wont be part of the dictionnary yet
        increase_degree!(c, ends(e)[1]) 
        increase_degree!(c, ends(e)[2]) 
    end
    degrees(c)[root] = 2

    return tree, c
end

end