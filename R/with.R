#' Among others: address table by their unquoted name
#' @description FIXME: missing description
#' @export
#' @examples
#' cdm_with(cdm_nycflights13(), airports)
cdm_with <- function(dm, code) {
  quo <- enquo(code)
  tables <- map(set_names(src_tbls(dm)), ~ tbl(dm, .))
  eval_tidy(quo, data = tables)
}
