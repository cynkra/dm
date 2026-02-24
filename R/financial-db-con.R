#' Connection to SQL Financial Database
#' @description Connects to relational.fel.cvut.cz unless the service is
#' unavailable, in which case databases.pacha.dev is used as a fallback
#' @return A `MariaDBConnection` object
#' @noRd
financial_db_con <- function() {
  if (Sys.getenv("DM_OFFLINE") != "") {
    cli::cli_abort("Offline")
  }

  err_relational <- tryCatch(return(relational_con()), error = identity)
  err_dbedu <- tryCatch(return(dbedu_con()), error = identity)

  cli::cli_abort(paste0(
    "Can't connect to relational.fel.cvut.cz or databases.pacha.dev:\n",
    conditionMessage(err_relational),
    "\n",
    conditionMessage(err_dbedu)
  ))
}

relational_con <- function() {
  DBI::dbConnect(
    RMariaDB::MariaDB(),
    username = "guest",
    password = "ctu-relational",
    dbname = "Financial_ijs",
    host = "relational.fel.cvut.cz"
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
