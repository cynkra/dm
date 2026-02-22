# graph_from_data_frame: print output is consistent

    Code
      print(g_directed)
    Output
      <dm_graph> directed, 3 vertices, 2 edges
      Vertices: a, b, c 
      Edges: a|b, b|c 
    Code
      print(g_undirected)
    Output
      <dm_graph> undirected, 3 vertices, 2 edges
      Vertices: a, b, c 
      Edges: a|b, b|c 

# graph_from_data_frame: zero-row data frame builds graph with no edges

    Code
      print(g)
    Output
      <dm_graph> undirected, 2 vertices, 0 edges
      Vertices: x, y 

