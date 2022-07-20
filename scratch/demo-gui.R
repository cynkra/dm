pkgload::load_all()

dm <- dmSVG:::get_dm("AdventureWorks2014")
dm_gui(dm = dm, select_tables = FALSE)

library(nycflights13)
dm <- dm(flights, airlines, airports, planes)
dm_gui(dm = dm)

dm_gui(dm = dm_nycflights13(cycle = TRUE))
