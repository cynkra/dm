#' Shiny app for defining dm objects
#'
#' @description
#' `r lifecycle::badge("experimental")`
#'
#' This function starts a Shiny application that allows to define `dm` objects
#' from a database or from local data frames.
#' The application generates R code that can be inserted or copy-pasted
#' into an R script or function.
#'
#' @details
#' In a future release, the app will also allow composing `dm` objects directly
#' from database connections or data frames.
#'
#' The signature of this function is subject to change without notice.
#' This should not pose too many problems, because it will usually be run
#' interactively.
#'
#' @inheritParams rlang::args_dots_empty
#' @param dm An initial dm object, currently required.
#' @param select_tables Show selectize input to select tables?
#' @param debug Set to `TRUE` to simplify debugging of the app.
#'
#' @export
#' @examples
#' \dontrun{
#' dm_nycflights13(cycle = TRUE) %>%
#'   dm_gui()
#' }
dm_gui <- function(..., dm = NULL, select_tables = TRUE, debug = FALSE) {
  check_dots_empty()

  check_suggested(
    c(
      "colourpicker",
      "htmltools",
      "htmlwidgets",
      "reactable",
      "rstudioapi",
      "shiny",
      "shinyAce",
      "shinydashboard"
    ),
    use = TRUE
  )

  gui_run(dm, select_tables, debug)
}
