test_that("generating code for creation of existing 'dm' works", {
  verify_output("out/code_from_paste.txt", {
    "empty"
    empty_dm() %>% dm_paste()

    "baseline"
    dm_for_filter %>% dm_paste()

    "changing the tab width"
    dm_for_filter %>% dm_paste(tab_width = 4)

    "we don't care if the tables really exist"
    dm_for_filter %>%
      dm_rename_tbl(t1_new = t1) %>%
      dm_paste()

    "produce `dm_select()` statements in addition to the rest"
    dm_for_filter %>%
      dm_select(t5, k = k, m) %>%
      dm_select(t1, a) %>%
      dm_paste(select = TRUE)

    "produce code with colors"
    dm_for_filter %>%
      dm_set_colors("orange" = t1:t3, "darkgreen" = t5:t6) %>%
      dm_paste(tab_width = 4)
  })
})
