# The `src:` line of a printed `dm` describes the machine that ran the test, not the behaviour
# under test: DuckDB reports the kernel and the R version, Postgres and MariaDB the user, host
# and database, SQLite and SQL Server their own build. None of that reproduces anywhere else,
# so a snapshot holding it is only ever valid on the machine that recorded it, and a
# re-recording just moves the problem to the next machine. The variant already says which
# backend this is.
scrub_src <- function(lines) {
  sub("^(\\s*src:\\s+).*$", "\\1<src>", lines)
}
