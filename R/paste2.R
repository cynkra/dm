dm_paste2 <- function(dm) {
  ptype <- dm_ptype(dm)

  tables <-
    ptype %>%
    dm_get_tables() %>%
    map_chr(df_paste)

  all_tables <- paste0(
    names(tables), " <- ", tables, "\n\n",
    collapse = ""
  )

  cli::cli_code(all_tables)

  dm_paste(ptype)
}

df_paste <- function(x) {
  cols <- map_chr(x, deparse_line)
  paste0(
    "tibble(",
    paste0("\n  ", names(cols), " = ", cols, collapse = ","),
    "\n)"
  )
}

deparse_line <- function(x) {
  x <- deparse(x, width.cutoff = 500, backtick = TRUE)
  gsub(" *\n *", " ", x)
}
