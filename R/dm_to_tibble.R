#' Convert a dm to a nested tibble
#'
#' We start from a chosen table and find other tables recursively, if we use a
#' left join we might lose some data.
#'
#' @param dm a dm
#' @param root the name of the main table
#' @param parent_join the type of join to use to join to the parent
#'
#' @return a tibble
#'
#' @noRd
dm_to_tibble <- function(dm, root) {

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
      keys <- list(
        fks = fks[i, c("child_fk_cols", "parent_key_cols", "on_delete")],
        pks = pks[pks$table == child_tbl_nm,]
      )

      by_cols <- with(keys$fks, setNames(unlist(child_fk_cols), unlist(parent_key_cols)))
      child_tbl <- gather_children(child_tbl_nm)
      dm <<- replace_in_dm(child_tbl_nm, child_tbl)
      child_tbl <- gather_parents(child_tbl_nm, except = root)
      child_keys <- compact(map(child_tbl, attr, "..keys.."))

      tbl <- nest_join(tbl, child_tbl, by = by_cols, name = child_tbl_nm)
      # store keys for reverse op
      attr(tbl[[child_tbl_nm]], "..keys..") <- list(own = keys, child_keys = child_keys)
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
      keys <- list(
        fks = fks[i, c("child_fk_cols", "parent_key_cols", "on_delete")],
        pks = pks[pks$table == parent_tbl_nm,]
      )
      by_cols <- with(keys$fks, setNames(unlist(parent_key_cols), unlist(child_fk_cols)))
      parent_tbl <- gather_parents(parent_tbl_nm)
      dm <<- replace_in_dm(parent_tbl_nm, parent_tbl)
      parent_tbl <- gather_children(parent_tbl_nm, except = root)

      # FIXME: when pack_join is merged, replace next lines
      parent_tbl <- pack(parent_tbl, !!parent_tbl_nm := -match(by_cols, names(parent_tbl)))
      tbl <- left_join(tbl, parent_tbl, by = by_cols)
      # tbl <- pack_join(tbl, parent_tbl, by = by_cols, name = parent_tbl_nm)
      attr(tbl[[parent_tbl_nm]], "..keys..") <- keys
    }
    tbl
  }

  pks <- dm_get_all_pks(dm)
  fks <- dm_get_all_fks(dm)
  updated_root_tbl1 <- gather_children(root)
  dm <- replace_in_dm(root, updated_root_tbl1)
  updated_root_tbl2 <- gather_parents(root)
  keys <- list(
    fks = fks[fks$child_table == root, c("child_fk_cols", "parent_table", "parent_key_cols", "on_delete")],
    pks = pks[pks$table == root,]
  )
  attr(updated_root_tbl2, "..keys..") <- keys
  updated_root_tbl2
}

