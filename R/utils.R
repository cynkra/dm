MAX_COMMAS <- 6L

commas <- function(x) {
  if (is_empty(x)) {
    x <- ""
  } else if (length(x) > MAX_COMMAS) {
    x[[MAX_COMMAS]] <- paste0(cli::symbol$ellipsis, " (", length(x), " total)")
    length(x) <- MAX_COMMAS
  }

  glue_collapse(x, sep = ", ")
}

tick <- function(x) {
  if (is_empty(x)) return(character())
  paste0("`", x, "`")
}

default_local_src <- function() {
  src_df(env = .GlobalEnv)
}
