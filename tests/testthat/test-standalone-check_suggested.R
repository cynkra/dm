test_that("`check_suggested()` works", {
  withr::local_envvar("TESTTHAT" = "")
  expect_snapshot({
    check_suggested("rlang", "foo")
    check_suggested("dm", "foo", use = NA)
    check_suggested("iurtnkjvmomweicopbt", "foo", use = NA)
    check_suggested("iurtnkjvmomweicopbt", use = NA)

    check_suggested("dm", "foo", use = FALSE)
    check_suggested("iurtnkjvmomweicopbt", "foo", use = FALSE)
    check_suggested("iurtnkjvmomweicopbt", use = FALSE)
  })
})

test_that("`check_suggested()` works for error messages", {
  withr::local_envvar("TESTTHAT" = "")
  expect_snapshot(error = TRUE, {
    check_suggested("iurtnkjvmomweicopbt", "foo")
  })
  expect_snapshot({
    # A message
    rlang::local_interactive(TRUE)
    check_suggested(c("iurtnkjvmomweicopbt (>= 0.5)", "xxx", "cli"), "foo", use = NA)
  })
})


test_that("`check_suggested()` will skip.", {
  # this should be skipped.
  check_suggested("iurtnkjvmomweicopbt", "foo")
  # Catching an error if it is not skipped.
  expect_equal("skipped", "not skipped")
})
