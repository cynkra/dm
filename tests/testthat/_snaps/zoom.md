# print() and format() methods for subclass `zoomed_dm` work

    Code
      dm_for_filter() %>% dm_zoom_to(tf_5) %>% as_zoomed_df() %>% tbl_sum()
    Output
      Zoomed table 
            "tf_5" 

---

    Code
      dm_for_filter() %>% dm_zoom_to(tf_2) %>% as_zoomed_df() %>% tbl_sum()
    Output
      Zoomed table 
            "tf_2" 

