#!/bin/bash

# Script to generate database-specific test files from template
# Usage: ./generate-db-tests.sh

set -e

# Define the databases we support
databases=("postgres" "maria" "mssql" "sqlite" "duckdb")

# Check if template exists
template_path="tests/testthat/template-db-tests.R"
if [ ! -f "$template_path" ]; then
    echo "Template file not found: $template_path"
    exit 1
fi

echo "Generating database test files..."

# Generate test files for each database
for db in "${databases[@]}"; do
    output_path="tests/testthat/test-${db}.R"
    
    # Create header
    cat > "$output_path" << EOF
# GENERATED FILE - DO NOT EDIT
# This file was generated from template-db-tests.R
# Edit the template and run generate-db-tests.sh to update

EOF
    
    # Replace placeholder and append content
    sed "s/{{DATABASE}}/$db/g" "$template_path" >> "$output_path"
    
    echo "Generated: $output_path"
done

echo "Database test generation complete!"