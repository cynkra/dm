#' Creates a test `dm`-object from \pkg{nycflights13}
#'
#' @description Creates an exemplary `dm`-object from the tables in \pkg{nycflights13}
#' along with key relations (two foreign key relations are violated, but we accept this,
#' since this should only be seen as a quick way of getting a `dm` with known tables to
#' play around with).
#'
#' @export
cdm_nycflights13 <- function() {
  dm(
    src_df("nycflights13")
  ) %>%
    cdm_add_pk(planes, tailnum) %>%
    cdm_add_pk(airlines, carrier) %>%
    cdm_add_pk(airports, faa) %>%
    cdm_add_fk(flights, tailnum, planes, check = FALSE) %>%
    cdm_add_fk(flights, carrier, airlines) %>%
    cdm_add_fk(flights, origin, airports) %>%
    cdm_add_fk(flights, dest, airports, check = FALSE)
}
