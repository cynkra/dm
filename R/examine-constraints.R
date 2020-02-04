#' Validate your data model
#'
#' This function returns a tibble with information about
#' which key constraints are met (`is_key = TRUE`) or violated (`FALSE`).
#' The printing for this object is special, use [as_tibble()]
#' to print as a regular tibble.
#'
#' @inheritParams dm_add_pk
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
#' @examples
#' dm_nycflights13() %>%
#'   dm_examine_constraints()
dm_examine_constraints <- function(dm) {
  check_not_zoomed(dm)
  dm_examine_constraints_impl(dm) %>%
    rename(columns = column) %>%
    mutate(columns = new_keys(columns)) %>%
    new_dm_examine_constraints()
}

dm_examine_constraints_impl <- function(dm) {
  pk_results <- check_pk_constraints(dm)
  fk_results <- check_fk_constraints(dm)
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
  problem_df <-
    x %>%
    as_tibble() %>%
    filter(problem != "")

  if (nrow(problem_df) == 0) {
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
