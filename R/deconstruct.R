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

new_fks <- function(..., child_uuid = NULL, child_fk_cols = NULL, parent_uuid = NULL, parent_key_cols = NULL) {
  check_dots_empty0(...)

  child_fk_cols <- new_keys(child_fk_cols)
  parent_key_cols <- new_keys(parent_key_cols)
  tibble(child_uuid, child_fk_cols, parent_uuid, parent_key_cols)
}

new_fks_in <- function(child_uuid = NULL, child_fk_cols = NULL, parent_key_cols = NULL) {
  new_fks(
    child_uuid = vec_cast(child_uuid, character()) %||% character(),
    child_fk_cols = child_fk_cols,
    parent_key_cols = parent_key_cols
  )
}

new_fks_out <- function(child_fk_cols = NULL, parent_uuid = NULL, parent_key_cols = NULL) {
  new_fks(
    child_fk_cols = child_fk_cols,
    parent_uuid = vec_cast(parent_uuid, character()) %||% character(),
    parent_key_cols = parent_key_cols
  )
}

new_keyed_tbl <- function(x,
                          ...,
                          pk = NULL,
                          fks_in = NULL,
                          fks_out = NULL,
                          uuid = NULL) {
  check_dots_empty()

  pk <- vec_cast(pk, character())
  fks_in <- vec_cast(fks_in, new_fks_in()) %||% new_fks_in()
  fks_out <- vec_cast(fks_out, new_fks_out()) %||% new_fks_out()

  if (is.null(uuid)) {
    uuid <- new_uuid()
  }

  class(x) <- unique(c("dm_keyed_tbl", class(x)))
  attr(x, "dm_key_info") <- list(
    pk = pk,
    fks_in = fks_in,
    fks_out = fks_out,
    uuid = uuid
  )

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
  stopifnot(is_dm_keyed_tbl(x))
  attr(x, "dm_key_info")
}

