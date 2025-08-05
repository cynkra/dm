# build_copy_queries snapshot test for dm_for_filter()

    Code
      dm_for_filter() %>% collect() %>% build_copy_queries(src_db, .) %>% as.list()
    Message
      `on_delete = "cascade"` not supported for duckdb
    Output
      $name
      [1] "tf_1" "tf_3" "tf_6" "tf_2" "tf_4" "tf_5"
      
      $remote_name
        tf_1   tf_3   tf_6   tf_2   tf_4   tf_5 
      "tf_1" "tf_3" "tf_6" "tf_2" "tf_4" "tf_5" 
      
      $columns
      $columns[[1]]
      [1] "a" "b"
      
      $columns[[2]]
      [1] "f"  "f1" "g" 
      
      $columns[[3]]
      [1] "zz" "n"  "o" 
      
      $columns[[4]]
      [1] "c"  "d"  "e"  "e1"
      
      $columns[[5]]
      [1] "h"  "i"  "j"  "j1"
      
      $columns[[6]]
      [1] "ww" "k"  "l"  "m" 
      
      
      $sql_table
      <SQL> CREATE TEMPORARY TABLE tf_1 (
        a INTEGER,
        b STRING,
        PRIMARY KEY (a)
      )
      <SQL> CREATE TEMPORARY TABLE tf_3 (
        f STRING,
        f1 INTEGER,
        g STRING,
        PRIMARY KEY (f, f1)
      )
      <SQL> CREATE TEMPORARY TABLE tf_6 (
        zz INTEGER,
        n STRING,
        o STRING,
        PRIMARY KEY (o),
        UNIQUE (n)
      )
      <SQL> CREATE TEMPORARY TABLE tf_2 (
        c STRING,
        d INTEGER,
        e STRING,
        e1 INTEGER,
        PRIMARY KEY (c),
        FOREIGN KEY (d) REFERENCES tf_1 (a),
        FOREIGN KEY (e, e1) REFERENCES tf_3 (f, f1)
      )
      <SQL> CREATE TEMPORARY TABLE tf_4 (
        h STRING,
        i STRING,
        j STRING,
        j1 INTEGER,
        PRIMARY KEY (h),
        FOREIGN KEY (j, j1) REFERENCES tf_3 (f, f1)
      )
      <SQL> CREATE TEMPORARY TABLE tf_5 (
        ww INTEGER,
        k INTEGER,
        l STRING,
        m STRING,
        PRIMARY KEY (k),
        FOREIGN KEY (m) REFERENCES tf_6 (n),
        FOREIGN KEY (l) REFERENCES tf_4 (h)
      )
      
      $sql_index
      $sql_index[[1]]
      NULL
      
      $sql_index[[2]]
      NULL
      
      $sql_index[[3]]
      NULL
      
      $sql_index[[4]]
      <SQL> CREATE INDEX tf_2__d ON tf_2 (d)
      <SQL> CREATE INDEX tf_2__e_e1 ON tf_2 (e, e1)
      
      $sql_index[[5]]
      <SQL> CREATE INDEX tf_4__j_j1 ON tf_4 (j, j1)
      
      $sql_index[[6]]
      <SQL> CREATE INDEX tf_5__m ON tf_5 (m)
      <SQL> CREATE INDEX tf_5__l ON tf_5 (l)
      
      
      $index_name
      $index_name[[1]]
      NULL
      
      $index_name[[2]]
      NULL
      
      $index_name[[3]]
      NULL
      
      $index_name[[4]]
      [1] "tf_2__d"    "tf_2__e_e1"
      
      $index_name[[5]]
      [1] "tf_4__j_j1"
      
      $index_name[[6]]
      [1] "tf_5__m" "tf_5__l"
      
      

# build_copy_queries avoids duplicate indexes

    Code
      as.list(queries)
    Output
      $name
      [1] "parent1"  "parent2"  "child"    "child__a"
      
      $remote_name
      $remote_name$parent1
      <Id> "parent1"
      
      $remote_name$parent2
      <Id> "parent2"
      
      $remote_name$child
      <Id> "child"
      
      $remote_name$child__a
      <Id> "child__a"
      
      
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
      
      

