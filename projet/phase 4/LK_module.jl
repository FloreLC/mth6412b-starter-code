module LK_module
include("./Comp_module.jl")
include("../phase 1/graph.jl")
using .Comp_module

export lin_kernighan

"""
Takes as parameters a graph, an algorithm for MST, a root (or nothing in whose case the root is randomly selected at each iteration),
iteration limit, time limit, step size as a vector of two numbers to bound the random number generator, an adaptive as a boolean to indicate whether
the step size update uses a fraction (0.3) of the previous result. It returns the best solution found as a graph, its cost, whether it is a tour
and the elapsed time it took.
"""
function lin_kernighan(g::Graph, algorithm::Function, root::Union{Node, nothing}, max_iterations::Int64, max_time::Int64, step::Vector{Float64,Float64}, adaptive::Bool) where T

    # call the required libraries
    using Random
    Random.seed!(seed) # set the seed for the random number generator
    
    # clocks the time
    starting_time = time()
    elapsed_time = time() - starting_time
    
    # creates starting objects to iteratively modify them
    one_tree = Graph{T}()
    tree_comp = zeros(Int, nb_nodes(g))
    tree_cost = 0
    dual_cost = 0

    # creates a dictionary that indicates the degree of each node in the 1-tree
    dict_pi = Dict{Node, Float64}()
    for n in nodes(graph)
        dict_pi[n] = 0.0
    end
    
    # creates a dictionary that represents the difference of degree with a tour
    graph_degree, graph_degree_prev = Dict{Node, Float64}(), Dict{Node, Float64}()
    for n in nodes(graph)
        graph_degree[n] = 0.0
        graph_degree_prev[n] = 0.0
    end

    # create a dictionary with the original weights
    og_weights = Dict{Edge, Float64}()
    for e in edges(g)
        og_weights[e] = weight(e)
    end

    # tracks the improvement over the cost function
    incumbent = -Inf # starting lower bound

    # initial step size
    step_size = rand(step[1]:0.1:step[2])

    # initialize the counter for the iterations
    iter = 1

    # the tour indicador is set to be false
    is_tour = false
    
    while iter <= max_iterations && elapsed_time <= max_time

        println("-----------------------------------------------------------------------------------------------------------")
        println("--- Iteration: $(iter) | Elapsed time (s): $(round(elapsed_time; digits = 4)) | Incumbent: $(incumbent) ---")
        println("-----------------------------------------------------------------------------------------------------------")

        # changes the weights in the graph
        for edge in edges(graph)
            # get the ends of the edge
            n1, n2 = ends(edge)

            set_weight!(edge, og_weights[edge] + dict_pi[n1] + dict_pi[n2])
        end
        
        # construct the 1-tree and the degree of the nodes
        if !isnothing(root)
            global one_tree, tree_comp = one_tree(Graph{T}("", nodes(g), copy(edges(g))), algorithm, root)
        else
            global one_tree, tree_comp = one_tree(Graph{T}("", nodes(g), copy(edges(g))), algorithm, nodes(graph)[rand(1:nb_nodes(graph))])
        end
        
        # compute the total cost of the 1-tree
        global tree_cost = sum(weight.(edges(one_tree)))

        # compute the lagrangian
        global dual_cost = tree_cost - 2*sum(values(dict_pi))

        # update the incumbent
        global incumbent = max(incumbent, dual_cost)

        # getting the difference with a degree of 2
        if !adaptive
            for n in nodes(graph)
                graph_degree[n] = degree(tree_comp, n) - 2
                graph_degree_prev[n] = graph_degree_prev[n]
            end
        else
            if iter == 1
                for n in nodes(graph)
                    global graph_degree[n] = degree(tree_comp, n) - 2
                    global graph_degree_prev[n] = graph_degree_prev[n]
                end
            else
                for n in nodes(graph)
                    global graph_degree_prev[n] = graph_degree[n]
                    global graph_degree[n] = degree(tree_comp, n) - 2
                end
            end
        end

        # check for a tour
        if all(collect(values(graph_degree)) .== 0)
            
            # here we should get the original weights in the tree
            for edge in edges(one_tree)

                # replace the weights
                set_weight!(edge, og_weights[edge])
            end

            # update the 1-tree cost
            global tree_cost = sum(weight.(edges(one_tree)))
            println("---------------------------------------------")
            println("----- A Hamiltonian tour has been found -----")
            println("---- The tour found has cost $(tree_cost) ----")
            println("---------------------------------------------")
            # indicator to check whether the solution is a tour
            global is_tour = true

            # updates the time
            global elapsed_time = time() - starting_time

            return one_tree, tree_cost, is_tour, elapsed_time
            break
        end

        # update the step size
        global step_size = rand(step[1]:0.1:step[2]) / iter

        # Update reduced costs
        for n in nodes(graph)
            dict_pi[n] = dict_pi[n] + step_size * (0.7*graph_degree[n] + 0.3*graph_degree_prev[n])
        end

        # increase the counter
        global iter = iter + 1

        # updates the time
        global elapsed_time = time() - starting_time
    end

    #### now it actually print out according to the progress and not when going out of the loop
    if !is_tour
        println("----------------------------------------------------")
        println("------ A Hamiltonian tour has not been found -------")
        println("-------- Best lower bound costs $(incumbent) -------")
        println("----------------------------------------------------")
    end
    
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
