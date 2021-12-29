dm_to_tibble <- function(dm, root, parent_join = c("left_join", "full_join")) {
  parent_join <- match.arg(parent_join)
  parent_join <- getFromNamespace(parent_join, "dplyr")

  replace_in_dm <- function(nm, new) {
    def <- dm_get_def(dm)
    def$data[[which(def$table == nm)]] <- new
    new_dm3(def)
  }

  gather_children <- function(root, except = NULL) {
    fks <- filter(fks, parent_table == root)
    tbl <- dm[[root]]
    n_children <- nrow(fks)
    for(i in seq_len(n_children)) {
      child_tbl_nm <- fks$child_table[i]
      if(child_tbl_nm %in% except) next
      keys <- setNames(unlist(fks$child_fk_cols[[i]]), unlist(fks$parent_key_cols[[i]]))
      child_tbl <- gather_children(child_tbl_nm)
      dm <<- replace_in_dm(child_tbl_nm, child_tbl)
      child_tbl <- gather_parents(child_tbl_nm, except = root)
      tbl <- nest_join(tbl, child_tbl, by = keys, name = child_tbl_nm)
    }
    tbl
  }

  gather_parents <- function(root, except = NULL) {
    fks <- filter(fks, child_table == root)
    tbl <- dm[[root]]
    n_parents <- nrow(fks)
    for(i in seq_len(n_parents)) {
      parent_tbl_nm <- fks$parent_table[i]
      if(parent_tbl_nm %in% except) next
      keys <- setNames(unlist(fks$parent_key_cols[[i]]), unlist(fks$child_fk_cols[[i]]))
      parent_tbl <- gather_parents(parent_tbl_nm)
      dm <<- replace_in_dm(parent_tbl_nm, parent_tbl)
      parent_tbl <- gather_children(parent_tbl_nm, except = root)
      parent_tbl <- pack(parent_tbl, !!parent_tbl_nm := -match(keys, names(parent_tbl)))
      tbl <- parent_join(tbl, parent_tbl, by = keys)
    }
    tbl
  }

  fks <- dm_get_all_fks(dm)
  updated_root_tbl <- gather_children(root)
  dm <- replace_in_dm(root, updated_root_tbl)
  gather_parents(root)
}
