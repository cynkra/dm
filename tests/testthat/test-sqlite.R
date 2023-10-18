test_that("dummy", {
  expect_snapshot({
    "dummy"
  })
})

test_that("dm_sql()", {
  # Need skip in every test block, unfortunately
  skip_if_src_not("sqlite")

  # https://github.com/tidyverse/dbplyr/pull/1190
  skip_if(is(my_test_con(), "MySQLConnection") && packageVersion("dbplyr") < "2.4.0")

  expect_snapshot({
    dm_for_filter_df() %>%
      dm_sql(my_test_con())
  })

  expect_snapshot({
    dm(x = data.frame(a = strrep("x", 300))) %>%
      dm_sql(my_test_con())
  })

  expect_snapshot({
    dm(x = data.frame(a = strrep("x", 10000))) %>%
      dm_sql(my_test_con())
  })
})
