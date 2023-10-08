# dummy

    Code
      # dummy

# dm_sql()

    Code
      dm_for_filter() %>% collect() %>% dm_sql(my_test_con())
    Output
      $pre
      $pre$tf_1
      <SQL> CREATE TEMPORARY TABLE "tf_1" (
        "a" INT IDENTITY,
        "b" varchar(255),
        PRIMARY KEY ("a")
      )
      
      $pre$tf_2
      <SQL> CREATE TEMPORARY TABLE "tf_2" (
        "c" varchar(255),
        "d" INT,
        "e" varchar(255),
        "e1" INT,
        PRIMARY KEY ("c")
      )
      
      $pre$tf_3
      <SQL> CREATE TEMPORARY TABLE "tf_3" (
        "f" varchar(255),
        "f1" INT,
        "g" varchar(255),
        PRIMARY KEY ("f", "f1")
      )
      
      $pre$tf_4
      <SQL> CREATE TEMPORARY TABLE "tf_4" (
        "h" varchar(255),
        "i" varchar(255),
        "j" varchar(255),
        "j1" INT,
        PRIMARY KEY ("h")
      )
      
      $pre$tf_5
      <SQL> CREATE TEMPORARY TABLE "tf_5" (
        "ww" INT,
        "k" INT,
        "l" varchar(255),
        "m" varchar(255),
        PRIMARY KEY ("k")
      )
      
      $pre$tf_6
      <SQL> CREATE TEMPORARY TABLE "tf_6" (
        "zz" INT,
        "n" varchar(255),
        "o" varchar(255),
        PRIMARY KEY ("o")
      )
      
      
      $load
      $load$tf_1
      <SQL> INSERT INTO "tf_1" ("b")
      SELECT TRY_CAST("b" AS VARCHAR(MAX)) AS "b"
      FROM (  VALUES ('A'), ('B'), ('C'), ('D'), ('E'), ('F'), ('G'), ('H'), ('I'), ('J')) AS drvd("b")
      
      $load$tf_2
      <SQL> INSERT INTO "tf_2" ("c", "d", "e", "e1")
      SELECT
        TRY_CAST("c" AS VARCHAR(MAX)) AS "c",
        TRY_CAST(TRY_CAST("d" AS NUMERIC) AS INT) AS "d",
        TRY_CAST("e" AS VARCHAR(MAX)) AS "e",
        TRY_CAST(TRY_CAST("e1" AS NUMERIC) AS INT) AS "e1"
      FROM (
        VALUES
          ('cat', 7, 'F', 6),
          ('dog', 6, 'E', 5),
          ('elephant', 2, 'D', 4),
          ('lion', 3, 'E', 5),
          ('seal', 4, 'F', 6),
          ('worm', 5, 'G', 7)
      ) AS drvd("c", "d", "e", "e1")
      
      $load$tf_3
      <SQL> INSERT INTO "tf_3" ("f", "f1", "g")
      SELECT
        TRY_CAST("f" AS VARCHAR(MAX)) AS "f",
        TRY_CAST(TRY_CAST("f1" AS NUMERIC) AS INT) AS "f1",
        TRY_CAST("g" AS VARCHAR(MAX)) AS "g"
      FROM (
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
      ) AS drvd("f", "f1", "g")
      
      $load$tf_4
      <SQL> INSERT INTO "tf_4" ("h", "i", "j", "j1")
      SELECT
        TRY_CAST("h" AS VARCHAR(MAX)) AS "h",
        TRY_CAST("i" AS VARCHAR(MAX)) AS "i",
        TRY_CAST("j" AS VARCHAR(MAX)) AS "j",
        TRY_CAST(TRY_CAST("j1" AS NUMERIC) AS INT) AS "j1"
      FROM (
        VALUES
          ('a', 'three', 'C', 3),
          ('b', 'four', 'D', 4),
          ('c', 'five', 'E', 5),
          ('d', 'six', 'F', 6),
          ('e', 'seven', 'F', 6)
      ) AS drvd("h", "i", "j", "j1")
      
      $load$tf_5
      <SQL> INSERT INTO "tf_5" ("ww", "k", "l", "m")
      SELECT
        TRY_CAST(TRY_CAST("ww" AS NUMERIC) AS INT) AS "ww",
        TRY_CAST(TRY_CAST("k" AS NUMERIC) AS INT) AS "k",
        TRY_CAST("l" AS VARCHAR(MAX)) AS "l",
        TRY_CAST("m" AS VARCHAR(MAX)) AS "m"
      FROM (
        VALUES
          (2, 1, 'b', 'house'),
          (2, 2, 'c', 'tree'),
          (2, 3, 'd', 'streetlamp'),
          (2, 4, 'e', 'streetlamp')
      ) AS drvd("ww", "k", "l", "m")
      
      $load$tf_6
      <SQL> INSERT INTO "tf_6" ("zz", "n", "o")
      SELECT
        TRY_CAST(TRY_CAST("zz" AS NUMERIC) AS INT) AS "zz",
        TRY_CAST("n" AS VARCHAR(MAX)) AS "n",
        TRY_CAST("o" AS VARCHAR(MAX)) AS "o"
      FROM (
        VALUES
          (1, 'house', 'e'),
          (1, 'tree', 'f'),
          (1, 'hill', 'g'),
          (1, 'streetlamp', 'h'),
          (1, 'garden', 'i')
      ) AS drvd("zz", "n", "o")
      
      
      $post
      $post$fk
      list()
      
      $post$unique
      list()
      
      $post$indexes
      list()
      
      

