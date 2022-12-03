
import Base.isequal
using Random
include("MST_module.jl")

"""
Takes as parameters a graph, an algorithm for MST, a root (or nothing in whose case the root is randomly selected at each iteration),
iteration limit, time limit, step size as a vector of two numbers to bound the random number generator, an adaptive as a boolean to indicate whether
the step size update uses a fraction (0.3) of the previous result. It returns the best solution found as a graph, its cost, whether it is a tour
and the elapsed time it took.
"""
function lin_kernighan(graph::Graph{T}, algorithm::Function, root::Union{Nothing, Node{T}}, max_iterations::Int64, max_time::Int64, step::Vector{Float64}) where T

    # clocks the time
    starting_time = time()
    elapsed_time = time() - starting_time

    ######### STEP 0 ##########
    # creates starting objects to iteratively modify the

    one_tree = Graph{T}("1tree", Vector{Node{T}}(), Vector{Edge{T}}())
    tree_comp = Component{T}()
    # root_tmp = Node{T}()
    tree_cost = 0
    dual_cost = 0

    period = floor(length(nodes(graph)) / 2)
    period_counter = 0
    is_first_period = true
    is_step_size_doubled = false

    # create a dictionary with the original weights
    og_weights = Dict{Edge, Float64}()
    for edge in edges(graph)
        og_weights[edge] = weight(edge)
    end

    # creates a dictionary that indicates the degree of each node in the 1-tree
    dict_pi = Dict{Node{T}, Float64}()
    for n in nodes(graph)
        dict_pi[n] = 0.0
    end

    # creates a dictionary that represents the difference of degree with a tour
    graph_degree = Dict{Node, Float64}()
    graph_degree_prev = Dict{Node, Float64}()
    for n in nodes(graph)
        graph_degree[n] = 0.0
        graph_degree_prev[n] = 0.0
    end

    ########## STEP 1 ##########
    # iteration counter
    iter = 1

    # tracks the improvement over the cost function
    incumbent = [-Inf, -Inf] # starting lower bound, where [1] is at iteration (i-th - 1) and [2] at iteration (i-th)

    # initial step size
    step_size = rand(step[1]:0.1:step[2])

    # the tour indicador is set to be false
    is_tour = false
    
    while iter <= max_iterations && elapsed_time <= max_time

        # create a dictionary with the original weights
        og_weights = Dict{Edge, Float64}()
        for edge in edges(graph)
            og_weights[edge] = weight(edge)
        end

        # modify the cost matrix
        # changes the weights in the graph
        for edge in edges(graph)
            # get the ends of the edge
            n1, n2 = ends(edge)
            
            set_weight!(edge, og_weights[edge] + dict_pi[n1] + dict_pi[n2])
            # set_weight!(edge, weight(edge) + dict_pi[n1] + dict_pi[n2])
        end

        println("++++++++++++++++++++++")
        @show og_weights
        println("++++++++++++++++++++++")

        ########## STEP 2 ##########
        # construct the 1-tree and the degree of the nodes
        
        one_tree, tree_comp, root_tmp = get_one_tree(Graph{T}("", nodes(graph), edges(graph)), algorithm, root)

        ########## STEP 3 ##########
        # compute the dual cost
        tree_cost = sum(weight.(edges(one_tree)))
        dual_cost = tree_cost - 2*sum(values(dict_pi))

        ########## STEP 4 ##########
        # compute the incumbent

        # update the incumbent to save the two previous results
        incumbent[1] = incumbent[2]
        incumbent[2] = max(incumbent[2], dual_cost)

        ########## STEP 5 ##########
        # compute the degree of the nodes minus 2
        for n in collect(keys(degrees(tree_comp)))
            graph_degree[n] = degree(tree_comp, n) - 2
        end

        elapsed_time = time() - starting_time

        println("-----------------------------------------------------------------------------------------------------------")
        println("--- Iteration: $(iter) | Elapsed time (s): $(round(elapsed_time; digits = 4)) | Incumbent: $(incumbent[2]) ---")
        println("-----------------------------------------------------------------------------------------------------------")

        ########## STEP 6 ##########
        # if we get a tour, then the degree minus 2 should be all zero
        if all(collect(values(graph_degree)) .== 0)

            println("---------------------------------------------")
            println("----- A Hamiltonian tour has been found -----")
            println("---- The tour found has cost $(incumbent[2]) ----")
            println("---------------------------------------------")
            # indicator to check whether the solution is a tour
            is_tour = true

            # updates the time
            elapsed_time = time() - starting_time

            return one_tree, tree_cost, is_tour, elapsed_time, tree_comp, graph
        end

        ########## STEP 7 ##########
        # choose a step size
        period_counter = period_counter + 1 # increase the counter

        # if we are at the first period and the incumbent has not impreved
        if is_first_period && (incumbent[2] <= incumbent[1]) && !is_step_size_doubled
            is_step_size_doubled = true
            step_size = step_size * 2
        else
            # if in the last iteration the incumbent gets improved
            if period_counter == period && (incumbent[1] < incumbent[2])
                step_size = step_size * 2
                period = floor(period * 2)
                is_first_period = false # the forward iterations are no longer within the first period
            elseif period_counter <= period
                step_size = step_size
            else
                period_counter = 0 # reinitialize the period counter
                step_size = step_size / 2
                period = floor(period / 2)
            end
        end

        ########## STEP 8 ##########
        # update penalizations

        # Update reduced costs
        for n in collect(keys(degrees(tree_comp)))
            dict_pi[n] = dict_pi[n] + step_size * graph_degree[n]
        end

        ########## STEP 9 ##########
        # increase the iteration counter
        iter = iter + 1
    end

    if !is_tour
        println("----------------------------------------------------")
        println("------ A Hamiltonian tour has not been found -------")
        println("-------- Tour has cost $(incumbent[2]) -------")
        println("----------------------------------------------------")
    end
    
    return one_tree, tree_cost, is_tour, elapsed_time, tree_comp, graph
end
