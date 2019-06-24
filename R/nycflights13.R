#' Creates a test `dm` object from \pkg{nycflights13}
#'
#' @description Creates an exemplary `dm` object from the tables in \pkg{nycflights13}
#' along with key relations (two foreign key relations are violated, but we accept this,
#' since this should only be seen as a quick way of getting a `dm` with known tables to
#' play around with).
#'
#' @param cycle_free Boolean, if `TRUE` (default), only one foreign key relation
#' (from `flights$origin` to `airports$faa`) between `flights` and `airports` is
#' established. If `FALSE`, a `dm` object with a double reference
#' between those tables will be produced.
#'
#' @export
cdm_nycflights13 <- function(cycle_free = TRUE) h(~ {
    dm <-
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

    if (cycle_free) dm %>% cdm_rm_fk(flights, dest, airports) else dm
  })
