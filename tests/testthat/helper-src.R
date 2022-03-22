if (!is_attached("dm_cache")) {
  ((attach))(new_environment(), pos = length(search()) - 1, name = "dm_cache")
}
cache <- search_env("dm_cache")

`%<-%` <- function(lhs, rhs, env = caller_env()) {
  defer_assign({{ lhs }}, copy_to_my_test_src(rhs, {{ lhs }}), env)
}

`%<--%` <- function(lhs, rhs, env = caller_env()) {
  defer_assign({{ lhs }}, rhs, env)
}

defer_assign <- function(lhs, rhs, env) {
  lhs <- as_name(ensym(lhs))

  value <- get0(lhs, cache)
  if (is.null(value)) {
    message("Deferring ", lhs)

    # Enable this for eager assignment:
    # force(rhs)

    value <- function() {
      # message("Querying ", lhs)
      out <- rhs
      out
    }
    assign(lhs, value, cache)
  } else {
    message("Using cached ", lhs)
  }
  assign(lhs, value, env)
  invisible(value)
}

copy_to_my_test_src <- function(rhs, lhs) {
  name <- as_name(ensym(lhs))
  # message("Evaluating ", name)

  src <- my_test_src()
  if (is.null(src)) {
    rhs
  } else if (is_dm(rhs)) {
    # We want all dm operations to work with key constraints on the database
    # (except for bad_dm)
    # message(name)
    suppressMessages(copy_dm_to(src, rhs))
  } else if (inherits(rhs, "list")) {
    suppressMessages(
      map(rhs, ~ copy_to(src, .x, name = unique_db_table_name(name), temporary = TRUE))
    )
  } else {
    suppressMessages(copy_to(src, rhs, name = name, temporary = TRUE))
  }
}

my_test_src_name <- {
  src <- Sys.getenv("DM_TEST_SRC")
  # Allow set but empty DM_TEST_SRC environment variable
  if (src == "") {
    src <- "df"
  }
  name <- gsub("^.*-", "", src)
  inform(crayon::green(paste0("Testing on ", name)))
  name
}

is_db_test_src <- function() {
  my_test_src_name != "df"
}

is_my_test_src_sqlite <- function() {
  inherits(my_db_test_src(), "src_SQLiteConnection")
}

my_test_src_fun %<--% {
  fun <- paste0("test_src_", my_test_src_name)
  get0(fun, inherits = TRUE)
}

my_test_src_cache %<--% {
  my_test_src_fun()()
}

my_test_src <- function() {
  fun <- my_test_src_fun()
  if (is.null(fun)) {
    abort(paste0("Data source not known: ", my_test_src_name))
  }
  tryCatch(
    my_test_src_cache(),
    error = function(e) {
      abort(paste0("Data source ", my_test_src_name, " not accessible: ", conditionMessage(e)))
    }
  )
}

sqlite_test_src %<--% dbplyr::src_dbi(DBI::dbConnect(RSQLite::SQLite(), ":memory:"), auto_disconnect = TRUE)

my_db_test_src <- function() {
  if (is_db_test_src()) {
    my_test_src()
  } else {
    sqlite_test_src()
  }
}

test_src_frame <- function(..., .temporary = TRUE, .env = parent.frame(), .unique_indexes = NULL) {
  src <- my_test_src()

  df <- tibble(...)
  if (is.null(src)) {
    return(df)
  }

  if (!.temporary) {
    name <- unique_db_table_name("test_frame")
    temporary <- FALSE
  } else if (is_mssql(src)) {
    name <- paste0("#", unique_db_table_name("test_frame"))
    temporary <- FALSE
  } else {
    name <- unique_db_table_name("test_frame")
    temporary <- TRUE
  }

  out <- copy_to(src, df, name = name, temporary = temporary, unique_indexes = .unique_indexes)
  out
}

