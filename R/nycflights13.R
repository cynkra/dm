#' Creates a dm object for the \pkg{nycflights13} data
#'
#' @description
#' Creates an example [`dm`] object from the tables in \pkg{nycflights13},
#' along with the references.
#' See [nycflights13::flights] for a description of the data.
#' As described in [nycflights13::planes], the relationship
#' between the `flights` table and the `planes` tables is "weak", it does not satisfy
#' data integrity constraints.
#'
#' @inheritParams rlang::args_dots_empty
#' @param cycle Boolean.
#'   If `FALSE` (default), only one foreign key relation
#'   (from `flights$origin` to `airports$faa`) between the `flights` table and the `airports` table is
#'   established.
#'   If `TRUE`, a `dm` object with a double reference
#'   between those tables will be produced.
#' @param color Boolean, if `TRUE` (default), the resulting `dm` object will have
#'   colors assigned to different tables for visualization with `dm_draw()`.
#' @param subset Boolean, if `TRUE` (default), the `flights` table is reduced to flights with column `day` equal to 10.
#' @param compound Boolean, if `FALSE`, no link will be established between tables `flights` and `weather`,
#'   because this requires compound keys.
#'
#' @return A `dm` object consisting of {nycflights13} tables, complete with primary and foreign keys and optionally colored.
#'
#' @export
#' @examplesIf rlang::is_installed("DiagrammeR")
#' dm_nycflights13() %>%
#'   dm_draw()
dm_nycflights13 <- function(..., cycle = FALSE, color = TRUE, subset = TRUE, compound = TRUE) {
  check_dots_empty()

  if (subset) {
    data <- nycflights_subset()
    flights <- data$flights
    weather <- data$weather
    airlines <- data$airlines
    airports <- data$airports
    planes <- data$planes
  } else {
    check_suggested("nycflights13", use = TRUE)

    flights <- nycflights13::flights
    weather <- nycflights13::weather
    airlines <- nycflights13::airlines
    airports <- nycflights13::airports
    planes <- nycflights13::planes
  }

  dm <-
    dm(airlines, airports, flights, planes, weather) %>%
    dm_add_pk(planes, tailnum) %>%
    dm_add_pk(airlines, carrier) %>%
    dm_add_pk(airports, faa) %>%
    dm_add_fk(flights, tailnum, planes) %>%
    dm_add_fk(flights, carrier, airlines) %>%
    dm_add_fk(flights, origin, airports)

  if (compound) {
    dm <-
      dm %>%
      dm_add_pk(weather, c(origin, time_hour)) %>%
      dm_add_fk(flights, c(origin, time_hour), weather)
  }

  if (color) {
    dm <-
      dm %>%
      dm_set_colors(
        "#5B9BD5" = flights,
        "#ED7D31" = c(starts_with("air"), planes),
        "#70AD47" = weather
      )
  }

  if (cycle) {
    dm <-
      dm %>%
      dm_add_fk(flights, dest, airports, check = FALSE)
  }

  dm
}

nycflights_subset <- function() {
  readRDS(system.file("extdata/nycflights13-small.rds", package = "dm"))
}
