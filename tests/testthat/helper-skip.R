skip_if_error <- function(expr) {
  tryCatch(
    force(expr),
    error = function(e) {
      skip(e$message)
    }
  )
}

skip_if_remote_src <- function(src = my_test_src()) {
  if (is_db(src)) skip("works only locally")
}

skip_if_src <- function(...) {
  if (my_test_src_name %in% c(...)) {
    skip(glue::glue("does not work on {commas(tick(c(...)))}"))
  }
}

skip_if_schema_supported <- function() {
  not_ok_dbs <- schema_supported_dbs()[["test_shortcut"]]
  skip_if_src(not_ok_dbs)
}

skip_if_src_not <- function(...) {
  if (!(my_test_src_name %in% c(...))) {
    skip(glue::glue("only works on {commas(tick(c(...)))}"))
  }
}

skip_if_ide <- function() {
  if (!isTRUE(as.logical(Sys.getenv("CI")))) {
    skip("Slow test. To run, set CI=true")
  }
}

suppress_mssql_message <- function(code) {
  if (my_test_src_name == "mssql") {
    suppressMessages(code)
  } else {
    code
  }
}

suppress_mssql_warning <- function(code) {
  if (my_test_src_name == "mssql") {
    suppressWarnings(code)
  } else {
    code
  }
}
