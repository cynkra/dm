# waldo

    Code
      dm %>% waldo::compare(dm, max_diffs = 10)
    Condition
      Warning:
      `transpose()` was deprecated in purrr 1.0.0.
      Please use `list_transpose()` instead.
      Warning:
      `transpose()` was deprecated in purrr 1.0.0.
      Please use `list_transpose()` instead.
      Warning:
      `transpose()` was deprecated in purrr 1.0.0.
      Please use `list_transpose()` instead.
      Warning:
      `transpose()` was deprecated in purrr 1.0.0.
      Please use `list_transpose()` instead.
      Warning:
      `transpose()` was deprecated in purrr 1.0.0.
      Please use `list_transpose()` instead.
      Warning:
      `transpose()` was deprecated in purrr 1.0.0.
      Please use `list_transpose()` instead.
      Warning:
      `transpose()` was deprecated in purrr 1.0.0.
      Please use `list_transpose()` instead.
      Warning:
      `transpose()` was deprecated in purrr 1.0.0.
      Please use `list_transpose()` instead.
      Warning:
      `transpose()` was deprecated in purrr 1.0.0.
      Please use `list_transpose()` instead.
      Warning:
      `transpose()` was deprecated in purrr 1.0.0.
      Please use `list_transpose()` instead.
      Warning:
      `transpose()` was deprecated in purrr 1.0.0.
      Please use `list_transpose()` instead.
      Warning:
      `transpose()` was deprecated in purrr 1.0.0.
      Please use `list_transpose()` instead.
    Output
      v No differences

---

    Code
      dm %>% dm_select_tbl(-airlines) %>% waldo::compare(dm, max_diffs = 10)
    Condition
      Warning:
      `transpose()` was deprecated in purrr 1.0.0.
      Please use `list_transpose()` instead.
      Warning:
      `transpose()` was deprecated in purrr 1.0.0.
      Please use `list_transpose()` instead.
      Warning:
      `transpose()` was deprecated in purrr 1.0.0.
      Please use `list_transpose()` instead.
      Warning:
      `transpose()` was deprecated in purrr 1.0.0.
      Please use `list_transpose()` instead.
      Warning:
      `transpose()` was deprecated in purrr 1.0.0.
      Please use `list_transpose()` instead.
      Warning:
      `transpose()` was deprecated in purrr 1.0.0.
      Please use `list_transpose()` instead.
      Warning:
      `transpose()` was deprecated in purrr 1.0.0.
      Please use `list_transpose()` instead.
      Warning:
      `transpose()` was deprecated in purrr 1.0.0.
      Please use `list_transpose()` instead.
      Warning:
      `transpose()` was deprecated in purrr 1.0.0.
      Please use `list_transpose()` instead.
      Warning:
      `transpose()` was deprecated in purrr 1.0.0.
      Please use `list_transpose()` instead.
      Warning:
      `transpose()` was deprecated in purrr 1.0.0.
      Please use `list_transpose()` instead.
    Output
      `old` is length 4
      `new` is length 5
      
      `names(old)[1:3]`:            "airports" "flights" "planes"
      `names(new)[1:4]`: "airlines" "airports" "flights" "planes"
      
      `old$airlines` is absent
      `new$airlines` is a list

---

    Code
      dm %>% dm_select(airlines, -name) %>% waldo::compare(dm, max_diffs = 10)
    Condition
      Warning:
      `transpose()` was deprecated in purrr 1.0.0.
      Please use `list_transpose()` instead.
      Warning:
      `transpose()` was deprecated in purrr 1.0.0.
      Please use `list_transpose()` instead.
      Warning:
      `transpose()` was deprecated in purrr 1.0.0.
      Please use `list_transpose()` instead.
      Warning:
      `transpose()` was deprecated in purrr 1.0.0.
      Please use `list_transpose()` instead.
      Warning:
      `transpose()` was deprecated in purrr 1.0.0.
      Please use `list_transpose()` instead.
      Warning:
      `transpose()` was deprecated in purrr 1.0.0.
      Please use `list_transpose()` instead.
      Warning:
      `transpose()` was deprecated in purrr 1.0.0.
      Please use `list_transpose()` instead.
      Warning:
      `transpose()` was deprecated in purrr 1.0.0.
      Please use `list_transpose()` instead.
      Warning:
      `transpose()` was deprecated in purrr 1.0.0.
      Please use `list_transpose()` instead.
      Warning:
      `transpose()` was deprecated in purrr 1.0.0.
      Please use `list_transpose()` instead.
      Warning:
      `transpose()` was deprecated in purrr 1.0.0.
      Please use `list_transpose()` instead.
      Warning:
      `transpose()` was deprecated in purrr 1.0.0.
      Please use `list_transpose()` instead.
    Output
      `old$airlines$data` is length 1
      `new$airlines$data` is length 2
      
      `names(old$airlines$data)`: "carrier"       
      `names(new$airlines$data)`: "carrier" "name"
      
      `old$airlines$data$name` is absent
      `new$airlines$data$name` is a character vector ('Endeavor Air Inc.', 'American Airlines Inc.', 'Alaska Airlines Inc.', 'JetBlue Airways', 'Delta Air Lines Inc.', ...)

