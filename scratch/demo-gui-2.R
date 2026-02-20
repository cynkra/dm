library(dm)
library(nycflights13)

dm <- dm(flights, airlines, airports, planes)
dm_gui(dm = dm)
