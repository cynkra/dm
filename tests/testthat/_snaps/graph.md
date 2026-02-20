# functions working with graphs do the right thing?

    Code
      attr(graph_edges(create_graph_from_dm(nyc_comp())), "vnames")
    Output
      [1] "airlines|flights" "airports|flights" "flights|planes"   "flights|weather" 

# empty graph

    Code
      names(graph_vertices(g0))
    Output
      character(0)
    Code
      names(graph_vertices(g1))
    Output
      [1] "x"
    Code
      attr(graph_edges(g0), "vnames")
    Output
      character(0)
    Code
      attr(graph_edges(g1), "vnames")
    Output
      character(0)

