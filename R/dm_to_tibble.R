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

  def <- dm_get_def(dm)

  gather_children <- function(def, root, except = NULL) {
    fks_subset <- filter(fks, parent_table == root)
    tbl <- def$data[[which(def$table == root)]]
    n_children <- nrow(fks_subset)
    for(i in seq_len(n_children)) {
      child_tbl_nm <- fks_subset$child_table[i]

      ## recurse if relevant
      if(child_tbl_nm %in% except) next
      def <- gather_children(def, child_tbl_nm)
      def <- gather_parents(def, child_tbl_nm, except = root)

      ## nest child table
      keys <- list(
        fks = fks_subset[i, c("child_fk_cols", "parent_key_cols", "on_delete")],
        pks = pks[pks$table == child_tbl_nm,]
      )
      by_cols <- with(keys$fks, setNames(unlist(child_fk_cols), unlist(parent_key_cols)))
      child_tbl <- def$data[[which(def$table == child_tbl_nm)]]
      tbl <- nest_join(tbl, child_tbl, by = by_cols, name = child_tbl_nm)

      ## store keys for reverse op
      # since nesting splits table and destroys attributes we store the child's
      # keys next to the table's own keys
      child_keys <- compact(map(child_tbl, attr, "..keys.."))
      attr(tbl[[child_tbl_nm]], "..keys..") <- list(own = keys, child_keys = child_keys)

      ## remove child from def
      def <- def[def$table != child_tbl_nm, ]
    }
    ## update def
    def$data[[which(def$table == root)]] <- tbl
    def
  }

  gather_parents <- function(def, root, except = NULL) {
    fks_subset <- filter(fks, child_table == root)
    tbl <- def$data[[which(def$table == root)]]
    n_parents <- nrow(fks_subset)
    for(i in seq_len(n_parents)) {
      parent_tbl_nm <- fks_subset$parent_table[i]

      ## recurse if relevant
      if(parent_tbl_nm %in% except) next
      def <- gather_parents(def, parent_tbl_nm)
      def <- gather_children(def, parent_tbl_nm, except = root)

      ## pack parent table
      keys <- list(
        fks = fks_subset[i, c("child_fk_cols", "parent_key_cols", "on_delete")],
        pks = pks[pks$table == parent_tbl_nm,]
      )
      by_cols <- with(keys$fks, setNames(unlist(parent_key_cols), unlist(child_fk_cols)))
      parent_tbl <- def$data[[which(def$table == parent_tbl_nm)]]
      # FIXME: when pack_join is merged, replace next lines
      parent_tbl <- pack(parent_tbl, !!parent_tbl_nm := -match(by_cols, names(parent_tbl)))
      tbl <- left_join(tbl, parent_tbl, by = by_cols)
      # tbl <- pack_join(tbl, parent_tbl, by = by_cols, name = parent_tbl_nm)

      ## store keys for reverse op
      attr(tbl[[parent_tbl_nm]], "..keys..") <- keys

      ## remove parent from def
      def <- def[def$table != parent_tbl_nm, ]
    }
    ## update def
    def$data[[which(def$table == root)]] <- tbl
    def
  }

  ## setup global variables
  # to ease the round trips we remove all unnecessary attrs since toJSON/fromJSON strips them
  pks <- as.data.frame(dm_get_all_pks(dm))
  fks <- as.data.frame(dm_get_all_fks(dm))
  pks[] <- map(pks, unclass)
  fks[] <- map(fks, unclass)
  attributes(pks$pk_col) <- NULL
  attributes(fks$parent_key_cols) <- NULL
  attributes(fks$child_fk_cols) <- NULL

  ## gather all tables into root table
  def <- gather_children(def, root)
  def <- gather_parents(def, root)
  tbl <- def$data[[1]]

  ## set the root table's keys as attributes
  keys <- list(
    fks = fks[fks$child_table == root, c("child_fk_cols", "parent_table", "parent_key_cols", "on_delete")],
    pks = pks[pks$table == root,]
  )
  attr(tbl, "..keys..") <- keys

  tbl
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

  replace_in_dm <- function(nm, new) {
    def <- dm_get_def(dm)
    def$data[[which(def$table == nm)]] <- new
    new_dm3(def)
  }

  populate_with_parents <- function(root) {
    tbl <- dm[[root]]
    parents_lgl <- map_lgl(tbl, is.data.frame)
    for (parent_tbl_nm in names(tbl)[parents_lgl]) {
      ## fetch data frame col
      parent_tbl <- tbl[[parent_tbl_nm]]

      ## bind its key cols back, removing "..keys.." attr
      keys <- attr(parent_tbl, "..keys..")
      by_cols <- with(keys$fks, setNames(unlist(parent_key_cols), unlist(child_fk_cols)))
      attr(parent_tbl, "..keys..") <- NULL
      parent_tbl <- bind_cols(
        setNames(tbl[names(by_cols)], by_cols),
        parent_tbl
      )

      ## set keys back in the dm
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

      ## recurse
      populate_with_parents(parent_tbl_nm)
      populate_with_children(parent_tbl_nm)
    }
    ## remove from source table and update dm
    tbl[parents_lgl] <- NULL
    dm <<- replace_in_dm(root, tbl)
  }

  populate_with_children <- function(root) {
    tbl <- dm[[root]]
    children_lgl <- map_lgl(tbl, is_bare_list)
    for (child_tbl_nm in names(tbl)[children_lgl]) {
      ## fetch list col in its own data frame
      child_tbl <- tbl[child_tbl_nm]

      ## bind its key cols back and reshape, removing "..keys.." attr
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

      ## set keys back in the dm
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

      ## recurse
      populate_with_children(child_tbl_nm)
      populate_with_parents(child_tbl_nm)
    }

    ## remove from source table and update dm
    tbl[children_lgl] <- NULL
    dm <<- replace_in_dm(root, tbl)
  }

  ## buid dm from root table
  keys <- attr(data, "..keys..")
  pks <- keys$pks$pk_col[[1]]
  pk_arg <- call2("c", !!!syms(pks))
  dm <- dm(!!root := data) %>%
    dm_add_pk(!!sym(root), !!pk_arg)

  ## populate recursively
  populate_with_parents(root)
  populate_with_children(root)

  ## remove attributes from root table
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
  # FIXME: Use correct `top_level_fun` once we have the round trip and wrappers
  check_suggested("jsonlite", TRUE, top_level_fun = "serialize_list_cols")
  children_lgl <- map_lgl(x, is_bare_list)
  parent_lgl <- map_lgl(x, is.data.frame)
  x[children_lgl] <- map(x[children_lgl], \(col){
    map_chr(col, \(item) {
      #browser()
      empty = !nrow(item)
      if(empty) {
        # toJSON destroys empty tibbles so to save the format we keep a 1
        # row table and we tag as empty
        # we use placeholders to preserve format
        item <- item[1,]
        item[map_lgl(item, is.integer)] <- 1L
        item[map_lgl(item, is.double)] <- 1
        item[map_lgl(item, is.character)] <- "a"
        item[map_lgl(item, is_tibble)] <- list(tibble(a = 1))
        item[map_lgl(item, is_bare_list)] <- list(list(1))
      }
      jsonlite::toJSON(list(
        #type = "child",
        # toJSON destroys empty tibbles so we save the names to rebuild
        # to be rigorous we'd have to save the type too
        empty = if(empty) TRUE,
        # we repeat keys in each element, we could also store in 1st only
        keys = attr(col, "..keys.."),
        data = serialize_list_cols(item)
      ),
      na = "string")
    })
  })
  x[parent_lgl] <- map(x[parent_lgl], \(df){
    # split by row before serialization
    #browser()
    row_dfs <- split(df, seq_len(nrow(df)))
    map_chr(row_dfs, \(row_df) {
      jsonlite::toJSON(list(
        # we repeat keys in each element, we could also store in 1st only
        #type = "parent",
        keys = attr(col, "..keys.."),
        data = serialize_list_cols(row_df)
      ),
      na = "string")
    })
  })
  names(x)[children_lgl] <- paste0(names(x)[children_lgl], "_json_child")
  names(x)[parent_lgl] <- paste0(names(x)[parent_lgl], "_json_parent")
  x
}