test_db_src_frame <- function(..., .temporary = TRUE, .env = parent.frame(),
                              .unique_indexes = NULL) {
  if (is_db_test_src()) {
    return(test_src_frame(..., .temporary = .temporary, .env = .env, .unique_indexes = .unique_indexes))
  }

  src <- my_db_test_src()

  df <- tibble(...)

  name <- unique_db_table_name("test_frame")

  out <- copy_to(src, df, name = name, temporary = .temporary, unique_indexes = .unique_indexes)

  if (!.temporary) {
    withr::defer(DBI::dbRemoveTable(con_from_src_or_con(src), name), envir = .env)
  }

  out
}


# for examine_cardinality...() ----------------------------------------------

data_card_1 %<-% tibble::tibble(a = 1:5, b = letters[1:5])
data_card_1_sqlite %<--% copy_to(sqlite_test_src(), data_card_1())
data_card_2 %<-% tibble::tibble(a = c(1, 3:6), b = letters[1:5])
data_card_3 %<-% tibble::tibble(c = 1:5)
data_card_4 %<-% tibble::tibble(c = c(1:5, 5L))
data_card_5 %<-% tibble::tibble(a = 1:5)
data_card_6 %<-% tibble::tibble(c = 1:4)
data_card_7 %<-% tibble::tibble(c = c(1:5, 5L, 6L))
data_card_8 %<-% tibble::tibble(c = c(1:6))
data_card_9 %<-% tibble::tibble(c = c(1:5, NA))
data_card_10 %<-% tibble::tibble(c = c(1:3, 4:3, NA))
data_card_11 %<-% tibble::tibble(a = 1:4, b = letters[1:4])
data_card_12 %<-% tibble::tibble(a = c(1:5, 5L), b = letters[c(1:5, 5L)])
data_card_13 %<-% tibble::tibble(a = 1:6, b = letters[1:6])

dm_for_card %<--% {
  dm(
    dc_1 = data_card_1(),
    dc_2 = data_card_11(),
    dc_3 = data_card_12(),
    dc_4 = data_card_13(),
    dc_5 = data_card_1(),
    dc_6 = data_card_7()
  ) %>%
    dm_add_fk(dc_2, c(a, b), dc_1, c(a, b)) %>%
    dm_add_fk(dc_3, c(a, b), dc_1, c(a, b)) %>%
    dm_add_fk(dc_3, c(b, a), dc_4, c(b, a)) %>%
    dm_add_fk(dc_4, c(b, a), dc_3, c(b, a)) %>%
    dm_add_fk(dc_5, c(b, a), dc_1, c(b, a)) %>%
    dm_add_fk(dc_6, c, dc_1, a)
}

# for check_key() ---------------------------------------------------------

data_mcard %<-%
  tribble(
    ~c1, ~c2, ~c3,
    1, 2, 3,
    4, 5, 3,
    1, 2, 4
  )

data_mcard_1 %<-% tibble(a = c(1, 2, 1), b = c(1, 4, 1), c = c(5, 6, 7))
data_mcard_2 %<-% tibble(a = c(1, 2, 3), b = c(4, 5, 6), c = c(7, 8, 9))
data_mcard_3 %<-% tibble(a = c(2, 1, 2), b = c(4, 5, 6), c = c(7, 8, 9))

# for table-surgery functions ---------------------------------------------

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
  c = as.integer(c(5, 6, 7)),
  d = c("a", "b", "c"),
  aef_id = as.integer(c(1, 2, 1)),
)

data_ts_parent %<-% tibble(
  aef_id = as.integer(c(1, 2)),
  a = as.integer(c(1, 2)),
  e = c("c", "b"),
  f = c(TRUE, FALSE)
)

list_of_data_ts_parent_and_child %<--% list(
  child_table = data_ts_child(),
  parent_table = data_ts_parent()
)

# for testing filter and semi_join ---------------------------------------------

# the following is for testing the filtering functionality:
tf_1 %<-% tibble(
  a = 1:10,
  b = LETTERS[1:10]
)

