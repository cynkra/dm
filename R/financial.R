#' Creates a dm object for the Financial data
#'
#' @description
#' `r lifecycle::badge("experimental")`
#'
#' `dm_financial()` creates an example [`dm`] object from the tables at
#' https://relational.fit.cvut.cz/dataset/Financial.
#' The connection is established once per session,
#' subsequent calls return the same connection.
#'
#' @return A `dm` object.
#'
#' @export
#' @examplesIf dm:::dm_has_financial() && rlang::is_installed("DiagrammeR")
#' dm_financial() %>%
#'   dm_draw()
dm_financial <- function() {
  check_suggested("RMariaDB",
    use = TRUE,
    top_level_fun = "dm_financial"
  )

  my_db <- financial_db_con()

  my_dm <-
    dm_from_src(my_db, learn_keys = FALSE) %>%
    dm_add_pk(districts, id) %>%
    dm_add_pk(accounts, id) %>%
    dm_add_pk(clients, id) %>%
    dm_add_pk(loans, id) %>%
    dm_add_pk(orders, id) %>%
    dm_add_pk(disps, id) %>%
    dm_add_pk(cards, id) %>%
    dm_add_pk(trans, id) %>%
    dm_add_fk(loans, account_id, accounts) %>%
    dm_add_fk(orders, account_id, accounts) %>%
    dm_add_fk(disps, account_id, accounts) %>%
    dm_add_fk(disps, client_id, clients) %>%
    dm_add_fk(accounts, district_id, districts) %>%
    dm_add_fk(cards, disp_id, disps) %>%
    dm_add_fk(trans, account_id, accounts) %>%
    dm_set_colors(darkgreen = loans)

  my_dm
}

dm_has_financial <- function() {
  # Not on CRAN:
  if (Sys.getenv("CI") != "true") return(FALSE)

  # Crashes observed with R < 3.5:
  if (getRversion() < 3.5) return(FALSE)

  # Connectivity:
  try_connect <- try(dm_financial(), silent = TRUE)
  if (inherits(try_connect, "try-error")) return(FALSE)

  # Accessing the connection:
  try_count <- try(collect(count(dm_financial()$districts)), silent = TRUE)
  if (inherits(try_connect, "try-error")) return(FALSE)

  TRUE
}

#' dm_financial_sqlite()
#'
#' `dm_financial_sqlite()` copies the data to a temporary SQLite database.
#' The data is downloaded once per session, subsequent calls return the same database.
#' The `trans` table is excluded due to its size.
#' @rdname dm_financial
#' @export
dm_financial_sqlite <- function() {
  check_suggested("RSQLite",
    use = TRUE,
    top_level_fun = "dm_financial_sqlite"
  )

  my_dm <-
    dm_financial() %>%
    dm_select_tbl(-trans)

  sqlite_db <- DBI::dbConnect(RSQLite::SQLite())
  sqlite_dm <- copy_dm_to(sqlite_db, my_dm, temporary = FALSE)

  sqlite_dm
}
