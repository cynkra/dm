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
      #if(child_tbl_nm == "tf_2") browser()
      if(child_tbl_nm %in% except) next
      # keys in format c(parent_key_nm = "child_key_nm")
      keys <- setNames(unlist(fks$child_fk_cols[[i]]), unlist(fks$parent_key_cols[[i]]))
      child_tbl <- gather_children(child_tbl_nm)
      dm <<- replace_in_dm(child_tbl_nm, child_tbl)
      child_tbl <- gather_parents(child_tbl_nm, except = root)
      tbl <- nest_join(tbl, child_tbl, by = keys, name = child_tbl_nm)
      # store keys for reverse op
      child_keys <- compact(map(child_tbl, attr, "..keys.."))
      attr(tbl[[child_tbl_nm]], "..keys..") <- list(keys, child_keys)
    }
    tbl
  }

  gather_parents <- function(root, except = NULL) {
    fks <- filter(fks, child_table == root)
    tbl <- dm[[root]]
    n_parents <- nrow(fks)
    for(i in seq_len(n_parents)) {
      parent_tbl_nm <- fks$parent_table[i]
      # if(parent_tbl_nm == "tf_1") browser()
      if(parent_tbl_nm %in% except) next
      # keys in format c(child_key_nm = "parent_key_nm")
      keys <- setNames(unlist(fks$parent_key_cols[[i]]), unlist(fks$child_fk_cols[[i]]))
      parent_tbl <- gather_parents(parent_tbl_nm)
      dm <<- replace_in_dm(parent_tbl_nm, parent_tbl)
      parent_tbl <- gather_children(parent_tbl_nm, except = root)
      parent_tbl <- pack(parent_tbl, !!parent_tbl_nm := -match(keys, names(parent_tbl)))
      tbl <- parent_join(tbl, parent_tbl, by = keys)
      # store keys for reverse op
      attr(tbl[[parent_tbl_nm]], "..keys..") <- keys
    }
    tbl
  }

  fks <- dm_get_all_fks(dm)
  updated_root_tbl <- gather_children(root)
  dm <- replace_in_dm(root, updated_root_tbl)
  gather_parents(root)
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
  dm <- dm(!!root := data)

  replace_in_dm <- function(nm, new) {
    def <- dm_get_def(dm)
    def$data[[which(def$table == nm)]] <- new
    new_dm3(def)
  }

  populate_with_parents <- function(root, except = NULL) {
    #browser()
    tbl <- dm[[root]]
    parents_lgl <- map_lgl(tbl, is.data.frame)
    for (parent_tbl_nm in names(tbl)[parents_lgl]) {
      #if(parent_tbl_nm == "tf_1") browser()
      # fetch data frame col
      parent_tbl <- tbl[[parent_tbl_nm]]

      # bind its keys back
      keys <- attr(parent_tbl, "..keys..")
      attr(parent_tbl, "..key..") <- NULL
      parent_tbl <- bind_cols(
        setNames(tbl[names(keys)], keys),
        parent_tbl
      )
      dm <<- dm_add_tbl(dm, !!parent_tbl_nm := parent_tbl)
      populate_with_parents(parent_tbl_nm)
      populate_with_children(parent_tbl_nm)
    }
    # remove from source table and update dm
    tbl[parents_lgl] <- NULL
    dm <<- replace_in_dm(root, tbl)
  }

  populate_with_children <- function(root, except = NULL) {
    #browser()
    tbl <- dm[[root]]
    children_lgl <- map_lgl(tbl, is_bare_list)
    for (child_tbl_nm in names(tbl)[children_lgl]) {
      #if(child_tbl_nm == "tf_5") browser()
      # fetch list col in its own data frame
      child_tbl <- tbl[child_tbl_nm]

      # bind its keys back
      keys <- attr(child_tbl[[1]], "..keys..")
      attr(child_tbl, "..key..") <- NULL
      #print(names(keys))
      child_tbl <- bind_cols(
        setNames(tbl[names(keys[[1]])], keys[[1]]),
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
      dm <<- dm_add_tbl(dm, !!child_tbl_nm := child_tbl)
      populate_with_children(child_tbl_nm)
      populate_with_parents(child_tbl_nm)
    }
    tbl[children_lgl] <- NULL
    dm <<- replace_in_dm(root, tbl)
  }

  populate_with_parents(root)
  populate_with_children(root)

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
  x[list_cols_lgl] <- map(x[list_cols_lgl], jsonlite::serializeJSON)
  x
}

#' Unerialize json colums
#'
#' @param x a tibble containing list (incl data frame) columns
#'
#' @return a tibble with list columns replaced with json columns
#'
#' @noRd
unserialize_json_cols <- function(x) {
  list_cols_lgl <- map_lgl(x, inherits, "json")
  x[list_cols_lgl] <- map(x[list_cols_lgl], jsonlite::unserializeJSON)
  x
