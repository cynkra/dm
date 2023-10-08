# dummy

    Code
      # dummy

# dm_sql()

    Code
      dm_for_filter() %>% collect() %>% dm_sql(my_test_con())
    Output
      $pre
      $pre$tf_1
      <SQL> CREATE TEMPORARY TABLE `tf_1` (
        `a` INT AUTO_INCREMENT,
        `b` VARCHAR(255),
        PRIMARY KEY (`a`)
      )
      
      $pre$tf_2
      <SQL> CREATE TEMPORARY TABLE `tf_2` (
        `c` VARCHAR(255),
        `d` INT,
        `e` VARCHAR(255),
        `e1` INT,
        PRIMARY KEY (`c`)
      )
      
      $pre$tf_3
      <SQL> CREATE TEMPORARY TABLE `tf_3` (
        `f` VARCHAR(255),
        `f1` INT,
        `g` VARCHAR(255),
        PRIMARY KEY (`f`, `f1`)
      )
      
      $pre$tf_4
      <SQL> CREATE TEMPORARY TABLE `tf_4` (
        `h` VARCHAR(255),
        `i` VARCHAR(255),
        `j` VARCHAR(255),
        `j1` INT,
        PRIMARY KEY (`h`)
      )
      
      $pre$tf_5
      <SQL> CREATE TEMPORARY TABLE `tf_5` (
        `ww` INT,
        `k` INT,
        `l` VARCHAR(255),
        `m` VARCHAR(255),
        PRIMARY KEY (`k`)
      )
      
      $pre$tf_6
      <SQL> CREATE TEMPORARY TABLE `tf_6` (
        `zz` INT,
        `n` VARCHAR(255),
        `o` VARCHAR(255),
        PRIMARY KEY (`o`)
      )
      
      
      $load
      $load$tf_1
      <SQL> INSERT INTO `tf_1` (`b`)
      SELECT CAST(`b` AS CHAR) AS `b`
      FROM (
        (
          SELECT NULL AS `b`
          WHERE (0 = 1)
        )
        UNION ALL
        (
        VALUES
          ROW('A'),
          ROW('B'),
          ROW('C'),
          ROW('D'),
          ROW('E'),
          ROW('F'),
          ROW('G'),
          ROW('H'),
          ROW('I'),
          ROW('J')
        )
      ) `values_table`
      
      $load$tf_2
      <SQL> INSERT INTO `tf_2` (`c`, `d`, `e`, `e1`)
      SELECT
        CAST(`c` AS CHAR) AS `c`,
        CAST(`d` AS INTEGER) AS `d`,
        CAST(`e` AS CHAR) AS `e`,
        CAST(`e1` AS INTEGER) AS `e1`
      FROM (
        (
          SELECT NULL AS `c`, NULL AS `d`, NULL AS `e`, NULL AS `e1`
          WHERE (0 = 1)
        )
        UNION ALL
        (
        VALUES
          ROW('cat', 7, 'F', 6),
          ROW('dog', 6, 'E', 5),
          ROW('elephant', 2, 'D', 4),
          ROW('lion', 3, 'E', 5),
          ROW('seal', 4, 'F', 6),
          ROW('worm', 5, 'G', 7)
        )
      ) `values_table`
      
      $load$tf_3
      <SQL> INSERT INTO `tf_3` (`f`, `f1`, `g`)
      SELECT
        CAST(`f` AS CHAR) AS `f`,
        CAST(`f1` AS INTEGER) AS `f1`,
        CAST(`g` AS CHAR) AS `g`
      FROM (
        (
          SELECT NULL AS `f`, NULL AS `f1`, NULL AS `g`
          WHERE (0 = 1)
        )
        UNION ALL
        (
        VALUES
          ROW('C', 2, 'one'),
          ROW('C', 3, 'two'),
          ROW('D', 4, 'three'),
          ROW('E', 5, 'four'),
          ROW('F', 6, 'five'),
          ROW('G', 7, 'six'),
          ROW('H', 7, 'seven'),
          ROW('I', 7, 'eight'),
          ROW('J', 10, 'nine'),
          ROW('K', 11, 'ten')
        )
      ) `values_table`
      
      $load$tf_4
      <SQL> INSERT INTO `tf_4` (`h`, `i`, `j`, `j1`)
      SELECT
        CAST(`h` AS CHAR) AS `h`,
        CAST(`i` AS CHAR) AS `i`,
        CAST(`j` AS CHAR) AS `j`,
        CAST(`j1` AS INTEGER) AS `j1`
      FROM (
        (
          SELECT NULL AS `h`, NULL AS `i`, NULL AS `j`, NULL AS `j1`
          WHERE (0 = 1)
        )
        UNION ALL
        (
        VALUES
          ROW('a', 'three', 'C', 3),
          ROW('b', 'four', 'D', 4),
          ROW('c', 'five', 'E', 5),
          ROW('d', 'six', 'F', 6),
          ROW('e', 'seven', 'F', 6)
        )
      ) `values_table`
      
      $load$tf_5
      <SQL> INSERT INTO `tf_5` (`ww`, `k`, `l`, `m`)
      SELECT
        CAST(`ww` AS INTEGER) AS `ww`,
        CAST(`k` AS INTEGER) AS `k`,
        CAST(`l` AS CHAR) AS `l`,
        CAST(`m` AS CHAR) AS `m`
      FROM (
        (
          SELECT NULL AS `ww`, NULL AS `k`, NULL AS `l`, NULL AS `m`
          WHERE (0 = 1)
        )
        UNION ALL
        (
        VALUES
          ROW(2, 1, 'b', 'house'),
          ROW(2, 2, 'c', 'tree'),
          ROW(2, 3, 'd', 'streetlamp'),
          ROW(2, 4, 'e', 'streetlamp')
        )
      ) `values_table`
      
      $load$tf_6
      <SQL> INSERT INTO `tf_6` (`zz`, `n`, `o`)
      SELECT
        CAST(`zz` AS INTEGER) AS `zz`,
        CAST(`n` AS CHAR) AS `n`,
        CAST(`o` AS CHAR) AS `o`
      FROM (
        (
          SELECT NULL AS `zz`, NULL AS `n`, NULL AS `o`
          WHERE (0 = 1)
        )
        UNION ALL
        (
        VALUES
          ROW(1, 'house', 'e'),
          ROW(1, 'tree', 'f'),
          ROW(1, 'hill', 'g'),
          ROW(1, 'streetlamp', 'h'),
          ROW(1, 'garden', 'i')
        )
      ) `values_table`
      
      
      $post
      $post$fk
      list()
      
      $post$unique
      list()
      
      $post$indexes
      list()
      
      

