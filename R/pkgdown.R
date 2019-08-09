#' Browse package documentation
#'
#' Opens the documentation website in a browser.
#'
#' @importFrom pkgdown preview_site
#' @keywords internal
#' @export
browse_docs <- function() {
  pkgdown::preview_site()
}
