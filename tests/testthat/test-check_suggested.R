test_that("`check_suggested()` works", {
  withr::local_envvar("TESTTHAT" = "")
  expect_snapshot({
    check_suggested("rlang", TRUE, top_level_fun = "foo")
    check_suggested("dm", NA, top_level_fun = "foo")
    check_suggested("iurtnkjvmomweicopbt", NA, top_level_fun = "foo")
    check_suggested("iurtnkjvmomweicopbt", NA)

    check_suggested("dm", FALSE, top_level_fun = "foo")
    check_suggested("iurtnkjvmomweicopbt", FALSE, top_level_fun = "foo")
    check_suggested("iurtnkjvmomweicopbt", FALSE)
  })
})

test_that("`check_suggested()` works for error messages", {
  withr::local_envvar("TESTTHAT" = "")
  expect_snapshot(error = TRUE, {
    check_suggested("iurtnkjvmomweicopbt", TRUE, top_level_fun = "foo")
    check_suggested("iurtnkjvmomweicopbt", TRUE)
  })
})


test_that("`check_suggested will skip.", {
  # this should be skipped.
  withr::with_envvar(c("TESTTHAT" = "true"),check_suggested("iurtnkjvmomweicopbt", TRUE, top_level_fun = "foo"))
  expect_equal("skipped", "not skipped")
})
