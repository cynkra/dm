library(dm)

con <- DBI::dbConnect(RPostgres::Postgres())

dm <-
  dm_from_con(con, schema = "av2014")
dm_gui(dm = dm, select_tables = FALSE)
