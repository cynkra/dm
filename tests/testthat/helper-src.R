try(library(dbplyr), silent = TRUE)
library(rprojroot)

if (!is_attached("dm_cache")) {
  ((attach))(new_environment(), pos = length(search()) - 1, name = "dm_cache")
}
cache <- search_env("dm_cache")

`%<-%` <- function(lhs, rhs) {
  lhs <- as_name(ensym(lhs))

  value <- get0(lhs, cache)
  if (is.null(value)) {
    message("Evaluating ", lhs)
    value <- rhs
    assign(lhs, value, cache)
  } else {
    message("Using cached ", lhs)
  }
  assign(lhs, value, parent.frame())
  invisible(value)
}

# for examine_cardinality...() ----------------------------------------------

message("for examine_cardinality...()")

d1 %<-% tibble::tibble(a = 1:5, b = letters[1:5])
d2 %<-% tibble::tibble(a = c(1, 3:6), b = letters[1:5])
d3 %<-% tibble::tibble(c = 1:5)
d4 %<-% tibble::tibble(c = c(1:5, 5L))
d5 %<-% tibble::tibble(a = 1:5)
d6 %<-% tibble::tibble(c = 1:4)
d7 %<-% tibble::tibble(c = c(1:5, 5L, 6L))
d8 %<-% tibble::tibble(c = c(1:6))

# for check_key() ---------------------------------------------------------

message("for check_fk() and check_set_equality()")
# for examine_cardinality...() ----------------------------------------------
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
d8_src <- test_load(d8)

data %<-%
  tribble(
    ~c1, ~c2, ~c3,
    1, 2, 3,
    4, 5, 3,
    1, 2, 4
  )

data_1 %<-% tibble(a = c(1, 2, 1), b = c(1, 4, 1), c = c(5, 6, 7))
data_2 %<-% tibble(a = c(1, 2, 3), b = c(4, 5, 6), c = c(7, 8, 9))
data_3 %<-% tibble(a = c(2, 1, 2), b = c(4, 5, 6), c = c(7, 8, 9))

# for table-surgery functions ---------------------------------------------

message("for table surgery")

data_ts %<-% tibble(
  a = as.integer(c(1, 2, 1)),
  b = c(1.1, 4.2, 1.1),
  c = as.integer(c(5, 6, 7)),
  d = c("a", "b", "c"),
  e = c("c", "b", "c"),
  f = c(TRUE, FALSE, TRUE)
)

data_ts_child %<-% tibble(
  b = c(1.1, 4.2, 1.1),
  aef_id = as.integer(c(1, 2, 1)),
  c = as.integer(c(5, 6, 7)),
  d = c("a", "b", "c"),
)

data_ts_parent %<-% tibble(
  aef_id = as.integer(c(1, 2)),
  a = as.integer(c(1, 2)),
  e = c("c", "b"),
  f = c(TRUE, FALSE)
)

# for testing filter and semi_join ---------------------------------------------

message("for testing filter and semi_join")

# the following is for testing the filtering functionality:
t1 %<-% tibble(
  a = 1:10,
  b = LETTERS[1:10]
)

t2 %<-% tibble(
  c = c("elephant", "lion", "seal", "worm", "dog", "cat"),
  d = 2:7,
  e = c(LETTERS[4:7], LETTERS[5:6])
)

t3 %<-% tibble(
  f = LETTERS[2:11],
  g = c("one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten")
)

t4 %<-% tibble(
  h = letters[1:5],
  i = c("three", "four", "five", "six", "seven"),
  j = c(LETTERS[3:6], LETTERS[6])
)

t5 %<-% tibble(
  k = 1:4,
  l = letters[2:5],
  m = c("house", "tree", "streetlamp", "streetlamp")
)

t6 %<-% tibble(
  n = c("house", "tree", "hill", "streetlamp", "garden"),
  o = letters[5:9]
)

t7 %<-% tibble(
  p = letters[4:9],
  q = c("elephant", "lion", "seal", "worm", "dog", "cat")
)

dm_for_filter_w_cycle %<-% {
  as_dm(list(
    t1 = t1, t2 = t2, t3 = t3, t4 = t4, t5 = t5, t6 = t6, t7 = t7
  )) %>%
    dm_add_pk(t1, a) %>%
    dm_add_pk(t2, c) %>%
    dm_add_pk(t3, f) %>%
    dm_add_pk(t4, h) %>%
    dm_add_pk(t5, k) %>%
    dm_add_pk(t6, n) %>%
    dm_add_pk(t7, p) %>%
    dm_add_fk(t2, d, t1) %>%
    dm_add_fk(t2, e, t3) %>%
    dm_add_fk(t4, j, t3) %>%
    dm_add_fk(t5, l, t4) %>%
    dm_add_fk(t5, m, t6) %>%
    dm_add_fk(t6, o, t7) %>%
    dm_add_fk(t7, q, t2)
}