#' Convert a tibble to a dm
#'
#' @param data a tibble containig a nested dm, created by `dm_to_tibble()`
#' @param root the name of the main table, i.e. the name of the root table used
#'   in the `dm_to_tibble()` call.
#'
#' @return a dm
#'
#' @noRd
tibble_to_dm <- function(data, root) {
  keys <- attr(data, "..keys..")

  pks <- keys$pks$pk_col[[1]]
  pk_arg <- call2("c", !!!syms(pks))
  dm <- dm(!!root := data)   %>%
    dm_add_pk(!!sym(root), !!pk_arg)

  replace_in_dm <- function(nm, new) {
    def <- dm_get_def(dm)
    def$data[[which(def$table == nm)]] <- new
    new_dm3(def)
  }

  populate_with_parents <- function(root) {
    tbl <- dm[[root]]
    parents_lgl <- map_lgl(tbl, is.data.frame)
    for (parent_tbl_nm in names(tbl)[parents_lgl]) {
      # fetch data frame col
      parent_tbl <- tbl[[parent_tbl_nm]]

      # bind its keys back
      keys <- attr(parent_tbl, "..keys..")
      by_cols <- with(keys$fks, setNames(unlist(parent_key_cols), unlist(child_fk_cols)))
      attr(parent_tbl, "..keys..") <- NULL
      parent_tbl <- bind_cols(
        setNames(tbl[names(by_cols)], by_cols),
        parent_tbl
      )
      pks <- keys$pks$pk_col[[1]]
      pk_arg <- call2("c", !!!syms(pks))
      dm <<- dm  %>%
        dm_add_tbl(!!parent_tbl_nm := parent_tbl) %>%
        dm_add_pk(!!sym(parent_tbl_nm), !!pk_arg)
      for (i in seq_len(nrow(keys$fks))) {
        fks <- keys$fks$child_fk_cols[[i]]
        child_fk_arg <- call2("c", !!!syms(fks))
        dm <<- dm_add_fk(dm, !!sym(root), !!child_fk_arg, !!sym(parent_tbl_nm))
      }

      populate_with_parents(parent_tbl_nm)
      populate_with_children(parent_tbl_nm)
    }
    # remove from source table and update dm
    tbl[parents_lgl] <- NULL
    dm <<- replace_in_dm(root, tbl)
  }

  populate_with_children <- function(root) {
    tbl <- dm[[root]]
    children_lgl <- map_lgl(tbl, is_bare_list)
    for (child_tbl_nm in names(tbl)[children_lgl]) {
      # fetch list col in its own data frame
      child_tbl <- tbl[child_tbl_nm]

      # bind its keys back
      keys <- attr(child_tbl[[1]], "..keys..")
      by_cols <- with(keys[[1]]$fks, setNames(unlist(child_fk_cols), unlist(parent_key_cols)))
      attr(child_tbl, "..keys..") <- NULL
      child_tbl <- bind_cols(
        setNames(tbl[names(by_cols)], by_cols),
        child_tbl
      ) %>%
        unnest(!!child_tbl_nm) %>%
        # assuming duplicate rows make no sense in data bases
        # otherwise not robust
        unique()
      # set back the keys
      for(col in names(keys[[2]])) {
        attr(child_tbl[[col]], "..keys..") <- keys[[2]][[col]]
      }

      pks <- keys[[1]]$pks$pk_col[[1]]
      pk_arg <- call2("c", !!!syms(pks))

      dm <<-
        dm_add_tbl(dm, !!child_tbl_nm := child_tbl) %>%
        dm_add_pk(!!sym(child_tbl_nm), !!pk_arg)

      for (i in seq_len(nrow(keys[[1]]$fks))) {
        fks <- keys[[1]]$fks$child_fk_cols[[i]]
        child_fk_arg <- call2("c", !!!syms(fks))
        dm <<- dm_add_fk(dm, !!sym(child_tbl_nm), !!child_fk_arg, !!sym(root))
      }

      populate_with_children(child_tbl_nm)
      populate_with_parents(child_tbl_nm)
    }
    tbl[children_lgl] <- NULL
    dm <<- replace_in_dm(root, tbl)
  }

  populate_with_parents(root)
  populate_with_children(root)

  tbl <- dm[[root]]
  attr(tbl, "..keys..") <- NULL
  dm <- replace_in_dm(root, tbl)
  dm
}


#' Serialize list colums
#'
#' @param x a tibble containing list (incl data frame) columns
#'
#' @return a tibble with list columns replaced with json columns
#'
#' @noRd
serialize_list_cols <- function(x) {
  list_cols_lgl <- map_lgl(x, is.list)
  if(!any(list_cols_lgl)) return(x)
  x[list_cols_lgl] <- map(x[list_cols_lgl], ~ {
    jsonlite::toJSON(list(
      data = serialize_list_cols(.x),
      keys = attr(.x, "..keys..")
    ))
  })
  x
}

# serialize_list_cols <- function(x) {
#   list_cols_lgl <- map_lgl(x, is.list)
#   x[list_cols_lgl] <- map(x[list_cols_lgl], jsonlite::serializeJSON)
#   x
# }

#' Unerialize json colums
#'
#' @param x a tibble containing list (incl data frame) columns
#'
#' @return a tibble with list columns replaced with json columns
#'
#' @noRd
unserialize_json_cols <- function(x) {
  json_cols_lgl <- map_lgl(x, inherits, "json")
  if(!any(json_cols_lgl)) return(x)
  x[json_cols_lgl] <- map(x[json_cols_lgl], ~{
    unserialized_obj <- jsonlite::fromJSON(.x)
    unserialized_col <- unserialize_json_cols(unserialized_obj$data)
    attr(unserialized_col, "..keys..") <- unserialized_obj$keys
    unserialized_col
    })
  x
}

# unserialize_json_cols <- function(x) {
#   json_cols_lgl <- map_lgl(x, inherits, "json")
#   x[json_cols_lgl] <- map(x[json_cols_lgl], jsonlite::unserializeJSON)
#   x
# }
