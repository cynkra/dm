library(tidyverse)
library(dbplyr)
pkgload::load_all()

dm <- cdm_nycflights13(cycle = FALSE)

src <- src_sqlite(":memory:", create = TRUE)

dm_sqlite <- cdm_copy_to(src, dm)

dm1 <-
  dm_sqlite %>%
  cdm_filter(airports, faa == "EWR")

dm1 %>% tbl("airports")
dm1 %>% tbl("flights")
dm1 %>% tbl("weather")
dm1 %>% tbl("airlines")
dm1 %>% tbl("planes")

dm1 %>% cdm_get_tables()

dm1 %>% cdm_get_tables() %>% map(nrow)

dm1 %>% cdm_get_data_model()

dm1 %>% tbl("airports") %>% sql_render()
dm1 %>% tbl("flights") %>% sql_render()
dm1 %>% tbl("weather") %>% sql_render()
dm1 %>% tbl("airlines") %>% sql_render()
dm1 %>% tbl("planes") %>% sql_render()

dm1 %>% tbl("airports") %>% count()
dm1 %>% tbl("flights") %>% count()
dm1 %>% tbl("weather") %>% count()
dm1 %>% tbl("airlines") %>% count()
dm1 %>% tbl("planes") %>% count()
