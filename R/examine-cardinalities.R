#' Learn about your data model
#'
#' @description
#' `r lifecycle::badge("experimental")`
#'
#' This function returns a tibble with information about
#' the cardinality of the FK constraints.
#' The printing for this object is special, use [as_tibble()]
#' to print as a regular tibble.
#'
# Can't @inheritParams dm_examine_constraints for some reason
#' @param .dm A `dm` object.
#' @inheritParams rlang::args_dots_empty
#' @param .progress Whether to display a progress bar, if `NA` (the default)
#'   hide in non-interactive mode, show in interactive mode. Requires the
#'   'progress' package.
#' @param dm,progress `r lifecycle::badge("deprecated")`
#'
#' @return A tibble with the following columns:
#'   \describe{
#'     \item{`child_table`}{child table,}
#'     \item{`child_fk_cols`}{foreign key column(s) in child table as list of character vectors,}
#'     \item{`parent_table`}{parent table,}
#'     \item{`parent_key_cols`}{key column(s) in parent table as list of character vectors,}
#'     \item{`cardinality`}{the nature of cardinality along the foreign key.}
#'   }
#'
#' @details Uses [examine_cardinality()] on each foreign key that is defined in the [`dm`].
#'
#' @family cardinality functions
#'
#' @export
#' @examplesIf rlang::is_installed("nycflights13")
#' dm_nycflights13() %>%
#'   dm_examine_cardinalities()
dm_examine_cardinalities <- function(.dm, ..., .progress = NA,
                                     dm = deprecated(), progress = deprecated()) {
  check_dots_empty()

  if (!is_missing(dm)) {
    deprecate_soft("1.0.0", "dm_examine_cardinalities(dm = )", "dm_examine_cardinalities(.dm = )")
  }

  if (is_missing(.dm)) {
    return(dm_examine_cardinalities(dm, .progress = .progress, progress = progress))
  }

  if (!is_missing(progress)) {
    if (is.na(progress)) {
      progress <- .progress
    }
    deprecate_soft("1.0.0", "dm_examine_cardinalities(progress = )", "dm_examine_cardinalities(.progress = )")
  }

  check_not_zoomed(.dm)
  .dm %>%
    dm_examine_cardinalities_impl(progress = .progress, top_level_fun = "dm_examine_cardinalities") %>%
    new_dm_examine_cardinalities()
}

#' @autoglobal
dm_examine_cardinalities_impl <- function(dm, progress = NA, top_level_fun = NULL) {
  fks <-
    dm_get_all_fks_impl(dm) %>%
    select(-on_delete)

  dm_def <- as.list(dm)
  fks_data <-
    fks %>%
    transmute(
      x_label = parent_table,
      y_label = child_table,
      x = map2(dm_def[x_label], parent_key_cols, ~ select(.x, all_of(.y))),
      y = map2(dm_def[y_label], child_fk_cols, ~ select(.x, all_of(.y))),
    )
  ticker <- new_ticker(
    "checking fk cardinalities",
    n = nrow(fks),
    progress = progress,
    top_level_fun = top_level_fun
  )

  fks %>%
    mutate(cardinality = pmap_chr(fks_data, ticker(examine_cardinality_impl0)))
}

new_dm_examine_cardinalities <- function(x) {
  class(x) <- c("dm_examine_cardinalities", class(x))
  x
}

#' @export
print.dm_examine_cardinalities <- function(x, ...) {
  if (nrow(x) == 0) {
    cli::cli_alert_warning("No FKs available in `dm`.")
    return(invisible(x))
  }
  x %>%
    mutate(
      cardinalities =
        pmap_chr(
          x,
          function(parent_table, parent_key_cols, child_table, child_fk_cols, cardinality) {
            paste0(
              "FK: ",
              child_table,
              "$(",
              commas(tick(child_fk_cols)),
              ") -> ",
              parent_table,
              "$(",
              commas(tick(parent_key_cols)),
              "): ",
              cardinality
            )
          }
        )
    ) %>%
    bullets_cardinalities()
}

#' @autoglobal
bullets_cardinalities <- function(x) {
  x <- mutate(
    x,
    col = if_else(grepl("mapping", cardinality), "black", "red")
  ) %>%
    arrange(col)
  walk2(x$cardinalities, x$col, ~ cli::cat_bullet(.x, bullet_col = .y))
  if (sum(x$col == "red") > 0) {
    cli::cli_alert_warning("Not all FK constraints satisfied, call `dm_examine_constraints()` for details.")
  }
  invisible(x)
}
