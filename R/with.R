#' Among others: address table by their unquoted name
#'
#' @param dm A [`dm`] object.
#' @param code An expression to evaluate in the context of the [`dm`] object.
#'
#' @description FIXME: missing description
#' @export
#' @examples
#' cdm_with(cdm_nycflights13(), airports)
cdm_with <- function(dm, code) {
  quo <- enquo(code)
  tables <- map(set_names(src_tbls(dm)), ~ tbl(dm, .))
  eval_tidy(quo, data = tables)
}
