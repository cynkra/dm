#' Connection to SQL Financial Database
#' @description Connects to relational.fit.cvut.cz unless the service is
#' unavailable, in which case db-edu.pacha.dev is used as a fallback
#' @return A `MariaDBConnection` object
#' @noRd
financial_db_con <- function() {
  err_relational <- tryCatch(return(relational_con()), error = identity)
  err_dbedu <- tryCatch(return(dbedu_con()), error = identity)

  abort(paste0(
    "Can't connect to relational.fit.cvut.cz or db-edu.pacha.dev:\n",
    conditionMessage(err_relational), "\n",
    conditionMessage(err_dbedu)
  ))
}

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
    password = "uQCy30sNP5arqMBGHVLZ",
    dbname = "financial",
    host = "databases.pacha.dev"
  )
}
