#!/usr/bin/env Rscript

# Script to generate database-specific test files from template
# Usage: Rscript generate-db-tests.R

# Define the databases we support
databases <- c("postgres", "maria", "mssql", "sqlite", "duckdb")

# Read the template
template_path <- file.path("tests", "testthat", "template-db-tests.R")
if (!file.exists(template_path)) {
  stop("Template file not found: ", template_path)
}

template_content <- readLines(template_path, warn = FALSE)

# Generate test files for each database
for (db in databases) {
  # Replace placeholder with actual database name
  content <- gsub("\\{\\{DATABASE\\}\\}", db, template_content)
  
  # Add header comment indicating this is generated
  header <- c(
    paste0("# GENERATED FILE - DO NOT EDIT"),
    paste0("# This file was generated from template-db-tests.R"),
    paste0("# Edit the template and run generate-db-tests.R to update"),
    "",
    content
  )
  
  # Write to output file
  output_path <- file.path("tests", "testthat", paste0("test-", db, ".R"))
  writeLines(header, output_path)
  
  cat("Generated:", output_path, "\n")
}

cat("Database test generation complete!\n")