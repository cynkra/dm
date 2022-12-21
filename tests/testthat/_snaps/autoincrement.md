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
        `x_id` INTEGER ,
        `x_data` TEXT ,
        PRIMARY KEY (`x_id`)
      )
      <SQL> CREATE TEMPORARY TABLE y (
        `y_id` INTEGER ,
        `x_id` INTEGER ,
        `y_data` TEXT ,
        PRIMARY KEY (`y_id`),
        FOREIGN KEY (`x_id`) REFERENCES x (`x_id`)
      )

---

    Code
      dm_paste(dm)
    Message
      dm::dm(
        x,
        y,
      ) %>%
        dm::dm_add_pk(x, x_id, autoincrement = TRUE) %>%
        dm::dm_add_pk(y, y_id) %>%
        dm::dm_add_fk(y, x_id, x)

