# Database Test Generation

This directory contains a template-based system for generating database-specific test files.

## Files

- `template-db-tests.R` - Template file for database-specific tests
- `generate-db-tests.sh` - Script to generate test files from template  
- `generate-db-tests.R` - R version of generation script (requires R)
- `test-{database}.R` - Generated test files (DO NOT EDIT DIRECTLY)

## How it works

1. **Template**: `template-db-tests.R` contains the test logic with `{{DATABASE}}` placeholders
2. **Generation**: Running the generation script replaces placeholders with actual database names
3. **Self-contained**: Each generated test file sets up its own database connection and test environment
4. **Synchronization**: All database test files stay in sync because they're generated from the same template

## Supported Databases

- postgres
- maria (MariaDB)  
- mssql (SQL Server)
- sqlite
- duckdb

## Usage

### Regenerate all database test files:
```bash
make generate-db-tests
# or
./generate-db-tests.sh
```

### Edit tests:
1. Edit `template-db-tests.R` (not the individual test-*.R files)
2. Run the generation script to update all database test files
3. Commit both the template and generated files

### Adding a new database:
1. Add the database name to the `databases` array in `generate-db-tests.sh`
2. Create a corresponding `test_src_<database>()` function in `helper-config-db.R`
3. Run the generation script

## Important Notes

- **Never edit the generated `test-*.R` files directly** - they will be overwritten
- **Always regenerate after editing the template** - files can get out of sync otherwise
- **The template uses `{{DATABASE}}` placeholders** - these get replaced during generation
- **Each test file is self-contained** - no global environment dependencies
- **Other tests may still use skip_if_src_not()** - these will run in default 'df' mode and skip database-specific functionality. Consider moving database-specific tests to the template if they need variants across all databases.