# serialize_list_cols <- function(x) {
#   list_cols_lgl <- map_lgl(x, is.list)
#   x[list_cols_lgl] <- map(x[list_cols_lgl], jsonlite::serializeJSON)
#   x
# }

tibble_from_json <- function(x) as_tibble(jsonlite::fromJSON(x))

#' Unerialize json colums
#'
#' @param x a tibble containing list (incl data frame) columns
#'
#' @return a tibble with list columns replaced with json columns
#'
#' @noRd
unserialize_json_cols <- function(x) {
  # FIXME: Use correct `top_level_fun` once we have the round trip and wrappers
  check_suggested("jsonlite", TRUE, top_level_fun = "serialize_list_cols")
  x <- as_tibble(x)
  children_lgl <- endsWith(names2(x), "_json_child")
  parent_lgl <- endsWith(names2(x), "_json_parent")

  x[children_lgl] <- map(x[children_lgl], \(col) {
    #browser()
    unserialized_obj <- map(col, jsonlite::fromJSON)

    unserialized_col <- map(unserialized_obj, ~ {
      #
      data <- unserialize_json_cols(.x$data)
      # rebuild empty data frames
      if(isTRUE(.x$empty)) {
        #browser()
        data <- data[0,]
      }
      data
      })
    keys <- unserialized_obj[[1]]$keys
    attr(unserialized_col, "..keys..") <- keys
    unserialized_col
    })

  x[parent_lgl] <- map(x[parent_lgl], \(col) {
    #browser()
    unserialized_obj <- map(col, jsonlite::fromJSON)
    unserialized_col <- map_dfr(unserialized_obj, ~unserialize_json_cols(.x$data))
    keys <- unserialized_obj[[1]]$keys
    attr(unserialized_col, "..keys..") <- keys
    unserialized_col
  })

  names(x)[children_lgl] <- sub("_json_child$", "", names(x)[children_lgl])
  names(x)[parent_lgl] <- sub("_json_parent$", "", names(x)[parent_lgl])
  x
}

# unserialize_json_cols <- function(x) {
#   json_cols_lgl <- map_lgl(x, inherits, "json")
#   x[json_cols_lgl] <- map(x[json_cols_lgl], jsonlite::unserializeJSON)
#   x
# }