tf_2_simple %<-% tibble(
  c = c("elephant", "lion", "seal", "worm", "dog", "cat"),
  d = 2:7,
  e = c(LETTERS[4:7], LETTERS[5:6])
)

tf_2 %<-% tibble(
  c = c("elephant", "lion", "seal", "worm", "dog", "cat"),
  d = 2:7,
  e = c(LETTERS[4:7], LETTERS[5:6]),
  e1 = c(4:7, 5:6),
)

tf_3_simple %<-% tibble(
  f = LETTERS[2:11],
  g = c("one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten")
)

tf_3 %<-% tibble(
  f = LETTERS[c(3, 3:11)],
  f1 = c(2:7, 7L, 7L, 10:11),
  g = c("one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten")
)

tf_4 %<-% tibble(
  h = letters[1:5],
  i = c("three", "four", "five", "six", "seven"),
  j = c(LETTERS[3:6], LETTERS[6]),
  j1 = c(3:6, 6L),
)

tf_5 %<-% tibble(
  k = 1:4,
  l = letters[2:5],
  m = c("house", "tree", "streetlamp", "streetlamp")
)

tf_6 %<-% tibble(
  n = c("house", "tree", "hill", "streetlamp", "garden"),
  o = letters[5:9]
)

tf_7 %<-% tibble(
  p = letters[4:9],
  q = c("elephant", "lion", "seal", "worm", "dog", "cat")
)

dm_for_filter_w_cycle %<-% {
  dm(
    tf_1 = tf_1(), tf_2 = tf_2(), tf_3 = tf_3(), tf_4 = tf_4(), tf_5 = tf_5(), tf_6 = tf_6(), tf_7 = tf_7()
  ) %>%
    dm_add_pk(tf_1, a) %>%
    dm_add_pk(tf_3, c(f, f1)) %>%
    #
    dm_add_pk(tf_2, c) %>%
    dm_add_fk(tf_2, d, tf_1) %>%
    dm_add_fk(tf_2, c(e, e1), tf_3) %>%
    #
    dm_add_pk(tf_4, h) %>%
    dm_add_fk(tf_4, c(j, j1), tf_3) %>%
    #
    dm_add_pk(tf_7, p) %>%
    dm_add_fk(tf_7, q, tf_2) %>%
    #
    dm_add_pk(tf_6, o) %>%
    dm_add_fk(tf_6, o, tf_7) %>%
    #
    dm_add_pk(tf_5, k) %>%
    dm_add_fk(tf_5, l, tf_4, on_delete = "cascade") %>%
    dm_add_fk(tf_5, m, tf_6, n)
}

dm_for_filter %<-% {
  dm_for_filter_w_cycle() %>%
    dm_select_tbl(-tf_7)
}

dm_for_filter_db %<--% {
  copy_dm_to(my_db_test_src(), dm_for_filter())
}

dm_for_filter_sqlite %<--% copy_dm_to(sqlite_test_src(), dm_for_filter())

dm_for_filter_rev %<-% {
  def_dm_for_filter <- dm_get_def(dm_for_filter())
  new_dm3(def_dm_for_filter[rev(seq_len(nrow(def_dm_for_filter))), ])
}

# Deprecated tests
dm_for_filter_simple %<-% {
  dm(
    tf_1 = tf_1(), tf_2 = tf_2_simple(), tf_3 = tf_3_simple(), tf_4 = tf_4(), tf_5 = tf_5(), tf_6 = tf_6()
  ) %>%
    dm_add_pk(tf_1, a) %>%
    dm_add_pk(tf_3, f) %>%
    #
    dm_add_pk(tf_2, c) %>%
    dm_add_fk(tf_2, d, tf_1) %>%
    dm_add_fk(tf_2, e, tf_3) %>%
    #
    dm_add_pk(tf_4, h) %>%
    dm_add_fk(tf_4, j, tf_3) %>%
    #
    dm_add_pk(tf_6, n) %>%
    #
    dm_add_pk(tf_5, k) %>%
    dm_add_fk(tf_5, l, tf_4) %>%
    dm_add_fk(tf_5, m, tf_6)
}

