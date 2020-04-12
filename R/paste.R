#' Create R code for a dm object
#'
#' `dm_paste()` takes an existing `dm` and emits the code necessary for its creation.
#'
#' @inheritParams dm_add_pk
#' @param select Boolean, default `FALSE`. If `TRUE` will produce code
#'   for reducing to necessary columns.
#' @param tab_width Indentation width for code from the second line onwards
#'
#' @details At the very least (if no keys exist in the given [`dm`]) a `dm()` statement is produced that -- when executed --
#' produces the same `dm`. In addition, the code for setting the existing primary keys as well as the relations between the
#' tables is produced. If `select = TRUE`, statements are included to select the respective columns of each table of the `dm` (useful if
#' only a subset of the columns of the original tables is used for the `dm`).
#'
#' Mind, that it is assumed, that the tables of the existing `dm` are available in the global environment under their names
#' within the `dm`.
#'
#' @return Code for producing the given `dm`.
#'
#' @export
#' @examples
#' dm_nycflights13() %>%
#'   dm_paste()
#'
#' dm_nycflights13() %>%
#'   dm_paste(select = TRUE)
dm_paste <- function(dm, select = FALSE, tab_width = 2) {
  # FIXME: Expose color as argument?
  code <- dm_paste_impl(
    dm = dm, select = select,
    tab_width = tab_width, color = TRUE
  )
  cli::cli_code(code)
  invisible(dm)
}

dm_paste_impl <- function(dm, select, tab_width, color) {
  check_not_zoomed(dm)
  check_no_filter(dm)

  tab <- paste0(rep(" ", tab_width), collapse = "")

  # we assume the tables exist and have the necessary columns
  # code for including the tables
  code_dm <- dm_paste_dm(dm)

  # adding code for selection of columns
  code_select <- if (select) dm_paste_select(dm)

  # adding code for establishing PKs
  code_pks <- dm_paste_pks(dm)

  # adding code for establishing FKs
  code_fks <- dm_paste_fks(dm)

  # adding code for color
  code_color <- if (color) dm_paste_color(dm)

  glue_collapse(c(code_dm, code_select, code_pks, code_fks, code_color), sep = glue(" %>%\n{tab}", .trim = FALSE))
}

dm_paste_dm <- function(dm) {
  glue("dm({glue_collapse1(tick_if_needed(src_tbls(dm)), ', ')})")
}

dm_paste_select <- function(dm) {
  tbl_select <- dm %>%
    dm_get_def() %>%
    mutate(cols = map(data, colnames)) %>%
    mutate(cols = map_chr(cols, ~ glue_collapse1(glue(", {tick_if_needed(.x)}")))) %>%
    mutate(code = glue("dm_select({tick_if_needed(table)}{cols})")) %>%
    pull()
}

dm_paste_pks <- function(dm) {
  # FIXME: this will fail with compound keys
  dm_get_all_pks_impl(dm) %>%
    mutate(code = glue("dm_add_pk({tick_if_needed(table)}, {tick_if_needed(pk_col)})")) %>%
    pull()
}

dm_paste_fks <- function(dm) {
  # FIXME: this will fail with compound keys
  tbl_fks <- dm_get_all_fks_impl(dm) %>%
    mutate(code = glue("dm_add_fk({tick_if_needed(child_table)}, {tick_if_needed(child_fk_cols)}, {tick_if_needed(parent_table)})")) %>%
    pull()
}

dm_paste_color <- function(dm) {
  colors <- dm_get_colors(dm)
  colors <- colors[names(colors) != "default"]
  glue("dm_set_colors({tick_if_needed(names(colors))} = {tick_if_needed(colors)})")
}

glue_collapse1 <- function(x, ...) {
  if (is_empty(x)) {
    ""
  } else {
    glue_collapse(x, ...)
  }
}
