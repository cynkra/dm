test_that("generating code for creation of existing 'dm' works", {
  verify_output("out/code_from_paste.txt",
      {dm_paste(empty_dm())
        dm_paste(dm_for_filter)
        # changing the tab width
        dm_paste(dm_for_filter, FALSE, 4)
        # we don't care if the tables really exist
        dm_paste(dm_for_filter %>% dm_rename_tbl(t1_new = t1))
        # produce `dm_select()` statements in addition to the rest
        dm_paste(dm_select(dm_for_filter, t5, k = k, m) %>% dm_select(t1, a), select = TRUE)
        # produce code with colors
        # FIXME: this leads to weirdness in 'out/code_from_paste.txt'
        dm_set_colors(dm_for_filter, "#A0BB55" = t1:t3, "darkgreen" = t5:t6) %>%
          dm_paste(tab_width = 4)
    })
})
