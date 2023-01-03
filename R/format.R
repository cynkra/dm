MAX_COMMAS <- 6L

commas <- function(x, max_commas = MAX_COMMAS, capped = FALSE, fun = identity) {
  if (is_null(max_commas)) max_commas <- MAX_COMMAS
  fun <- as_function(fun)

  if (is_empty(x)) {
    x <- ""
  } else if (length(x) > max_commas) {
    cap <- if (!capped) paste0(" (", length(x), " total)")

    x <- c(
      fun(x[seq_len(max_commas - 1)]),
      paste0(cli::symbol$ellipsis, cap)
    )
  } else {
    x <- fun(x)
  }

  glue_collapse(x, sep = ", ")
}

tick <- function(x) {
  if (is_empty(x)) {
    return(character())
  }
  paste0("`", x, "`")
}

deparse_keys <- function(x) {
  ticked <- map(x, tick_if_needed)
  out <- map_chr(ticked, paste, collapse = ", ")
  add_c <- lengths(ticked) != 1
  out[add_c] <- paste0("c(", out[add_c], ")")
  out
}

# next 2 are borrowed from {tibble}:
tick_if_needed <- function(x) {
  needs_ticks <- !is_syntactic(x)
  x[needs_ticks] <- tick(x[needs_ticks])
  x
}

is_syntactic <- function(x) {
  x == make.names(x)
}

if_pkg_version <- function(pkg, min_version, if_true, if_false = NULL) {
  if (packageVersion(pkg) >= min_version) if_true else if_false
}

format_classes <- function(class) {
  commas(tick(class))
}

trim_width <- function(x, width) {
  if (nchar(x) > width) {
    paste0(strtrim(x, width), cli::symbol$ellipsis)
  } else {
    x
  }
}

char_vec_to_sym <- function(x) {
  map(x, ~ if (length(.x) > 1) {
    paste0("c(", glue_collapse(syms(.x), ", "), ")")
  } else {
    sym(.x)
  })
}