message("for testing filter and semi_join (2)")

list_for_filter %<-% list(t1 = t1, t2 = t2, t3 = t3, t4 = t4, t5 = t5, t6 = t6)
dm_for_filter %<-% {
  dm_for_filter_w_cycle %>%
    dm_select_tbl(-t7)
}

message("for testing filter and semi_join (3)")

output_1 %<-% list(
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

output_3 %<-% list(
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

def_dm_for_filter <- dm_get_def(dm_for_filter)

dm_for_filter_rev %<-%
  new_dm3(def_dm_for_filter[rev(seq_len(nrow(def_dm_for_filter))), ])

# for tests on `dm` objects: dm_add_pk(), dm_add_fk() ------------------------

message("for tests on `dm` objects: dm_add_pk(), dm_add_fk()")

dm_test_obj %<-% as_dm(list(
  dm_table_1 = d2,
  dm_table_2 = d4,
  dm_table_3 = d7,
  dm_table_4 = d8
))

dm_test_obj_2 %<-% as_dm(list(
  dm_table_1 = d4,
  dm_table_2 = d7,
  dm_table_3 = d8,
  dm_table_4 = d6
))


# for `dm_nrow()` ---------------------------------------------------------

rows_dm_obj <- 24L


# Complicated `dm` --------------------------------------------------------

message("complicated dm")

list_for_filter_2 %<-%
  modifyList(
    list_for_filter,
    list(
      t6_2 = tibble(p = letters[1:6], f = LETTERS[6:11]),
      t4_2 = tibble(
        r = letters[2:6],
        s = c("three", "five", "six", "seven", "eight"),
        t = c(LETTERS[4:7], LETTERS[5])
      ),
      a = tibble(a_1 = letters[10:18], a_2 = 5:13),
      b = tibble(b_1 = LETTERS[12:15], b_2 = letters[12:15], b_3 = 9:6),
      c = tibble(c_1 = 4:10),
      d = tibble(d_1 = 1:6, b_1 = LETTERS[c(12:14, 13:15)]),
      e = tibble(e_1 = 1:2, b_1 = LETTERS[c(12:13)])
    )
  )

dm_more_complex %<-% {
  as_dm(list_for_filter_2) %>%
    dm_add_pk(t1, a) %>%
    dm_add_pk(t2, c) %>%
    dm_add_pk(t3, f) %>%
    dm_add_pk(t4, h) %>%
    dm_add_pk(t4_2, r) %>%
    dm_add_pk(t5, k) %>%
    dm_add_pk(t6, n) %>%
    dm_add_pk(t6_2, p) %>%
    dm_add_pk(a, a_1) %>%
    dm_add_pk(b, b_1) %>%
    dm_add_pk(c, c_1) %>%
    dm_add_pk(d, d_1) %>%
    dm_add_pk(e, e_1) %>%
    dm_add_fk(t2, d, t1) %>%
    dm_add_fk(t2, e, t3) %>%
    dm_add_fk(t4, j, t3) %>%
    dm_add_fk(t5, l, t4) %>%
    dm_add_fk(t5, l, t4_2) %>%
    dm_add_fk(t5, m, t6) %>%
    dm_add_fk(t6_2, f, t3) %>%
    dm_add_fk(b, b_2, a) %>%
    dm_add_fk(b, b_3, c) %>%
    dm_add_fk(d, b_1, b) %>%
    dm_add_fk(e, b_1, b)
}

# for testing `dm_disambiguate_cols()` ----------------------------------------

message("for dm_disambiguate_cols()")

iris_1 %<-% {
  as_tibble(iris) %>%
    mutate(key = row_number()) %>%
    select(key, everything())
}
iris_2 %<-% {
  iris_1 %>%
    mutate(other_col = TRUE)
}
iris_3 %<-% {
  iris_2 %>%
    mutate(one_more_col = 1)
}

iris_1_dis %<-% {
  iris_1 %>%
    rename_at(2:6, ~ sub("^", "iris_1.", .))
}
iris_2_dis %<-% {
  iris_2 %>%
    rename_at(1:7, ~ sub("^", "iris_2.", .))
}
iris_3_dis %<-% {
  iris_3 %>%
    rename_at(1:7, ~ sub("^", "iris_3.", .))
}


dm_for_disambiguate %<-% {
  as_dm(list(iris_1 = iris_1, iris_2 = iris_2, iris_3 = iris_3)) %>%
    dm_add_pk(iris_1, key) %>%
    dm_add_fk(iris_2, key, iris_1)
}

dm_for_disambiguate_2 %<-% {
  as_dm(list(iris_1 = iris_1_dis, iris_2 = iris_2_dis, iris_3 = iris_3_dis)) %>%
    dm_add_pk(iris_1, key) %>%
    dm_add_fk(iris_2, iris_2.key, iris_1)
}

# star schema data model for testing `dm_flatten_to_tbl()`

message("star schema")

fact %<-% tibble(
  fact = c(
    "acorn",
    "blubber",
    "cinderella",
    "depth",
    "elysium",
    "fantasy",
    "gorgeous",
    "halo",
    "ill-advised",
    "jitter"
  ),
  dim_1_key = 14:5,
  dim_2_key = letters[3:12],
  dim_3_key = LETTERS[24:15],
  dim_4_key = 7:16,
  something = 1:10
)

fact_clean %<-% {
  fact %>%
    rename(
      fact.something = something
    )
}

dim_1 %<-% tibble(
  dim_1_pk = 1:20,
  something = letters[3:22]
)
dim_1_clean %<-% {
  dim_1 %>%
    rename(dim_1.something = something)
}

dim_2 %<-% tibble(
  dim_2_pk = letters[1:20],
  something = LETTERS[5:24]
)
dim_2_clean %<-% {
  dim_2 %>%
    rename(dim_2.something = something)
}

dim_3 %<-% tibble(
  dim_3_pk = LETTERS[5:24],
  something = 3:22
)
dim_3_clean %<-% {
  dim_3 %>%
    rename(dim_3.something = something)
}

dim_4 %<-% tibble(
  dim_4_pk = 19:7,
  something = 19:31
)
dim_4_clean %<-% {
  dim_4 %>%
    rename(dim_4.something = something)
}

dm_for_flatten %<-% {
  as_dm(list(
    fact = fact,
    dim_1 = dim_1,
    dim_2 = dim_2,
    dim_3 = dim_3,
    dim_4 = dim_4
  )) %>%
    dm_add_pk(dim_1, dim_1_pk) %>%
    dm_add_pk(dim_2, dim_2_pk) %>%
    dm_add_pk(dim_3, dim_3_pk) %>%
    dm_add_pk(dim_4, dim_4_pk) %>%
    dm_add_fk(fact, dim_1_key, dim_1) %>%
    dm_add_fk(fact, dim_2_key, dim_2) %>%
    dm_add_fk(fact, dim_3_key, dim_3) %>%
    dm_add_fk(fact, dim_4_key, dim_4)
}

result_from_flatten %<-% {
  fact_clean %>%
    left_join(dim_1_clean, by = c("dim_1_key" = "dim_1_pk")) %>%
    left_join(dim_2_clean, by = c("dim_2_key" = "dim_2_pk")) %>%
    left_join(dim_3_clean, by = c("dim_3_key" = "dim_3_pk")) %>%
    left_join(dim_4_clean, by = c("dim_4_key" = "dim_4_pk"))
}

# 'bad' dm (no ref. integrity) for testing dm_flatten_to_tbl() --------

tbl_1 %<-% tibble(a = c(1, 2, 4, 5), b = a)
tbl_2 %<-% tibble(id = 1:2, c = letters[1:2])
tbl_3 %<-% tibble(id = 2:4, d = letters[2:4])

bad_dm %<-% {
  as_dm(list(tbl_1 = tbl_1, tbl_2 = tbl_2, tbl_3 = tbl_3)) %>%
    dm_add_pk(tbl_2, id) %>%
    dm_add_pk(tbl_3, id) %>%
    dm_add_fk(tbl_1, a, tbl_2) %>%
    dm_add_fk(tbl_1, b, tbl_3)
}

dm_nycflights_small %<-% {
  as_dm(
    list(
      flights = nycflights13::flights %>% slice(1:800),
      planes = nycflights13::planes,
      airlines = nycflights13::airlines,
      airports = nycflights13::airports,
      weather = nycflights13::weather %>% slice(1:800)
    )
  ) %>%
    dm_add_pk(planes, tailnum) %>%
    dm_add_pk(airlines, carrier) %>%
    dm_add_pk(airports, faa) %>%
    dm_add_fk(flights, tailnum, planes) %>%
    dm_add_fk(flights, carrier, airlines) %>%
    dm_add_fk(flights, dest, airports)
}

zoomed_dm <- dm_zoom_to(dm_for_filter, t2)
zoomed_dm_2 <- dm_zoom_to(dm_for_filter, t3)

# for database tests -------------------------------------------------

# postgres needs to be cleaned of t?_2019_* tables for learn-test
get_test_tables_from_postgres <- function() {
  src_postgres <- src_test("postgres")
  con_postgres <- src_postgres$con

  dbGetQuery(con_postgres, "SELECT table_name FROM information_schema.tables WHERE table_schema = 'public'") %>%
    as_tibble() %>%
    filter(grepl("^t[0-9]{1}_[0-9]{4}_[0-9]{2}_[0-9]{2}_[0-9]{2}_[0-9]{2}_[0-9]{2}_[0-9]+", table_name))
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

# Only run if the top level call is devtools::test() or testthat::test_check()
if (is_this_a_test()) {
  library(nycflights13)

  message("connecting")

  dbplyr::test_register_src("df", src_df(env = .GlobalEnv))

  if (packageVersion("RSQLite") >= "2.1.1.9003") {
    try(dbplyr::test_register_src("sqlite", src_sqlite(":memory:", create = TRUE)), silent = TRUE)
  }

  local(try(
    {
      con <- DBI::dbConnect(
        RPostgres::Postgres(),
        dbname = "postgres", host = "localhost", port = 5432,
        user = "postgres", bigint = "integer"
      )
      src <- src_dbi(con, auto_disconnect = TRUE)
      dbplyr::test_register_src("postgres", src)
      clear_postgres()
    },
    silent = TRUE
  ))


  # This will only work, if run on TS's laptop
  try(
    {
      source("/Users/tobiasschieferdecker/git/cynkra/dm/.Rprofile")
      con_mssql <- mssql_con()
      src_mssql <- src_dbi(con_mssql)
      dbplyr::test_register_src("mssql", src_mssql)
    },
    silent = TRUE
  )

  message("loading into database")

  dm_for_filter_src %<-% dm_test_load(dm_for_filter)
  dm_for_filter_rev_src %<-% dm_test_load(dm_for_filter_rev)
  dm_for_filter_w_cycle_src %<-% dm_test_load(dm_for_filter_w_cycle)
  dm_test_obj_src %<-% dm_test_load(dm_test_obj)
  dm_test_obj_2_src %<-% dm_test_load(dm_test_obj_2)
  dm_for_flatten_src %<-% dm_test_load(dm_for_flatten)
  dm_more_complex_src %<-% dm_test_load(dm_more_complex)
  dm_for_disambiguate_src %<-% dm_test_load(dm_for_disambiguate)
  dm_nycflights_small_src %<-% dm_test_load(dm_nycflights_small, set_key_constraints = FALSE)

  message("loading data frames into database")

  d1_src %<-% dbplyr::test_load(d1)
  d2_src %<-% dbplyr::test_load(d2)
  d3_src %<-% dbplyr::test_load(d3)
  d4_src %<-% dbplyr::test_load(d4)
  d5_src %<-% dbplyr::test_load(d5)
  d6_src %<-% dbplyr::test_load(d6)

  # names of sources for naming files for mismatch-comparison; 1 name for each src needs to be given
  src_names %<-% names(d1_src) # e.g. gets src names of list entries of object d1_src
  active_srcs <- tibble(src = src_names)
  lookup <- tibble(
    src = c("df", "sqlite", "postgres", "mssql"),
    class_src = c("src_local", "src_SQLiteConnection", "src_PqConnection", "src_Microsoft SQL Server"),
    class_con = c(NA_character_, "SQLiteConnection", "PqConnection", "Microsoft SQL Server")
  )
  active_srcs_class <- semi_join(lookup, active_srcs, by = "src") %>% pull(class_src)

  data_check_key_src %<-% dbplyr::test_load(data)

  data_1_src %<-% dbplyr::test_load(data_1)
  data_2_src %<-% dbplyr::test_load(data_2)
  data_3_src %<-% dbplyr::test_load(data_3)

  data_ts_src %<-% dbplyr::test_load(data_ts)
  data_ts_child_src %<-% dbplyr::test_load(data_ts_child)
  data_ts_parent_src %<-% dbplyr::test_load(data_ts_parent)

  list_of_data_ts_parent_and_child_src %<-% map2(
    .x = data_ts_child_src,
    .y = data_ts_parent_src,
    ~ list("child_table" = .x, "parent_table" = .y)
  )

  t1_src %<-% dbplyr::test_load(t1)
  t3_src %<-% dbplyr::test_load(t3)

  test_srcs <- dbplyr:::test_srcs$get()
}
