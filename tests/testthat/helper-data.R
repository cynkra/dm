
data <-
  tribble(
    ~c1, ~c2, ~c3,
    1, 2, 3,
    4, 5, 3,
    1, 2, 4
  )

data_1 <- tibble(a = c(1, 2, 1), b = c(1, 4, 1), c = c(5, 6, 7))
data_2 <- tibble(a = c(1, 2, 3), b = c(4, 5, 6), c = c(7, 8, 9))
data_3 <- tibble(a = c(2, 1, 2), b = c(4, 5, 6), c = c(7, 8, 9))

data_4 <- tibble(
  a = as_integer(c(1, 2, 1)),
  b = c(1.1, 4.2, 1.1),
  c = as_integer(c(5, 6, 7)),
  d = c("a", "b", "c"),
  e = c("c", "b", "c"),
  f = c(TRUE, FALSE, TRUE)
  )

data_4_child <- tibble(
  b = c(1.1, 4.2, 1.1),
  aef_id = as_integer(c(1, 2, 1)),
  c = as_integer(c(5, 6, 7)),
  d = c("a", "b", "c"),
  )

data_4_parent <- tibble(
  aef_id = as_integer(c(1, 2)),
  a = as_integer(c(1, 2)),
  e = c("c", "b"),
  f = c(TRUE, FALSE)
)

list_of_data_4_parent_and_child <- list("child_table" = data_4_child, "parent_table" = data_4_parent)

# In-memory SQLite DB
data_4_db_sqlite <- tbl_memdb(data_4, name = "data_4_db_sqlite") # FIXME: logical turns integer, see http://gitlab.private.cynkra.com/g/cynkra/public/dm/issues/14
data_4_child_db_sqlite <- tbl_memdb(data_4_child, name = "data_4_child_db_sqlite")
data_4_parent_db_sqlite <- tbl_memdb(data_4_parent, name = "data_4_parent_db_sqlite")

list_of_data_4_parent_and_child_db_sqlite <- list("child_table" = data_4_child_db_sqlite, "parent_table" = data_4_parent_db_sqlite)

# localhost postgres DB
drv <- Postgres()
conn <- dbConnect(drv, host = "localhost", port = 5432)
data_4_db_pg <- copy_to(conn, data_4, name = "data_4_db_pg", overwrite = TRUE)
data_4_child_db_pg <- copy_to(conn, data_4_child, name = "data_4_child_db_pg", overwrite = TRUE)
data_4_parent_db_pg <- copy_to(conn, data_4_parent, name = "data_4_parent_db_pg", overwrite = TRUE)

list_of_data_4_parent_and_child_db_pg <- list("child_table" = data_4_child_db_pg, "parent_table" = data_4_parent_db_pg)
