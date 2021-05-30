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
#' # The dm doesn't satisfy its constraints
#' dm_examine_constraints(nycflights)
#'
#' repaired_insert <-
#'   nycflights %>%
#'   dm_repair_constraints("insert")
#'
#' repaired_delete <-
#'   nycflights %>%
#'   dm_repair_constraints("delete")
#'
#' # both repaired dms satisfy all constraints
#' dm_examine_constraints(repaired_insert)
#' dm_examine_constraints(repaired_delete)
#'
#' # but we have more planes in repaired_insert and less flights in repaired_delete
#' nrow(nycflights$planes)
#' nrow(nycflights$flights)
#'
#' nrow(repaired_insert$planes)
#' nrow(repaired_insert$flights)
#'
#' nrow(repaired_delete$planes)
#' nrow(repaired_delete$flights)
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

anti_join_in_place <- function(dm, tbl, tbl_nm) {
  cond <- imap(collect(tbl), ~ map(.x, ~ call("==", sym(.y), .x), .y))
  cond <- pmap(cond, ~ reduce(list(...), ~ call("(", call("&", .x, .y))))
  cond <- reduce(cond, ~ call("|", .x, .y))
  sql_cond <- dbplyr::translate_sql(!!cond)

  con <- dm_get_con(dm)
  query <- glue("DELETE FROM {tbl_nm} WHERE {sql_cond}")
  n <- DBI::dbExecute(con, query)
  # message(glue("{n} rows were removed"))
  # synchronize dm
  dm_mutate_tbl(dm, !!sym(tbl_nm) := tbl(con, tbl_nm))
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

  if (!is.null(plan$delete)) {
    # primary keys must exist in order to delete rows
    # suppressMessages(out <- dm_rows_insert(dm, plan$delete, in_place = in_place))
    # I expected this to remove rows in linked fact tables, it doesn't
    tbl_nm <- names(plan$delete)
    tbl <- plan$delete[[tbl_nm]]

    src <- dm_get_src_impl(dm)
    if (!is.null(src) & in_place)  {
        # persistent anti join
        out <- anti_join_in_place(dm, tbl, tbl_nm)
      } else {
        # non persistent anti join
        out <- dm %>%
          dm_mutate_tbl(!!sym(tbl_nm) := anti_join(.[[tbl_nm]], tbl, copy = TRUE, by = names(tbl)))
      }
  }
  out
}