---

    Code
      dm %>% dm_rm_fk() %>% waldo::compare(dm, max_diffs = 10)
    Condition
      Warning:
      `vec_unchop()` was deprecated in vctrs 0.5.0.
      Please use `list_unchop()` instead.
    Message
      Removing foreign keys: %>%
        dm_rm_fk(flights, carrier, airlines) %>%
        dm_rm_fk(flights, origin, airports) %>%
        dm_rm_fk(flights, tailnum, planes) %>%
        dm_rm_fk(flights, c(origin, time_hour), weather)
    Condition
      Warning:
      `transpose()` was deprecated in purrr 1.0.0.
      Please use `list_transpose()` instead.
      Warning:
      `transpose()` was deprecated in purrr 1.0.0.
      Please use `list_transpose()` instead.
      Warning:
      `transpose()` was deprecated in purrr 1.0.0.
      Please use `list_transpose()` instead.
      Warning:
      `transpose()` was deprecated in purrr 1.0.0.
      Please use `list_transpose()` instead.
      Warning:
      `transpose()` was deprecated in purrr 1.0.0.
      Please use `list_transpose()` instead.
      Warning:
      `transpose()` was deprecated in purrr 1.0.0.
      Please use `list_transpose()` instead.
      Warning:
      `transpose()` was deprecated in purrr 1.0.0.
      Please use `list_transpose()` instead.
      Warning:
      `transpose()` was deprecated in purrr 1.0.0.
      Please use `list_transpose()` instead.
      Warning:
      `transpose()` was deprecated in purrr 1.0.0.
      Please use `list_transpose()` instead.
      Warning:
      `transpose()` was deprecated in purrr 1.0.0.
      Please use `list_transpose()` instead.
      Warning:
      `transpose()` was deprecated in purrr 1.0.0.
      Please use `list_transpose()` instead.
      Warning:
      `transpose()` was deprecated in purrr 1.0.0.
      Please use `list_transpose()` instead.
    Output
      `old$airlines$fks` is length 0
      `new$airlines$fks` is length 1
      
      `names(old$airlines$fks)`:          
      `names(new$airlines$fks)`: "flights"
      
      `old$airlines$fks$flights` is absent
      `new$airlines$fks$flights` is a list
      
      `old$airports$fks` is length 0
      `new$airports$fks` is length 1
      
      `names(old$airports$fks)`:          
      `names(new$airports$fks)`: "flights"
      
      `old$airports$fks$flights` is absent
      `new$airports$fks$flights` is a list
      
      `old$planes$fks` is length 0
      `new$planes$fks` is length 1
      
      `names(old$planes$fks)`:          
      `names(new$planes$fks)`: "flights"
      
      `old$planes$fks$flights` is absent
      `new$planes$fks$flights` is a list
      
      `old$weather$fks` is length 0
      `new$weather$fks` is length 1
      
      And 2 more differences ...

---

    Code
      dm %>% dm_rm_pk(fail_fk = FALSE) %>% waldo::compare(dm, max_diffs = 10)
    Message
      Removing primary keys: %>%
        dm_rm_pk(airlines) %>%
        dm_rm_pk(airports) %>%
        dm_rm_pk(planes) %>%
        dm_rm_pk(weather)
    Condition
      Warning:
      `transpose()` was deprecated in purrr 1.0.0.
      Please use `list_transpose()` instead.
      Warning:
      `transpose()` was deprecated in purrr 1.0.0.
      Please use `list_transpose()` instead.
      Warning:
      `transpose()` was deprecated in purrr 1.0.0.
      Please use `list_transpose()` instead.
      Warning:
      `transpose()` was deprecated in purrr 1.0.0.
      Please use `list_transpose()` instead.
      Warning:
      `transpose()` was deprecated in purrr 1.0.0.
      Please use `list_transpose()` instead.
      Warning:
      `transpose()` was deprecated in purrr 1.0.0.
      Please use `list_transpose()` instead.
      Warning:
      `transpose()` was deprecated in purrr 1.0.0.
      Please use `list_transpose()` instead.
      Warning:
      `transpose()` was deprecated in purrr 1.0.0.
      Please use `list_transpose()` instead.
      Warning:
      `transpose()` was deprecated in purrr 1.0.0.
      Please use `list_transpose()` instead.
      Warning:
      `transpose()` was deprecated in purrr 1.0.0.
      Please use `list_transpose()` instead.
      Warning:
      `transpose()` was deprecated in purrr 1.0.0.
      Please use `list_transpose()` instead.
      Warning:
      `transpose()` was deprecated in purrr 1.0.0.
      Please use `list_transpose()` instead.
    Output
      `old$airlines$pks$column` is length 0
      `new$airlines$pks$column` is length 1
      
      `old$airlines$pks$column[[1]]` is absent
      `new$airlines$pks$column[[1]]` is a character vector ('carrier')
      
      `old$airports$pks$column` is length 0
      `new$airports$pks$column` is length 1
      
      `old$airports$pks$column[[1]]` is absent
      `new$airports$pks$column[[1]]` is a character vector ('faa')
      
      `old$planes$pks$column` is length 0
      `new$planes$pks$column` is length 1
      
      `old$planes$pks$column[[1]]` is absent
      `new$planes$pks$column[[1]]` is a character vector ('tailnum')
      
      `old$weather$pks$column` is length 0
      `new$weather$pks$column` is length 1
      
      `old$weather$pks$column[[1]]` is absent
      `new$weather$pks$column[[1]]` is a character vector ('origin', 'time_hour')

