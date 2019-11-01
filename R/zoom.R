dm_zoom_to_tbl <- function(dm, table) {
  if (is_zoomed(dm)) abort_no_zoom_allowed()
  check_no_filter(dm)

  # for now only one table can be zoomed on
  zoom <- as_string(ensym(table))
  check_correct_input(dm, zoom)

  structure(
    new_dm3(
      dm_get_def(dm) %>%
        mutate(zoom = if_else(table == !!zoom, data, list(NULL)))
      ),
    class = c("zoomed_dm", "dm")
    )
}

is_zoomed <- function(dm) {
  inherits(dm, "zoomed_dm")
}

dm_zoom_out <- function(dm) {
  new_dm3(
    dm_get_def(dm) %>%
      mutate(zoom = list(NULL))
    )
}

get_zoomed_tbl <- function(dm) {
  dm_get_zoomed_tbl(dm) %>%
    pull(zoom) %>%
    pluck(1)
}
