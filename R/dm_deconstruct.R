#' Create code to deconstruct a dm object
#'
#' @description
#' `r lifecycle::badge("experimental")`
#'
#' Emits code that assigns each table in the dm to a variable,
#' using [pull_tbl()] with `keyed = TRUE`.
#' These tables retain information about primary and foreign keys,
#' even after data transformations,
#' and can be converted back to a dm object with [dm()].
#'
#' @inheritParams dm_add_pk
#' @param dm_name The code to use to access the dm object,
#'   by default the expression passed to this function.
#'
#' @return This function is called for its side effect of printing
#'   generated code.
#'
#' @export
#' @examples
#' dm <- dm_nycflights13()
#' dm_deconstruct(dm)
#' airlines <- pull_tbl(dm, "airlines", keyed = TRUE)
#' airports <- pull_tbl(dm, "airports", keyed = TRUE)
#' flights <- pull_tbl(dm, "flights", keyed = TRUE)
#' planes <- pull_tbl(dm, "planes", keyed = TRUE)
#' weather <- pull_tbl(dm, "weather", keyed = TRUE)
#' by_origin <-
#'   flights %>%
#'   group_by(origin) %>%
#'   summarize(mean_arr_delay = mean(arr_delay, na.rm = TRUE)) %>%
#'   ungroup()
#'
#' by_origin
#' dm(airlines, airports, flights, planes, weather, by_origin) %>%
#'   dm_draw()
dm_deconstruct <- function(dm, dm_name = NULL) {
  dm_name <- enquo(dm_name)
  if (quo_is_null(dm_name)) {
    dm_name <- enexpr(dm)
  } else {
    dm_name <- quo_get_expr(dm_name)
  }

  dm_name <- as.character(dm_name)

  names <- names(dm)
  code <- paste0(
    tick_if_needed(names), " <- pull_tbl(", dm_name, ", ",
    map_chr(names, deparse), ", keyed = TRUE)",
    collapse = "\n"
  )

  message(code)

  invisible()
}
