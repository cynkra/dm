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
