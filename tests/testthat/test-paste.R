test_that("path argument", {
  path <- tempfile()
  dm() %>% dm_paste(path = path)
  expect_identical(readLines(path), c("dm::dm(", ")"))
})

test_that("output", {
  local_options(lifecycle_verbosity = "warning")

  expect_snapshot({
    "empty"
    empty_dm() %>% dm_paste()

    "empty table"
    dm(a = tibble()) %>% dm_paste(options = "tables")

    "baseline"
    dm_for_filter() %>% dm_paste()

    "changing the tab width"
    dm_for_filter() %>% dm_paste(tab_width = 4)

    "we don't care if the tables really exist"
    dm_for_filter() %>%
      dm_rename_tbl(tf_1_new = tf_1) %>%
      dm_paste()

    "produce `dm_select()` statements in addition to the rest"
    dm_for_filter() %>%
      dm_select(tf_5, k = k, m) %>%
      dm_select(tf_1, a) %>%
      dm(x = copy_to_my_test_src(tibble(q = 1L), qq)) %>%
      dm_paste(options = "select")

    "produce code with colors"
    dm_for_filter() %>%
      dm_set_colors("orange" = tf_1:tf_3, "darkgreen" = tf_5:tf_6) %>%
      dm_paste()

    "tick if needed"
    a <- tibble(x = 1)
    names(a) <- "a b"
    dm(a) %>%
      dm_zoom_to(a) %>%
      dm_insert_zoomed("a b") %>%
      dm_add_pk(a, "a b") %>%
      dm_add_fk("a b", "a b", a) %>%
      dm_set_colors(green = "a b") %>%
      dm_paste(options = "all")

    "FK referencing non default PK"
    b <- tibble(x = 1, y = "A", z = "A")
    c <- tibble(x = "A", y = "A")

    dm(b, c) %>%
      dm_add_pk(c, x) %>%
      dm_add_fk(b, y, c) %>%
      dm_add_fk(b, z, c, y) %>%
      dm_paste()

    # UKs
    dm_for_filter() %>%
      dm_add_uk(tf_5, l) %>%
      dm_add_uk(tf_6, n) %>%
      dm_paste()

    "on_delete if needed"
    dm(b, c) %>%
      dm_add_pk(c, x) %>%
      dm_add_fk(b, y, c, on_delete = "cascade") %>%
      dm_add_fk(b, z, c, y, on_delete = "no_action") %>%
      dm_paste()

    "all of nycflights13"
    dm_nycflights13() %>%
      dm_paste(options = "all")

    "deprecation warning for select argument"
    dm() %>%
      dm_paste(select = TRUE)

    "error for bad option"
    writeLines(conditionMessage(
      expect_error(dm_paste(dm(), options = c("bogus", "all", "mad")))
    ))
  })
})

test_that("output 2", {
  skip_if(getRversion() < "4.2")
  local_options(lifecycle_verbosity = "warning")

  expect_snapshot({
    "no error for factor column that leads to code with width > 500"
    dm(tibble(
      a = factor(
        levels = expand.grid(
          letters,
          as.character(1:5)
        ) %>%
          transmute(x = paste0(Var1, Var2)) %>%
          pull()
      )
    )) %>%
      dm_paste(options = "tables")
  })
})

test_that("chunking behavior for large dm", {
  # Test that dm_paste chunks long pipe chains to avoid stack overflow

  # Create a dm with many tables and foreign keys to trigger chunking
  create_large_dm <- function(n_tables = 55) {
    main_table <- tibble(id = integer(0))
    tables <- list(main = main_table)
    for (i in 1:n_tables) {
      table_name <- paste0("table_", i)
      tables[[table_name]] <- tibble(
        id = integer(0),
        main_id = integer(0)
      )
    }
    dm_obj <- do.call(dm, tables)
    dm_obj <- dm_obj %>% dm_add_pk(main, id)
    for (i in 1:n_tables) {
      table_name <- paste0("table_", i)
      dm_obj <- dm_obj %>%
        dm_add_pk(!!table_name, id) %>%
        dm_add_fk(!!table_name, main_id, main)
    }
    dm_obj
  }

  # Create a dm with 55 tables (generates 111 operations: 56 PKs + 55 FKs, exceeding the 100-op threshold)
  large_dm <- create_large_dm(55)

  # Use dm_paste_impl() directly, which returns the code as a character string
  code <- dm:::dm_paste_impl(large_dm, c("keys", "color"), 2)

  # Should generate more than 100 operations, triggering chunking
  expect_true(grepl("dm_step_1 <-", code))
  expect_true(grepl("dm_step_1 %>%", code))
})
