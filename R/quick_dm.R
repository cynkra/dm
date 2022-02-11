#' Build a dm with compact syntax
#'
#' `quick_dm()` helps you build a syntax with minimal typing. `->>` and `->`
#' are used here to define foreign key constraints and means something completely
#' different from what they do in base R. Columns that are not provided explicitly
#' are built as logical.
#'
#' @param ... tables or constraints
#'
#' * Tables can be provided just like in `dm()`
#' * `~ table` is used to define an empty table in the dm, this is usually not necessary
#'   because `table` names are infered from constraints
#' * fk to pk relationships are created with `->>`,  fk to non pk parent keys are created with `->`,
#'   below we illustrate with `->>`
#' * `child[child_fk_cols] ->> parent[parent_key_cols]` will create a fk relationship,
#'   it will also create the tables, columns and pk if relevant
#' * `child[child_fk_cols] ->> parent` is the same as `child[child_fk_cols] ->> parent[child_fk_cols]`,
#'   and `child ->> parent[parent_key_cols]` is the same as
#'   `child[parent_key_cols] ->> parent[parent_key_cols]` (i.e. no need to repeat
#'   keys on both sides)
#' * `NULL ->> table[pk_cols]` is used to define a primary key without mentioning
#'   a child table
#' * if `cols` is of length 1 the syntaxes `table[cols]`,
#'  `table[[cols]]` and `table$cols_value`
#'
#' @return a dm
#' @export
#'
#' @examples
#' # minimal dms
#' dm1 <- quick_dm(child$fk ->> parent$pk)
#' dm_draw(dm1)
#'
#' dm2 <- quick_dm(~ table_without_key, NULL ->> table_with_pk$pk)
#' dm_draw(dm2)
#'
#' # reproduce structure of some dms from the package
#' dm_nycflights13_quick <-
#'   quick_dm(
#'     flights$carrier ->> airlines,
#'     flights$tailnum ->> planes,
#'     flights$origin ->> airports,
#'     flights[c("origin", "time_hour")] ->> weather,
#'   )
#' dm_draw(dm_nycflights13_quick)
#'
#' dm_for_filter_quick <-
#'   quick_dm(
#'     tf_2$d ->> tf_1$a,
#'     NULL ->> tf_2$c,
#'     tf_2[c("e","e1")] ->> tf_3[c("f", "f1")],
#'     tf_4[c("j","j1")] ->> tf_3[c("f", "f1")],
#'     tf_5$l ->> tf_4$h,
#'     tf_5$m -> tf_6$n,
#'     NULL ->> tf_5$k,
#'     NULL ->> tf_6$o
#'   )
#' dm_draw(dm_for_filter_quick)
#'
#' # building prototypes for `dm_unnest_tbl`
#' airlines_wrapped <-
#'   dm_nycflights13() %>%
#'     dm_wrap_tbl(airlines)
#'
#' airlines_wrapped %>%
#'   dm_unnest_tbl(airlines, flights, quick_dm(flights$carrier ->> airlines))
quick_dm <- function(...) {
  dots <- enexprs(...)
  env <- caller_env()

  # detect arg types -----------------------------------------------------------
  nms <- names2(dots)
  formulas_lgl <- map_lgl(dots, ~ {
    fml_bool <- is_formula(.x)
    if (fml_bool && !(length(.x) == 2 && is_symbol(.x[[2]])))
      abort("Wrong formula argument, should be of the form `~ table`")
    fml_bool
  })
  fks_lgl <- map_lgl(dots, ~ is_call(., "<-") | is_call(., "<<-"))
  data_frames_lgl <- !(formulas_lgl | fks_lgl)
  named_lgl <- nms != ""
  if (any(named_lgl & !data_frames_lgl))
    abort("Only data frame arguments should be named")

  # extract data frames --------------------------------------------------------
  empty_df_nms <- map_chr(dots[formulas_lgl], ~ as_name(.x[[2]]))
  empty_dfs <- rep_named(empty_df_nms, list(tibble()))
  existing_dfs <- map(exprs_auto_name(dots[data_frames_lgl]), eval, env)
  dfs <- c(empty_dfs, existing_dfs)

  # extract keys take an expression such as `tbl`, `tbl$col_sym`, `tbl[[col_chr]]` or `tbl[col_chrs]`
  # and return a one row tibble of table and keys
  extract_keys <- function(expr, table_col, key_col) {
    if (is.null(expr)) {
      res <- tibble("{table_col}" := NA_character_, "{key_col}" := list(NULL))
    } else if (is_call(expr, "$")) {
      res <- tibble("{table_col}" := as.character(expr[[2]]), "{key_col}" := list(as.character(expr[[3]])))
    } else if (is_call(expr, "[")) {
      if (length(expr) > 3) abort("wrong use of `[`")
      key_name <- eval(expr[[3]], env)
      res <- tibble("{table_col}" := as.character(expr[[2]]), "{key_col}" := list(key_name))
    } else if (is_call(expr, "[[")) {
      if (length(expr) > 3) abort("wrong use of `[[`")
      key_name <- eval(expr[[3]], env)
      if (length(key_name) > 1) abort("wrong use of `[[`")
      res <- tibble("{table_col}" := as.character(expr[[2]]), "{key_col}" := list(key_name))
    } else if (is_symbol(expr)) {
      res <- tibble("{table_col}" := as.character(expr), "{key_col}" := list(NULL))
    }
    res
  }

  # fks ------------------------------------------------------------------------
  fks <- map_dfr(dots[fks_lgl], ~ {
    row <- bind_cols(
      extract_keys(.x[[2]], "parent_table", "parent_key_cols"),
      extract_keys(.x[[3]], "child_table", "child_fk_cols"),
      arrow = as.character(.x[[1]])
    )
    parent_shows_no_key <- is_symbol(.x[[2]])
    child_shows_no_key <- is_symbol(.x[[3]])
    if (parent_shows_no_key) {
      row$parent_key_cols <- row$child_fk_cols
    }
    if (child_shows_no_key) {
      row$child_fk_cols <- row$parent_key_cols
    }

    row
  })

  # implicit tables ------------------------------------------------------------
  implicit_df_nms <- setdiff(
    if (NROW(fks)) c(fks$parent_table, fks$child_table),
    c(names(dfs), NA_character_))
  implicit_dfs <- rep_named(implicit_df_nms, list(tibble()))
  dfs <- c(dfs, implicit_dfs)

  # implicit pks ---------------------------------------------------------------
  pks <- if (NROW(fks)) {
      fks %>%
      filter(arrow == "<<-") %>%
      select(1:2) %>%
      set_names(c("table", "pk_col")) %>%
      distinct()
  }

  fks <-
    fks %>%
    filter(!is.na(child_table))

  # implicit columns -----------------------------------------------------------
  explicit_col_names <-
    map_dfr(dfs, ~ tibble(col = names(.)), .id = "table")

  implicit_col_names <-
    bind_rows(
      if (NROW(pks)) set_names(pks, c("table", "col")),
      if (NROW(fks)) set_names(fks[3:4], c("table", "col")),
      if (NROW(fks)) set_names(fks[1:2], c("table", "col")))

  if (NROW(implicit_col_names)) {
    implicit_col_names <-
      implicit_col_names %>%
      unnest_longer(col) %>%
      setdiff(explicit_col_names)

    if (NROW(implicit_col_names)) {
      for(nm in implicit_col_names$table) {
        cols <- with(implicit_col_names, col[table == nm])
        dfs[[nm]][cols] <- logical()
      }
    }
  }

  # build dm -------------------------------------------------------------------
  dm <- dm(!!!dfs)
  # apply pks
  if (NROW(pks)) {
    dm <- reduce2(pks$table, pks$pk_col, .init = dm, .f = ~{
      dm_add_pk(.x, !!.y, !!..3)
    })
  }
  # apply fks
  if (NROW(fks)) {
    dm <- reduce(
      split(fks, seq(nrow(fks))),
      .init = dm,
      .f = ~{
        dm_add_fk(
          .x, !!.y$child_table, !!.y$child_fk_cols[[1]],
          !!.y$parent_table, !!.y$parent_key_cols[[1]])
      })
  }

  dm
}
