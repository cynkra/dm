c_list_of <- function(x) {
  if (length(x) == 0) {
    # vctrs internals
    return(attr(x, "ptype"))
  }

  vec_c(!!!x, .name_spec = zap())
}

unnest_col <- function(x, col, ptype) {
  col_data <- x[[col]]
  out <- x[rep(seq_len(nrow(x)), lengths(col_data)), ]

  if (length(col_data) > 0) {
    col_data <- unlist(col_data, recursive = FALSE, use.names = FALSE)
    if (!identical(col_data[0], ptype)) {
      abort(paste0(
        "Internal: unnest_col() ptype mismatch, must be ",
        class(ptype)[[1]],
        ", not ",
        class(col_data[0])[[1]]
      ))
    }
  } else {
    col_data <- ptype
  }

  out[[col]] <- col_data
  out
}

unnest_list_of_df <- function(x, col) {
  col_data <- x[[col]]
  stopifnot(is_list_of(col_data))

  out <- x[rep(seq_len(nrow(x)), map_int(col_data, vec_size)), setdiff(names(x), col)]
  out <- vec_cbind(out, c_list_of(col_data))
  out
}
