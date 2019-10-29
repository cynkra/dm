cdm_zoom_to_tbl <- function(dm, table) {
  if (is_zoomed(dm)) abort_no_zoom_allowed()

  # for now only one table can be zoomed on
  zoom <- as_string(ensym(table))
  check_correct_input(dm, zoom)

  structure(
    new_dm3(
      cdm_get_def(dm) %>%
        mutate(zoom = if_else(table == !!zoom, data, list(NULL)))
      ),
    class = c("zoomed_dm", "dm")
    )
}

is_zoomed <- function(dm) {
  inherits(dm, "zoomed_dm")
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

cdm_insert_zoomed_tbl <- function(dm, new_tbl_name) {
  if (!is_zoomed(dm)) abort_no_table_zoomed()
  new_tbl_name_chr <- as_string(enexpr(new_tbl_name))
  if (new_tbl_name_chr == "") abort_table_needs_name()
  old_tbl_name <- orig_name_zoomed(dm)
  new_tbl <- list(get_zoomed_tbl(dm))
  # filters need to be split: old_filters belong to old table, new ones to the inserted one
  all_filters <- get_filter_for_table(dm, old_tbl_name)
  old_filters <- all_filters %>% filter(!zoomed)
  new_filters <- all_filters %>% filter(zoomed) %>% mutate(zoomed = FALSE)

  update_filter(dm, old_tbl_name, vctrs::list_of(old_filters)) %>%
    cdm_add_tbl_impl(new_tbl, new_tbl_name_chr, vctrs::list_of(new_filters)) %>%
    cdm_zoom_out()
}

# FIXME: this is a very basic implementation:
# it does not care at all about potential changes in the key columns of the table
# it just erases the old keys; this needs to be tracked though
cdm_update_zoomed_tbl <- function(dm) {
  if (!is_zoomed(dm)) return(dm)
  table_name <- cdm_get_zoomed_tbl(dm) %>% pull(table)
  upd_filter <- vctrs::list_of(get_filter_for_table(dm, table_name) %>% mutate(zoomed = FALSE))
  new_def <- cdm_get_def(dm) %>%
    mutate(
      data = if_else(table != !!table_name, data, zoom),
      pks = if_else(table != !!table_name, pks, update_zoomed_pk(dm)),
      fks = if_else(table != !!table_name, fks, update_zoomed_fks(dm)),
      filters = if_else(table != !!table_name, filters, upd_filter),
      zoom = list(NULL)
      )
  new_dm3(new_def)
}

update_zoomed_pk <- function(dm) {
  vctrs::list_of(new_pk())
}

update_zoomed_fks <- function(dm) {
  vctrs::list_of(new_fk())
}

orig_name_zoomed <- function(dm) {
  cdm_get_def(dm) %>%
    filter(map_lgl(zoom, ~!is_null(.))) %>%
    pull(table)
}
