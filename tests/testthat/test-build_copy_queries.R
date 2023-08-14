test_that("build_copy_queries snapshot test for pixarfilms", {
  src_db <- my_db_test_src()

  # build regular dm from `dm_pixarfilms()`
  pixar_dm <-
    # fetch sample dm
    dm_pixarfilms() %>%
    # make it regular
    dm_filter(pixar_films = (!is.na(film))) %>%
    dm_select_tbl(-pixar_people)

  skip_if_not_installed("testthat", "3.1.1")

  expect_snapshot(
    variant = my_test_src_name,
    {
      pixar_dm %>%
        build_copy_queries(
          src_db,
          .
        ) %>%
        as.list() # to print full queries
    }
  )
})


test_that("build_copy_queries snapshot test for dm_for_filter()", {
  src_db <- my_db_test_src()

  skip_if_not_installed("testthat", "3.1.1")

  expect_snapshot(
    variant = my_test_src_name,
    {
      dm_for_filter() %>%
        build_copy_queries(
          src_db,
          .
        ) %>%
        as.list() # to print full queries
    }
  )
})


test_that("build_copy_queries avoids duplicate indexes", {
  src_db <- my_db_test_src()

  # build a dm whose index might be duplicated if naively build (child__a__key)
  ambiguous_dm <- dm(
    parent1 = tibble(key = 1),
    parent2 = tibble(a__key = 1),
    child = tibble(a__key = 1),
    child__a = tibble(key = 1)
  ) %>%
    dm_add_pk(parent1, key) %>%
    dm_add_pk(parent2, a__key) %>%
    dm_add_fk(child, a__key, parent2) %>%
    dm_add_fk(child__a, key, parent2)

  queries <-
    build_copy_queries(
      src_db,
      ambiguous_dm,
      table_names =
        names(ambiguous_dm) %>%
          repair_table_names_for_db(temporary = FALSE, con = src_db, schema = NULL)
    )

  expect_equal(anyDuplicated(unlist(queries$index_name)), 0)

  skip_if_not_installed("testthat", "3.1.1")

  expect_snapshot(
    variant = my_test_src_name,
    {
      as.list(queries)
    }
  )
})