---

    Code
      dm %>% dm_set_colors(yellow = flights) %>% waldo::compare(dm, max_diffs = 10)
    Condition
      Warning:
      `transpose()` was deprecated in purrr 1.0.0.
      Please use `list_transpose()` instead.
      Warning:
      `transpose()` was deprecated in purrr 1.0.0.
      Please use `list_transpose()` instead.
      Warning:
      `transpose()` was deprecated in purrr 1.0.0.
      Please use `list_transpose()` instead.
      Warning:
      `transpose()` was deprecated in purrr 1.0.0.
      Please use `list_transpose()` instead.
      Warning:
      `transpose()` was deprecated in purrr 1.0.0.
      Please use `list_transpose()` instead.
      Warning:
      `transpose()` was deprecated in purrr 1.0.0.
      Please use `list_transpose()` instead.
      Warning:
      `transpose()` was deprecated in purrr 1.0.0.
      Please use `list_transpose()` instead.
      Warning:
      `transpose()` was deprecated in purrr 1.0.0.
      Please use `list_transpose()` instead.
      Warning:
      `transpose()` was deprecated in purrr 1.0.0.
      Please use `list_transpose()` instead.
      Warning:
      `transpose()` was deprecated in purrr 1.0.0.
      Please use `list_transpose()` instead.
      Warning:
      `transpose()` was deprecated in purrr 1.0.0.
      Please use `list_transpose()` instead.
      Warning:
      `transpose()` was deprecated in purrr 1.0.0.
      Please use `list_transpose()` instead.
    Output
      `old$flights$display`: "#FFFF00FF"
      `new$flights$display`: "#5B9BD5FF"

---

    Code
      dm %>% dm_zoom_to(flights) %>% waldo::compare(dm, max_diffs = 10)
    Condition
      Warning:
      `transpose()` was deprecated in purrr 1.0.0.
      Please use `list_transpose()` instead.
      Warning:
      `transpose()` was deprecated in purrr 1.0.0.
      Please use `list_transpose()` instead.
      Warning:
      `transpose()` was deprecated in purrr 1.0.0.
      Please use `list_transpose()` instead.
      Warning:
      `transpose()` was deprecated in purrr 1.0.0.
      Please use `list_transpose()` instead.
      Warning:
      `transpose()` was deprecated in purrr 1.0.0.
      Please use `list_transpose()` instead.
      Warning:
      `transpose()` was deprecated in purrr 1.0.0.
      Please use `list_transpose()` instead.
      Warning:
      `transpose()` was deprecated in purrr 1.0.0.
      Please use `list_transpose()` instead.
      Warning:
      `transpose()` was deprecated in purrr 1.0.0.
      Please use `list_transpose()` instead.
      Warning:
      `transpose()` was deprecated in purrr 1.0.0.
      Please use `list_transpose()` instead.
      Warning:
      `transpose()` was deprecated in purrr 1.0.0.
      Please use `list_transpose()` instead.
      Warning:
      `transpose()` was deprecated in purrr 1.0.0.
      Please use `list_transpose()` instead.
      Warning:
      `transpose()` was deprecated in purrr 1.0.0.
      Please use `list_transpose()` instead.
    Output
      `old$flights$zoom` is an S3 object of class <tbl_df/tbl/data.frame>, a list
      `new$flights$zoom` is NULL
      
      `old$flights$col_tracker_zoom` is a character vector ('year', 'month', 'day', 'dep_time', 'sched_dep_time', ...)
      `new$flights$col_tracker_zoom` is NULL

