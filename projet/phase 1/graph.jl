import Base.show
include("./edge.jl")
"""Type abstrait dont d'autres types de graphes dériveront."""
abstract type AbstractGraph{T} end

"""Type representant un graphe comme un ensemble de noeuds.

Exemple :

    node1 = Node("Joe", 3.14)
    node2 = Node("Steve", exp(1))
    node3 = Node("Jill", 4.12)
    G = Graph("Ick", [node1, node2, node3])

Attention, tous les noeuds doivent avoir des données de même type.
"""
mutable struct Graph{T} <: AbstractGraph{T}
  name::String
  nodes::Vector{Node{T}}
  edges::Vector{Edge{T}}
end

function Graph{T}() where T
  name = ""
  nodes = Vector{Node{T}}()
  edges = Vector{Edge{T}}()
  return Graph{T}(name, nodes, edges)
end

"""Ajoute un noeud au graphe."""
function add_node!(graph::Graph{T}, node::Node{T}) where T
  push!(graph.nodes, node)
  graph
end
function add_edge!(graph::Graph{T}, edge::Edge{T}) where T
  push!(graph.edges, edge)
  graph
end
# on présume que tous les graphes dérivant d'AbstractGraph
# posséderont des champs `name` et `nodes`.

"""Renvoie le nom du graphe."""
name(graph::AbstractGraph) = graph.name

"""Renvoie la liste des noeuds du graphe."""
nodes(graph::AbstractGraph) = graph.nodes


"""Renvoie le nombre de noeuds du graphe."""
nb_nodes(graph::AbstractGraph) = length(graph.nodes)

"""Renvoie la liste des edges du graphe."""
edges(graph::AbstractGraph) = graph.edges

"""Renvoie le nombre des edges du graphe."""
nb_edges(graph::AbstractGraph) = length(graph.edges)

"""Retourn l'indice dans le vecteur des noeuds du graphe graph du noeud s. Nothing si le noeud ne fait pas parti du graphe."""
function get_node(graph::Graph, s::String) 
  i = findfirst(x -> ( name(x) == s), nodes(graph))  

  if !(isnothing(i)) 
    return nodes(graph)[i] 
  else
    @warn("Graph $(name(graph)) has no node $s")
  end
  return nothing
end

"""Affiche un graphe"""
function show(graph::Graph)
  println("Graph ", name(graph), " has ", nb_nodes(graph), " nodes and $(nb_edges(graph)) edges.")
  for node in nodes(graph)
    show(node)
  end
  for edge in edges(graph)
    show(edge)
  end
end


""" Renvoi un objet edge du graphe g avec pour extremites n1 et n2. nothing sinon"""
function get_edge(g::Graph{T}, n1::Node{T}, n2::Node{T}) where T
    i = findfirst(x ->name.(ends(x)) == (name(n1), name(n2)) , edges(g))
    if isnothing(i)
      i = findfirst(x -> name.(ends(x)) == (name(n2), name(n1)) , edges(g))
    end

  return edges(g)[i]
end


"""" Lis le fichier tsp et en extrait les données
    - Construit l'objet Graph 
    - Construit les objets Nodes (explicites ou implicites)
    - Construit les objets Edges
    
    Retourne le graph associé au fichier donné en argument.
    Si le graphe décrit est representable (ie. les noeuds ont une donnée coordonnées spécifiée), l'image est sauvegardée
Pour lancer le programme:
    Se placer dans le dossier projet/phase1
    lancer julia main.jl "Nom de l'instance".tsp 
    exemple:
        julia main.jl gr17.tsp
"""
function build_graph(filename::String)
  graph_nodes, graph_edges, edges_brut, weights = read_stsp(filename)
  header = read_header(filename)
  graph_name = split( last(split(filename, "/")), ".")[1]
  ### Construire les nodes
  if header["DISPLAY_DATA_TYPE"] == "TWOD_DISPLAY" || header["DISPLAY_DATA_TYPE"] == "COORD_DISPLAY"
      g = Graph{Vector{Float64}}(graph_name, Vector{Node}(), Vector{Edge}())
      for n in keys(graph_nodes)
          add_node!(g, Node("$(n)", graph_nodes[n]))
      end
  else
      g = Graph{Nothing}(graph_name, Vector{Node}(), Vector{Edge}())
      for i in 1:parse(Int, header["DIMENSION"])
          add_node!(g, Node("$(i)", nothing))
      end
  end


  ### Construire les edges 
  g_nodes = nodes(g)
  for i in eachindex(edges_brut)
      #Si le format des donnees est tel que les aretes i-i sont explicitées (edge_weight_format) et le poid d'une telle arete est nul, et c'est bien une arete i-i, alors on ne cré pas l'arete. 
      #Autrement elle est créée et ajoutée au graphe.
      if header["EDGE_WEIGHT_FORMAT"] in ["FULL_MATRIX", "UPPER_DIAG_ROW", "LOWER_DIAG_ROW"] && weights[i]==0 && edges_brut[i][1] == edges_brut[i][2] 
      else
          # Fonction get_node renvoie l'objet Node dans g en fonction de son nom
          u = get_node(g, "$(edges_brut[i][1])")
          v = get_node(g, "$(edges_brut[i][2])")
          edge = Edge{typeof(data(u))}((u,v),weights[i])
          add_edge!(g, edge)
      end
  end
  return g
end

function get_associated_edges(g::AbstractGraph, n::AbstractNode)
  e_with_n = Vector{AbstractEdge}()
  for e in edges(g)
    if name(ends(e)[1]) == name(n) || name(ends(e)[2]) == name(n)
      push!(e_with_n, e)
    end
  end
  return e_with_n
end