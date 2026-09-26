# Creates the root of a package named `package`, only the `DESCRIPTION` matters here
local_package_root <- function(package, .local_envir = parent.frame()) {
  root <- withr::local_tempdir(.local_envir = .local_envir)
  writeLines(paste0("Package: ", package), file.path(root, "DESCRIPTION"))
  root
}

test_that("`is_pkgdown_dm()` is FALSE outside of pkgdown", {
  withr::local_envvar(IN_PKGDOWN = NA)
  withr::local_dir(local_package_root("dm"))

  expect_false(is_pkgdown_dm())
})

test_that("`is_pkgdown_dm()` is FALSE when pkgdown builds another package (#2194)", {
  withr::local_envvar(IN_PKGDOWN = "true")
  withr::local_dir(local_package_root("dependsondm"))

  expect_false(is_pkgdown_dm())
})

test_that("`is_pkgdown_dm()` is TRUE when pkgdown builds dm", {
  withr::local_envvar(IN_PKGDOWN = "true")
  withr::local_dir(local_package_root("dm"))

  expect_true(is_pkgdown_dm())
})

test_that("`is_pkgdown_dm()` is silent and FALSE without a readable `DESCRIPTION`", {
  withr::local_envvar(IN_PKGDOWN = "true")
  withr::local_dir(withr::local_tempdir())

  expect_false(expect_silent(is_pkgdown_dm()))
})