dm_for_filter_simple_db %<--% {
  copy_dm_to(my_db_test_src(), dm_for_filter_simple())
}

# for tests on `dm` objects: dm_add_pk(), dm_add_fk() ------------------------

dm_test_obj %<-% as_dm(list(
  dm_table_1 = data_card_2(),
  dm_table_2 = data_card_4(),
  dm_table_3 = data_card_7(),
  dm_table_4 = data_card_8(),
  dm_table_5 = data_card_9(),
  dm_table_6 = data_card_10()
))

dm_test_obj_2 %<-% as_dm(list(
  dm_table_1 = data_card_4(),
  dm_table_2 = data_card_7(),
  dm_table_3 = data_card_8(),
  dm_table_4 = data_card_6()
))

# for `dm_nrow()` ---------------------------------------------------------

rows_dm_obj <- 36L

# Complicated `dm` --------------------------------------------------------

dm_more_complex_part %<-% {
  dm(
    tf_6_2 = tibble(p = letters[1:6], f = LETTERS[6:11], f1 = c(6:7, 7L, 7L, 10:11)),
    tf_4_2 = tibble(
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
}

dm_more_complex %<-% {
  dm(
    !!!dm_get_tables(dm_for_filter_w_cycle()),
    !!!dm_get_tables(dm_more_complex_part())
  ) %>%
    dm_add_pk(tf_1, a) %>%
    dm_add_pk(tf_2, c) %>%
    dm_add_pk(tf_3, c(f, f1)) %>%
    dm_add_pk(tf_4, h) %>%
    dm_add_pk(tf_4_2, r) %>%
    dm_add_pk(tf_5, k) %>%
    dm_add_pk(tf_6, n) %>%
    dm_add_pk(tf_6_2, p) %>%
    dm_add_pk(a, a_1) %>%
    dm_add_pk(b, b_1) %>%
    dm_add_pk(c, c_1) %>%
    dm_add_pk(d, d_1) %>%
    dm_add_pk(e, e_1) %>%
    dm_add_fk(tf_2, d, tf_1) %>%
    dm_add_fk(tf_2, c(e, e1), tf_3) %>%
    dm_add_fk(tf_4, c(j, j1), tf_3) %>%
    dm_add_fk(tf_5, l, tf_4) %>%
    dm_add_fk(tf_5, l, tf_4_2) %>%
    dm_add_fk(tf_5, m, tf_6) %>%
    dm_add_fk(tf_6_2, c(f, f1), tf_3) %>%
    dm_add_fk(b, b_2, a) %>%
    dm_add_fk(b, b_3, c) %>%
    dm_add_fk(d, b_1, b) %>%
    dm_add_fk(e, b_1, b)
}

# for testing `dm_disambiguate_cols()` ----------------------------------------

iris_1 %<-% {
  datasets::iris %>%
    as_tibble() %>%
    mutate(key = row_number()) %>%
    select(key, everything())
}
iris_2 %<-% {
  iris_1() %>%
    mutate(other_col = 1L)
}
iris_3 %<-% {
  iris_2() %>%
    mutate(one_more_col = 1)
}

iris_1_dis %<-% {
  iris_1() %>%
    rename_at(2:6, ~ sub("^", "iris_1.", .))
}
iris_2_dis %<-% {
  iris_2() %>%
    rename_at(1:7, ~ sub("^", "iris_2.", .))
}
iris_3_dis %<-% {
  iris_3() %>%
    rename_at(1:7, ~ sub("^", "iris_3.", .))
}

dm_for_disambiguate %<-% {
  list(iris_1 = iris_1(), iris_2 = iris_2(), iris_3 = iris_3()) %>%
    as_dm() %>%
    dm_add_pk(iris_1, key) %>%
    dm_add_fk(iris_2, key, iris_1)
}

# star schema data model for testing `dm_flatten_to_tbl()` ------

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
  dim_1_key_1 = 14:5,
  dim_1_key_2 = LETTERS[14:5],
  dim_2_key = letters[3:12],
  dim_3_key = LETTERS[24:15],
  dim_4_key = 7:16,
  something = 1:10
)

fact_clean %<-% {
  fact() %>%
    rename(
      fact.something = something
    )
}

dim_1 %<-% tibble(
  dim_1_pk_1 = 1:20,
  dim_1_pk_2 = LETTERS[1:20],
  something = letters[3:22]
)
dim_1_clean %<-% {
  dim_1() %>%
    rename(dim_1.something = something)
}

dim_2 %<-% tibble(
  dim_2_pk = letters[1:20],
  something = LETTERS[5:24]
)
dim_2_clean %<-% {
  dim_2() %>%
    rename(dim_2.something = something)
}

dim_3 %<-% tibble(
  dim_3_pk = LETTERS[5:24],
  something = 3:22
)
dim_3_clean %<-% {
  dim_3() %>%
    rename(dim_3.something = something)
}

dim_4 %<-% tibble(
  dim_4_pk = 19:7,
  something = 19:31
)
dim_4_clean %<-% {
  dim_4() %>%
    rename(dim_4.something = something)
}


# dm for testing iterative dm_disentangle() -----------------------------------------

entangled_dm %<-% {
  dm(
    a = tf_5() %>% rename(a = k),
    b = tf_5() %>% rename(b = k),
    c = tf_5() %>% rename(c = k),
    d = tf_5() %>% rename(d = k),
    e = tf_5() %>% rename(e = k),
    f = tf_5() %>% rename(f = k),
    g = tf_5() %>% rename(g = k),
    h = tf_5() %>% rename(h = k)
  ) %>%
    dm_add_pk(b, b) %>%
    dm_add_pk(c, c) %>%
    dm_add_pk(d, d) %>%
    dm_add_pk(e, e) %>%
    dm_add_pk(f, f) %>%
    dm_add_pk(g, g) %>%
    dm_add_pk(h, h) %>%
    dm_add_fk(a, a, b) %>%
    dm_add_fk(a, a, c) %>%
    dm_add_fk(b, b, d) %>%
    dm_add_fk(c, c, d) %>%
    dm_add_fk(d, d, e) %>%
    dm_add_fk(d, d, f) %>%
    dm_add_fk(e, e, g) %>%
    dm_add_fk(f, f, g) %>%
    dm_add_fk(g, g, h)
}

entangled_dm_2 %<-% {
  dm(
    a = tf_5() %>% rename(a = k),
    b = tf_5() %>% rename(b = k),
    c = tf_5() %>% rename(c = k),
    d = tf_5() %>% rename(d = k),
    e = tf_5() %>% rename(e = k),
    f = tf_5() %>% rename(f = k)
  ) %>%
    dm_add_pk(b, b) %>%
    dm_add_pk(c, c) %>%
    dm_add_pk(d, d) %>%
    dm_add_pk(e, e) %>%
    dm_add_pk(f, f) %>%
    dm_add_fk(a, a, d) %>%
    dm_add_fk(b, b, d) %>%
    dm_add_fk(c, c, d) %>%
    dm_add_fk(a, a, e) %>%
    dm_add_fk(d, d, e)
}

# dm_flatten() ------------------------------------------------------------


dm_for_flatten %<-% {
  as_dm(list(
    fact = fact(),
    dim_1 = dim_1(),
    dim_2 = dim_2(),
    dim_3 = dim_3(),
    dim_4 = dim_4()
  )) %>%
    dm_add_pk(dim_1, c(dim_1_pk_1, dim_1_pk_2)) %>%
    dm_add_pk(dim_2, dim_2_pk) %>%
    dm_add_pk(dim_3, dim_3_pk) %>%
    dm_add_pk(dim_4, dim_4_pk) %>%
    dm_add_fk(fact, c(dim_1_key_1, dim_1_key_2), dim_1) %>%
    dm_add_fk(fact, dim_2_key, dim_2) %>%
    dm_add_fk(fact, dim_3_key, dim_3) %>%
    dm_add_fk(fact, dim_4_key, dim_4)
}

result_from_flatten %<-% {
  fact_clean() %>%
    left_join(dim_1_clean(), by = c("dim_1_key_1" = "dim_1_pk_1", "dim_1_key_2" = "dim_1_pk_2")) %>%
    left_join(dim_2_clean(), by = c("dim_2_key" = "dim_2_pk")) %>%
    left_join(dim_3_clean(), by = c("dim_3_key" = "dim_3_pk")) %>%
    left_join(dim_4_clean(), by = c("dim_4_key" = "dim_4_pk"))
}

# 'bad' dm (no ref. integrity) for testing dm_flatten_to_tbl() --------

tbl_1 %<-% tibble(a = as.integer(c(1, 2, 4, 5, NA)), x = LETTERS[3:7], b = a)
tbl_2 %<-% tibble(id = c(1:3, 3), x = LETTERS[c(3:5, 5)], c = letters[1:4])
tbl_3 %<-% tibble(id = c(2:4, 4), d = letters[2:5])

bad_dm_base %<-% {
  as_dm(list(tbl_1 = tbl_1(), tbl_2 = tbl_2(), tbl_3 = tbl_3()))
}

# avoid copying constraints for invalid dm
bad_dm %<--% {
  bad_dm_base() %>%
    dm_add_pk(tbl_2, c(id, x)) %>%
    dm_add_pk(tbl_3, id) %>%
    dm_add_fk(tbl_1, c(a, x), tbl_2) %>%
    dm_add_fk(tbl_1, b, tbl_3)
}

dm_nycflights_small_base %<-% {
  dm(!!!dm_get_tables(dm_nycflights13()))
}

# Do not add PK and FK constraints to the database
dm_nycflights_small %<--% {
  dm_nycflights_small_base() %>%
    dm_add_pk(planes, tailnum) %>%
    dm_add_pk(airlines, carrier) %>%
    dm_add_pk(airports, faa) %>%
    dm_add_fk(flights, tailnum, planes) %>%
    dm_add_fk(flights, carrier, airlines) %>%
    dm_add_fk(flights, dest, airports)
}

dm_nycflights_small_cycle %<--% {
  dm_nycflights_small() %>%
    dm_add_fk(flights, origin, airports)
}

nyc_comp %<--% {
  dm_nycflights_small() %>%
    dm_add_pk(weather, c(origin, time_hour)) %>%
    dm_add_fk(flights, c(origin, time_hour), weather)
}

zoomed_dm <- function() dm_zoom_to(dm_for_filter(), tf_2)
zoomed_dm_2 <- function() dm_zoom_to(dm_for_filter(), tf_3)

# FIXME: regarding PR #313: everything below this line needs to be at least reconsidered if not just dumped.

# for database tests -------------------------------------------------

# postgres needs to be cleaned of t?_2019_* tables for learn-test
get_test_tables_from_postgres <- function() {
  src_postgres <- my_test_src()
  con_postgres <- src_postgres$con

  con_postgres %>%
    dbGetQuery("SELECT table_name FROM information_schema.tables WHERE table_schema = 'public'") %>%
    as_tibble() %>%
    filter(grepl("^tf_[0-9]{1}_[0-9]{4}_[0-9]{2}_[0-9]{2}_[0-9]{2}_[0-9]{2}_[0-9]{2}_[0-9]+", table_name))
}

is_postgres_empty <- function() {
  nrow(get_test_tables_from_postgres()) == 0
}

clear_postgres <- function() {
  src_postgres <- my_test_src()
  con_postgres <- src_postgres$con

  walk(
    get_test_tables_from_postgres() %>%
      pull(),
    ~ dbExecute(con_postgres, glue("DROP TABLE {.x} CASCADE"))
  )
}
