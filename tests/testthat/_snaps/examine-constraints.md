# output

    Code
      dm() %>% dm_examine_constraints()
    Message <cliMessage>
      i No constraints defined.
    Code
      dm_nycflights_small() %>% dm_examine_constraints()
    Message <cliMessage>
      ! Unsatisfied constraints:
    Output
      * Table `flights`: foreign key dest into table `airports`: 4 values (4.1%) of `flights$dest` not in `airports$faa`: BQN, PSE, SJU, STT
      * Table `flights`: foreign key tailnum into table `planes`: 497 values (17.5%) of `flights$tailnum` not in `planes$tailnum`: N0EGMQ, N1EAMQ, N200AA, N263AV, N267AT, ...
    Code
      dm_nycflights_small_cycle() %>% dm_examine_constraints()
    Message <cliMessage>
      ! Unsatisfied constraints:
    Output
      * Table `flights`: foreign key dest into table `airports`: 4 values (4.1%) of `flights$dest` not in `airports$faa`: BQN, PSE, SJU, STT
      * Table `flights`: foreign key tailnum into table `planes`: 497 values (17.5%) of `flights$tailnum` not in `planes$tailnum`: N0EGMQ, N1EAMQ, N200AA, N263AV, N267AT, ...
    Code
      dm_nycflights_small_cycle() %>% dm_select_tbl(-flights) %>%
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
      dm_nycflights_small_cycle() %>% dm_examine_constraints() %>% as_tibble()
    Output
      # A tibble: 7 x 6
        table   kind  columns ref_table is_key problem                                
        <chr>   <chr> <keys>  <chr>     <lgl>  <chr>                                  
      1 flights FK    dest    airports  FALSE  "4 values (4.1%) of `flights$dest` not~
      2 flights FK    tailnum planes    FALSE  "497 values (17.5%) of `flights$tailnu~
      3 airlin~ PK    carrier <NA>      TRUE   ""                                     
      4 airpor~ PK    faa     <NA>      TRUE   ""                                     
      5 planes  PK    tailnum <NA>      TRUE   ""                                     
      6 flights FK    carrier airlines  TRUE   ""                                     
      7 flights FK    origin  airports  TRUE   ""                                     

# output for compound keys

    Code
      bad_dm() %>% dm_examine_constraints()
    Message <cliMessage>
      ! Unsatisfied constraints:
    Output
      * Table `tbl_2`: primary key id: has duplicate values: 3
      * Table `tbl_3`: primary key id: has duplicate values: 4
      * Table `tbl_1`: foreign key a into table `tbl_2`: 2 values (40%) of `tbl_1$a` not in `tbl_2$id`: 4, 5
      * Table `tbl_1`: foreign key b into table `tbl_3`: 2 values (40%) of `tbl_1$b` not in `tbl_3$id`: 1, 5

