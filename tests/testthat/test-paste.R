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
    dm(tibble(a = factor(levels = expand.grid(
      letters, as.character(1:5)
    ) %>%
      transmute(x = paste0(Var1, Var2)) %>%
      pull()))) %>%
      dm_paste(options = "tables")
  })
})

test_that("dm_paste() handles very long pipe chains without C stack error", {
  # Test for issue #400: dm_paste() generates pipes that are too long
  # This test verifies that the issue has been resolved or demonstrates the scale of the problem
  
  # Create many small tables with relationships to create a very long pipe chain
  tables <- map(1:150, ~ tibble(
    id = 1:3,
    parent_id = if (.x > 1) rep(1:3, length.out = 3) else NA_integer_,
    value = paste0("table_", .x, "_row_", 1:3)
  ))
  names(tables) <- paste0("table_", 1:150)
  
  # Create the dm with all tables
  large_dm <- do.call(dm, tables)
  
  # Add primary keys to all tables (this will create many dm_add_pk() statements)
  for (i in 1:150) {
    large_dm <- dm_add_pk(large_dm, !!sym(paste0("table_", i)), id)
  }
  
  # Add foreign keys from each table to the previous one (creates many dm_add_fk() statements)
  for (i in 2:150) {
    large_dm <- dm_add_fk(
      large_dm, 
      !!sym(paste0("table_", i)), 
      parent_id, 
      !!sym(paste0("table_", i - 1))
    )
  }
  
  # This generates a very long pipe chain with 150 + 149 = 299 pipe operations
  # In the past this would have caused "Error: C stack usage ... is too close to the limit"
  # Now it should succeed, which indicates the issue has been resolved
  expect_no_error({
    dm_paste(large_dm)
  })
  
  # To verify the scale of the pipe chain, capture the output to a file and count pipes
  temp_file <- tempfile()
  dm_paste(large_dm, path = temp_file)
  result_code <- readLines(temp_file)
  result_string <- paste(result_code, collapse = "\n")
  pipe_count <- stringr::str_count(result_string, "%>%")
  
  # Should have around 299 pipes (150 PKs + 149 FKs, minus 1 for the base dm() call)
  expect_gt(pipe_count, 250)
  
  # Clean up
  unlink(temp_file)
})
