# GitHub Copilot Instructions for dm Package

## Development Guidelines

Please refer to [CLAUDE.md](../CLAUDE.md) in the root directory for comprehensive development notes and best practices when working with this codebase.

Key points from CLAUDE.md:
- Use the devcontainer for all R operations
- Use `testthat::test_local(filter = "name")` for running specific test files
- Always add tests when fixing bugs to prevent regression

## Package Context

This is the **dm** package - a grammar of joined tables in R that provides tools for working with relational data models. The package focuses on:

- Creating and manipulating data models (dm objects)
- Managing primary and foreign key relationships
- Filtering and joining across multiple tables
- Visualizing table relationships
- Converting between different data sources

Please ensure any suggestions or code generation align with these core functionalities and the R package development standards.
