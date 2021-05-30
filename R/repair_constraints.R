#' Repair a data model's constraints
#'
#' @param dm A dm object
#' @param fk_repair Either `"add"` or `"delete"`, `"add"` will update
#'   the parent table by adding the missing primary keys while `"delete"`
#'   will remove from the child table the rows featuring the orphan foreign keys.
#' @inheritParams dm_examine_constraints
#' @inheritParams dplyr::rows_insert
#'
#' @return a dm
#' @export
#'
#' @examples
#' nycflights <- dm_nycflights13()
#'
#' repaired_add <-
#'   nycflights %>%
#'   dm_repair_constraints("add")
#'
#' repaired_delete <-
#'   nycflights %>%
#'   dm_repair_constraints("delete")
#'
#' nrow(nycflights$planes)
#' nrow(nycflights$flights)
#'
#' # we have more planes, and the same amount of flights
#' nrow(repaired_add$planes)
#' nrow(repaired_add$flights)
#'
#'
#' # we (should) have the same amount of planes, and fewer flights
#' nrow(repaired_delete$planes)
#' nrow(repaired_delete$flights) # this is not right
#'
#'
dm_repair_constraints <- function(dm,
                                  fk_repair = c("insert", "delete"),
                                  progress = NA,
                                  in_place = NULL) {
  fk_repair <- match.arg(fk_repair)
  # TODO : pk_repair
  check_not_zoomed(dm)
  constraints <-
    dm_examine_constraints_impl(dm, progress = progress, fk_repair = fk_repair)
  plans <- compact(constraints$repair_plan)

  reduce(plans, dm_apply_repair_plan, .init = dm, in_place = in_place)
}


new_repair_plan <- function(insert = NULL, update = NULL, delete = NULL) {
  structure(lst(insert, update, delete), class = "dm_repair_plan")
}


dm_apply_repair_plan <- function(dm, plan, in_place = NULL) {
  # TODO : implement progress argument once dm_rows_* functions are given progress bars
  # progress <- check_progress(progress)

  # TODO : Emit message only once (also fix in the current implementation?)
  if (is_null(in_place)) {
    message("Not persisting, use `in_place = FALSE` to turn off this message.")
    in_place <- FALSE
  }

  out <- dm
  if (!is.null(plan$insert)) {
    # TODO: find a way to remove "Matching, by =" message due to `dm_rows_run` and `rows_insert.tbl_dbi`
    suppressMessages(out <- dm_rows_insert(dm, plan$insert, in_place = in_place))
  }
  if (!is.null(plan$update)) {
    # not used atm
    out <- dm_rows_update(dm, plan$update, in_place = in_place)
  }
  if (!is.null(plan$delete)) {
    # primary keys must exist in order to delete rows
    suppressMessages(out <- dm_rows_insert(dm, plan$delete, in_place = in_place))
    # I expected this to remove rows in linked fact tables, it doesn't
    out <- dm_rows_delete(out, plan$delete, in_place = in_place)
  }
  if (in_place) out else invisible(out)
}
