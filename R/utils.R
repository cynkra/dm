MAX_COMMAS <- 6L

commas <- function(x, max_commas = MAX_COMMAS, capped = FALSE) {
  if (is_null(max_commas)) max_commas <- MAX_COMMAS
  if (is_empty(x)) {
    x <- ""
  } else if (length(x) > max_commas) {
    x[[max_commas]] <- paste0(
      cli::symbol$ellipsis, " (",
      if (capped) ">= ",
      length(x),
      " total)"
    )
    length(x) <- max_commas
  }

  glue_collapse(x, sep = ", ")
}

tick <- function(x) {
  if (is_empty(x)) {
    return(character())
  }
  paste0("`", x, "`")
}

default_local_src <- function() {
  src_df(env = .GlobalEnv)
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
