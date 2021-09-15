test_that("`check_suggested()` works", {
  expect_snapshot({
    check_suggested("dm", TRUE, top_level_fun = "foo")
    try(check_suggested("not-a-package", TRUE, top_level_fun = "foo"))
    try(check_suggested("not-a-package", TRUE, message = "not installed!"))

    check_suggested("dm", NA, top_level_fun = "foo")
    check_suggested("not-a-package", NA, top_level_fun = "foo")
    check_suggested("not-a-package", NA, message = "not installed!")

    check_suggested("dm", FALSE, top_level_fun = "foo")
    check_suggested("not-a-package", FALSE, top_level_fun = "foo")
    check_suggested("not-a-package", FALSE, message = "not installed!")
  })
})
