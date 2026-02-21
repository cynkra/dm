#' Infer primary and foreign keys
#'
#' @description
#' `r lifecycle::badge("experimental")`
#'
#' `dm_infer_keys()` automatically infers primary and foreign key
#' relationships based on column naming heuristics.
#' Unless `quiet = TRUE`, the equivalent `dm_add_pk()` and `dm_add_fk()` calls
#' are emitted as a message.
#'
#' @inheritParams dm_add_pk
#' @param heuristics Character vector of heuristics to use for key inference.
#'   Use `"auto"` (the default) to apply all available heuristics.
#'   Available heuristics:
#'   - `"column_name"`: Finds columns with identical names across tables.
#'     If exactly one table has unique values for a column, that table gets
#'     a primary key and other tables get foreign keys.
#'   - `"id_column"`: Matches columns named `<table>_id` in child tables
#'     to a column named `id` in a parent table.
#'     Simple pluralization rules are applied to match table names
#'     (e.g., `customer_id` matches the `customers` table).
#' @param quiet If `TRUE`, suppresses the message showing the equivalent code.
#'
#' @details
#' The function applies the specified heuristics to detect potential
#' primary and foreign key relationships.
#' Each heuristic looks for commonly applied naming patterns:
#'
#' - **Column name equality** (`"column_name"`): The most basic heuristic.
#'   Columns with the same name in multiple tables indicate a relationship.
#'   This works well for datasets that follow consistent naming conventions
#'   like ADaM (Analysis Data Model) in pharmaceutical research, where
#'   `USUBJID` appears across multiple tables.
#'
#' - **`id` column pattern** (`"id_column"`): Detects the common pattern where
#'   parent tables have an `id` primary key and child tables reference them
#'   via `<table_name>_id` columns (e.g., `customers.id` and `orders.customer_id`).
#'   Handles both `snake_case` and common singular/plural forms.
#'
#' Existing keys are preserved.
#' Columns where all tables have unique values (ambiguous PK) or
#' no table has unique values (no valid PK candidate) are skipped.
#' Constraint checking is not performed; use [dm_examine_constraints()]
#' to validate the inferred keys.
#'
#' @return An updated `dm` with inferred primary and foreign keys added.
#'
#' @concept key inference
#'
#' @examplesIf rlang::is_installed("DiagrammeR")
#' # Create tables with a shared column
#' orders <- tibble::tibble(
#'   order_id = 1:5,
#'   customer_id = c(1L, 2L, 1L, 3L, 2L),
#'   amount = c(100, 200, 150, 300, 250)
#' )
#'
#' customers <- tibble::tibble(
#'   customer_id = 1:3,
#'   name = c("Alice", "Bob", "Charlie")
#' )
#'
#' # Create dm without keys
#' my_dm <- dm(orders, customers)
#'
#' # Automatically infer and add keys
#' my_dm_with_keys <- dm_infer_keys(my_dm)
#' dm_get_all_pks(my_dm_with_keys)
#' dm_get_all_fks(my_dm_with_keys)
#'
#' # Draw the result
#' dm_draw(my_dm_with_keys)
#'
#' @export
dm_infer_keys <- function(dm, ..., heuristics = "auto", quiet = FALSE) {
  check_dots_empty()
  check_not_zoomed(dm)

  all_heuristics <- c("column_name", "id_column")

  if (identical(heuristics, "auto")) {
    heuristics <- all_heuristics
  } else {
    heuristics <- arg_match(heuristics, values = all_heuristics, multiple = TRUE)
  }

  table_names <- src_tbls_impl(dm, quiet = TRUE)

  if (length(table_names) < 2) {
    return(dm)
  }

  tables <- dm_get_tables_impl(dm)
  existing_pks <- dm_get_all_pks_impl(dm)

  # Collect inferred keys across heuristics
  pks_to_add <- list()
  fks_to_add <- list()

  if ("column_name" %in% heuristics) {
    result <- infer_keys_by_column_name(tables, table_names, existing_pks)
    pks_to_add <- c(pks_to_add, result$pks)
    fks_to_add <- c(fks_to_add, result$fks)
  }

  if ("id_column" %in% heuristics) {
    # Merge already-existing and just-inferred PKs
    all_pk_tables <- c(existing_pks$table, vapply(pks_to_add, `[[`, character(1), "table"))
    result <- infer_keys_by_id_column(tables, table_names, all_pk_tables, pks_to_add, fks_to_add)
    pks_to_add <- result$pks
    fks_to_add <- result$fks
  }

  if (length(pks_to_add) == 0 && length(fks_to_add) == 0) {
    if (!quiet) {
      cli::cli_alert_info("No keys could be inferred.")
    }
    return(dm)
  }

  # Emit equivalent code as a message
  if (!quiet) {
    code <- infer_keys_code(pks_to_add, fks_to_add)
    message("Inferred keys:")
    message("dm %>%")
    message(paste0("  ", paste0(code, collapse = " %>%\n  ")))
  }

  # Apply keys
  for (pk in pks_to_add) {
    dm <- dm_add_pk_impl(dm, pk$table, pk$columns, autoincrement = FALSE, force = FALSE)
  }
  for (fk in fks_to_add) {
    dm <- dm_add_fk_impl(
      dm,
      fk$child_table,
      list(fk$child_columns),
      fk$parent_table,
      list(fk$parent_columns),
      on_delete = "no_action"
    )
  }

  dm
}

