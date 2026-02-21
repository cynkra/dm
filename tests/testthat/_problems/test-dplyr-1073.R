# Extracted from test-dplyr.R:1073

# setup ------------------------------------------------------------------------
library(testthat)
test_env <- simulate_test_env(package = "dm", path = "..")
attach(test_env, warn.conflicts = FALSE)

# prequel ----------------------------------------------------------------------
zoomed_grouped_out_dm <- dm_zoom_to(dm_for_filter(), tf_2) %>% group_by(c, e, e1)
zoomed_grouped_in_dm <- dm_zoom_to(dm_for_filter(), tf_3) %>% group_by(g)

# test -------------------------------------------------------------------------
skip_if_remote_src()
expect_equivalent_tbl(
    dm_zoomed() %>%
      left_join(tf_3, by = join_by(e == e)) %>%
      tbl_zoomed(),
    left_join(tf_2(), tf_3(), by = join_by(e == e))
  )
