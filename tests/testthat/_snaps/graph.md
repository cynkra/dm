# functions working with graphs do the right thing?

    Code
      attr(graph_edges(create_graph_from_dm(nyc_comp())), "vnames")
    Output
      [1] "airlines|flights" "airports|flights" "flights|planes"   "flights|weather" 

# empty graph

    Code
      print(g0)
    Output
      <dm_graph> undirected, 0 vertices, 0 edges
    Code
      print(g1)
    Output
      <dm_graph> undirected, 1 vertex, 0 edges
      Vertices: x 

