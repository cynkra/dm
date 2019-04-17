try({
  library(rprojroot)
  library(testthat)
  library(dbplyr)
})

src_df <- src_df(env = new.env())
src_sqlite <- src_sqlite(":memory:", create = TRUE)
src_postgres <- src_postgres(dbname = "postgres", host = "localhost", port = 5432, user = "postgres")

test_register_src("df", src_df)
test_register_src("sqlite", src_sqlite)
test_register_src("postgres", src_postgres)

# for check_cardinality...() ----------------------------------------------
d1 <- tibble::tibble(a = 1:5, b = letters[1:5])
d2 <- tibble::tibble(a = c(1, 3:6), b = letters[1:5])
d3 <- tibble::tibble(c = 1:5)
d4 <- tibble::tibble(c = c(1:5, 5))
d5 <- tibble::tibble(a = 1:5)
d6 <- tibble::tibble(c = 1:4)

d1_src <- test_load(d1, name = "d1")
d2_src <- test_load(d2, name = "d2")
d3_src <- test_load(d3, name = "d3")
d4_src <- test_load(d4, name = "d4")
d5_src <- test_load(d5, name = "d5")
d6_src <- test_load(d6, name = "d6")

# names of sources for naming files for mismatch-comparison; 1 name for each src needs to be given
src_names <- names(d1_src) # e.g. gets src names of list entries of object d1_src

# for check_key() ---------------------------------------------------------
data <-
  tribble(
    ~c1, ~c2, ~c3,
    1, 2, 3,
    4, 5, 3,
    1, 2, 4
  )

data_check_key_src <- test_load(data, name = "data_check_key")

# for check_fk() and check_set_equality() -------------------------
data_1 <- tibble(a = c(1, 2, 1), b = c(1, 4, 1), c = c(5, 6, 7))
data_2 <- tibble(a = c(1, 2, 3), b = c(4, 5, 6), c = c(7, 8, 9))
data_3 <- tibble(a = c(2, 1, 2), b = c(4, 5, 6), c = c(7, 8, 9))

data_1_src <- test_load(data_1, name = "data_1")
data_2_src <- test_load(data_2, name = "data_2")
data_3_src <- test_load(data_3, name = "data_3")

# for table-surgery functions ---------------------------------------------
data_ts <- tibble(
  a = as_integer(c(1, 2, 1)),
  b = c(1.1, 4.2, 1.1),
  c = as_integer(c(5, 6, 7)),
  d = c("a", "b", "c"),
  e = c("c", "b", "c"),
  f = c(TRUE, FALSE, TRUE)
)

data_ts_child <- tibble(
  b = c(1.1, 4.2, 1.1),
  aef_id = as_integer(c(1, 2, 1)),
  c = as_integer(c(5, 6, 7)),
  d = c("a", "b", "c"),
)

data_ts_parent <- tibble(
  aef_id = as_integer(c(1, 2)),
  a = as_integer(c(1, 2)),
  e = c("c", "b"),
  f = c(TRUE, FALSE)
)

data_ts_src <- test_load(data_ts, name = "data_ts")
data_ts_child_src <- test_load(data_ts_child, name = "data_ts_child")
data_ts_parent_src <- test_load(data_ts_parent, name = "data_ts_parent")

list_of_data_ts_parent_and_child_src <- map2(
  .x = data_ts_child_src,
  .y = data_ts_parent_src,
  ~ list("child_table" = .x, "parent_table" = .y)
)


# for `dm`-object tests: cdm_add_key(), dm_add_pk() --------------------------------

dm_test_obj <- as_dm(list(dm_table_1 = d2, dm_table_2 = d4, dm_table_3 = d2))
dm_test_obj_src <- dm_test_load(dm_test_obj)
