list(
  # Backend runs: DM_TEST_SRC selects the database backend
  # (see tests/testthat/helper-src.R), and the custom after-install action
  # provisions the matching server. The variables travel through the generic
  # "env" matrix field, which the rcc-full job applies to the environment of
  # all steps. SKIP_UPDATE_SNAPSHOTS opts these entries out of the snapshot
  # updater, which would otherwise run the test suite a second time against
  # the backend and accept backend-specific snapshots.
  data.frame(
    os = "ubuntu-22.04",
    r = "release",
    env = paste0(
      "DM_TEST_SRC=",
      c(
        "test-mssql",
        "test-postgres",
        "test-maria",
        "test-mysql-maria",
        "test-duckdb",
        "test-sqlite"
      ),
      "\nSKIP_UPDATE_SNAPSHOTS=true"
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
  # Instrumented validation run. DM_VALIDATE makes the custom after-install
  # action uncomment code marked "# INSTRUMENT: validate"; covr then builds
  # and tests the instrumented sources. SKIP_UPDATE_SNAPSHOTS opts out of the
  # snapshot updater, which would otherwise run the instrumented tests twice.
  data.frame(
    os = "ubuntu-22.04",
    r = "release",
    env = "DM_VALIDATE=true\nSKIP_UPDATE_SNAPSHOTS=true",
    covr = "true",
    desc = "instrumented validation"
  )
)
