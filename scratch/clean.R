library(tidyverse)
library(dm)

library(rlang)

dm <- dm_nycflights13()
dm %>% dm_draw()

create_exist <- function(dm, child, parent) {
  child <- ensym(child)
  parent <- ensym(parent)
  parent.exist <- sym(paste0(as.character(parent), ".exist"))
  browser()
  pk_col <- sym(dm_get_pk(dm, !!parent))

  dm %>%
    dm_zoom_to(!!parent) %>%
    mutate(!!parent.exist := 1L) %>%
    dm_update_zoomed() %>%
    dm_zoom_to(!!child) %>%
    left_join(!!parent, select = c(!!pk_col, !!parent.exist)) %>%
    mutate(!!parent.exist := coalesce(!!parent.exist, 0L)) %>%
    dm_update_zoomed() %>%
    dm_zoom_to(!!parent) %>%
    select(-!!parent.exist) %>%
    dm_update_zoomed()
}

dm %>%
  create_exist(flights, airlines) %>%
  create_exist(flights, planes) %>%
  create_exist(flights, airports)
