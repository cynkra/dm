#' Prototype for a dm object
#'
#' @description
#' `r lifecycle::badge("experimental")`
#'
#' The prototype contains all tables, all primary and foreign keys,
#' but no data.
#' All tables are truncated and converted to zero-row tibbles,
#' also for remote data models.
#' Column names retain their type.
#' This is useful for performing creation and population of a database
#' in separate steps.
#'
#' @inheritParams dm_has_fk
#' @export
#' @examplesIf dm:::dm_has_financial()
#' dm_financial() %>%
#'   dm_ptype()
#'
#' dm_financial() %>%
#'   dm_ptype() %>%
#'   dm_nrow()
dm_ptype <- function(dm) {
  check_not_zoomed(dm)

  # collect() doesn't support n argument for data frames
  # collect() requires n > 0: https://github.com/tidyverse/dbplyr/issues/415
  dm %>%
    dm_get_def() %>%
    mutate(data = map(data, ~ head(.x, 0))) %>%
    new_dm3() %>%
    collect()
}
