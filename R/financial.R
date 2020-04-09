#' Creates a dm object for the Financial data
#'
#' @description
#' \lifecycle{experimental}
#'
#' Creates an example [`dm`] object from the tables at
#' <https://relational.fit.cvut.cz/dataset/Financial>.
#' The data is downloaded once per session,
#' subsequent calls return the same database.
#' The `trans` table is excluded due to its size.
#'
#' @return A `dm` object.
#'
#' @export
#' @examples
#' if (getRversion() >= "3.4") {
#'   if (rlang::is_installed("RMariaDB") && rlang::is_installed("RSQLite")) {
#'     dm_financial_sqlite() %>%
#'       dm_draw()
#'   }
#' }
dm_financial_sqlite <- function() {
  stopifnot(rlang::is_installed("RMariaDB"))
  stopifnot(rlang::is_installed("RSQLite"))

  my_db <- DBI::dbConnect(
    RMariaDB::MariaDB(),
    user = "guest",
    password = "relational",
    dbname = "Financial_ijs",
    host = "relational.fit.cvut.cz"
  )
  my_dm <-
    dm_from_src(my_db) %>%
    dm_select_tbl(-trans, -tkeys)

  sqlite_db <- DBI::dbConnect(RSQLite::SQLite())
  sqlite_dm <- copy_dm_to(sqlite_db, my_dm, temporary = FALSE)

  sqlite_dm %>%
    dm_add_pk(districts, id) %>%
    dm_add_pk(accounts, id) %>%
    dm_add_pk(clients, id) %>%
    dm_add_pk(loans, id) %>%
    dm_add_pk(orders, id) %>%
    dm_add_pk(disps, id) %>%
    dm_add_pk(cards, id) %>%
    dm_add_fk(loans, account_id, accounts) %>%
    dm_add_fk(orders, account_id, accounts) %>%
    dm_add_fk(disps, account_id, accounts) %>%
    dm_add_fk(disps, client_id, clients) %>%
    dm_add_fk(accounts, district_id, districts) %>%
    dm_add_fk(cards, disp_id, disps) %>%
    dm_set_colors(darkgreen = loans)
}
