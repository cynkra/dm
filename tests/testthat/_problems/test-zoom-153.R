# Extracted from test-zoom.R:153

# setup ------------------------------------------------------------------------
library(testthat)
test_env <- simulate_test_env(package = "dm", path = "..")
attach(test_env, warn.conflicts = FALSE)

# test -------------------------------------------------------------------------
skip_if_remote_src()
expect_snapshot({
    nyc_comp() %>% dm_zoom_to(weather)
    nyc_comp() %>%
      dm_zoom_to(weather) %>%
      dm_update_zoomed()
    nyc_comp_2 <-
      nyc_comp() %>%
      dm_zoom_to(weather) %>%
      dm_insert_zoomed("weather_2")
    nyc_comp_2 %>%
      get_all_keys()
    attr(dm_E(create_graph_from_dm(nyc_comp_2)), "vnames")

    nyc_comp_3 <-
      nyc_comp() %>%
      dm_zoom_to(flights) %>%
      dm_insert_zoomed("flights_2")
    nyc_comp_3 %>%
      get_all_keys()
    attr(dm_E(create_graph_from_dm(nyc_comp_3)), "vnames")
  })
