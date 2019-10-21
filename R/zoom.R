cdm_zoom_to_tbl <- function(dm, table) {
  # for now only one table can be zoomed on
  zoom <- as_string(ensym(table))
  check_correct_input(dm, zoom)
  zoom_tbl <- tbl(dm, zoom)

  new_dm2(
    zoom = tibble(table = zoom, zoom = list(zoom_tbl)),
    base_dm = dm
  )
}

is_zoomed <- function(dm) {
  !all(cdm_get_zoomed_tbl(dm) %>% pull(zoom) %>% map_lgl(is_null))
}

cdm_zoom_out <- function(dm) {
  new_dm2(
    zoom = new_zoom(),
    base_dm = dm
  )
}
