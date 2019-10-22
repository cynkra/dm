cdm_zoom_to_tbl <- function(dm, table) {
  # for now only one table can be zoomed on
  zoom <- as_string(ensym(table))
  check_correct_input(dm, zoom)

  new_dm3(
    cdm_get_def(dm) %>%
      mutate(zoom = if_else(table == !!zoom, data, list(NULL)))
  )
}

is_zoomed <- function(dm) {
  !is_null(get_zoomed_tbl(dm))
}

cdm_zoom_out <- function(dm) {
  new_dm3(
    cdm_get_def(dm) %>%
      mutate(zoom = list(NULL))
  )
}

get_zoomed_tbl <- function(dm) {
  cdm_get_zoomed_tbl(dm) %>%
    pull(zoom) %>%
    pluck(1)
}
