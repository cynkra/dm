try(library(dbplyr), silent = TRUE)
library(rprojroot)

# postgres needs to be cleaned of t?_2019_* tables for learn-test ---------

get_test_tables_from_postgres <- function() {
  src_postgres <- src_test("postgres")
  con_postgres <- src_postgres$con

  dbGetQuery(con_postgres, "SELECT table_name FROM information_schema.tables WHERE table_schema = 'public'") %>%
    as_tibble() %>%
    filter(str_detect(table_name, "^t[0-9]{1}_[0-9]{4}_[0-9]{2}_[0-9]{2}_[0-9]{2}_[0-9]{2}_[0-9]{2}_[0-9]+"))
}

is_postgres_empty <- function() {
  nrow(get_test_tables_from_postgres()) == 0
}

clear_postgres <- function() {
  src_postgres <- src_test("postgres")
  con_postgres <- src_postgres$con

  walk(
    get_test_tables_from_postgres() %>%
      pull(),
    ~ dbExecute(con_postgres, glue("DROP TABLE {.x} CASCADE"))
  )
}


# register srcs -----------------------------------------------------------

test_register_src("df", src_df(env = new_environment()))

if (packageVersion("RSQLite") >= "2.1.1.9003") {
  try(test_register_src("sqlite", src_sqlite(":memory:", create = TRUE)), silent = TRUE)
}

local(try(
  {
    src <- src_postgres(dbname = "postgres", host = "localhost", port = 5432, user = "postgres")
    test_register_src("postgres", src)
    clear_postgres()
  },
  silent = TRUE
))


# Only run if the top level call is devtools::test() or testthat::test_check()
# In addition: this will only work, if run on TS's laptop
if (is_this_a_test()) {
  try(
    {
      source("/Users/tobiasschieferdecker/git/cynkra/dm/.Rprofile")
      con_mssql <- mssql_con()
      src_mssql <- src_dbi(con_mssql)
      test_register_src("mssql", src_mssql)
    },
    silent = TRUE
  )
}


# for check_cardinality...() ----------------------------------------------
d1 <- tibble::tibble(a = 1:5, b = letters[1:5])
d2 <- tibble::tibble(a = c(1, 3:6), b = letters[1:5])
d3 <- tibble::tibble(c = 1:5)
d4 <- tibble::tibble(c = c(1:5, 5))
d5 <- tibble::tibble(a = 1:5)
d6 <- tibble::tibble(c = 1:4)
d7 <- tibble::tibble(c = c(1:5, 5, 6))
d8 <- tibble::tibble(c = c(1:6))

d1_src <- test_load(d1)
d2_src <- test_load(d2)
d3_src <- test_load(d3)
d4_src <- test_load(d4)
d5_src <- test_load(d5)
d6_src <- test_load(d6)

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

data_check_key_src <- test_load(data)

# for check_fk() and check_set_equality() -------------------------
data_1 <- tibble(a = c(1, 2, 1), b = c(1, 4, 1), c = c(5, 6, 7))
data_2 <- tibble(a = c(1, 2, 3), b = c(4, 5, 6), c = c(7, 8, 9))
data_3 <- tibble(a = c(2, 1, 2), b = c(4, 5, 6), c = c(7, 8, 9))

data_1_src <- test_load(data_1)
data_2_src <- test_load(data_2)
data_3_src <- test_load(data_3)

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

data_ts_src <- test_load(data_ts)
data_ts_child_src <- test_load(data_ts_child)
data_ts_parent_src <- test_load(data_ts_parent)

list_of_data_ts_parent_and_child_src <- map2(
  .x = data_ts_child_src,
  .y = data_ts_parent_src,
  ~ list("child_table" = .x, "parent_table" = .y)
)


# for testing filter and semi_join ----------------------------------------

# the following is for testing the filtering functionality:
t1 <- tibble(
  a = 1:10,
  b = LETTERS[1:10]
)

t2 <- tibble(
  c = c("elephant", "lion", "seal", "worm", "dog", "cat"),
  d = 2:7,
  e = c(LETTERS[4:7], LETTERS[5:6])
)

t3 <- tibble(
  f = LETTERS[2:11],
  g = c("one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten")
)

t4 <- tibble(
  h = letters[1:5],
  i = c("three", "four", "five", "six", "seven"),
  j = c(LETTERS[3:6], LETTERS[6])
)

t5 <- tibble(
  k = 1:4,
  l = letters[2:5],
  m = c("house", "tree", "streetlamp", "streetlamp")
)

t6 <- tibble(
  n = c("house", "tree", "hill", "streetlamp", "garden"),
  o = letters[5:9]
)

