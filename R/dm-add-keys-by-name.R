#' Infer and add keys based on column name equality
#'
#' @description
#' `dm_add_keys_by_name()` automatically infers primary and foreign key
#' relationships by finding columns with identical names across tables.
#' For each shared column name, if exactly one table has unique values
#' (potential primary key) and other tables have non-unique values
#' (potential foreign keys), the relationships are established.
#'
#' @inheritParams dm_add_pk
#' @param quiet If `TRUE`, suppresses messages about added keys.
#'
#' @details
#' The function works by:
#' 1. Finding columns that appear in multiple tables
#' 2. For each shared column, checking which tables have unique values
#' 3. If exactly one table has unique values and others don't, it adds:
#'    - A primary key to the table with unique values
#'    - Foreign keys from tables with non-unique values
#'
#' This is particularly useful for datasets that follow naming conventions
#' like ADaM (Analysis Data Model) in pharmaceutical research, where
#' `USUBJID` (subject ID) appears across multiple tables and is unique
#' in the subject-level table (ADSL) but not in other tables.
#'
#' Columns where all tables have unique values (ambiguous PK) or no table
#' has unique values (no valid PK candidate) are skipped.
#'
#' @return An updated `dm` with inferred primary and foreign keys added.
#'
#' @family primary key functions
#' @family foreign key functions
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
#' dm_get_all_pks(my_dm)
#' dm_get_all_fks(my_dm)
#'
#' # Automatically infer and add keys
#' my_dm_with_keys <- dm_add_keys_by_name(my_dm)
#' dm_get_all_pks(my_dm_with_keys)
#' dm_get_all_fks(my_dm_with_keys)
#'
#' # Draw the result
#' dm_draw(my_dm_with_keys)
#'
#' @export
dm_add_keys_by_name <- function(dm, ..., quiet = FALSE) {
  check_dots_empty()
  check_not_zoomed(dm)

  table_names <- names(dm)

  if (length(table_names) < 2) {
    return(dm)
  }

  # Get all column names for each table
  tables <- dm_get_tables_impl(dm)
  all_cols <- lapply(table_names, function(tbl) {
    colnames(tables[[tbl]])
  })
  names(all_cols) <- table_names

  # Find columns that appear in multiple tables
  all_col_names <- unlist(all_cols)
  col_counts <- table(all_col_names)
  shared_cols <- names(col_counts[col_counts > 1])

  if (length(shared_cols) == 0) {
    if (!quiet) {
      cli::cli_alert_info("No shared column names found across tables.")
    }
    return(dm)
  }

  pks_added <- character()
  fks_added <- character()

  # For each shared column, determine PK/FK relationships
  for (col in shared_cols) {
    # Find tables that have this column
    tables_with_col <- table_names[vapply(
      all_cols,
      function(cols) col %in% cols,
      logical(1)
    )]

    if (length(tables_with_col) < 2) {
      next
    }

    # Check which tables have unique values for this column (potential PK)
    uniqueness <- vapply(
      tables_with_col,
      function(tbl) {
        tbl_data <- tables[[tbl]]
        vals <- tbl_data[[col]]
        # A column is a PK candidate if all values are unique and no NAs
        !anyNA(vals) && !anyDuplicated(vals)
      },
      logical(1)
    )

    pk_tables <- tables_with_col[uniqueness]
    fk_tables <- tables_with_col[!uniqueness]

    # If exactly one table has unique values and others don't, establish relationships
    if (length(pk_tables) == 1 && length(fk_tables) >= 1) {
      pk_table <- pk_tables[1]

      # Check if this table already has a PK
      existing_pks <- dm_get_all_pks(dm)
      has_pk <- pk_table %in% existing_pks$table

      # Add PK if not already set
      if (!has_pk) {
        dm <- dm_add_pk_impl(dm, pk_table, col, autoincrement = FALSE, force = FALSE)
        pks_added <- c(pks_added, paste0(pk_table, "$", col))
      }

      # Add FKs from other tables
      for (fk_table in fk_tables) {
        # Check if FK already exists
        existing_fks <- dm_get_all_fks(dm)
        has_fk <- any(
          existing_fks$child_table == fk_table &
            existing_fks$parent_table == pk_table
        )

        if (!has_fk) {
          dm <- tryCatch(
            dm_add_fk_impl(dm, fk_table, list(col), pk_table, list(col), on_delete = "no_action"),
            error = function(e) dm
          )
          fks_added <- c(fks_added, paste0(fk_table, "$", col, " -> ", pk_table))
        }
      }
    }
  }

  if (!quiet) {
    if (length(pks_added) > 0) {
      cli::cli_alert_success("Added primary key{?s}: {.field {pks_added}}")
    }
    if (length(fks_added) > 0) {
      cli::cli_alert_success("Added foreign key{?s}: {.field {fks_added}}")
    }
    if (length(pks_added) == 0 && length(fks_added) == 0) {
      cli::cli_alert_info("No keys could be inferred from shared column names.")
    }
  }

  dm
}
