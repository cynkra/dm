# snapshot test

    Code
      dm_for_filter() %>% dm_sql(test_src_duckdb()$con)
    Message
      `on_delete = "cascade"` not supported for duckdb
    Output
      $pre
      $pre$tf_1
      <SQL> CREATE TEMPORARY TABLE tf_1 (
        a INTEGER,
        b STRING,
        PRIMARY KEY (a),
        UNIQUE (a)
      )
      
      $pre$tf_3
      <SQL> CREATE TEMPORARY TABLE tf_3 (
        f STRING,
        f1 INTEGER,
        g STRING,
        PRIMARY KEY (f, f1),
        UNIQUE (f, f1),
        UNIQUE (g)
      )
      
      $pre$tf_6
      <SQL> CREATE TEMPORARY TABLE tf_6 (
        zz INTEGER,
        n STRING,
        o STRING,
        PRIMARY KEY (o),
        UNIQUE (o),
        UNIQUE (n)
      )
      
      $pre$tf_2
      <SQL> CREATE TEMPORARY TABLE tf_2 (
        c STRING,
        d INTEGER,
        e STRING,
        e1 INTEGER,
        PRIMARY KEY (c),
        UNIQUE (c),
        FOREIGN KEY (d) REFERENCES tf_1 (a),
        FOREIGN KEY (e, e1) REFERENCES tf_3 (f, f1)
      )
      
      $pre$tf_4
      <SQL> CREATE TEMPORARY TABLE tf_4 (
        h STRING,
        i STRING,
        j STRING,
        j1 INTEGER,
        PRIMARY KEY (h),
        UNIQUE (h),
        FOREIGN KEY (j, j1) REFERENCES tf_3 (f, f1)
      )
      
      $pre$tf_5
      <SQL> CREATE TEMPORARY TABLE tf_5 (
        ww INTEGER,
        k INTEGER,
        l STRING,
        m STRING,
        PRIMARY KEY (k),
        UNIQUE (k),
        FOREIGN KEY (m) REFERENCES tf_6 (n),
        FOREIGN KEY (l) REFERENCES tf_4 (h)
      )
      
      
      $load
      $load$tf_1
      <SQL> INSERT INTO tf_1 (a, b)
      SELECT CAST(a AS INTEGER) AS a, CAST(b AS TEXT) AS b
      FROM (
        SELECT NULL AS a, NULL AS b
        WHERE (0 = 1)
      
        UNION ALL
      
        VALUES
          (1, 'A'),
          (2, 'B'),
          (3, 'C'),
          (4, 'D'),
          (5, 'E'),
          (6, 'F'),
          (7, 'G'),
          (8, 'H'),
          (9, 'I'),
          (10, 'J')
      ) values_table
      
      $load$tf_3
      <SQL> INSERT INTO tf_3 (f, f1, g)
      SELECT CAST(f AS TEXT) AS f, CAST(f1 AS INTEGER) AS f1, CAST(g AS TEXT) AS g
      FROM (
        SELECT NULL AS f, NULL AS f1, NULL AS g
        WHERE (0 = 1)
      
        UNION ALL
      
        VALUES
          ('C', 2, 'one'),
          ('C', 3, 'two'),
          ('D', 4, 'three'),
          ('E', 5, 'four'),
          ('F', 6, 'five'),
          ('G', 7, 'six'),
          ('H', 7, 'seven'),
          ('I', 7, 'eight'),
          ('J', 10, 'nine'),
          ('K', 11, 'ten')
      ) values_table
      
      $load$tf_6
      <SQL> INSERT INTO tf_6 (zz, n, o)
      SELECT CAST(zz AS INTEGER) AS zz, CAST(n AS TEXT) AS n, CAST(o AS TEXT) AS o
      FROM (
        SELECT NULL AS zz, NULL AS n, NULL AS o
        WHERE (0 = 1)
      
        UNION ALL
      
        VALUES
          (1, 'house', 'e'),
          (1, 'tree', 'f'),
          (1, 'hill', 'g'),
          (1, 'streetlamp', 'h'),
          (1, 'garden', 'i')
      ) values_table
      
      $load$tf_2
      <SQL> INSERT INTO tf_2 (c, d, e, e1)
      SELECT
        CAST(c AS TEXT) AS c,
        CAST(d AS INTEGER) AS d,
        CAST(e AS TEXT) AS e,
        CAST(e1 AS INTEGER) AS e1
      FROM (
        SELECT NULL AS c, NULL AS d, NULL AS e, NULL AS e1
        WHERE (0 = 1)
      
        UNION ALL
      
        VALUES
          ('elephant', 2, 'D', 4),
          ('lion', 3, 'E', 5),
          ('seal', 4, 'F', 6),
          ('worm', 5, 'G', 7),
          ('dog', 6, 'E', 5),
          ('cat', 7, 'F', 6)
      ) values_table
      
      $load$tf_4
      <SQL> INSERT INTO tf_4 (h, i, j, j1)
      SELECT
        CAST(h AS TEXT) AS h,
        CAST(i AS TEXT) AS i,
        CAST(j AS TEXT) AS j,
        CAST(j1 AS INTEGER) AS j1
      FROM (
        SELECT NULL AS h, NULL AS i, NULL AS j, NULL AS j1
        WHERE (0 = 1)
      
        UNION ALL
      
        VALUES
          ('a', 'three', 'C', 3),
          ('b', 'four', 'D', 4),
          ('c', 'five', 'E', 5),
          ('d', 'six', 'F', 6),
          ('e', 'seven', 'F', 6)
      ) values_table
      
      $load$tf_5
      <SQL> INSERT INTO tf_5 (ww, k, l, m)
      SELECT
        CAST(ww AS INTEGER) AS ww,
        CAST(k AS INTEGER) AS k,
        CAST(l AS TEXT) AS l,
        CAST(m AS TEXT) AS m
      FROM (
        SELECT NULL AS ww, NULL AS k, NULL AS l, NULL AS m
        WHERE (0 = 1)
      
        UNION ALL
      
        VALUES
          (2, 1, 'b', 'house'),
          (2, 2, 'c', 'tree'),
          (2, 3, 'd', 'streetlamp'),
          (2, 4, 'e', 'streetlamp')
      ) values_table
      
      
      $post
      $post$uk
      named list()
      
      $post$fk
      named list()
      
      $post$indexes
      $post$indexes$tf_2
      <SQL> CREATE INDEX tf_2__d ON tf_2 (d)
      <SQL> CREATE INDEX tf_2__e_e1 ON tf_2 (e, e1)
      
      $post$indexes$tf_4
      <SQL> CREATE INDEX tf_4__j_j1 ON tf_4 (j, j1)
      
      $post$indexes$tf_5
      <SQL> CREATE INDEX tf_5__m ON tf_5 (m)
      <SQL> CREATE INDEX tf_5__l ON tf_5 (l)
      
      
      

