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
  pks <- dm_get_all_pks(dm)
  fks <- dm_get_all_fks(dm)

  tbl_defs <-
    list(
      tbl = dm_get_tables(dm),
      pks = deframe(pks),
      children = split(fks$child_table, fks$parent_table),
      fks = split(fks, fks$child_table)
    ) %>%
    transpose()

  gather <- function(tbl_nm, except = NULL) {
    # browser()
    tbl_def <- tbl_defs[[tbl_nm]]
    own_keys <- compact(tbl_def[c("pks", "fks")])
    tbl <- tbl_def$tbl

    # gather children
    children_keys <- list()
    children_nms <- setdiff(tbl_def$children, except)
    for (child_nm in children_nms) {
      tbl_keys <- gather(child_nm, except = tbl_nm)
      child_tbl <- tbl_keys$tbl
      child_keys <- tbl_keys$keys
      children_keys[[child_nm]] <- child_keys
      fks <- filter(child_keys$own_keys$fks, parent_table == tbl_nm)
      by <- with(fks, set_names(unlist(child_fk_cols), unlist(parent_key_cols)))
      tbl <- nest_join(tbl, child_tbl, by = by, name = child_nm)
    }
    children_keys <- compact(children_keys)

    # gather parents
    parents_keys <- list()
    parent_nms <- setdiff(unique(tbl_def$fks$parent_table), except)
    for (parent_nm in parent_nms) {
      tbl_keys <- gather(parent_nm, except = tbl_nm)
      parent_tbl <- tbl_keys$tbl
      parent_keys <- tbl_keys$keys
      parents_keys[[parent_nm]] <- parent_keys
      fks <- filter(tbl_def$fks, parent_table == parent_nm)
      by <- with(fks, set_names(unlist(parent_key_cols), unlist(child_fk_cols)))
      # FIXME: when pack_join is merged, replace next lines
      parent_tbl <- pack(parent_tbl, !!parent_nm := -match(by, names(parent_tbl)))
      tbl <- left_join(tbl, parent_tbl, by = by)
      # tbl <- pack_join(tbl, parent_tbl, by = by_cols, name = parent_tbl_nm)
    }
    parents_keys <- compact(parents_keys)

    # add keys
    keys <-
      lst(own_keys, children_keys, parents_keys) %>%
      compact()

    lst(tbl, keys)
  }

  gather(root)
}

#' Convert a tibble to a dm
#'
#' @param data a tibble containing a nested dm, created by `dm_to_tibble()`
#' @param keys a nested list containing keys, created by `dm_to_tibble()`
#' @param root the name of the main table, i.e. the name of the root table used
#'   in the `dm_to_tibble()` call.
#'
#' @return a dm
#'
#' @noRd
tibble_to_dm <- function(data, keys, root) {
  dm <- dm()
  populate <- function(tbl, tbl_nm, keys) {
    # browser()
    # populate dm with parents
    parents_lgl <- map_lgl(tbl, is.data.frame)
    for (parent_nm in names(tbl)[parents_lgl]) {
      ## fetch data frame col
      parent_tbl <- tbl[[parent_nm]]
      parent_keys <- keys$parents_keys[[parent_nm]]
      ## bind its key cols back
      fks <- filter(keys$own_keys$fks, parent_table == parent_nm)
      by_cols <-
        with(fks, set_names(unlist(parent_key_cols), unlist(child_fk_cols)))
      parent_tbl <- bind_cols(
        set_names(tbl[names(by_cols)], by_cols),
        parent_tbl
      )
      populate(parent_tbl, parent_nm, parent_keys)
      tbl[[parent_nm]] <- NULL
    }

    # populate dm with children
    children_lgl <- map_lgl(tbl, is_bare_list)
    for (child_nm in names(tbl)[children_lgl]) {
      ## fetch list col in its own data frame
      child_tbl <- tbl[child_nm]
      child_keys <- keys$children_keys[[child_nm]]
      ## bind its key cols back and reshape
      fks <- filter(child_keys$own_keys$fks, parent_table == tbl_nm)
      by_cols <-
        with(fks, set_names(unlist(child_fk_cols), unlist(parent_key_cols)))
      child_tbl <- bind_cols(
        set_names(tbl[names(by_cols)], by_cols),
        child_tbl
      ) %>%
        unnest(!!child_nm) %>%
        # assuming duplicate rows make no sense in data bases
        # otherwise not robust
        unique()
      populate(child_tbl, child_nm, child_keys)
      tbl[[child_nm]] <- NULL
    }

    pks <- keys$own_keys$pks
    pk_arg <- call2("c", !!!syms(pks))
    dm <<- dm %>%
      dm_add_tbl(!!tbl_nm := tbl) %>%
      dm_add_pk(!!sym(tbl_nm), !!pk_arg)
  }

  add_fks <- function(keys) {
    # browser()
    fks <- keys$own_keys$fks
    for (i in seq_len(NROW(fks))) {
      table <- fks$child_table[[i]]
      columns <- fks$child_fk_cols[[i]]
      columns_arg <- call2("c", !!!syms(columns))
      ref_table <- fks$parent_table[[i]]
      dm <<- dm_add_fk(dm, !!sym(table), !!columns_arg, !!sym(ref_table))
    }
    for (key in keys$parents_keys) {
      add_fks(key)
    }
    for (key in keys$children_keys) {
      add_fks(key)
    }
  }

  populate(data, root, keys)
  add_fks(keys)
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
      # browser()
      empty = !NROW(item)
      if (empty) {
        # toJSON destroys empty tibbles so to save the format we keep a 1
        # row table and we tag as empty
        # we use placeholders to preserve format
        item <- item[NA_integer_, ]
        item[map_lgl(item, is.integer)] <- 1L
        item[map_lgl(item, is.double)] <- 1
        item[map_lgl(item, is.character)] <- "a"
        item[map_lgl(item, is_tibble)] <- list(tibble(a = 1)[0])
        item[map_lgl(item, is_bare_list)] <- list(list(1))
      }
      jsonlite::toJSON(list(
        empty = if (empty) TRUE,
        data = serialize_list_cols(item)
      ),
      na = "string"
      )
    })
  })
  x[parent_lgl] <- map(x[parent_lgl], \(df){
    # split by row before serialization
    # browser()
    row_dfs <- split(df, seq_len(nrow(df)))
    map_chr(row_dfs, \(row_df) {
      jsonlite::toJSON(list(
        data = serialize_list_cols(row_df)
      ),
      na = "string"
      )
    })
  })
  names(x)[children_lgl] <- paste0(names(x)[children_lgl], "_json_child")
  names(x)[parent_lgl] <- paste0(names(x)[parent_lgl], "_json_parent")
  x
}

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
    # browser()
    unserialized_obj <- map(col, jsonlite::fromJSON)

    unserialized_col <- map(unserialized_obj, ~ {
      #
      data <- unserialize_json_cols(.x$data)
      # rebuild empty data frames
      if (isTRUE(.x$empty)) {
        # browser()
        data <- data[0, ]
      }
      data
    })
    keys <- unserialized_obj[[1]]$keys
    unserialized_col
  })

  x[parent_lgl] <- map(x[parent_lgl], \(col) {
    # browser()
    unserialized_obj <- map(col, jsonlite::fromJSON)
    unserialized_col <- map_dfr(unserialized_obj, ~ unserialize_json_cols(.x$data))
    keys <- unserialized_obj[[1]]$keys
    unserialized_col
  })

  names(x)[children_lgl] <- sub("_json_child$", "", names(x)[children_lgl])
  names(x)[parent_lgl] <- sub("_json_parent$", "", names(x)[parent_lgl])
  x
}
