list(
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
  ),
  # Instrumented validation run. The DM_VALIDATE flag travels through the
  # generic "env" matrix field to the custom before/after-install actions,
  # which uncomment code marked "# INSTRUMENT: validate" and opt out of the
  # snapshot updater. covr then builds and tests the instrumented sources.
  data.frame(
    os = "ubuntu-22.04",
    r = "release",
    env = "DM_VALIDATE=true",
    covr = "true",
    desc = "instrumented validation"
  )
)
