#' Remove cycles from a [`dm`]
#'
#' Produce a cycle-free [`dm`] by multiplying parent tables
#'
#' @inheritParams dm_disambiguate_cols
#' @param naming_template Naming template for the tables to be created as a length 1 character variable.
#' Default `NULL` leads to names of the form: `<parent_table>_<row_number>`.
#' Keywords are:
#' - `.pt`  : original name of parent table
#' - `.pkc` : primary key column name(s) of original parent table. Multiple columns are separated by an underscore.
#' - `.ct`  : name of child table
#' - `.fkc` : foreign key column name(s). Multiple columns are separated by an underscore
#' - `.num` : integer counting the tables based on each original parent table
#'
#' @details Starting from the graph representation of the `dm`, it is tested which
#' of the graph's components (connected undirectional subgraphs) has a cycle.
#' Now taking the direction of the relations into account, for components with a cycle
#' it is now it is determined which vertices (here: parent tables) have both:
#' - 2 or more incoming foreign keys
#' - multiple possible (undirected) paths between the participating tables in at last one of those foreign keys
#'
#' Those tables are copied and reinserted into the `dm` with a new name while distributing the
#' foreign keys among the newly created tables.
#'
#' This function is a no-op if:
#' - no cycles are detected.
#' - at least one "endless" cycles is detected (possible to walk endlessly in direction of arrows).
#'
#' @return A cycle-free `dm` object.
#' @export
#'
#' @examples
#' dm_disentangle(dm_nycflights13())
#' dm_disentangle(dm_nycflights13(cycle = TRUE))
#' dm_disentangle(dm_nycflights13(cycle = TRUE), naming_template = ".pt..fkc")
dm_disentangle <- function(dm, naming_template = NULL, quiet = FALSE) {
  # if not all tables are connected, the condition
  # length(E(g)) < length(V(g))
  # is not enough to determine that there is no cycle
  # we need to break up the graph into independent subgraphs using igraph::decompose()
  full_g <- create_graph_from_dm(dm, directed = TRUE)
  g <- igraph::decompose(full_g)
  # if there is no cycle in any of the components we don't need to do anything
  no_cycles <- map_lgl(g, ~ length(E(.)) < length(V(.)))
  if (all(no_cycles)) {
    message("No cycle detected, returning original `dm`.")
    return(dm)
  }

  # get all incoming edges, recreate the vertices (parent tables) with more than 1 incoming edge
  # as often as there are incoming edges and use one foreign key relation per vertex,
  # unless there is just 1 path between the two vertices
  all_edges_in <- map(
    g[!no_cycles], ~ igraph::incident_edges(., V(.), mode = "in")
  ) %>%
    flatten()

  num_edges_in <- map_int(all_edges_in, length)
  multiple_edges_in <- all_edges_in[num_edges_in > 1]

  # see https://github.com/cynkra/dm/pull/862#issuecomment-1070989387
  # need to determine which edges are acceptable as they are
  # (those still might need to be re-implemented if the vertex is replaced)
  edge_participants <- map(multiple_edges_in, attr, "vnames") %>%
    map(strsplit, split = "\\|") %>%
    enframe(name = "parent_table", value = "child_table") %>%
    unnest(child_table) %>%
    mutate(child_table = map_chr(child_table, ~ .x[1])) %>%
    # igraph::all_simple_paths() counts multiple edges between two vertices as one path:
    # in this case we use the number of foreign keys
    mutate(num_paths = map2_int(
      parent_table,
      child_table,
      ~ max(
        length(dm_get_all_fks_impl(dm) %>% filter(parent_table == .x, child_table == .y) %>% pull()),
        length(igraph::all_simple_paths(full_g, .x, .y, mode = "all"))
      )
    ))

  # only those parent tables have to be recreated who have at least one entry
  # with multiple simple paths between the related tables
  action_needed <- edge_participants %>%
    group_by(parent_table) %>%
    summarize(any_mult_path = any(num_paths > 1), .groups = "drop") %>%
    filter(any_mult_path) %>%
    pull(parent_table)

  # if for any graph component with a cycle no action is needed for any parent table,
  # that means that for this component there are either:
  # - no parent tables with 2 or more incoming FKs
  # - or if there are such parent tables, then for each such FK relation there
  #   is only that one (direct) path possible between parent and child table
  # This implies, that the detected cycle must be an "endless" cycle, i.e. you can
  # walk in the direction of the arrows endlessly -> this case does not have a unique
  # solution, therefore the original `dm` is returned.
  endless_cycles <- map_lgl(g[!no_cycles], ~ !any(action_needed %in% names(igraph::V(.))))
  if (any(endless_cycles)) {
    failed_components <- map_chr(g[!no_cycles][endless_cycles], ~ commas(tick(names(igraph::V(.)))))
    cli::cli_alert_warning(
      glue(
        "Returning original `dm`, endless cycle{s_if_plural(failed_components)['n']} ",
        "detected in component{s_if_plural(failed_components)['n']}:\n(",
        paste(map_chr(g[!no_cycles][endless_cycles], ~ commas(tick(names(igraph::V(.))))), collapse = ")\n("),
        ")\nNot supported are cycles of types:"
      )
    )
    cli::cat_bullet(
      c('`tbl_1` -> `tbl_2` -> `tbl_3` -> `tbl_1`', '`tbl_1` -> `tbl_2` -> `tbl_1`'),
      bullet_col = 'red'
    )
    return(dm)
  }

  recipe <- edge_participants %>%
    filter(parent_table %in% !!action_needed) %>%
    left_join(dm_get_all_fks_impl(dm), by = c("parent_table", "child_table")) %>%
    distinct() %>%
    group_by(parent_table) %>%
    mutate(create_new_table = num_paths > 1) %>%
    arrange(desc(create_new_table)) %>%
    mutate(
      child_fk_cols_char = map_chr(child_fk_cols, ~ paste0(unlist(.x), collapse = "_")),
      parent_key_cols_char = map_chr(parent_key_cols, ~ paste0(unlist(.x), collapse = "_"))
    ) %>%
    # create table names for new parent tables
    # for those relations where no new parent table is required we're using the first newly created table
    mutate(new_pt_name = if_else(
      create_new_table,
      glue::glue(create_new_pt_name(naming_template)),
      NA_character_)
    ) %>%
    mutate(new_pt_name = if_else(!create_new_table, new_pt_name[1], new_pt_name)) %>%
    select(-num_paths) %>%
    group_split()

  rm_cycles(dm, recipe, quiet)
}

