#' Creates a [`dm`] object for the \pkg{nycflights13} data
#'
#' @description Creates an example [`dm`] object from the tables in \pkg{nycflights13},
#' along with the references.
#' See [nycflights13::flights] for a description of the data.
#' As described in [nycflights13::planes], the relationship
#' between the `flights` table and the `planes` tables is "weak", it does not satisfy
#' data integrity constraints.
#'
#' @param cycle Boolean. If `FALSE` (default), only one foreign key relation
#'   (from `flights$origin` to `airports$faa`) between the `flights` table and the `airports` table is
#'   established. If `TRUE`, a `dm` object with a double reference
#'   between those tables will be produced.
#' @param color Boolean, if `TRUE` (default), the resulting `dm` object will have
#'   colors assigned to different tables for visualization with `cdm_draw()`
#'
#' @export
#' @examples
#' if (rlang::is_installed("nycflights13")) {
#'   cdm_nycflights13() %>%
#'     cdm_draw()
#' }
cdm_nycflights13 <- nse_function(c(cycle = FALSE, color = TRUE), ~ {
  dm <-
    dm(
      src_df("nycflights13")
    ) %>%
    cdm_add_pk(planes, tailnum) %>%
    cdm_add_pk(airlines, carrier) %>%
    cdm_add_pk(airports, faa) %>%
    cdm_add_fk(flights, tailnum, planes, check = FALSE) %>%
    cdm_add_fk(flights, carrier, airlines) %>%
    cdm_add_fk(flights, origin, airports)

  if (color) {
    dm <-
      dm %>%
      cdm_set_colors(
        flights = "blue",
        airports = ,
        planes = ,
        airlines = "orange",
        weather = "green"
      )
  }

  if (cycle) {
    dm <-
      dm %>%
      cdm_add_fk(flights, dest, airports, check = FALSE)
  }

  dm
})
