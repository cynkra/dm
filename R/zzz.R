.onLoad <- function(libname, pkgname) {
  backports::import(pkgname, c("...length"))
  backports::import(pkgname, c("...names"))

  if (getRversion() >= "3.4") {
    dm_financial <<- memoise::memoise(dm_financial, cache = cache_attach())
    dm_financial_sqlite <<- memoise::memoise(dm_financial_sqlite, cache = cache_attach())
  }

  nycflights_subset <<- memoise::memoise(nycflights_subset, cache = cache_attach())

  dm_has_financial <<- memoise::memoise(dm_has_financial, cache = cache_attach())

  check_suggested <<- memoise::memoise(check_suggested)

  register_pkgdown_methods()

  check_version_on_load
  vctrs::s3_register("waldo::compare_proxy", "dm")

  check_version_on_load(
    "RSQLite",
    "2.2.8",
    "to use the {.code returning} argument in {.code rows_*()}."
  )
  check_version_on_load("dbplyr", "2.2.0", "to use the {.code rows_*()} functions.")

  # rigg(enum_pk_candidates_impl)
  # rigg(build_copy_data)
  # rigg(dm_insert_zoomed_outgoing_fks)
  # rigg(dm_upgrade)
  # rigg(check_df_structure)
  # rigg(dm_insert_zoomed)
  # rigg(dm_select_tbl_impl)
  # rigg(dm_insert_zoomed_outgoing_fks)
  # rigg(dm_rm_pk_impl)
  # rigg(dm_rm_fk_impl)
  # rigg(cdm_rm_fk)

  rlang::run_on_load()
}

.onAttach <- function(libname, pkgname) {
  if (!isTRUE(getOption("dm.suppress_dplyr_startup_message"))) {
    attached <- search()
    missing_pkgs <- setdiff(
      "dplyr",
      sub("^package:", "", grep("^package:", attached, value = TRUE))
    )
    if (length(missing_pkgs) > 0) {
      packageStartupMessage(cli::format_message(c(
        "!" = paste0(
          "In a coming version, {.pkg dm} will no longer reexport {.pkg dplyr} functions. ",
          'For best results, run {.code library("dplyr")} before {.code library("dm")}.'
        ),
        "i" = "To suppress this message unconditionally, set {.code options(dm.suppress_dplyr_startup_message = TRUE)}."
      )))
    }
  }
}

setup_graph_functions <- function(ns) {
  use_igraph <- getOption("dm.use_igraph")

  if (is.null(use_igraph) && !rlang::is_installed("igraph")) {
    packageStartupMessage(cli::format_message(c(
      "!" = "Package {.pkg igraph} is not installed. {.pkg dm} will use a pure R fallback.",
      "i" = "Install {.pkg igraph} for better performance: {.run install.packages(\"igraph\")}",
      "i" = "Set {.code options(dm.use_igraph = FALSE)} to suppress this message."
    )))
  } else if (isTRUE(use_igraph)) {
    rlang::check_installed("igraph", reason = "because `options(dm.use_igraph = TRUE)` is set.")
  } else if (isFALSE(use_igraph) || !rlang::is_installed("igraph")) {
    graph_from_data_frame <<- graph_from_data_frame_fallback
    graph_vertices <<- graph_vertices_fallback
    graph_edges <<- graph_edges_fallback
    graph_dfs <<- graph_dfs_fallback
    graph_topo_sort <<- graph_topo_sort_fallback
    graph_distances <<- graph_distances_fallback
    graph_induced_subgraph <<- graph_induced_subgraph_fallback
    graph_shortest_paths <<- graph_shortest_paths_fallback
    graph_delete_vertices <<- graph_delete_vertices_fallback
    graph_neighbors <<- graph_neighbors_fallback
    graph_vcount <<- graph_vcount_fallback
    graph_girth <<- graph_girth_fallback
  }
}

rigg <- function(fun) {
  name <- deparse(substitute(fun))

  rig <- get("rig", asNamespace("boomer"), mode = "function")

  assign(name, rig(fun, ignore = c("~", "{", "(")), getNamespace("dm"))
}

check_version_on_load <- function(package, version, reason) {
  check_version <- function(...) {
    if (utils::packageVersion(package) < version) {
      message <- c(
        paste0("You need {.pkg {package} >= {version}} ", reason),
        `i` = 'Install with {.code install.packages("{package}")}'
      )

      cli::cli_inform(message)
    }
  }

  # Always register hook in case package is later unloaded & reloaded
  setHook(packageEvent(package, "onLoad"), check_version)

  # Avoid registration failures during loading (pkgload or regular)
  if (isNamespaceLoaded(package)) {
    check_version()
  }

  invisible()
}
