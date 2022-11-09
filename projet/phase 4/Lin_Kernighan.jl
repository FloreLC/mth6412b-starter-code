# include the required functions

################################
###### initial parameters ######
################################

# this gets the number of nodes in the graph
V = length(Nodes)

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

while iter <= max_iter && elapsed_time <= max_time #&& graph_degree != 2

    # print out the progress so far
    println("-----------------------------------------------------------------------------------------------------------")
    println("   Iteration: $(iter+1) | Elapsed time (s): $(round(elapsed_time; digits = 4)) | Incumbent: $(incumbent)   ")
    println("-----------------------------------------------------------------------------------------------------------")

    ##################################################################
    ################## STEP 2: Construct the 1-tree ##################
    ##################################################################
    # update the distance (this should be a function dual_distance!())
    for i in range(1, length = V)
        for j in range(1, length = V)
            graph["distance_matrix"][i,j] = graph["distance_matrix"][i,j] - PI[i] - PI[j]
        end
    end

    # construct the 1-tree
    OneTree = one_tree(graph, algorithm, node)
    
    #################################################################
    ################## STEP 3: Update the cost ######################
    #################################################################
    dual_cost = graph["total_cost"] - 2*sum(PI)
    
    #################################################################
    ############# STEP 4: Get the current incumbent #################
    #################################################################
    incumbent = max(incumbent, dual_cost)

    #################################################################
    ################ STEP 5: Get the graph degree ###################
    #################################################################
    graph_degree = graph["degree"] .- 2

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
    norm_degree = sqrt(sum(graph["degree"] .^ 2))
    # update the step size
    step = step * (incumbent - dual_cost) / norm_degree

    #################################################################
    ################ STEP 8: Update reduced costs ###################
    #################################################################
    for k in range(1, V)
        PI[k] = PI[k] + step*graph_degree[k]
    end

    #################################################################
    ################ STEP 8: Update reduced costs ###################
    #################################################################
    # increase the counter
    iter = iter + 1

    # updates the time
    elapsed_time = (time_ns() - elapsed_time)/1.0e9
end