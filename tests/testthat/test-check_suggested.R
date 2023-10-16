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
    # A message
    rlang::local_interactive(TRUE)
    check_suggested(c("iurtnkjvmomweicopbt (>= 0.5)", "xxx", "cli"), NA, top_level_fun = "foo")
  })
})


test_that("`check_suggested will skip.", {
  # this should be skipped.
  check_suggested("iurtnkjvmomweicopbt", TRUE, top_level_fun = "foo")
  # Catching an error if it is not skipped.
  expect_equal("skipped", "not skipped")
})
