#!/usr/bin/env Rscript

# Tool to generate backend-specific test files from templates
# This replaces the DM_TEST_SRC environment variable approach

library(fs)
library(purrr)
library(readr)
library(stringr)

# Define backend configurations
backends <- list(
  df = list(
    name = "df",
    test_src_name = "df",
    full_name = "data frames"
  ),
  duckdb = list(
    name = "duckdb", 
    test_src_name = "duckdb",
    full_name = "DuckDB"
  ),
  postgres = list(
    name = "postgres",
    test_src_name = "postgres", 
    full_name = "PostgreSQL"
  ),
  maria = list(
    name = "maria",
    test_src_name = "maria",
    full_name = "MariaDB"
  ),
  mssql = list(
    name = "mssql",
    test_src_name = "mssql",
    full_name = "SQL Server"
  ),
  sqlite = list(
    name = "sqlite",
    test_src_name = "sqlite",
    full_name = "SQLite"
  )
)

# Template patterns to identify files that need backend-specific versions
template_patterns <- c(
  "build_copy_queries",
  "flatten", 
  "rows-dm",
  "json_nest",
  "json_pack",
  "meta"
)

# Generate header for backend-specific test files
generate_header <- function(backend_name, full_name) {
  glue::glue('
# This file is generated automatically by tools/generate-backend-tests.R
# Do not edit manually - edit the template and regenerate

# Backend-specific tests for {full_name}

')
}

# Replace template variables in test content
replace_template_vars <- function(content, backend) {
  result <- content %>%
    str_replace_all("my_test_src_name", paste0('"', backend$test_src_name, '"')) %>%
    str_replace_all("my_test_src\\(\\)", paste0("test_src_", backend$name, "()")) %>%
    str_replace_all("is_db_test_src\\(\\)", ifelse(backend$name == "df", "FALSE", "TRUE"))
  
  # For data frame backend, replace my_db_test_src() with test_src_duckdb() 
  # since data frame tests that need a database should use DuckDB
  if (backend$name == "df") {
    result <- str_replace_all(result, "my_db_test_src\\(\\)", "test_src_duckdb()")
  } else {
    result <- str_replace_all(result, "my_db_test_src\\(\\)", paste0("test_src_", backend$name, "()"))
  }
  
  result
}

# Generate backend-specific test file
generate_backend_test <- function(template_file, backend) {
  template_content <- read_file(template_file)
  
  # Check for backend-specific patterns
  backend_patterns <- c("my_test_src", "my_db_test_src", "variant\\s*=\\s*my_test_src_name")
  has_backend_code <- any(str_detect(template_content, backend_patterns))
  
  cli::cli_inform("Checking {path_file(template_file)} for backend patterns...")
  cli::cli_inform("  Has backend code: {has_backend_code}")
  
  # Skip if not a template that uses backend-specific functions
  if (!has_backend_code) {
    return(NULL)
  }
  
  header <- generate_header(backend$name, backend$full_name)
  processed_content <- replace_template_vars(template_content, backend)
  
  # Create output file path
  base_name <- path_ext_remove(path_file(template_file))
  base_name <- str_remove(base_name, "^test-")
  output_file <- path("tests", "testthat", paste0("test-", base_name, "-", backend$name, ".R"))
  
  # Write the file
  full_content <- paste0(header, processed_content)
  write_file(full_content, output_file)
  
  cli::cli_inform("Generated {output_file}")
  output_file
}

# Main function to generate all backend-specific tests
generate_all_backend_tests <- function() {
  # Find all test files that match our template patterns
  template_files <- character(0)
  for (pattern in template_patterns) {
    pattern_files <- dir_ls("tests/testthat", regexp = paste0("test-.*", pattern, ".*\\.R$"))
    template_files <- c(template_files, pattern_files)
  }
  
  # Remove duplicates
  template_files <- unique(template_files)
  
  cli::cli_h1("Generating backend-specific test files")
  cli::cli_inform("Found {length(template_files)} template files: {path_file(template_files)}")
  
  generated_files <- list()
  
  # Generate files for each backend and template
  for (backend_name in names(backends)) {
    backend <- backends[[backend_name]]
    cli::cli_h2("Backend: {backend$full_name}")
    
    backend_files <- map(template_files, ~ generate_backend_test(.x, backend))
    backend_files <- compact(backend_files)
    generated_files[[backend_name]] <- backend_files
  }
  
  # Write summary
  total_generated <- sum(map_int(generated_files, length))
  cli::cli_alert_success("Generated {total_generated} backend-specific test files")
  
  invisible(generated_files)
}

# Run if called as script
if (!interactive()) {
  generate_all_backend_tests()
}