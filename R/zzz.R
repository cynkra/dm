.onLoad <- function(libname, pkgname) {
  backports::import(pkgname, c("...length"))
}
