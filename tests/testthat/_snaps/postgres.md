# snapshot test

    Code
      dm_for_filter() %>% dm_sql(my_test_con())
    Message
      ! The `names()` method of <tbl_lazy> is for internal use only.
      i Did you mean `colnames()`?
      ! The `names()` method of <tbl_lazy> is for internal use only.
      i Did you mean `colnames()`?
      ! The `names()` method of <tbl_lazy> is for internal use only.
      i Did you mean `colnames()`?
      ! The `names()` method of <tbl_lazy> is for internal use only.
      i Did you mean `colnames()`?
      ! The `names()` method of <tbl_lazy> is for internal use only.
      i Did you mean `colnames()`?
      ! The `names()` method of <tbl_lazy> is for internal use only.
      i Did you mean `colnames()`?
    Output
      $pre
      $pre$tf_1
      <SQL> CREATE TEMPORARY TABLE "tf_1" (
        "src" BYTEA,
        "lazy_query" BYTEA,
        PRIMARY KEY ("a")
      )
      
      $pre$tf_2
      <SQL> CREATE TEMPORARY TABLE "tf_2" (
        "src" BYTEA,
        "lazy_query" BYTEA,
        PRIMARY KEY ("c")
      )
      
      $pre$tf_3
      <SQL> CREATE TEMPORARY TABLE "tf_3" (
        "src" BYTEA,
        "lazy_query" BYTEA,
        PRIMARY KEY ("f", "f1")
      )
      
      $pre$tf_4
      <SQL> CREATE TEMPORARY TABLE "tf_4" (
        "src" BYTEA,
        "lazy_query" BYTEA,
        PRIMARY KEY ("h")
      )
      
      $pre$tf_5
      <SQL> CREATE TEMPORARY TABLE "tf_5" (
        "src" BYTEA,
        "lazy_query" BYTEA,
        PRIMARY KEY ("k")
      )
      
      $pre$tf_6
      <SQL> CREATE TEMPORARY TABLE "tf_6" (
        "src" BYTEA,
        "lazy_query" BYTEA,
        PRIMARY KEY ("o")
      )
      
      
      $load
      $load$tf_1
      <SQL> INSERT INTO "tf_1" ("b")
      SELECT CAST("b" AS TEXT) AS "b"
      FROM (  VALUES ('A'), ('B'), ('C'), ('D'), ('E'), ('F'), ('G'), ('H'), ('I'), ('J')) AS drvd("b")
      
      $load$tf_2
      <SQL> INSERT INTO "tf_2" ("c", "d", "e", "e1")
      SELECT
        CAST("c" AS TEXT) AS "c",
        CAST("d" AS INTEGER) AS "d",
        CAST("e" AS TEXT) AS "e",
        CAST("e1" AS INTEGER) AS "e1"
      FROM (
        VALUES
          ('elephant', 2, 'D', 4),
          ('lion', 3, 'E', 5),
          ('seal', 4, 'F', 6),
          ('worm', 5, 'G', 7),
          ('dog', 6, 'E', 5),
          ('cat', 7, 'F', 6)
      ) AS drvd("c", "d", "e", "e1")
      
      $load$tf_3
      <SQL> INSERT INTO "tf_3" ("f", "f1", "g")
      SELECT
        CAST("f" AS TEXT) AS "f",
        CAST("f1" AS INTEGER) AS "f1",
        CAST("g" AS TEXT) AS "g"
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
        CAST("h" AS TEXT) AS "h",
        CAST("i" AS TEXT) AS "i",
        CAST("j" AS TEXT) AS "j",
        CAST("j1" AS INTEGER) AS "j1"
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
        CAST("ww" AS INTEGER) AS "ww",
        CAST("k" AS INTEGER) AS "k",
        CAST("l" AS TEXT) AS "l",
        CAST("m" AS TEXT) AS "m"
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
        CAST("zz" AS INTEGER) AS "zz",
        CAST("n" AS TEXT) AS "n",
        CAST("o" AS TEXT) AS "o"
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
      
      

