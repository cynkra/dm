tbl_insert <- function(target, source, ..., dry_run = FALSE) {
  UseMethod("tbl_insert", target)
}

tbl_insert.data.frame <- function(target, source, ..., dry_run = FALSE) {
  rbind(target, source)
}

tbl_insert.tbl_df <- function(target, source, ..., dry_run = FALSE) {
  bind_rows(target, source)
}

tbl_insert.tbl_dbi <- function(target, source, ..., dry_run = FALSE) {
  # Also in dry-run mode, for early notification of problems
  # Already quoted!?!
  name <- target_table_name(target, dry_run)

  if (dry_run) {
    union_all(target, source)
  } else {
    sql <- paste0(
      "INSERT INTO ", name, "\n",
      sql_render(source)
    )
    dbExecute(target$con, sql)
    invisible(NULL)
  }
}
