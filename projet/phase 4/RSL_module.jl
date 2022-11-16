
mutable struct Tree{T} 
    node::Node{T}
    children::Vector{Tree{T}}
    parent::Union{Tree{T}, Nothing}
end
node(t::Tree) = t.node

function rsl(g::Graph{T}, root::Node{T}, algorithm::Function) where T
    println("Inegalite triangulaire: $(has_triang_ineg(g))")
    if has_triang_ineg(g)==true
       
        #calculer un arbre de recouvrement minimal 
        arbre_graph, composante =algorithm(g)

        tree_structure = Tree{T}(root,  Vector{Tree{T}}(), nothing)
        create_child!(arbre, tree_structure, [root])

        tour_nodes = Vector{Node{T}}()
        parcours_preordre!(tree_structure, tour_nodes)

        tour_edges = Vector{Edge{T}}()
        for i in 1:(length(list) - 1)
            e = get_edge(g, Node{T}(name(list[i]), data(list[i])), Node{T}(name(list[i+1]), data(list[i+1])))
            if !(isnothing(e))
                push!(tour_edges, e)
            end
        end
        e = get_edge(g, Node{T}(name(list[1]), data(list[1])), Node{T}(name(list[end]), data(list[end])))
        if !(isnothing(e))
            push!(tour_edges, e)
        else
            println("Aucun tour n'a ete trouvé")
            return nothing
        end
        poids = sum(weight.(tour_edges))
        println("Poids de la tournee: $(poids)")
        return Graph{T}("RSL_Tour de $(name(g))", nodes(g), tour_edges)
    end
    return nothing
end


function create_child!(g::Graph{T}, parent::Tree{T}, deja_la::Vector{Node{T}}) where T
    root = node(parent)
    for n in nodes(g)
        if isnothing( findfirst(x -> name(x)== name(n),deja_la)) && !isnothing(get_edge(g, root, n))
            new_item = Tree{T}(n, Vector{Tree{T}}(), parent)
            push!(deja_la, n)
            push!(children(parent), new_item)
        end
    end

    for c in children(parent)
        create_child!(g, c, deja_la)
    end

    parent
end

function parcours_preordre!(root::Tree{T}, list::Vector{Node{T}}) where T
    isnothing(root) && return 
    push!(list, node(root))
    for t in children(tree)
        parcours_preordre!(t, list)
    end
    list
end

"""
Renvoi true si l'inégalité triangulaire est vérifiée dans un graphe g , false sinon
"""
function has_triang_ineg(g::Graph{T}) where T
   resultats = Vector{Bool}()
   for e in edges(g)
       (new1, new2) = ends(e)
     
       for new3 in nodes(g)
           if !isnothing(get_edge(g, new1, new3)) && !isnothing(get_edge(g, new2, new3))
               if  weight(e) <= weight(get_edge(g, new1, new3))+weight(get_edge(g, new2, new3))
                   push!(resultats, true) 
               else 
                   push!(resultats, false)
               end
           end
       end
   end
   return all(resultats)
end

