# output

    Code
      dm() %>% dm_examine_constraints()
    Message <cliMessage>
      i No constraints defined.
    Code
      dm_nycflights13() %>% dm_examine_constraints()
    Message <cliMessage>
      ! Unsatisfied constraints:
    Output
      * Table `flights`: foreign key tailnum into table `planes`: 1640 entries (14.6%) of `flights$tailnum` not in `planes$tailnum`: N722MQ (27), N725MQ (20), N520MQ (19), N723MQ (19), N508MQ (16), ...
    Code
      dm_nycflights13(cycle = TRUE) %>% dm_examine_constraints()
    Message <cliMessage>
      ! Unsatisfied constraints:
    Output
      * Table `flights`: foreign key dest into table `airports`: 242 entries (2.2%) of `flights$dest` not in `airports$faa`: SJU (187), BQN (28), STT (15), PSE (12)
      * Table `flights`: foreign key tailnum into table `planes`: 1640 entries (14.6%) of `flights$tailnum` not in `planes$tailnum`: N722MQ (27), N725MQ (20), N520MQ (19), N723MQ (19), N508MQ (16), ...
    Code
      dm_nycflights13(cycle = TRUE) %>% dm_select_tbl(-flights) %>%
        dm_examine_constraints()
    Message <cliMessage>
      i All constraints satisfied.
    Code
      # n column
      dm_for_filter_w_cycle() %>% dm_examine_constraints()
    Message <cliMessage>
      i All constraints satisfied.

# output as tibble

    Code
      dm_nycflights13(cycle = TRUE) %>% dm_examine_constraints() %>% as_tibble()
    Output
      # A tibble: 7 x 6
        table   kind  columns ref_table is_key problem                                
        <chr>   <chr> <keys>  <chr>     <lgl>  <chr>                                  
      1 flights FK    dest    airports  FALSE  "242 entries (2.2%) of `flights$dest` ~
      2 flights FK    tailnum planes    FALSE  "1640 entries (14.6%) of `flights$tail~
      3 airlin~ PK    carrier <NA>      TRUE   ""                                     
      4 airpor~ PK    faa     <NA>      TRUE   ""                                     
      5 planes  PK    tailnum <NA>      TRUE   ""                                     
      6 flights FK    carrier airlines  TRUE   ""                                     
      7 flights FK    origin  airports  TRUE   ""                                     

