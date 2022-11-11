# include the required functions
include("tree.jl")

# here we have a function like
function LinKernighan(g::Graph{T}, algorithm::Function, root::Node{T}, max_iterations::Int64, max_time::Int64, step::Float64, adaptive::Bool) where T
    ################################
    ###### initial parameters ######
    ################################

    # this gets the number of nodes in the graph
    # V = length(Nodes)
    V = nb_nodes(g)

    # set the starting PI vector
    PI = [0 for i in range(1, length = V)]
    ################################

    #####################################
    ##### here starts the algorithm #####
    #####################################

    # tracks the improvement over the cost function
    incumbent = -Inf # starting lower bound

    # clocks the time
    elapsed_time = 0

    # initialize the counter for the iterations
    iter = 1

    while iter <= max_iterations && elapsed_time <= max_time

        # print out the progress so far
        println("-----------------------------------------------------------------------------------------------------------")
        println("--- Iteration: $(iter) | Elapsed time (s): $(round(elapsed_time; digits = 4)) | Incumbent: $(incumbent) ---")
        println("-----------------------------------------------------------------------------------------------------------")

        ##################################################################
        ################## STEP 2: Construct the 1-tree ##################
        ##################################################################
        # if we do this way, we are going to modify the weights each time
        # and hence the obtained tour 1-tree will not have the 'rea' weights
        # therefore we might change them again to the original ones.
        g_dual = g.copy()
        
        # changes the weights in the graph
        for edge in edges(g_dual)
            # get the ends of the edge
            n1, n2 = ends(edge)
        
            # LUIS: I think we are not actually replacing the edge
            # replace the weight
            set_weight!(edge, edge.weight - PI[data(n1)] - PI[data(n2)])
        end

        # construct the 1-tree
        OneTree, TreeDegree = one_tree(g_dual, algorithm, root)
        
        #################################################################
        ################## STEP 3: Update the cost ######################
        #################################################################
        # compute the total cost of the 1-tree
        TreeCost = sum(weight.(edges(OneTree)))
        # update the cost
        dual_cost = TreeCost - 2*sum(PI)
        
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
        if !adaptive
            graph_degree = [degree(TreeDegree, n) - 2 for n in nodes(g)]
            graph_degree_prev = graph_degree.copy()
        else
            if k == 1
                graph_degree = [degree(TreeDegree, n) - 2 for n in nodes(g)]
                graph_degree_prev = graph_degree.copy()
            else
                graph_degree_prev = graph_degree.copy()
                graph_degree = [degree(TreeDegree, n) - 2 for n in nodes(g)]
            end
        end

        #################################################################
        ################## STEP 6: Check for a tour #####################
        #################################################################
        if all(graph_degree .== 0)
            # here we should get the original weights in the tree
            for edge in edges(Onetree)
                # get the ends of the edge
                n1, n2 = ends(edge)
        
                # LUIS: I think we are not actually replacing the edge
                # replace the weight of the edge in g whose ends are n1 and n2
                set_weight!(edge, weight(get_edge(g, n1, n2)))
            end
            # update the 1-tree cost
            TreeCost = sum(weight.(edges(OneTree)))
            println("---------------------------------------------")
            println("----- A Hamiltonian tour has been found -----")
            println("---- The tour found has cost $(TreeCost) ----")
            println("---------------------------------------------")
            return OneTree
            break
        end

        #################################################################
        ################ STEP 7: Update the step size ###################
        #################################################################
        # compute the norm
        norm_degree = sqrt(sum(values(TreeDegree) .^ 2))
        # update the step size
        step = step * (incumbent - dual_cost) / norm_degree

        #################################################################
        ################ STEP 8: Update reduced costs ###################
        #################################################################
        # if not adaptive graph_degree and graph_degree_prev are equal
        for k in range(1, V)
            PI[k] = PI[k] + step*(0.7*graph_degree[k] + 0.3*graph_degree_prev[k])
        end

        #################################################################
        ################ STEP 8: Update reduced costs ###################
        #################################################################
        # increase the counter
        iter = iter + 1

        # updates the time
        elapsed_time = (time_ns() - elapsed_time)/1.0e9
    end

    println("---------------------------------------------")
    println("--- A Hamiltonian tour could not be found ---")
    println("---------------------------------------------")
    # here we should get the original weights in the tree
    for edge in edges(Onetree)
        # get the ends of the edge
        n1, n2 = ends(edge)

        # LUIS: I think we are not actually replacing the edge
        # replace the weight of the edge in g whose ends are n1 and n2
        set_weight!(edge, weight(get_edge(g, n1, n2)))
    end
    # update the 1-tree cost
    TreeCost = sum(weight.(edges(OneTree)))
    return OneTree

end