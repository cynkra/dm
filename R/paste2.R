dm_paste2 <- function(dm) {
  ptype <- dm_ptype(dm)

  tables <-
    ptype %>%
    dm_get_tables() %>%
    map_chr(df_paste)

  all_tables <- glue_collapse(
    glue("{names(tables)} <- {tables}\n\n", .trim = FALSE)
  )

  if (has_length(all_tables)) {
    cli::cli_code(all_tables)
  }

  dm_paste(ptype)
}

df_paste <- function(x) {
  cols <- map_chr(x, deparse_line)
  if (is_empty(x)) {
    cols <- ""
  } else {
    cols <- paste0(
      paste0("\n  ", names(cols), " = ", cols, collapse = ","),
      "\n"
    )
  }

  paste0("tibble(", cols, ")")
}

deparse_line <- function(x) {
  x <- deparse(x, width.cutoff = 500, backtick = TRUE)
  gsub(" *\n *", " ", x)
}
