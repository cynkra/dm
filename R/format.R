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

default_local_src <- function() {
  structure(
    list(tbl_f = as_tibble, name = "<environment: R_GlobalEnv>", env = .GlobalEnv),
    class = c("src_local", "src")
  )
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
