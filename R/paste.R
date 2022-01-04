#' Create R code for a dm object
#'
#' `dm_paste()` takes an existing `dm` and emits the code necessary for its creation.
#'
#' @inheritParams dm_add_pk
#' @param select
#'   Deprecated, see `"select"` in the `options` argument.
#' @param ... Must be empty.
#' @param tab_width Indentation width for code from the second line onwards
#' @param options Formatting options. A character vector containing some of:
#'   - `"tables"`: [tibble()] calls for empty table definitions
#'     derived from [dm_ptype()], overrides `"select"`.
#'   - `"select"`: [dm_select()] statements for columns that are part
#'     of the dm.
#'   - `"keys"`: [dm_add_pk()] and [dm_add_fk()] statements for adding keys.
#'   - `"color"`: [dm_set_colors()] statements to set color.
#'   - `"all"`: All options above except `"select"`
#'
#'   Default `NULL` is equivalent to `c("keys", "color")`
#' @param path Output file, if `NULL` the code is printed to the console.
#'
#' @details
#' The code emitted by the function reproduces the structure of the `dm` object.
#' The `options` argument controls the level of detail: keys, colors,
#' table definitions.
#' Data in the tables is never included, see [dm_ptype()] for the underlying logic.
#'
#' @return Code for producing the prototype of the given `dm`.
#'
#' @export
#' @examples
#' dm() %>%
#'   dm_paste()
#' @examplesIf rlang::is_installed("nycflights13")
#'
#' dm_nycflights13() %>%
#'   dm_paste()
#'
#' dm_nycflights13() %>%
#'   dm_paste(options = "select")
dm_paste <- function(dm, select = NULL, ..., tab_width = 2,
                     options = NULL, path = NULL) {
  check_dots_empty(action = warn)

  options <- check_paste_options(options, select, caller_env())

  if (!is.null(path)) {
    check_suggested("brio",
      use = TRUE,
      top_level_fun = "dm_paste"
    )
  }

  code <- dm_paste_impl(dm = dm, options, tab_width = tab_width)

  if (is.null(path)) {
    cli::cli_code(code)
  } else {
    brio::write_lines(code, path)
  }
  invisible(dm)
}

check_paste_options <- function(options, select, env) {
  allowed_options <- c("all", "tables", "keys", "select", "color")

  if (is.null(options)) {
    options <- c("keys", "color")
  } else {
    if (!all(options %in% allowed_options)) {
      abort_unknown_option(options, allowed_options)
    }
  }

  if (!is.null(select)) {
    deprecate_soft("0.1.2", "dm::dm_paste(select = )", "dm::dm_paste(options = 'select')", env = env)
    if (isTRUE(select)) {
      options <- c(options, "select")
    }
  }

  if ("all" %in% options) {
    options <- allowed_options
  }

  if ("tables" %in% options) {
    options <- setdiff(options, "select")
  }

  options
}

dm_paste_impl <- function(dm, options, tab_width) {
  check_not_zoomed(dm)
  check_no_filter(dm)

  tab <- paste0(rep(" ", tab_width), collapse = "")

  # code for including table definitions
  code_tables <- if ("tables" %in% options) dm_paste_tables(dm, tab)

  # code for including the tables
  code_construct <- dm_paste_construct(dm, tab)

  # adding code for selection of columns
  code_select <- if ("select" %in% options) dm_paste_select(dm)

  # adding code for establishing PKs
  code_pks <- if ("keys" %in% options) dm_paste_pks(dm)

  # adding code for establishing FKs
  code_fks <- if ("keys" %in% options) dm_paste_fks(dm)

  # adding code for color
  code_color <- if ("color" %in% options) dm_paste_color(dm)

  # combine dm and paste code
  code_dm <- glue_collapse(
    c(
      code_construct,
      code_select,
      code_pks,
      code_fks,
      code_color
    ),
    sep = glue(" %>%\n{tab}", .trim = FALSE)
  )

  paste0(code_tables, code_dm)
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

dm_paste_construct <- function(dm, tab) {
  if (length(dm) == 0) {
    return("dm::dm(\n)")
  }

  paste0(
    "dm::dm(\n",
    paste0(tab, tick_if_needed(src_tbls_impl(dm)), ",\n", collapse = ""),
    ")"
  )
}

dm_paste_select <- function(dm) {
  tbl_select <-
    dm %>%
    dm_get_def() %>%
    mutate(cols = map(data, colnames)) %>%
    mutate(cols = map_chr(cols, ~ glue_collapse1(glue(", {tick_if_needed(.x)}")))) %>%
    mutate(code = glue("dm::dm_select({tick_if_needed(table)}{cols})")) %>%
    pull()
}

dm_paste_pks <- function(dm) {
  dm %>%
    dm_get_all_pks_impl() %>%
    mutate(code = glue("dm::dm_add_pk({tick_if_needed(table)}, {deparse_keys(pk_col)})")) %>%
    pull()
}

dm_paste_fks <- function(dm) {
  pks <-
    dm %>%
    dm_get_all_pks_impl() %>%
    set_names(c("parent_table", "parent_default_pk_cols"))

  fks <-
    dm %>%
    dm_get_all_fks_impl()

  fpks <-
    left_join(fks, pks, by = "parent_table")

  need_non_default <- !map2_lgl(fpks$parent_key_cols, fpks$parent_default_pk_cols, identical)
  fpks$non_default_parent_key_cols <- ""
  fpks$non_default_parent_key_cols[need_non_default] <- paste0(", ", deparse_keys(fpks$parent_key_cols[need_non_default]))

  on_delete <- if_else(
    fpks$on_delete != "no_action",
    glue(", on_delete = \"{fpks$on_delete}\""),
    ""
  )

  glue("dm::dm_add_fk({tick_if_needed(fpks$child_table)}, {deparse_keys(fpks$child_fk_cols)}, {tick_if_needed(fpks$parent_table)}{fpks$non_default_parent_key_cols}{on_delete})")
}

dm_paste_color <- function(dm) {
  colors <- dm_get_colors(dm)
  colors <- colors[names(colors) != "default"]
  glue("dm::dm_set_colors({tick_if_needed(names(colors))} = {tick_if_needed(colors)})")
}

df_paste <- function(x, tab) {
  cols <- map_chr(x, deparse_line)
  if (is_empty(x)) {
    cols <- character()
  } else {
    cols <- paste0(tab, tick_if_needed(names(cols)), " = ", cols, ",\n", collapse = "")
  }

  paste0("tibble::tibble(\n", cols, ")")
}

deparse_line <- function(x) {
  attrs <- attributes(x)
  # Workaround necessary for R < 3.5:
  if (length(attrs) > 0) {
    attributes(x) <- attrs[sort(names(attrs))]
  }
  x <- deparse(x, width.cutoff = 500, backtick = TRUE)
  gsub(" *\n *", " ", x)
}

glue_collapse1 <- function(x, ...) {
  if (is_empty(x)) {
    ""
  } else {
    glue_collapse(x, ...)
  }
}

dquote <- function(x) {
  if (is_empty(x)) {
    return(character())
  }
  paste0('"', x, '"')
}

# Errors ------------------------------------------------------------------

abort_unknown_option <- function(options, all_options) {
  abort(error_txt_unknown_option(options, all_options), .subclass = dm_error_full("unknown_option"))
}

error_txt_unknown_option <- function(options, all_options) {
  bad_options <- setdiff(options, all_options)
  glue("Option unknown: {commas(dquote(bad_options))}. Must be one of {commas(dquote(all_options))}.")
}
