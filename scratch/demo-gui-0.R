library(dm)

dm <- dmSVG:::get_dm("AdventureWorks2014")

con <- DBI::dbConnect(RPostgres::Postgres())

DBI::dbExecute(con, "CREATE SCHEMA av2014")

copy_dm_to(con, dm, schema = "av2014", temporary = FALSE)
