test_that("dummy", {
  expect_snapshot({
    "dummy"
  })
})

test_that("dm_sql()", {
  # Need skip in every test block, unfortunately
  skip_if_src_not("mssql")

  # https://github.com/tidyverse/dbplyr/pull/1190
  skip_if(is(my_test_con(), "MySQLConnection"))

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

test_that("long text columns with copy_dm_to()", {
  # Need skip in every test block, unfortunately
  skip_if_src_not("mssql")

  dm <- dm(x = data.frame(a = strrep("x", 300)))
  dm_out <- copy_dm_to(my_test_con(), dm)
  expect_equal(collect(dm_out$x)$a, dm$x$a)
  dm_out_out <- copy_dm_to(my_test_con(), dm_out)
  expect_equal(collect(dm_out_out$x)$a, dm$x$a)

  dm <- dm(x = data.frame(a = strrep("x", 10000)))
  dm_out <- copy_dm_to(my_test_con(), dm)
  expect_equal(collect(dm_out$x)$a, dm$x$a)
  dm_out_out <- copy_dm_to(my_test_con(), dm_out)
  expect_equal(collect(dm_out_out$x)$a, dm$x$a)
})
