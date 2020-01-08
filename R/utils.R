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

is_hex_color <- function(x) {
  grepl("^#[A-Fa-f0-9]{6}$", x)
}

col_to_hex <- function(x) {
  # from hex or name to rgb
  map(x, function(x) col2rgb(x)[, 1]) %>%
    # from rgb to hex
    map_chr(function(x) rgb(x[1], x[2], x[3], maxColorValue = 255))
}
