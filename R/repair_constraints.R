new_repair_plan <- function(problem = "", repair_tbl_name = NA, repair_tbl_obj = tibble(), repair = NULL) {
  if (is.null(repair)) {
    out <- structure(
      lst(problem),
      class = c("dm_repair_plan", "tbl_df", "tbl", "data.frame"),
      row.names = 0L
    )
    return(out)
  }
  structure(
    lst(problem, repair_tbl_name, repair_tbl_obj = list(repair_tbl_obj), repair),
    class = c("dm_repair_plan", "tbl_df", "tbl", "data.frame"),
    row.names = 0L
  )
}
