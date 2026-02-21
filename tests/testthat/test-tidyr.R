test_that("basic test: 'unite()'-methods work", {
  # see issue #361
  skip_if_remote_src()
  expect_equivalent_tbl(
    dm_zoomed() %>%
      unite("new_col", c, e) %>%
      tbl_zoomed(),
    unite(tf_2(), "new_col", c, e)
  )

  expect_equivalent_tbl(
    dm_for_filter() %>%
      pull_tbl(tf_2, keyed = TRUE) %>%
      unite("new_col", c, e) %>%
      unclass_keyed_tbl(),
    unite(tf_2(), "new_col", c, e)
  )

  expect_dm_error(
    unite(dm_for_filter()),
    "only_possible_w_zoom"
  )
})

test_that("basic test: 'separate()'-methods work", {
  skip_if_remote_src()
  expect_equivalent_tbl(
    dm_zoomed() %>%
      unite("new_col", c, e) %>%
      separate("new_col", c("c", "e")) %>%
      select(c, d, e, e1) %>%
      tbl_zoomed(),
    tf_2()
  )

  expect_equivalent_tbl(
    dm_for_filter() %>%
      pull_tbl(tf_2, keyed = TRUE) %>%
      unite("new_col", c, e) %>%
      separate("new_col", c("c", "e")) %>%
      select(c, d, e, e1),
    dm_for_filter() %>%
      pull_tbl(tf_2, keyed = TRUE)
  )

  expect_dm_error(
    separate(dm_for_filter()),
    "only_possible_w_zoom"
  )
})

test_that("key tracking works", {
  skip_if_remote_src()
  expect_snapshot({
    dm_zoomed() %>%
      unite("new_col", c, e) %>%
      dm_update_zoomed() %>%
      get_all_keys()

    dm_zoomed() %>%
      unite("new_col", c, e, remove = FALSE) %>%
      dm_update_zoomed() %>%
      get_all_keys()

    dm_zoomed() %>%
      unite("new_col", c, e, remove = FALSE) %>%
      dm_update_zoomed() %>%
      dm_add_fk(tf_2, new_col, tf_6) %>%
      dm_zoom_to(tf_2) %>%
      separate(new_col, c("c", "e"), remove = TRUE) %>%
      dm_update_zoomed() %>%
      get_all_keys()

    dm_zoomed() %>%
      unite("new_col", c, e, remove = FALSE) %>%
      dm_update_zoomed() %>%
      dm_add_fk(tf_2, new_col, tf_6) %>%
      dm_zoom_to(tf_2) %>%
      separate(new_col, c("c", "e"), remove = FALSE) %>%
      dm_update_zoomed() %>%
      get_all_keys()
  })
})


# tests for compound keys -------------------------------------------------

test_that("output for compound keys", {
  # FIXME: COMPOUND: Need proper test
  skip_if_remote_src()

  expect_snapshot({
    unite_weather_dm <-
      nyc_comp() %>%
      dm_zoom_to(weather) %>%
      mutate(chr_col = "airport") %>%
      unite("new_col", origin, chr_col) %>%
      dm_update_zoomed()
    unite_weather_dm %>% get_all_keys()
    unite_weather_dm %>% get_all_keys()
    unite_flights_dm <-
      nyc_comp() %>%
      dm_zoom_to(flights) %>%
      mutate(chr_col = "airport") %>%
      unite("new_col", origin, chr_col) %>%
      dm_update_zoomed()
    unite_flights_dm %>% get_all_keys()
    unite_flights_dm %>% get_all_keys()
    nyc_comp() %>%
      dm_zoom_to(weather) %>%
      separate(origin, c("o1", "o2"), sep = "^..", remove = TRUE) %>%
      dm_update_zoomed()
    nyc_comp() %>%
      dm_zoom_to(weather) %>%
      separate(origin, c("o1", "o2"), sep = "^..", remove = FALSE) %>%
      dm_update_zoomed()
  })
})

# Signature alignment tests ------------------------------------------------

test_that("dm tidyr method signatures match tidyr data.frame method signatures", {
  skip_on_cran()

  tidyr_ns <- asNamespace("tidyr")
  dm_ns <- asNamespace("dm")

  verbs <- c("unite", "separate")

  for (verb in verbs) {
    df_method <- tryCatch(
      get(paste0(verb, ".data.frame"), envir = tidyr_ns),
      error = function(e) NULL
    )
    if (is.null(df_method)) {
      next
    }

    df_args <- names(formals(df_method))

    for (cls in c("dm", "dm_zoomed", "dm_keyed_tbl")) {
      method_name <- paste0(verb, ".", cls)
      dm_method <- tryCatch(
        get(method_name, envir = dm_ns),
        error = function(e) NULL
      )
      if (is.null(dm_method)) {
        next
      }

      dm_args <- names(formals(dm_method))
      missing_args <- setdiff(df_args, dm_args)
      expect_true(
        length(missing_args) == 0,
        label = paste0(
          method_name,
          " is missing args from ",
          verb,
          ".data.frame: ",
          paste(missing_args, collapse = ", ")
        )
      )
    }
  }
})
