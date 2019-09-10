test_that("`cdm_flatten()` does the right thing", {
  map(
    dm_for_flatten_src,
    ~expect_equivalent(
      cdm_flatten(.) %>% collect(),
      result_from_flatten
    )
  )
})
