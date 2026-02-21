# Set up database-specific testing environment
local({
  # Override my_test_src_name for this file
  my_test_src_name <<- "{{DATABASE}}"

  # Override my_test_src_fun for this file
  my_test_src_fun <<- function() {
    get0("test_src_{{DATABASE}}", inherits = TRUE)
  }

  # Override my_test_src_cache for this file
  my_test_src_cache <<- function() {
    tryCatch(
      my_test_src_fun()(),
      error = function(e) {
        skip(paste0("Data source {{DATABASE}} not accessible: ", conditionMessage(e)))
      }
    )
  }

  # Override my_test_src for this file
  my_test_src <<- function() {
    testthat::skip_if_not_installed("dbplyr")

    fun <- my_test_src_fun()
    if (is.null(fun)) {
      skip(paste0("Data source not known: {{DATABASE}}"))
    }
    my_test_src_cache()
  }
})

test_that("dummy", {
  expect_snapshot({
    "dummy"
  })
})

test_that("dm_sql()", {
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
