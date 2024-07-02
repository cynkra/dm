data.frame(
  os = "ubuntu-22.04",
  r = "release",
  test_src = c(
    "test-mssql",
    "test-postgres",
    "test-maria",
    "test-mysql-maria",
    "test-duckdb",
    "test-sqlite"
  ),
  covr = "true",
  desc = c(
    "SQL Server with covr",
    "Postgres with covr",
    "MariaDB with covr",
    "MySQL with covr",
    "DuckDB with covr",
    "SQLite with covr"
  )
)
