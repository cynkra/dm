#' Remove cycles from a [`dm`]
#'
#' Produce a cycle-free [`dm`] by multiplying parent tables
#'
#' @inheritParams dm_disambiguate_cols
#' @param naming_template Naming template for the tables to be created as a length 1 character variable.
#' Default `NULL` leads to names of the form: `<parent_table>_<row_number>`.
#' Keywords are given in {glue}-style:
#' - `{.pt}`  : original name of parent table
#' - `{.pkc}` : primary key column name(s) of original parent table. Multiple columns are separated by an underscore.
#' - `{.ct}`  : name of child table
#' - `{.fkc}` : foreign key column name(s). Multiple columns are separated by an underscore
#' - `{.n}` : new table number: integer counting the tables based on each original parent table
#'
#' @details Starting from the graph representation of the `dm`, it is tested which
#' of the graph's components (connected undirectional subgraphs) has a cycle.
#' Now taking the direction of the relations into account, for components with a cycle
#' it is determined which vertices (here: parent tables) have both:
#' - 2 or more incoming foreign keys
#' - multiple possible (undirected) paths between the participating tables in at last one of those foreign keys
#'
#' Certain other conditions are checked and the tables in the resulting list are copied and
#' reinserted into the `dm` with a new name while distributing the
#' foreign keys among the newly created tables.
#'
#' This function will undergo several iterations if necessary to remove all cycles.
#'
#' This function is a no-op if:
#' - no cycles are detected.
#' - at least one "endless" cycles is detected (possible to walk endlessly in direction of arrows).
#'
#' @family remove cyclic FK relations
#' @return A cycle-free `dm` object.
#'
#' @export
#'
#' @examples
#' dm_disentangle(dm_nycflights13())
#' dm_disentangle(dm_nycflights13(cycle = TRUE))
#' dm_disentangle(dm_nycflights13(cycle = TRUE), naming_template = "{.pt}.{.fkc}")
dm_disentangle <- function(dm, naming_template = NULL, quiet = FALSE) {
  cycle_info <- check_cycles_in_components(dm)
  if (all(cycle_info$no_cycles)) {
    message("No cycle detected, returning original `dm`.")
    return(dm)
  }

  endless_cycles <- check_endless_cycles(dm, cycle_info)
  if (!is_empty(endless_cycles)) {
    cli::cli_alert_warning(
      glue(
        "Returning original `dm`, endless cycle{s_if_plural(endless_cycles)['n']} ",
        "detected in component{s_if_plural(endless_cycles)['n']}:\n(",
        paste(endless_cycles, sep = "", collapse = ")\n("),
        ")\nNot supported are cycles of types:"
      )
    )
    cli::cat_bullet(
      c('`tbl_1` -> `tbl_2` -> `tbl_3` -> `tbl_1`', '`tbl_1` -> `tbl_2` -> `tbl_1`'),
      bullet_col = 'red'
    )
    return(dm)
  }

  recipe <- create_recipe_clone_pt(dm, cycle_info, naming_template)
  new_dm <- reduce(recipe, dm_clone_pt_impl, quiet, .init = dm)

  no_cycles <- check_cycles_in_components(new_dm)$no_cycles
  if (!all(no_cycles)) {
    dm_disentangle(new_dm, naming_template, quiet)
  } else {
    new_dm
  }
}

#' Remove cycles from a [`dm`]
#'
#' Multiply a specific parent table based on its foreign key relations
#'
#' @family remove cyclic FK relations
#' @inheritParams dm_disentangle
#' @param parent_table A table of the `dm` with incoming foreign keys
#'
#' @details Firstly, a plan for the multiplication of the given `parent_table` is created.
#' This depends on the number of incoming foreign keys and the number of possible paths
#' between the `parent_table` and its child tables.
#'
#' Subsequently the table is being cloned as many times as is necessary to avoid
#' cycles in the graph representation of the `dm` originating from this table,
#' distributing the originally incoming foreign keys among the clones.
#'
#' For more details about the multiplication plan see [`dm_disentangle`].
#'
#' @return A `dm` object with untangled foreign key relations regarding `parent_table`.
#' @export
#'
#' @examples
#' dm_clone_pt(dm_nycflights13(), flights)
#' dm_clone_pt(dm_nycflights13(), airports)
dm_clone_pt <- function(
    dm,
    parent_table,
    naming_template = NULL,
    quiet = FALSE) {
  table_name <- dm_tbl_name(dm, {{ parent_table }})
  cycle_info <- check_cycles_in_components(dm)

  recipe <- create_recipe_clone_pt(dm, cycle_info, naming_template, table_name)

  if (!has_length(recipe)) {
    message(glue::glue("No reason found to clone {tick(table_name)} returning original `dm`."))
    return(dm)
  }

  dm_clone_pt_impl(dm, recipe[[1]], quiet)
}

dm_clone_pt_impl <- function(dm, recipe_tbl, quiet) {
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
      "{commas(tick(unique(recipe_tbl$new_pt_name)))}."
    ))
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
    gsub("{.pt}", "{parent_table}", naming_template, fixed = TRUE) %>%
      gsub("{.pkc}", "{parent_key_cols_char}", ., fixed = TRUE) %>%
      gsub("{.ct}", "{child_table}", ., fixed = TRUE) %>%
      gsub("{.fkc}", "{child_fk_cols_char}", ., fixed = TRUE) %>%
      gsub("{.n}", "{row_number()}", ., fixed = TRUE)
  }
}

