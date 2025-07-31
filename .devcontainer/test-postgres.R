#!/usr/bin/env Rscript

# Test script to verify PostgreSQL connection in devcontainer
cat("Testing PostgreSQL connection...\n")

# Test network connection
tryCatch({
  con_network <- DBI::dbConnect(
    RPostgres::Postgres(),
    host = "postgres",
    port = 5432,
    user = "compose",
    password = "YourStrong!Passw0rd",
    dbname = "test"
  )
  cat("✓ Network connection successful\n")
  DBI::dbDisconnect(con_network)
}, error = function(e) {
  cat("✗ Network connection failed:", e$message, "\n")
})

# Test socket connection (if available)
if (file.exists("/var/run/postgresql")) {
  tryCatch({
    con_socket <- DBI::dbConnect(
      RPostgres::Postgres(),
      host = "/var/run/postgresql",
      user = "compose",
      dbname = "test"
    )
    cat("✓ Socket connection successful\n")
    DBI::dbDisconnect(con_socket)
  }, error = function(e) {
    cat("✗ Socket connection failed:", e$message, "\n")
  })
} else {
  cat("ⓘ Socket directory not available\n")
}

# Test using environment variables
tryCatch({
  con_env <- DBI::dbConnect(RPostgres::Postgres())
  cat("✓ Environment variable connection successful\n")
  DBI::dbDisconnect(con_env)
}, error = function(e) {
  cat("✗ Environment variable connection failed:", e$message, "\n")
})

cat("Connection test completed.\n")
