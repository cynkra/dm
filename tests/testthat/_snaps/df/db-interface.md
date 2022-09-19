# build_copy_queries avoids duplicate indexes

    Code
      as.list(queries)
    Output
      $name
      [1] "parent1"  "parent2"  "child"    "child__a"
      
      $remote_name
      $remote_name$parent1
      <IDENT> parent1
      
      $remote_name$parent2
      <IDENT> parent2
      
      $remote_name$child
      <IDENT> child
      
      $remote_name$child__a
      <IDENT> child__a
      
      
      $columns
      $columns[[1]]
      [1] "key"
      
      $columns[[2]]
      [1] "a__key"
      
      $columns[[3]]
      [1] "a__key"
      
      $columns[[4]]
      [1] "key"
      
      
      $sql_table
      <SQL> CREATE TEMPORARY TABLE parent1 (
        "key" DOUBLE,
        PRIMARY KEY ("key")
      )
      <SQL> CREATE TEMPORARY TABLE parent2 (
        a__key DOUBLE,
        PRIMARY KEY (a__key)
      )
      <SQL> CREATE TEMPORARY TABLE child (
        a__key DOUBLE,
        FOREIGN KEY (a__key) REFERENCES parent2 (a__key)
      )
      <SQL> CREATE TEMPORARY TABLE child__a (
        "key" DOUBLE,
        FOREIGN KEY ("key") REFERENCES parent2 (a__key)
      )
      
      $sql_index
      $sql_index[[1]]
      NULL
      
      $sql_index[[2]]
      NULL
      
      $sql_index[[3]]
      <SQL> CREATE INDEX child__a__key ON child (a__key)
      
      $sql_index[[4]]
      <SQL> CREATE INDEX child__a__key__1 ON child__a ("key")
      
      
      $index_name
      $index_name[[1]]
      NULL
      
      $index_name[[2]]
      NULL
      
      $index_name[[3]]
      [1] "child__a__key"
      
      $index_name[[4]]
      [1] "child__a__key__1"
      
      

