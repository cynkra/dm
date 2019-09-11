test_that("`cdm_flatten_to_tbl()` does the right thing", {
  map(
    dm_for_flatten_src,
    ~expect_equivalent(
      cdm_flatten_to_tbl(., fact) %>% collect(),
      result_from_flatten
    )
  )
})
