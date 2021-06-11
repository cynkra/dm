#' Validate your data model
#'
#' This function returns a tibble with information about
#' which key constraints are met (`is_key = TRUE`) or violated (`FALSE`).
#' The printing for this object is special, use [as_tibble()]
#' to print as a regular tibble.
#'
#' @inheritParams dm_add_pk
#' @param progress Whether to display a progress bar, if `NA` (the default)
#'   hide in non-interactive mode, show in interactive mode. Requires the
#'   'progress' package.
#'
#' @return A tibble with the following columns:
#'   \describe{
#'     \item{`table`}{the table in the `dm`,}
#'     \item{`kind`}{"PK" or "FK",}
#'     \item{`columns`}{the table columns that define the key,}
#'     \item{`ref_table`}{for foreign keys, the referenced table,}
#'     \item{`is_key`}{logical,}
#'     \item{`problem`}{if `is_key = FALSE`, the reason for that.}
#'   }
#'
#' @details For the primary key constraints, it is tested if the values in the respective columns are all unique.
#' For the foreign key constraints, the tests check if for each foreign key constraint, the values of the foreign key column
#' form a subset of the values of the referenced column.
#'
#' @export
#' @examplesIf rlang::is_installed("nycflights13")
#' dm_nycflights13() %>%
#'   dm_examine_constraints()
dm_examine_constraints <- function(dm, progress = NA) {
  check_not_zoomed(dm)
  dm %>%
    dm_examine_constraints_impl(progress = progress) %>%
    rename(columns = column) %>%
    mutate(columns = new_keys(columns)) %>%
    new_dm_examine_constraints()
}

dm_examine_constraints_impl <- function(dm, progress = NA) {
  pk_results <- check_pk_constraints(dm, progress)
  fk_results <- check_fk_constraints(dm, progress)
  bind_rows(
    pk_results,
    fk_results
  ) %>%
    arrange(is_key, desc(kind), table)
}

new_dm_examine_constraints <- function(x) {
  class(x) <- c("dm_examine_constraints", class(x))
  x
}

#' @export
print.dm_examine_constraints <- function(x, ...) {
  key_df <-
    x %>%
    as_tibble()
  problem_df <-
    key_df %>%
    filter(problem != "")

  if (nrow(key_df) == 0) {
    cli::cli_alert_info("No constraints defined.")
  } else if (nrow(problem_df) == 0) {
    cli::cli_alert_info("All constraints satisfied.")
  } else {
    cli::cli_alert_warning("Unsatisfied constraints:")

    problem_df %>%
      mutate(
        into = if_else(kind == "FK", paste0(" into table ", tick(ref_table)), "")
      ) %>%
      # FIXME: Use cli styles
      mutate(text = paste0(
        "Table ", tick(table), ": ",
        kind_to_long(kind), " ", format(columns),
        into,
        ": ", problem
      )) %>%
      pull(text) %>%
      cli::cat_bullet(bullet_col = "red")
  }

  invisible(x)
}

kind_to_long <- function(kind) {
  if_else(kind == "PK", "primary key", "foreign key")
}

check_pk_constraints <- function(dm, progress = NA) {
  pks <- dm_get_all_pks_impl(dm)
  if (nrow(pks) == 0) {
    return(tibble(
      table = character(),
      kind = character(),
      column = new_keys(),
      ref_table = character(),
      is_key = logical(),
      problem = character()
    ))
  }
  table_names <- pks$table
  columns     <- pks$pk_col

  ticker <- new_ticker("checking pk constraints", length(table_names), progress = progress)
  candidates <- map2(set_names(table_names), columns, ticker(~ {
    tbl <- tbl_impl(dm, .x)
    enum_pk_candidates_impl(tbl, list(.y))
  }))

  tbl_is_pk <-
    tibble(table = table_names, candidate = candidates) %>%
    unnest_df("candidate", tibble(column = new_keys(), candidate = logical(), why = character())) %>%
    rename(is_key = candidate, problem = why)

  tibble(
    table = table_names,
    kind = "PK",
    column = pks$pk_col,
    ref_table = NA_character_
  ) %>%
    left_join(tbl_is_pk, by = c("table", "column"))
}

check_fk_constraints <- function(dm, progress = NA) {
  fks <- dm_get_all_fks_impl(dm)
  pts <- map(fks$parent_table, tbl_impl, dm = dm)
  cts <- map(fks$child_table, tbl_impl, dm = dm)
  fks_tibble <-
    mutate(fks, t1 = cts, t2 = pts) %>%
    select(t1, t1_name = child_table, colname = child_fk_cols, t2, t2_name = parent_table, pk = parent_key_cols)

  ticker <- new_ticker("checking fk constraints", nrow(fks_tibble), progress = progress)

  fks_tibble %>%
    mutate(
      problem = pmap_chr(fks_tibble, ticker(check_fk)),
      is_key = (problem == ""),
      kind = "FK"
    ) %>%
    select(table = t1_name, kind, column = colname, ref_table = t2_name, is_key, problem)
}
