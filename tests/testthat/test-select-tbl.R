test_that("cdm_select_tbl() selects a part of a larger `dm` as a reduced `dm`?", {
  def <-
    dm_for_filter %>%
    cdm_rm_fk(t5, m, t6) %>%
    cdm_rm_fk(t2, d, t1) %>%
    cdm_get_def()

  dm_for_filter_smaller <- new_dm3(def[def$table %in% c("t1", "t6"), ])

  expect_equivalent_dm(
    cdm_select_tbl(dm_for_filter, -t2, -t3, -t4, -t5),
    dm_for_filter_smaller
  )
})

test_that("cdm_rename_tbl() renames a `dm`", {

  dm_rename <-
    as_dm(list(a = tibble(x = 1), b = tibble(y = 1))) %>%
    cdm_add_pk(b, y) %>%
    cdm_add_fk(a, x, b)

  dm_rename_a <-
    as_dm(list(c = tibble(x = 1), b = tibble(y = 1))) %>%
    cdm_add_pk(b, y) %>%
    cdm_add_fk(c, x, b)

  dm_rename_b <-
    as_dm(list(a = tibble(x = 1), e = tibble(y = 1))) %>%
    cdm_add_pk(e, y) %>%
    cdm_add_fk(a, x, e)

  dm_rename_bd <-
    as_dm(list(a = tibble(x = 1), d = tibble(y = 1))) %>%
    cdm_add_pk(d, y) %>%
    cdm_add_fk(a, x, d)

  expect_equivalent_dm(
    cdm_rename_tbl(dm_rename, c = a),
    dm_rename_a
  )

  expect_equivalent_dm(
    cdm_rename_tbl(dm_rename, e = b),
    dm_rename_b
  )

  skip("dm argument")
  expect_equivalent_dm(
    cdm_rename_tbl(dm_rename, d = b),
    dm_rename_bd
  )
})
