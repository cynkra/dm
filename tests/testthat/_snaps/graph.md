# functions working with graphs do the right thing?

    Code
      attr(igraph::E(create_graph_from_dm(nyc_comp())), "vnames")
    Output
      [1] "airlines|flights" "airports|flights" "flights|planes"   "flights|weather" 

# empty graph

    Code
      create_graph_from_dm(empty_dm())
    Output
      IGRAPH 09d08a5 UN-- 0 0 -- 
      + attr: name (v/c)
      + edges from 09d08a5 (vertex names):
    Code
      create_graph_from_dm(dm(x = tibble(a = 1)))
    Output
      IGRAPH 58c94e2 UN-- 1 0 -- 
      + attr: name (v/c)
      + edges from 58c94e2 (vertex names):

