#' Browse package documentation
#'
#' Opens the documentation website in a browser.
#'
#' @importFrom utils browseURL packageName head
#' @keywords internal
#' @export
browse_docs <- function() {
  path <- get_docs_path()
  browseURL(path)
}

get_docs_path <- function() {
  system.file(package = packageName(), "pkgdown", "index.html")
}
