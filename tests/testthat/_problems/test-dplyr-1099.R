# Extracted from test-dplyr.R:1099

# setup ------------------------------------------------------------------------
library(testthat)
test_env <- simulate_test_env(package = "dm", path = "..")
attach(test_env, warn.conflicts = FALSE)

# prequel ----------------------------------------------------------------------
zoomed_grouped_out_dm <- dm_zoom_to(dm_for_filter(), tf_2) %>% group_by(c, e, e1)
zoomed_grouped_in_dm <- dm_zoom_to(dm_for_filter(), tf_3) %>% group_by(g)

# test -------------------------------------------------------------------------
skip_if_remote_src()
dm <- dm_for_filter()
tbl_2 <- keyed_tbl_impl(dm, "tf_2")
tbl_3 <- keyed_tbl_impl(dm, "tf_3")
result <- left_join(tbl_2, tbl_3, by = join_by(e == e))
