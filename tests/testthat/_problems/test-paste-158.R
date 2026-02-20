# Extracted from test-paste.R:158

# setup ------------------------------------------------------------------------
library(testthat)
test_env <- simulate_test_env(package = "dm", path = "..")
attach(test_env, warn.conflicts = FALSE)

# test -------------------------------------------------------------------------
create_large_dm <- function(n_tables = 55) {
    # Create main table
    main_table <- tibble(id = integer(0))

    # Create list of tables
    tables <- list(main = main_table)

    # Create many tables that reference the main table
    for (i in 1:n_tables) {
      table_name <- paste0("table_", i)
      tables[[table_name]] <- tibble(
        id = integer(0),
        main_id = integer(0)
      )
    }

    # Create dm
    dm_obj <- do.call(dm, tables)

    # Add primary key to main table
    dm_obj <- dm_obj %>% dm_add_pk(main, id)

    # Add primary keys and foreign keys to all other tables
    for (i in 1:n_tables) {
      table_name <- paste0("table_", i)
      dm_obj <- dm_obj %>%
        dm_add_pk(!!table_name, id) %>%
        dm_add_fk(!!table_name, main_id, main)
    }

    return(dm_obj)
  }
large_dm <- create_large_dm(55)
output <- capture.output(dm_paste(large_dm))
output_text <- paste(output, collapse = "\n")
expect_true(
    grepl("dm_step_", output_text),
    info = "Expected chunking with intermediate variables for large dm"
  )