# Heuristic: column_name --------------------------------------------------
# Find columns with identical names across tables; check uniqueness to
# determine which table owns the PK.

infer_keys_by_column_name <- function(tables, table_names, existing_pks) {
  all_cols <- lapply(tables, colnames)

  # Build a column -> tables mapping
  col_to_tables <- list()
  for (tbl in table_names) {
    for (col in all_cols[[tbl]]) {
      col_to_tables[[col]] <- c(col_to_tables[[col]], tbl)
    }
  }

  # Keep only columns in 2+ tables
  shared_cols <- names(Filter(function(x) length(x) >= 2, col_to_tables))

  pks <- list()
  fks <- list()

  for (col in shared_cols) {
    tbls_with_col <- col_to_tables[[col]]

    is_unique <- vapply(
      tbls_with_col,
      function(tbl) {
        vals <- tables[[tbl]][[col]]
        !anyNA(vals) && !anyDuplicated(vals)
      },
      logical(1)
    )

    pk_tables <- tbls_with_col[is_unique]
    fk_tables <- tbls_with_col[!is_unique]

    # Only proceed if exactly one table has unique values
    if (length(pk_tables) != 1 || length(fk_tables) < 1) {
      next
    }

    pk_table <- pk_tables

    # Add PK if not already set
    if (!pk_table %in% existing_pks$table) {
      pks <- c(pks, list(list(table = pk_table, columns = col)))
    }

    # Add FKs
    for (fk_table in fk_tables) {
      fks <- c(
        fks,
        list(list(
          child_table = fk_table,
          child_columns = col,
          parent_table = pk_table,
          parent_columns = col
        ))
      )
    }
  }

  list(pks = pks, fks = fks)
}

# Heuristic: id_column ----------------------------------------------------
# Match <table>_id columns to a unique `id` column in the parent table.

infer_keys_by_id_column <- function(tables, table_names, all_pk_tables, pks, fks) {
  all_cols <- lapply(tables, colnames)

  # Find tables that have a unique `id` column
  tables_with_id <- character()
  for (tbl in table_names) {
    if ("id" %in% all_cols[[tbl]]) {
      vals <- tables[[tbl]][["id"]]
      if (!anyNA(vals) && !anyDuplicated(vals)) {
        tables_with_id <- c(tables_with_id, tbl)
      }
    }
  }

  if (length(tables_with_id) == 0) {
    return(list(pks = pks, fks = fks))
  }

  # Already-tracked FK signatures for deduplication
  fk_sigs <- vapply(
    fks,
    function(fk) {
      paste(
        fk$child_table,
        paste(fk$child_columns, collapse = ","),
        fk$parent_table,
        paste(fk$parent_columns, collapse = ","),
        sep = "|"
      )
    },
    character(1)
  )

  for (pk_table in tables_with_id) {
    # Generate candidate FK column names
    fk_col_candidates <- unique(c(
      paste0(pk_table, "_id"),
      paste0(singularize(pk_table), "_id")
    ))

    for (other_tbl in setdiff(table_names, pk_table)) {
      matching <- intersect(fk_col_candidates, all_cols[[other_tbl]])
      if (length(matching) == 0) {
        next
      }

      fk_col <- matching[[1]]

      # Add PK on id if not already tracked
      if (!pk_table %in% all_pk_tables) {
        pks <- c(pks, list(list(table = pk_table, columns = "id")))
        all_pk_tables <- c(all_pk_tables, pk_table)
      }

      # Add FK if not already tracked
      sig <- paste(other_tbl, fk_col, pk_table, "id", sep = "|")
      if (!sig %in% fk_sigs) {
        fks <- c(
          fks,
          list(list(
            child_table = other_tbl,
            child_columns = fk_col,
            parent_table = pk_table,
            parent_columns = "id"
          ))
        )
        fk_sigs <- c(fk_sigs, sig)
      }
    }
  }

  list(pks = pks, fks = fks)
}

# Helpers ------------------------------------------------------------------

singularize <- function(x) {
  if (grepl("ies$", x)) {
    sub("ies$", "y", x)
  } else if (grepl("ses$|xes$|zes$|ches$|shes$", x)) {
    sub("es$", "", x)
  } else if (grepl("s$", x)) {
    sub("s$", "", x)
  } else {
    x
  }
}

infer_keys_code <- function(pks, fks) {
  code_parts <- character()

  for (pk in pks) {
    code_parts <- c(
      code_parts,
      glue("dm_add_pk({tick_if_needed(pk$table)}, {deparse_keys(new_keys(list(pk$columns)))})")
    )
  }

  for (fk in fks) {
    if (identical(fk$child_columns, fk$parent_columns)) {
      code_parts <- c(
        code_parts,
        glue(
          "dm_add_fk({tick_if_needed(fk$child_table)}, {deparse_keys(new_keys(list(fk$child_columns)))}, {tick_if_needed(fk$parent_table)})"
        )
      )
    } else {
      code_parts <- c(
        code_parts,
        glue(
          "dm_add_fk({tick_if_needed(fk$child_table)}, {deparse_keys(new_keys(list(fk$child_columns)))}, {tick_if_needed(fk$parent_table)}, {deparse_keys(new_keys(list(fk$parent_columns)))})"
        )
      )
    }
  }

  code_parts
}
