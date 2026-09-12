list(
  # Backend runs: DM_TEST_SRC selects the database backend
  # (see tests/testthat/helper-src.R), and the custom after-install action
  # provisions the matching server. The variables travel through the generic
  # "env" matrix field, which the rcc-full job applies to the environment of
  # all steps. SKIP_UPDATE_SNAPSHOTS opts these entries out of the snapshot
  # updater, which would otherwise run the test suite a second time against
  # the backend and accept backend-specific snapshots.
  data.frame(
    os = "ubuntu-26.04",
    r = "release",
    env = paste0(
      "DM_TEST_SRC=",
      c(
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
      "Postgres with covr",
      "MariaDB with covr",
      "MySQL with covr",
      "DuckDB with covr",
      "SQLite with covr"
    )
  ),
  # SQL Server is the one backend that cannot run on the default runner, and
  # the reason is upstream of both this repository and `ankane/setup-sqlserver`:
  # Microsoft publishes no `mssql-server-*.list` under
  # packages.microsoft.com/config/ubuntu/26.04/ at all, so the action's
  # `apt-get` step has no repository to add and the entry dies in
  # `after-install`. Of the images that are served, 24.04 (Noble) carries only
  # SQL Server 2025, which is what the action installs by default, and
  # `ankane/setup-sqlserver` tests exactly that combination; 22.04 also offers
  # 2022 but is a generation further back. Nothing is lost by staying here:
  # Posit Package Manager serves a full Noble CRAN mirror and r-universe builds
  # the same binaries for Noble as for Resolute, so this entry still installs
  # binaries rather than compiling.
  #
  # Move this row back to the default once Microsoft publishes a 26.04
  # repository, and then revisit the ODBC driver generation pinned in
  # `.github/odbc/`, which follows whatever `mssql-tools` installs here.
  data.frame(
    os = "ubuntu-24.04",
    r = "release",
    env = "DM_TEST_SRC=test-mssql\nSKIP_UPDATE_SNAPSHOTS=true",
    covr = "true",
    desc = "SQL Server with covr"
  ),
  # Instrumented validation run. DM_VALIDATE makes the custom after-install
  # action uncomment code marked "# INSTRUMENT: validate"; covr then builds
  # and tests the instrumented sources. SKIP_UPDATE_SNAPSHOTS opts out of the
  # snapshot updater, which would otherwise run the instrumented tests twice.
  data.frame(
    os = "ubuntu-26.04",
    r = "release",
    env = "DM_VALIDATE=true\nSKIP_UPDATE_SNAPSHOTS=true",
    covr = "true",
    desc = "instrumented validation"
  )
)
