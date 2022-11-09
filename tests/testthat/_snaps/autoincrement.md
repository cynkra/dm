# autoincrement produces valid R code

    Code
      dm
    Output
      -- Metadata --------------------------------------------------------------------
      Tables: `x`, `y`
      Columns: 5
      Primary keys: 2
      Foreign keys: 1

# autoincrement produces valid SQL queries and R code - RSQLite

    Code
      df$sql_table
    Output
      <SQL> CREATE TEMPORARY TABLE x (
        `x_id` INT,
        `x_data` TEXT,
        PRIMARY KEY (`x_id`) -- AUTOINCREMENT
      )
      <SQL> CREATE TEMPORARY TABLE y (
        `y_id` INT,
        `x_id` INT,
        `y_data` TEXT,
        PRIMARY KEY (`y_id`),
        FOREIGN KEY (`x_id`) REFERENCES x (`x_id`)
      )

---

    Code
      dm
    Output
      -- Metadata --------------------------------------------------------------------
      Tables: `x`, `y`
      Columns: 5
      Primary keys: 2
      Foreign keys: 1
