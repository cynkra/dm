new_uuid <- function() {
  out <- as.raw(sample.int(16, 16) - 1L)
  paste0(
    paste0(out[1:4], collapse = ""),
    "-",
    paste0(out[5:6], collapse = ""),
    "-",
    paste0(out[7:8], collapse = ""),
    "-",
    paste0(out[9:10], collapse = ""),
    "-",
    paste0(out[11:16], collapse = "")
  )
}

vec_new_uuid_along <- function(x) {
  map_chr(x, function(.x) new_uuid())
}

new_fks_in <- function(child_table = NULL, child_fk_cols = NULL, parent_key_cols = NULL) {
  child_table <- vec_cast(child_table, character()) %||% character()
  child_fk_cols <- vec_cast(child_fk_cols, new_keys()) %||% new_keys()
  parent_key_cols <- vec_cast(parent_key_cols, new_keys()) %||% new_keys()

  tibble(child_table, child_fk_cols, parent_key_cols)
}

new_fks_out <- function(child_fk_cols = NULL, parent_table = NULL, parent_key_cols = NULL) {
  child_fk_cols <- vec_cast(child_fk_cols, new_keys()) %||% new_keys()
  parent_table <- vec_cast(parent_table, character()) %||% character()
  parent_key_cols <- vec_cast(parent_key_cols, new_keys()) %||% new_keys()

  tibble(child_fk_cols, parent_table, parent_key_cols)
}

new_keyed_tbl <- function(x, ..., pk = NULL, fks_in = NULL, fks_out = NULL, uuid = NULL) {
  check_dots_empty()

  stopifnot(!is.null(pk))
  stopifnot(!is.null(fks_in))
  stopifnot(!is.null(fks_out))

  pk <- vec_cast(pk, new_keys())
  fks_in <- vec_cast(fks_in, new_fks_in())
  fks_out <- vec_cast(fks_out, new_fks_out())

  if (is.null(uuid)) {
    uuid <- new_uuid()
  }

  structure(
    x,
    dm_key_info = list(
      pk = pk,
      fks_in = fks_in,
      fks_out = fks_out
    ),
    class = unique(c("dm_keyed_tbl", class(x)))
  )
}
