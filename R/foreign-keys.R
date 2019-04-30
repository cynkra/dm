#' Add a reference from one table of a `dm` to another
#'
#' @export
cdm_add_fk <- function(dm, table, column, ref_table, ref_column, set_ref_pk = FALSE) {
  table_name <- as_name(enquo(table))
  ref_table_name <- as_name(enquo(ref_table))

  column_name <- as_name(enexpr(column))
  ref_column_name <- as_name(enexpr(ref_column))

  check_correct_input(dm, table_name)
  check_correct_input(dm, ref_table_name)

  check_col_input(dm, table_name, column_name)
  check_col_input(dm, ref_table_name, ref_column_name)

  # ref_column has to be primary key of ref_table
  if (!set_ref_pk) {
    if (is_empty(cdm_get_pk(dm, !!ref_table_name)) ||
        !(cdm_get_pk(dm, !!ref_table_name) == ref_column_name)) {
      abort(paste0(
        "'", ref_column_name, "' needs to be primary key of '", ref_table_name,
        "' but isn't. You can set parameter 'set_ref_pk = TRUE', or use function",
        " cdm_add_pk() to set it as primary key.")
      )
    }
  } else {
    if (is_empty(cdm_get_pk(dm, !!table_name)) ||
        !(cdm_get_pk(dm, !!table_name) == ref_column_name)) {
      dm <- cdm_add_pk(dm, !!ref_table_name, eval_tidy(ref_column_name))
    }
  }

  tbl_obj <- cdm_get_tables(dm)[[table_name]]
  ref_tbl_obj <- cdm_get_tables(dm)[[ref_table_name]]

  if (!is_subset(tbl_obj, !! column_name, ref_tbl_obj, !! ref_column_name)) {
    abort(paste0(
      "Column `",
      column_name,
      "` in table `",
      table_name,
      "` contains values that are not present in column `",
      ref_column_name,
      "` in table `",
      ref_table_name,
      "`")
      )
  }

  cdm_add_fk_impl(dm, table_name, column_name, ref_table_name, ref_column_name)
}


cdm_add_fk_impl <- function(dm, table, column, ref_table, ref_column) {
  cdm_data_model <- cdm_get_data_model(dm)

  new_data_model <- upd_data_model_reference(cdm_data_model, table, column, ref_table, ref_column)

  new_dm(cdm_get_src(dm), cdm_get_tables(dm), new_data_model)
}

#' Does a reference from one table of a `dm` to another exist?
#'
#' @export
cdm_has_fk <- function(dm, table, ref_table) {
  table_name <- as_name(enquo(table))
  ref_table_name <- as_name(enquo(ref_table))

  check_correct_input(dm, table_name)
  check_correct_input(dm, ref_table_name)

  dm_data_model <- cdm_get_data_model(dm)
  any(dm_data_model$references$table == table_name & dm_data_model$references$ref == ref_table_name)
}

#' Retrieve the name of the column marked as foreign key, pointing from one table of a `dm` to another
#'
#' @export
cdm_get_fk <- function(dm, table, ref_table) {
  table_name <- as_name(enquo(table))
  ref_table_name <- as_name(enquo(ref_table))

  check_correct_input(dm, table_name)
  check_correct_input(dm, ref_table_name)

  dm_data_model <- cdm_get_data_model(dm)
  fk_ind <- dm_data_model$references$table == table_name & dm_data_model$references$ref == ref_table_name

  as.character(dm_data_model$references$column[fk_ind]) # FIXME: maybe something nicer?
}

#' Remove reference(s) from one table of a `dm` to another
#'
#' @details Can either remove one reference between the two tables or all at once if parameter `column = NULL`.
#' All parameters can be provided unquoted or quoted.'
#'
#' @export
cdm_rm_fk <- function(dm, table, column, ref_table) {

  table_name <- as_name(enquo(table))
  ref_table_name <- as_name(enquo(ref_table))

  check_correct_input(dm, eval_tidy(table_name))
  check_correct_input(dm, eval_tidy(ref_table_name))

  if (!cdm_has_fk(dm, !! table_name, !! ref_table_name)) {
    return(dm)
  }

  if (quo_is_null(enquo(column))) {
      col_names <- cdm_get_fk(dm, !! table_name, !! ref_table_name)
  } else {
    col_names <- as_name(enexpr(column))
    if (col_names == "") {
      abort("Parameter 'column' has to be set. 'NULL' for removing all references.")
    }
  }

  if (!(all(col_names %in% cdm_get_fk(dm, !! table_name, !! ref_table_name)))) {
    abort(paste0("The given column '",
                 paste0(col_names, collapse = ", "),
                 "' is not a foreign key column of table '",
                 table_name,
                 "' with regards to ref_table '",
                 ref_table_name,
                 "'. Foreign key columns are: '",
                 paste0(cdm_get_fk(dm, !! table_name, !! ref_table_name), collapse = ", "), "'.")
          )
  }

  dm$data_model <-
    rm_data_model_reference(
      cdm_get_data_model(dm),
      table_name,
      col_names,
      ref_table_name
      )

  dm
}

#' Find foreign key candidates in a table
#'
#' @description Which columns are foreign candidates of a table, referencing the primary key column of another `dm`-object's table?
#' `cdm_check_for_fk_candidates()` checks first, if `ref_table` has a primary key set. Then it determines
#' for each column of `table`, if this column contains only a subset of values of the primary key column of
#' `ref_table` and is therefore a candidate for a foreign key from `table` to `ref_table`.
#'
#' @examples
#' \dontrun{
#' library(nycflights13)
#' library(dplyr)
#'
#' nycflights_dm <- dm(src_df(pkg = "nycflights13"))
#'
#' nycflights_dm %>%
#'   cdm_add_pk(airports, faa) %>%
#'   cdm_check_for_fk_candidates(flights, airports)
#' }
#'
#' @export
cdm_check_for_fk_candidates <- function(dm, table, ref_table) {

  table_name <- as_name(enquo(table))
  ref_table_name <- as_name(enquo(ref_table))

  check_correct_input(dm, table_name)
  check_correct_input(dm, ref_table_name)

  if (!cdm_has_pk(dm, !! ref_table_name)) {
    abort(
      paste0("ref_table '", ref_table_name, "' needs a primary key first.",
             " Candidates are: '",
             paste0(
               cdm_check_for_pk_candidates(dm, !! ref_table_name) %>%
                 filter(candidate == TRUE) %>%
                 pull(column),
               collapse = ", "
               ),
             "'. Use 'cdm_add_pk()' to set it.")
    )
  }

  tbl <- cdm_get_tables(dm)[[table_name]]
  tbl_colnames <- colnames(tbl)

  ref_tbl <- cdm_get_tables(dm)[[ref_table_name]]
  ref_tbl_pk <- cdm_get_pk(dm, !! ref_table_name)

  map_dfr(tbl_colnames,
          ~ {
            if (is_subset(tbl,!!.x, ref_tbl,!!ref_tbl_pk)) {
              tibble(
                candidate = TRUE,
                column = .x,
                table = table_name,
                ref_table = ref_table_name,
                ref_table_pk = ref_tbl_pk
              )
            } else {
              tibble(
                candidate = FALSE,
                column = .x,
                table = table_name,
                ref_table = ref_table_name,
                ref_table_pk = ref_tbl_pk
              )
            }
          })
}