dm_for_filter <- as_dm(list(t1 = t1, t2 = t2, t3 = t3, t4 = t4, t5 = t5, t6 = t6)) %>%
  cdm_add_pk(t1, a) %>%
  cdm_add_pk(t2, c) %>%
  cdm_add_pk(t3, f) %>%
  cdm_add_pk(t4, h) %>%
  cdm_add_pk(t5, k) %>%
  cdm_add_pk(t6, n) %>%
  cdm_add_fk(t2, d, t1) %>%
  cdm_add_fk(t2, e, t3) %>%
  cdm_add_fk(t4, j, t3) %>%
  cdm_add_fk(t5, l, t4) %>%
  cdm_add_fk(t5, m, t6)

dm_for_filter_smaller <- as_dm(list(t3 = t3, t4 = t4, t5 = t5)) %>%
  cdm_add_pk(t3, f) %>%
  cdm_add_pk(t4, h) %>%
  cdm_add_pk(t5, k) %>%
  cdm_add_fk(t4, j, t3) %>%
  cdm_add_fk(t5, l, t4)

t7 <- tibble(
  p = letters[4:9],
  q = c("elephant", "lion", "seal", "worm", "dog", "cat")
)

dm_for_filter_w_cycle <- as_dm(list(t1 = t1, t2 = t2, t3 = t3, t4 = t4, t5 = t5, t6 = t6, t7 = t7)) %>%
  cdm_add_pk(t1, a) %>%
  cdm_add_pk(t2, c) %>%
  cdm_add_pk(t3, f) %>%
  cdm_add_pk(t4, h) %>%
  cdm_add_pk(t5, k) %>%
  cdm_add_pk(t6, n) %>%
  cdm_add_pk(t7, p) %>%
  cdm_add_fk(t2, d, t1) %>%
  cdm_add_fk(t2, e, t3) %>%
  cdm_add_fk(t4, j, t3) %>%
  cdm_add_fk(t5, l, t4) %>%
  cdm_add_fk(t5, m, t6) %>%
  cdm_add_fk(t6, o, t7) %>%
  cdm_add_fk(t7, q, t2)

output_1 <- list(
  t1 = tibble(a = c(4:7), b = LETTERS[4:7]),
  t2 = tibble(c = c("seal", "worm", "dog", "cat"), d = 4:7, e = c("F", "G", "E", "F")),
  t3 = tibble(f = LETTERS[5:7], g = c("four", "five", "six")),
  t4 = tibble(h = letters[3:5], i = c("five", "six", "seven"), j = c("E", "F", "F")),
  t5 = tibble(
    k = 2:4,
    l = letters[3:5],
    m = c("tree", "streetlamp", "streetlamp")
  ),
  t6 = tibble(
    n = c("tree", "streetlamp"),
    o = c("f", "h")
  )
)

output_3 <- list(
  t1 = tibble::tribble(
    ~a, ~b,
    4L, "D",
    7L, "G"
  ),
  t2 = tibble::tribble(
    ~c, ~d, ~e,
    "seal", 4L, "F",
    "cat", 7L, "F"
  ),
  t3 = tibble::tribble(
    ~f, ~g,
    "F", "five"
  ),
  t4 = tibble::tribble(
    ~h, ~i, ~j,
    "d", "six", "F",
    "e", "seven", "F"
  ),
  t5 = tibble::tribble(
    ~k, ~l, ~m,
    3L, "d", "streetlamp",
    4L, "e", "streetlamp"
  ),
  t6 = tibble::tribble(
    ~n, ~o,
    "streetlamp", "h"
  )
)

dm_for_filter_rev <-
  new_dm(
    cdm_get_src(dm_for_filter),
    rev(cdm_get_tables(dm_for_filter)),
    cdm_get_data_model(dm_for_filter)
  )

t1_src <- test_load(t1)
t3_src <- test_load(t3)

# for tests on `dm` objects: cdm_add_pk(), cdm_add_pk() ------------------------

cdm_test_obj <- as_dm(list(cdm_table_1 = d2, cdm_table_2 = d4, cdm_table_3 = d7, cdm_table_4 = d8))
cdm_test_obj_src <- cdm_test_load(cdm_test_obj)
dm_for_filter_src <- cdm_test_load(dm_for_filter)
dm_for_filter_rev_src <- cdm_test_load(dm_for_filter_rev)
dm_for_filter_smaller_src <- cdm_test_load(dm_for_filter_smaller)
dm_for_filter_w_cycle_src <- cdm_test_load(dm_for_filter_w_cycle)

# for `dm_nrow()` ---------------------------------------------------------

rows_dm_obj <- 24L
