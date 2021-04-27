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
      * Table `flights`: foreign key tailnum into table `planes`: values of `flights$tailnum` not in `planes$tailnum`: N722MQ (27), N725MQ (20), N520MQ (19), N723MQ (19), N508MQ (16), ...
    Code
      dm_nycflights13(cycle = TRUE) %>% dm_examine_constraints()
    Message <cliMessage>
      ! Unsatisfied constraints:
    Output
      * Table `flights`: foreign key dest into table `airports`: values of `flights$dest` not in `airports$faa`: SJU (187), BQN (28), STT (15), PSE (12)
      * Table `flights`: foreign key tailnum into table `planes`: values of `flights$tailnum` not in `planes$tailnum`: N722MQ (27), N725MQ (20), N520MQ (19), N723MQ (19), N508MQ (16), ...
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
      # A tibble: 9 x 6
        table   kind  columns     ref_table is_key problem                            
        <chr>   <chr> <keys>      <chr>     <lgl>  <chr>                              
      1 flights FK    dest        airports  FALSE  "values of `flights$dest` not in `~
      2 flights FK    tailnum     planes    FALSE  "values of `flights$tailnum` not i~
      3 airlin~ PK    carrier     <NA>      TRUE   ""                                 
      4 airpor~ PK    faa         <NA>      TRUE   ""                                 
      5 planes  PK    tailnum     <NA>      TRUE   ""                                 
      6 weather PK    origin, ti~ <NA>      TRUE   ""                                 
      7 flights FK    carrier     airlines  TRUE   ""                                 
      8 flights FK    origin      airports  TRUE   ""                                 
      9 flights FK    origin, ti~ weather   TRUE   ""                                 

# output for compound keys

    Code
      bad_dm() %>% dm_examine_constraints()
    Message <cliMessage>
      ! Unsatisfied constraints:
    Output
      * Table `tbl_2`: primary key id, x: has duplicate values: 3, E (2)
      * Table `tbl_3`: primary key id: has duplicate values: 4 (2)
      * Table `tbl_1`: foreign key a, x into table `tbl_2`: values of `tbl_1$a`, `tbl_1$x` not in `tbl_2$id`, `tbl_2$x`: 4, E (1), 5, F (1)
      * Table `tbl_1`: foreign key b into table `tbl_3`: values of `tbl_1$b` not in `tbl_3$id`: 1 (1), 5 (1)

