#' Browse package documentation
#'
#' Opens the documentation website in a browser.
#'
#' @keywords internal
#'
#' @return Opens the {dm}-website as a side effect
#'
#' @examples
#' browse_docs()
#'
#' @export
browse_docs <- function() {
  utils::browseURL("https://krlmlr.github.io/dm/")
}
