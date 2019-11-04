#' Disentangle relationships
#'
#' A normalized data model does not contain multiple key relations pointing from one table to another.
#' If such a situation should occur anyway, this function can help to untie the knot.
#'
#' @inheritParams cdm_add_pk
#' @param child_table Table from which multiple foreign keys are pointing to another table
#'
#' @details Sometimes a table points with more than one column to another table.
#' Usually these two columns have a different meaning, but refer to the same primary key values
#' of the parent table, as e.g. in `cdm_nycflights13(cycle = TRUE)`.
#' `cdm_disentangle()` will insert as many copies of the old parent table(s), as there are duplicate key relations between
#' the two tables, replace the old parent table(s) with them and install new foreign key relations, thus
#' removing the cycles in the relationship graph that were introduced in this way.
#'
#' @export
#' @examples
#' cdm_disentangle(cdm_nycflights13(cycle = TRUE), flights)
cdm_disentangle <- function(dm, child_table) {
  table_name <- as_string(ensym(child_table))
  check_correct_input(dm, table_name)
  check_no_filter(dm)

  all_entangled_rels <- get_all_entangled_rels(dm, table_name)

  old_pts <- all_entangled_rels$parent_table
  old_fk_cols <- all_entangled_rels$child_fk_col
  new_pts <- all_entangled_rels$new_parent_table
  new_order <- new_tbl_order(dm, all_entangled_rels)
  new_colors <- all_entangled_rels$color

  # remove old multiple fks between given table and parent table(s)
  reduce2(old_fk_cols, old_pts, ~cdm_rm_fk(..1, !!table_name, !!..2, !!..3), .init = dm) %>%
    # add two new tables, pks are installed, fks are not available (at least not those from given table)
    reduce2(old_pts, new_pts, ~cdm_zoom_to_tbl(..1, !!..2) %>% cdm_insert_zoomed_tbl(!!..3), .init = .) %>%
    # old parent table is deselected, new ones take its place
    cdm_select_tbl(!!!new_order) %>%
    cdm_set_colors(!!!set_names(new_colors, new_pts)) %>%
    # implement the FKs
    reduce2(old_fk_cols, new_pts, ~cdm_add_fk(..1, !!table_name, !!..2, !!..3), .init = .)
}

# get all entangled relations in a tibble
get_all_entangled_rels <- function(dm, table_name) {
  colors <- cdm_get_colors(dm) %>% mutate(color = coalesce(color, "default"))

  cdm_get_all_fks(dm) %>%
    filter(child_table == table_name) %>%
    # finds those direct neighbours that are referenced from table more than once (directed)
    filter(map_lgl(parent_table, ~ sum(. == parent_table) > 1)) %>%
    mutate(new_parent_table = paste0(child_fk_col, ".", parent_table)) %>%
    left_join(colors, by = c("parent_table" = "table"))
}

new_tbl_order <- function(dm, all_entangled_rels) {
  # order in the old version of the dm: the new tables will be inserted right where the old parent table was
  old_order <- src_tbls(dm)
  red_all_entangled_rels <- select(all_entangled_rels, pt = parent_table, npt = new_parent_table) %>%
    group_by(pt) %>%
    summarize(npt = list(npt))
  pt <- red_all_entangled_rels$pt
  npt <- red_all_entangled_rels$npt
  reduce2(
    pt,
    npt,
    ~append(
      setdiff(..1, ..2),
      ..3,
      after = which(..2 == ..1) - 1),
    .init = old_order)
}