check_cycles_in_components <- function(dm) {
  # if not all tables are connected, the condition
  # length(E(g)) < length(V(g))
  # is not enough to determine that there is no cycle
  # we need to break up the graph into independent subgraphs using igraph::decompose()
  full_g <- create_graph_from_dm(dm, directed = TRUE)
  g <- igraph::decompose(full_g)
  # if there is no cycle in any of the components we don't need to do anything
  no_cycles <- map_lgl(g, ~ length(E(.)) < length(V(.)))
  list(full_g = full_g, g = g, no_cycles = no_cycles)
}

check_endless_cycles <- function(dm, cycle_info) {
  # Checking for endless cycles of all types (`t1` -> `t2` -> `t3` -> `t1`) or
  # (`t1` -> `t2` -> `t3`), i.e. you can walk in the direction of the arrows
  # endlessly -> this case does not have a unique solution, therefore the original `dm` is returned.
  which_endless <- map_lgl(cycle_info$g[!cycle_info$no_cycles], has_endless_cycle)
  map_chr(cycle_info$g[!cycle_info$no_cycles][which_endless], ~ commas(tick(names(igraph::V(.)))))
}

has_endless_cycle <- function(g) {
  distances <- igraph::distances(g, mode = "out")
  num_tables <- dim(distances)[1]
  test_tibble <- crossing(t1 = seq_len(num_tables), t2 = seq_len(num_tables)) %>%
    filter(t1 != t2) %>%
    mutate(dist_lt_inf = map2_lgl(t1, t2, ~ distances[.x, .y] < Inf))
  left_join(
    test_tibble,
    rename(test_tibble, dist_lt_inf_inv = dist_lt_inf),
    by = c("t1" = "t2", "t2" = "t1")
  ) %>%
    mutate(endless_cycle = map2_lgl(dist_lt_inf, dist_lt_inf_inv, ~ all(.x, .y))) %>%
    pull() %>%
    any()
}

create_recipe_clone_pt <- function(
    dm,
    cycle_info,
    naming_template,
    parent_table = NULL) {
  # get all incoming edges, recreate the vertices (parent tables) with more than 1 incoming edge
  # as often as there are incoming edges and use one foreign key relation per vertex,
  # unless there is just 1 path between the two vertices
  all_edges_in <- map(
    cycle_info$g[!cycle_info$no_cycles], ~ igraph::incident_edges(., V(.), mode = "in")
  ) %>%
    flatten()

  num_edges_in <- map_int(all_edges_in, length)
  multiple_edges_in <- all_edges_in[num_edges_in > 1]

  if (!is.null(parent_table)) {
    if (parent_table %in% names(multiple_edges_in)) {
      multiple_edges_in <- multiple_edges_in[parent_table]
    } else {
      return(list())
    }
  }

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
        length(igraph::all_simple_paths(cycle_info$full_g, .x, .y, mode = "all"))
      )
    ))

  # one more tool to decide which PT to deal with first:
  # check if there is a directed path between any two PT considered here
  # choose to first deal with the PT with the lowest total number in this category
  min_directed_paths_from <- if (length(unique(edge_participants$parent_table)) == 1) {
    unique(edge_participants$parent_table)
  } else {
    crossing(
      pt1 = unique(edge_participants$parent_table),
      pt2 = unique(edge_participants$parent_table)
    ) %>%
      filter(pt1 != pt2) %>%
      mutate(num_simple_paths = map2_int(
        pt1,
        pt2,
        ~ length(igraph::all_simple_paths(cycle_info$full_g, .x, .y, mode = "out"))
      )) %>%
      group_by(pt1) %>%
      summarize(num_paths_from = sum(num_simple_paths)) %>%
      filter(num_paths_from == min(num_paths_from)) %>%
      pull(pt1)
  }
  # 1. only those parent tables have to be recreated who have at least one entry
  # with multiple simple paths between the related tables
  # 2. also, if there is only one child table that has multiple paths to the parent table
  # then the problem is often solved when not multiplying this parent table
  # 3. in addition we should start here with the most "central" parent table,
  # that means in this case the one with the highest number of paths between it and its child tables.
  # Under certain circumstances disentangling this table resolves already the whole problem.
  # example: entangled_dm_2()
  # Having said that, there is no proof that this leads to the best results.
  # Might want to revisit that later on.
  action_needed_prep <- edge_participants %>%
    filter(parent_table %in% min_directed_paths_from) %>%
    group_by(parent_table) %>%
    # in addition to the condition
    summarize(
      any_mult_path = any(num_paths > 1) && sum(num_paths > 1) != 1,
      sum_num_paths_gt_1 = sum(num_paths[num_paths > 1]),
      .groups = "drop"
    ) %>%
    filter(any_mult_path)
  action_needed <- if (nrow(action_needed_prep) > 0) {
    action_needed_prep %>%
      filter(sum_num_paths_gt_1 == max(sum_num_paths_gt_1)) %>%
      pull(parent_table)
  } else {
    character(0)
  }

  edge_participants %>%
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
      NA_character_
    )) %>%
    mutate(new_pt_name = if_else(!create_new_table, new_pt_name[1], new_pt_name)) %>%
    select(-num_paths) %>%
    group_split()
}
