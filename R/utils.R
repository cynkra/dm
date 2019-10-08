MAX_COMMAS <- 6L

commas <- function(x) {
  if (is_empty(x)) {
    x <- ""
  } else if (length(x) > MAX_COMMAS) {
    length(x) <- MAX_COMMAS + 1L
    x[[MAX_COMMAS + 1L]] <- cli::symbol$ellipsis
  }

  glue_collapse(x, sep = ", ")
}

tick <- function(x) {
  paste0("`", x, "`")
}

default_local_src <- function() {
  src_df(env = .GlobalEnv)
}

