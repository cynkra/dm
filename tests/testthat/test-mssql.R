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

test_that("copy_dm_to() loads tables larger than one chunk (#2467)", {
  # Need skip in every test block, unfortunately
  skip_if_src_not("mssql")

  dm <- dm(x = data.frame(a = 1:2500, b = as.character(1:2500)))

  # SQL Server loads in chunks of 1000 rows, other databases in one statement
  load <- dm_dml_load(dm, my_test_con())
  expect_length(load$x, if (is_mssql(my_test_con())) 3 else 1)

  dm_out <- copy_dm_to(my_test_con(), dm)
  out <- collect(dm_out$x)
  expect_equal(sort(out$a), dm$x$a)
  expect_equal(out$b[order(out$a)], dm$x$b)

  # Tables that fit into one chunk keep a single statement
  expect_s4_class(dm_dml_load(dm(x = data.frame(a = 1:1000)), my_test_con())$x, "SQL")
})

test_that("copy_dm_to() loads large tables with autoincrement keys in chunks (#2467)", {
  # Need skip in every test block, unfortunately
  skip_if_src_not("mssql")
  skip_if_not(is_mssql(my_test_con()))

  dm <-
    dm(x = data.frame(id = 1:2500, b = as.character(1:2500))) %>%
    dm_add_pk(x, id, autoincrement = TRUE)

  # Each chunk enables and disables explicit inserts into the identity column on its own
  load <- dm_dml_load(dm, my_test_con())
  expect_length(load$x, 3)
  expect_true(all(grepl("^SET IDENTITY_INSERT .* ON\n", unlist(load$x))))
  expect_true(all(grepl("\nSET IDENTITY_INSERT .* OFF$", unlist(load$x))))

  dm_out <- copy_dm_to(my_test_con(), dm)
  out <- collect(dm_out$x)
  expect_equal(sort(out$id), dm$x$id)
  expect_equal(out$b[order(out$id)], dm$x$b)
})
