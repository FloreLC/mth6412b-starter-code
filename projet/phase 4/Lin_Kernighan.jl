# include the required functions

# here we have a function like
# function LinKernighan(g::Graph{T}, algorithm::Function, starting_node::Node{T}, max_iterations::Int64, max_time::Int64, step::Float64) where T

################################
###### initial parameters ######
################################

# this gets the number of nodes in the graph
V = length(Nodes) # nb_nodes(g)

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
iter = 0

while iter <= max_iterations && elapsed_time <= max_time #&& graph_degree != 2

    # print out the progress so far
    println("-----------------------------------------------------------------------------------------------------------")
    println("   Iteration: $(iter+1) | Elapsed time (s): $(round(elapsed_time; digits = 4)) | Incumbent: $(incumbent)   ")
    println("-----------------------------------------------------------------------------------------------------------")

    ##################################################################
    ################## STEP 2: Construct the 1-tree ##################
    ##################################################################
    # update the distance (this should be a function dual_distance!())
    # one should create a copy of the graph to modify its weights such that
    # after finishing the process one could get back the cost in the 'original scale'
    # g_dual = g.copy()
    
    for i in range(1, length = V)
        for j in range(1, length = V)
            g_dual["distance_matrix"][i,j] = g_dual["distance_matrix"][i,j] - PI[i] - PI[j]
        end
    end

    # construct the 1-tree
    OneTree = tree(g, algorithm, starting_node)
    
    #################################################################
    ################## STEP 3: Update the cost ######################
    #################################################################
    dual_cost = OneTree["total_cost"] - 2*sum(PI)
    
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
        graph_degree = OneTree["degree"] .- 2
        graph_degree_prev = graph_degree.copy()
    else
        if k == 0
            graph_degree = OneTree["degree"] .- 2
            graph_degree_prev = graph_degree.copy()
        else
            graph_degree_prev = graph_degree.copy()
            graph_degree = OneTree["degree"] .- 2
        end
    end

    #################################################################
    ################## STEP 6: Check for a tour #####################
    #################################################################
    if all(graph_degree .== 0)
        println("---------------------------------------------")
        println("----- A Hamiltonian tour has been found -----")
        println("---------------------------------------------")
        break
    end

    #################################################################
    ################ STEP 7: Update the step size ###################
    #################################################################
    # compute the norm
    norm_degree = sqrt(sum(OneTree["degree"] .^ 2))
    # update the step size
    step = step * (incumbent - dual_cost) / norm_degree

    #################################################################
    ################ STEP 8: Update reduced costs ###################
    #################################################################
    # if adaptive here we save lines of code
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