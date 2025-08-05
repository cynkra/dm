data.frame(
  os = "ubuntu-22.04",
  r = "release",
  setup_db = c(
    "mssql",
    "postgres", 
    "maria",
    "mysql-maria",
    "duckdb",
    "sqlite"
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
