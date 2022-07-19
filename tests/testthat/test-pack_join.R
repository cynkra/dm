test_that("`pack_join()` works", {
  df1 <- tibble(col1 = 1:2, key = letters[1:2])
  df2 <- tibble(col2 = 3:4, key = letters[1:2])
  df3 <- tibble(col3 = 3:4, key3 = letters[1:2])
  expect_snapshot(pack_join(df1, df2))
  expect_snapshot(pack_join(df1, df2, name = "packed_col"))
  expect_snapshot(pack_join(df1, df3, by = c(key = "key3")))
  expect_snapshot(pack_join(df1, df3, by = c(key = "key3"), keep = TRUE))


  # fails with remote table
  dm_fin <- skip_if_error(dm_financial_sqlite())
  expect_snapshot_error(pack_join(df1, dm_fin$accounts, by = c(col1 = "id")))
  # unless copy = TRUE
  expect_snapshot(pack_join(df1, dm_fin$accounts, by = c(col1 = "id"), copy = TRUE))

  # when we have conflicting columns, the column in x is overwritten silently
  # consistent with dplyr::nest_join
  df4 <- tibble(df5 = integer())
  df5 <- tibble(col = integer())
  expect_snapshot(pack_join(df4, df5, by = c(df5 = "col")))

  # No conflict occurs when packing `y` before the join
  df6 <- tibble(df6 = integer())
  expect_snapshot(pack_join(df5, df6, by = c(col = "df6")))
})

test_that("`pack_join()` works with zoomed_dm", {
  dm_nyc <- dm_nycflights13()

  name_packed_df <- "packed_flights"
  by_column <- "carrier"

  dm_nyc_new <- dm_nyc %>%
    dm_zoom_to(airlines) %>%
    pack_join(flights, by = by_column, name = name_packed_df) %>%
    dm_update_zoomed()

  # key relations should stay the same after packing
  expect_equal(get_all_keys(dm_nyc), get_all_keys(dm_nyc_new))

  # the new table should have only one additional (packed) column
  expect_equal(colnames(dm_nyc_new$airlines), c(colnames(dm_nyc$airlines), name_packed_df))

  # the packed table should have the same number of rows as the unpacked one
  expect_equal(nrow(dm_nyc_new$airlines$packed_flights), nrow(dm_nyc$flights))

  # but it should have fewer columns
  expect_equal(
    setdiff(colnames(dm_nyc$flights), colnames(dm_nyc_new$airlines$packed_flights)),
    by_column
  )
})
