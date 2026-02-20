library(tidyverse)
library(dbplyr)
pkgload::load_all()

dm <- dm_nycflights13(cycle = FALSE)

src <- src_sqlite(":memory:", create = TRUE)

dm_sqlite <- dm_copy_to(src, dm)

dm1 <-
  dm_sqlite %>%
  dm_filter(airports, faa == "EWR")

dm1 %>% tbl_impl("airports")
dm1 %>% tbl_impl("flights")
dm1 %>% tbl_impl("weather")
dm1 %>% tbl_impl("airlines")
dm1 %>% tbl_impl("planes")

dm1 %>% dm_get_tables()

dm1 %>% dm_get_tables() %>% map(nrow)

dm1 %>% tbl_impl("airports") %>% sql_render()
dm1 %>% tbl_impl("flights") %>% sql_render()
dm1 %>% tbl_impl("weather") %>% sql_render()
dm1 %>% tbl_impl("airlines") %>% sql_render()
dm1 %>% tbl_impl("planes") %>% sql_render()

dm1 %>% tbl_impl("airports") %>% count() %>% explain()
dm1 %>% tbl_impl("flights") %>% count() %>% explain()
dm1 %>% tbl_impl("weather") %>% count() %>% explain()
dm1 %>% tbl_impl("airlines") %>% count() %>% explain()
dm1 %>% tbl_impl("planes") %>% count() %>% explain()

dm1 %>% tbl_impl("airports") %>% count()
dm1 %>% tbl_impl("flights") %>% count()
dm1 %>% tbl_impl("weather") %>% count()
dm1 %>% tbl_impl("airlines") %>% count()
dm1 %>% tbl_impl("planes") %>% count()