is_dm_keyed_tbl <- function(x) {
  inherits(x, "dm_keyed_tbl")
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
#' @noRd
unclass_keyed_tbl <- function(tbl) {
  if (inherits(tbl, "dm_keyed_tbl")) {
    new_classes <- class(tbl)[class(tbl) != "dm_keyed_tbl"]
    class(tbl) <- new_classes
  }

  attr(tbl, "dm_key_info") <- NULL

  tbl
}

pks_df_from_keys_info <- function(tables) {
  pks <- map(unname(tables), new_pks_from_keys_info)
  tibble(table = names2(tables), pks)
}

new_pks_from_keys_info <- function(tbl) {
  df_keys <- keyed_get_info(tbl)
  if (is.null(df_keys$pk)) {
    NULL
  } else {
    new_pk(list(df_keys$pk))
  }
}

fks_df_from_keys_info <- function(tables) {
  info <- map(tables, keyed_get_info)

  fks_in <-
    map_dfr(info, ~ tibble(.x$fks_in, parent_uuid = .x$uuid))

  fks_out <-
    map_dfr(info, ~ tibble(child_uuid = .x$uuid, .x$fks_out))

  fks <-
    vec_rbind(fks_out, fks_in, .ptype = new_fks(child_uuid = character(), parent_uuid = character())) %>%
    distinct()

  uuid_lookup <- tibble(
    table = names2(tables),
    data = map(unname(tables), unclass_keyed_tbl),
    uuid = map_chr(info, "uuid")
  )

  child_uuid_lookup <- set_names(uuid_lookup, paste0("child_", names(uuid_lookup)))
  parent_uuid_lookup <- set_names(uuid_lookup, paste0("parent_", names(uuid_lookup)))

  fks %>%
    left_join(child_uuid_lookup, by = "child_uuid") %>%
    left_join(parent_uuid_lookup, by = "parent_uuid") %>%
    select(-child_uuid, -parent_uuid) %>%
    filter(map2_lgl(child_fk_cols, child_data, ~ all(.x %in% colnames(.y)))) %>%
    filter(map2_lgl(parent_key_cols, parent_data, ~ all(.x %in% colnames(.y)))) %>%
    group_by(parent_table) %>%
    # FIXME: Capture on_delete
    summarize(fks = list(new_fk(as.list(parent_key_cols), child_table, as.list(child_fk_cols), "no_action"))) %>%
    ungroup() %>%
    rename(table = parent_table)
}

new_fks_from_keys_info <- function(tbl) {
  if (is_dm_keyed_tbl(tbl)) {
    df_keys <- keyed_get_info(tbl)$fks_in
    df_fks <- tibble(
      ref_column = map(df_keys$parent_key_cols, as.character),
      table = df_keys$child_table,
      column = map(df_keys$child_fk_cols, as.character),
      on_delete = "no_action"
    )

    new_fk(df_fks$ref_column, df_fks$table, df_fks$column, df_fks$on_delete)
  }
}

# FIXME: Pass suffix and keep when ready
keyed_build_join_spec <- function(x, y, by = NULL, suffix = NULL) {
  info_x <- keyed_get_info(x)
  info_y <- keyed_get_info(y)

  if (is.null(by)) {
    by <- keyed_by(x, y)
  } else if (!is_named2(by)) {
    by <- set_names(by, by)
  }

  if (is.null(suffix)) {
    suffix <- c(".x", ".y")
  }

  rename <- join_rename_rules(colnames(x), colnames(y), by, suffix)

  # Is one of the "by" column sets a primary key? Keep the primary key of the *other* table!
  if (keyed_is_pk(x, names(by))) {
    new_pk <- join_rename(info_y$pk, rename$y)
  } else if (keyed_is_pk(y, by)) {
    new_pk <- join_rename(info_x$pk, rename$x)
  } else {
    new_pk <- NULL
  }

  # Keep all foreign keys
  new_fks_in <-
    vec_rbind(
      join_rename_key(info_x$fks_in, "parent_key_cols", rename$x),
      join_rename_key(info_y$fks_in, "parent_key_cols", rename$y),
    )

  new_fks_out <-
    vec_rbind(
      join_rename_key(info_x$fks_out, "child_fk_cols", rename$x),
      join_rename_key(info_y$fks_out, "child_fk_cols", rename$y),
    )

  # need to remove the `"dm_keyed_tbl"` class to avoid infinite recursion
  # while joining
  x_tbl <- unclass_keyed_tbl(x)
  y_tbl <- unclass_keyed_tbl(y)

  list(
    x_tbl = x_tbl,
    y_tbl = y_tbl,
    by = enframe(by, "x", "y"),
    suffix = suffix,
    new_pk = new_pk,
    new_fks_in = new_fks_in,
    new_fks_out = new_fks_out,
    new_uuid = new_uuid()
  )
}

keyed_by <- function(x, y) {
  fks_df <- fks_df_from_keys_info(list(x = x, y = y))

  if (nrow(fks_df) == 0) {
    abort("Can't infer `by`: foreign key information lost?")
  }

  stopifnot(map_int(fks_df$fks, NROW) > 0)

  if (nrow(fks_df) > 1) {
    abort("Can't infer `by`: foreign key available in both directions")
  }

  if (nrow(fks_df$fks[[1]]) > 1) {
    abort("Can't infer `by`: multiple foreign keys available")
  }

  fk <- fks_df$fks[[1]][1, ]

  if (fks_df$table == "x") {
    set_names(fk$column[[1]], fk$ref_column[[1]])
  } else {
    set_names(fk$ref_column[[1]], fk$column[[1]])
  }
}

keyed_is_pk <- function(x, cols) {
  info <- keyed_get_info(x)

  # cols must include at least all pk columns
  !is.null(info$pk) && all(info$pk %in% cols)
}

join_rename_rules <- function(x, y, by, suffix) {
  by_idx <- match(by, y)
  stopifnot(!anyNA(by_idx))
  stopifnot(length(by_idx) > 0)
  conflicts <- intersect(x, y[-by_idx])

  x_new <- x
  x_new[x_new %in% conflicts()] <- paste0(x_new, suffix[[1]])

  y_new <- y
  y_new[by_idx] <- names(by)
  y_new[y_new %in% conflicts()] <- paste0(y_new, suffix[[2]])

  list(
    x = set_names(x_new, x),
    y = set_names(y_new, y)
  )
}

join_rename <- function(x, rename) {
  if (is.null(x)) {
    return(NULL)
  }
  stopifnot(all(x %in% names(rename)))
  unname(rename[x])
}

join_rename_key <- function(x, colname, rename) {
  stopifnot(colname %in% names(x))
  x[[colname]] <- new_keys(map(x[[colname]], join_rename, rename))
  x
}
