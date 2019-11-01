cdm_disentangle <- function(dm, table) {
  table_name <- as_string(ensym(table))
  check_correct_input(dm, table_name)

  all_entangled_rels <- get_all_entangled_rels(dm, table_name)

  new_dm <- dm
  for (i in seq_along(all_entangled_rels)) {
    fk_rels <- all_entangled_rels[[i]]
    orig_pt_vec <- fk_rels$parent_table
    # name of original parent table
    orig_pt <- unique(orig_pt_vec)
    # original PK or parent table: will be set for each of the new tables
    orig_pt_pk <- cdm_get_pk(new_dm, !!orig_pt)
    # original color of parent table: will be set for each of the new tables
    old_color <- cdm_get_colors(dm) %>%
      filter(table == orig_pt) %>%
      pull(color)
    # list with the new parent tables, already with the new names
    new_pts <- map(orig_pt_vec, ~tbl(new_dm, .)) %>% set_names(fk_rels$new_parent_table)
    new_colors <- set_names(rep(old_color, length(new_pts)), names(new_pts))

    # order in the old version of the dm: the new tables will be inserted right where the old parent table was
    old_order <- src_tbls(new_dm)
    old_ind <- which(orig_pt == old_order) - 1
    new_order <- append(setdiff(old_order, orig_pt), names(new_pts), after = old_ind)

    # in next loop step we start with `new_dm`
    new_dm <-
      # add the new parent tables (duplicates of the old one) with the new names
      reduce2(new_pts, names(new_pts), cdm_add_tbl_impl, .init = new_dm) %>%
      # deselect the old parent table (key relations are dropped) and get things into the right order
      cdm_select_tbl(!!!new_order) %>%
      # each of the new tables gets the same PK
      reduce(names(new_pts), ~cdm_add_pk(..1, !!..2, !!orig_pt_pk), .init = .) %>%
      # set the new FKs pointing from the child table to the new parent tables
      reduce2(fk_rels$child_fk_col, names(new_pts), ~cdm_add_fk(..1, !!table_name, !!..2, !!..3), .init = .) %>%
      # set the old color for all new parent tables
      cdm_set_colors(!!!new_colors)
    }
  new_dm
}

# get all entangled relations in a tibble
get_all_entangled_rels <- function(dm, table_name) {
  cdm_get_all_fks(dm) %>%
    filter(child_table == table_name,
           # finds those direct neighbours that are referenced from table more than once (directed)
           map_lgl(parent_table, ~ sum(. == parent_table) > 1)) %>%
    mutate(new_parent_table = paste0(child_fk_col, ".", parent_table)) %>%
    # each set of duplicate references will be handled separately
    group_split(parent_table)
}
