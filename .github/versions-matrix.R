data.frame(
  os = "ubuntu-22.04",
  r = "release",
  test_src = c(
    "test-mssql",
    "test-postgres",
    "test-maria",
    "test-mysql-maria",
    "test-duckdb",
    "test-sqlite",
    "test-arrow",
    "test-dtplyr",
    "test-duckplyr_stingy",
    "test-duckplyr_lavish"
  ),
  covr = "true",
  desc = c(
    "SQL Server with covr",
    "Postgres with covr",
    "MariaDB with covr",
    "MySQL with covr",
    "DuckDB with covr",
    "SQLite with covr",
    "Arrow with covr",
    "dtplyr with covr",
    "duckplyr stingy with covr",
    "duckplyr lavish with covr"
  )
)
