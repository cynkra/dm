test_that("cdm_zoom_to_tbl() works", {

  # no zoom in unzoomed `dm`
  expect_false(
    is_zoomed(dm_for_filter)
  )

  # zoom in zoomed `dm`
  expect_true(
    is_zoomed(dm_for_filter %>% cdm_zoom_to_tbl(t1))
  )

  expect_s3_class(
    dm_for_filter %>% cdm_zoom_to_tbl(t3),
    c("zoomed_dm", "dm")
  )
})


test_that("cdm_zoom_out() works", {
  # no zoom in zoomed out from zoomed `dm`
  expect_false(is_zoomed(dm_for_filter %>% cdm_zoom_to_tbl(t1) %>% cdm_zoom_out()))

  expect_s3_class(
    dm_for_filter %>% cdm_zoom_to_tbl(t3) %>% cdm_zoom_out(),
    c("dm")
  )
})

# FIXME: works when actively testing, but not for R CMD check
# test_that("print() and format() methods for subclass `zoomed_dm` work", {
#   expect_output(
#     dm_for_filter %>% cdm_zoom_to_tbl(t5) %>% print(),
#     "# A zoomed table of a `dm`: t5"
#   )
#
#   expect_output(
#     dm_for_filter %>% cdm_zoom_to_tbl(t2) %>% format(),
#     "# A zoomed table of a `dm`: t2"
#   )
# })


test_that("cdm_get_zoomed_tbl() works", {
# get zoomed tbl works
  expect_identical(
    dm_for_filter %>% cdm_zoom_to_tbl(t2) %>% cdm_get_zoomed_tbl(),
    tibble(table = "t2",
           zoom = list(t2))
  )

# function for getting only the tibble itself works
  expect_identical(
    dm_for_filter %>% cdm_zoom_to_tbl(t3) %>% get_zoomed_tbl(),
    t3
  )

})

test_that("zooming works also on DBs", {
  walk(
    dm_for_filter_src,
    ~expect_identical(
      cdm_zoom_to_tbl(., t3) %>% cdm_get_zoomed_tbl(),
      tibble(table = "t3",
             zoom = list(tbl(., "t3"))
             )
      )
  )
})

test_that("cdm_insert_tbl() works", {
  # test that a new tbl is inserted, based on the requested one
  expect_equivalent_dm(
    cdm_zoom_to_tbl(dm_for_filter, t4) %>% cdm_insert_zoomed_tbl(t4_new),
    dm_for_filter %>% cdm_add_tbl(t4_new = t4)
  )
})

test_that("cdm_update_tbl() works", {
  # setting table t7 as zoomed table for t3 and removing its primary key and foreign keys pointing to it
  skip("test needs PR #105 in order to work")
  new_dm_for_filter <- cdm_get_def(dm_for_filter) %>%
    mutate(
      zoom = if_else(table == "t3", list(t7), NULL),
      pks = if_else(table == "t3", vctrs::list_of(new_pk()), pks),
      fks = if_else(table == "t3", vctrs::list_of(new_fk()), fks)) %>%
    new_dm3()

  # test that the old table is updated correctly
  expect_equivalent_dm(
    cdm_update_zoomed_tbl(new_dm_for_filter),
    dm_for_filter %>%
      cdm_rm_tbl(t3) %>%
      cdm_add_tbl(t3 = t7) %>%
      # FIXME: with PR #106 this would be much easier
      cdm_get_def() %>%
      arrange(c(1, 2, 6, 4, 5)) %>%
      new_dm3()
  )
})