rm_cycles <- function(dm, recipe, quiet) {
  for (i in seq_len(length(recipe))) {
    dm <- rm_cycle_one_pt(dm, recipe[[i]], quiet)
  }
  dm
}

rm_cycle_one_pt <- function(dm, recipe_tbl, quiet) {
  # remove all FKs from original parent table (otherwise dm_insert_zoomed will make use of them)
  new_dm <- dm_get_def(dm) %>%
    mutate(fks = if_else(table == unique(recipe_tbl$parent_table), list_of(new_fk()), fks)) %>%
    new_dm3() %>%
    reduce(
      unique(recipe_tbl$new_pt_name),
      insert_new_pts,
      old_pt_name = unique(recipe_tbl$parent_table),
      .init = .
    ) %>%
    dm_rm_tbl(unique(recipe_tbl$parent_table))
  if (!quiet) {
    message(glue::glue(
      "Replaced table {tick(unique(recipe_tbl$parent_table))} with ",
      "{commas(tick(unique(recipe_tbl$new_pt_name)))}."))
  }

  for (i in seq_len(nrow(recipe_tbl))) {
    new_dm <- dm_add_fk_impl(
      new_dm,
      recipe_tbl$child_table[i],
      recipe_tbl$child_fk_cols[i],
      recipe_tbl$new_pt_name[i],
      recipe_tbl$parent_key_cols[i],
      on_delete = recipe_tbl$on_delete[i]
    )
  }
  new_dm
}

insert_new_pts <- function(dm, old_pt_name, new_pt_name) {
  dm_zoom_to(dm, !!old_pt_name) %>%
    dm_insert_zoomed(!!new_pt_name)
}

create_new_pt_name <- function(naming_template) {
  if (is.null(naming_template)) {
    "{parent_table}_{row_number()}"
  } else {
    gsub(".pt", "{parent_table}", naming_template) %>%
      gsub(".pkc", "{parent_key_cols_char}", .) %>%
      gsub(".ct", "{child_table}", .) %>%
      gsub(".fkc", "{child_fk_cols_char}", .) %>%
      gsub(".num", "{row_number()}", .)
  }
}
