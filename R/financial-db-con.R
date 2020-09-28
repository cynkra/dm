#' Connection to SQL Financial Database
#' @description Connects to relational.fit.cvut.cz unless the service is
#' unavailable, in which case db-edu.pacha.dev is used as a fallback
#' @param source (type: character) which service to use, by default is
#' "relational.fit" but it can be set to "db-edu" as well
#' @return A `MariaDBConnection` object
#' @export
#' @examplesIf dm:::dm_has_financial() && rlang::is_installed("RMariaDB")
#' financial_db_con()
financial_db_con <- function(source = "relational.fit") {
  stopifnot(any(source %in% c("relational.fit","db-edu")))

  relational_con <- function() {
    DBI::dbConnect(
      RMariaDB::MariaDB(),
      username = "guest",
      password = "relational",
      dbname = "Financial_ijs",
      host = "relational.fit.cvut.cz"
    )
  }

  dbedu_con <- function() {
    DBI::dbConnect(
      RMariaDB::MariaDB(),
      username = "student",
      password = "tx5mvyRQqD",
      dbname = "loan_application",
      host = "db-edu.pacha.dev"
    )
  }

  if (source == "relational.fit") {
    con <- tryCatch(relational_con(), silent = TRUE)
    if (inherits(my_db, "try-error")) {
      con <- tryCatch(dbedu_con(), silent = TRUE)
    }
  } else {
    con <- tryCatch(dbedu_con(), silent = TRUE)
  }

  return(con)
}
