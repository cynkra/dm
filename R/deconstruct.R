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
  child_fk_cols <- new_keys(child_fk_cols)
  parent_key_cols <- new_keys(parent_key_cols)

  tibble(child_table, child_fk_cols, parent_key_cols)
}

# TODO: I am wondering if `parent_table` shouldn't be the first parameter here?
# That way, across both function signatures, the `*_table` will always come at first position
new_fks_out <- function(child_fk_cols = NULL, parent_table = NULL, parent_key_cols = NULL) {
  child_fk_cols <- new_keys(child_fk_cols)
  parent_table <- vec_cast(parent_table, character()) %||% character()
  parent_key_cols <- new_keys(parent_key_cols)

  tibble(child_fk_cols, parent_table, parent_key_cols)
}

new_keyed_tbl <- function(x, ..., pk = NULL, fks_in = NULL, fks_out = NULL, uuid = NULL) {
  check_dots_empty()

  pk <- vec_cast(pk, character())
  fks_in <- vec_cast(fks_in, new_fks_in()) %||% new_fks_in()
  fks_out <- vec_cast(fks_out, new_fks_out()) %||% new_fks_out()

  if (is.null(uuid)) {
    uuid <- new_uuid()
  }

  x <- structure(
    x,
    dm_key_info = list(
      pk = pk,
      fks_in = fks_in,
      fks_out = fks_out,
      uuid = uuid
    ),
    class = unique(c("dm_keyed_tbl", class(x)))
  )

  # TODO: `structure()` reintroduces rownames; check if {rlang} and {vctrs}
  # has an alternative; commented out for now because few other tests fail
  # x <- remove_rownames(x)
  x
}

new_keyed_tbl_from_keys_info <- function(tbl, keys_info) {
  new_keyed_tbl(
    tbl,
    pk = keys_info$pk,
    fks_in = keys_info$fks_in,
    fks_out = keys_info$fks_out,
    uuid = keys_info$uuid
  )
}

keyed_get_info <- function(x) {
  stopifnot(inherits(x, "dm_keyed_tbl"))
  attr(x, "dm_key_info")
}

#' @export
tbl_sum.dm_keyed_tbl <- function(x, ...) {
  info <- keyed_get_info(x)

  if (is.null(info$pk)) {
    pk_info <- cli::symbol$em_dash
  } else {
    pk_info <- commas(tick(info$pk))
  }

  fks_in_info <- nrow(info$fks_in)
  fks_out_info <- nrow(info$fks_out)

  c(
    NextMethod(),
    Keys = paste0(pk_info, " | ", fks_in_info, " | ", fks_out_info)
  )
}

#' @title Remove `"dm_keyed_tbl"` class
#'
#' @return If entered table has `"dm_keyed_tbl"` class, it will be removed. All
#' other classes will be preserved.
#'
#' @examples
#' dm <- dm_nycflights13()
#' class(dm$airlines)
#' class(dm:::unclass_keyed_tbl(dm$airlines))
#' @keywords internal
unclass_keyed_tbl <- function(tbl) {
  if (inherits(tbl, "dm_keyed_tbl")) {
    new_classes <- class(tbl)[class(tbl) != "dm_keyed_tbl"]
    class(tbl) <- new_classes
  }

  tbl
}
