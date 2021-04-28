# functions working with graphs do the right thing?

    Code
      attr(igraph::E(create_graph_from_dm(nyc_comp())), "vnames")
    Output
      [1] "airlines|flights" "airports|flights" "flights|planes"   "flights|weather" 

