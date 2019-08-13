MAX_COMMAS <- 5L

commas <- function(x) {
  if (is_empty(x)) {
    x <- ""
  } else if (length(x) > MAX_COMMAS) {
    length(x) <- MAX_COMMAS + 1L
    x[[MAX_COMMAS]] <- cli::symbol$ellipsis
  }

  glue_collapse(x, sep = ", ")
}

tick <- function(x) {
  paste0("`", x, "`")
}
