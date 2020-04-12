dm_paste2 <- function(dm) {
  all_tables <- dm_paste_tables(dm)

  if (has_length(all_tables)) {
    cli::cli_code(all_tables)
  }

  dm_paste(ptype)
}

dm_paste_tables <- function(dm, tab) {
  ptype <- dm_ptype(dm)

  tables <-
    ptype %>%
    dm_get_tables() %>%
    map_chr(df_paste, tab)

  glue_collapse1(
    glue("{tick_if_needed(names(tables))} <- {tables}\n\n", .trim = FALSE)
  )
}

df_paste <- function(x, tab) {
  cols <- map_chr(x, deparse_line)
  if (is_empty(x)) {
    cols <- ""
  } else {
    cols <- paste0(
      paste0("\n", tab, tick_if_needed(names(cols)), " = ", cols, collapse = ","),
      "\n"
    )
  }

  paste0("tibble(", cols, ")")
}

deparse_line <- function(x) {
  x <- deparse(x, width.cutoff = 500, backtick = TRUE)
  gsub(" *\n *", " ", x)
}
