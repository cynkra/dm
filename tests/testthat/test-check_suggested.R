test_that("`check_suggested()` works", {
  expect_snapshot({
    check_suggested("dm", TRUE, top_level_fun = "foo")

    check_suggested("dm", NA, top_level_fun = "foo")
    check_suggested("iurtnkjvmomweicopbt", NA, top_level_fun = "foo")
    check_suggested("iurtnkjvmomweicopbt", NA, message = "not installed!")

    check_suggested("dm", FALSE, top_level_fun = "foo")
    check_suggested("iurtnkjvmomweicopbt", FALSE, top_level_fun = "foo")
    check_suggested("iurtnkjvmomweicopbt", FALSE, message = "not installed!")
  })
})

test_that("`check_suggested()` works for error messages", {
  expect_snapshot(error = TRUE, {
    check_suggested("iurtnkjvmomweicopbt", TRUE, top_level_fun = "foo")
    check_suggested("iurtnkjvmomweicopbt", TRUE, message = "not installed!")
  })
})
