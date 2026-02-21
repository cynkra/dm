# output

    Code
      dm() %>% dm_examine_constraints()
    Message
      i No constraints defined.
    Code
      dm_nycflights_small() %>% dm_examine_constraints()
    Message
      ! Unsatisfied constraints:
    Output
      * Table `flights`: foreign key `dest` into table `airports`: values of `flights$dest` not in `airports$faa`: SJU (30), BQN (6), STT (4), PSE (2)
      * Table `flights`: foreign key `tailnum` into table `planes`: values of `flights$tailnum` not in `planes$tailnum`: N725MQ (6), N537MQ (5), N722MQ (5), N730MQ (5), N736MQ (5), ...
    Code
      dm_nycflights_small_cycle() %>% dm_examine_constraints()
    Message
      ! Unsatisfied constraints:
    Output
      * Table `flights`: foreign key `dest` into table `airports`: values of `flights$dest` not in `airports$faa`: SJU (30), BQN (6), STT (4), PSE (2)
      * Table `flights`: foreign key `tailnum` into table `planes`: values of `flights$tailnum` not in `planes$tailnum`: N725MQ (6), N537MQ (5), N722MQ (5), N730MQ (5), N736MQ (5), ...
    Code
      dm_nycflights_small_cycle() %>% dm_select_tbl(-flights) %>%
        dm_examine_constraints()
    Message
      i All constraints satisfied.
    Code
      # n column
      dm_for_filter_w_cycle() %>% dm_examine_constraints()
    Message
      i All constraints satisfied.

# output as tibble

    Code
      dm_nycflights_small_cycle() %>% dm_examine_constraints() %>% as_tibble()
    Output
      # A tibble: 7 x 6
        table    kind  columns ref_table is_key problem                               
        <chr>    <chr> <keys>  <chr>     <lgl>  <chr>                                 
      1 flights  FK    dest    airports  FALSE  "values of `flights$dest` not in `air~
      2 flights  FK    tailnum planes    FALSE  "values of `flights$tailnum` not in `~
      3 airlines PK    carrier <NA>      TRUE   ""                                    
      4 airports PK    faa     <NA>      TRUE   ""                                    
      5 planes   PK    tailnum <NA>      TRUE   ""                                    
      6 flights  FK    carrier airlines  TRUE   ""                                    
      7 flights  FK    origin  airports  TRUE   ""                                    

# .max_value parameter works

    Code
      dm_nycflights_small_cycle() %>% dm_examine_constraints(.max_value = Inf)
    Message
      ! Unsatisfied constraints:
    Output
      * Table `flights`: foreign key `dest` into table `airports`: values of `flights$dest` not in `airports$faa`: SJU (30), BQN (6), STT (4), PSE (2)
      * Table `flights`: foreign key `tailnum` into table `planes`: values of `flights$tailnum` not in `planes$tailnum`: N725MQ (6), N537MQ (5), N722MQ (5), N730MQ (5), N736MQ (5), N3GBAA (4), N509MQ (4), N719MQ (4), N723MQ (4), N734MQ (4), N739MQ (4), N856MQ (4), N3CJAA (3), N3FRAA (3), N500MQ (3), N513MQ (3), N515MQ (3), N526MQ (3), N532MQ (3), N534MQ (3), N5FAAA (3), N713MQ (3), N846MQ (3), N0EGMQ (2), N3AEMQ (2), N3BCAA (2), N3BTAA (2), N3CCAA (2), N3CDAA (2), N3CHAA (2), N3CSAA (2), N3CUAA (2), N3DXAA (2), N3ERAA (2), N3ETAA (2), N3EYAA (2), N3FAAA (2), N3FWAA (2), N3GFAA (2), N3GRAA (2), N3HYAA (2), N3JWAA (2), N4YFAA (2), N4YGAA (2), N501MQ (2), N503MQ (2), N504MQ (2), N507JB (2), N507MQ (2), N516MQ (2), N517MQ (2), N518MQ (2), N522MQ (2), N525UA (2), N527MQ (2), N539AA (2), N542MQ (2), N586UA (2), N5DEAA (2), N5DWAA (2), N5FLAA (2), N832MQ (2), N835MQ (2), N850MQ (2), N854MQ (2), N8EGMQ (2), N318AT (1), N395AA (1), N3ACAA (1), N3AHAA (1), N3APAA (1), N3BFAA (1), N3BGAA (1), N3BKAA (1), N3BSAA (1), N3BUAA (1), N3CEAA (1), N3CFAA (1), N3CGAA (1), N3CWAA (1), N3CXAA (1), N3DFAA (1), N3DGAA (1), N3DHAA (1), N3DPAA (1), N3DRAA (1), N3DSAA (1), N3DUAA (1), N3DWAA (1), N3DYAA (1), N3EAAA (1), N3ECAA (1), N3EHAA (1), N3EUAA (1), N3EXAA (1), N3GAAA (1), N3GTAA (1), N3GUAA (1), N3HAAA (1), N3HCAA (1), N3HXAA (1), N3JAAA (1), N3JBAA (1), N3JJAA (1), N3JMAA (1), N3JNAA (1), N3JPAA (1), N4WKAA (1), N4WMAA (1), N4WNAA (1), N4WWAA (1), N4XBAA (1), N4XKAA (1), N4XMAA (1), N4XNAA (1), N4XSAA (1), N4YBAA (1), N4YHAA (1), N4YJAA (1), N4YKAA (1), N4YSAA (1), N502MQ (1), N505MQ (1), N506MQ (1), N510MQ (1), N511MQ (1), N512MQ (1), N514MQ (1), N526JB (1), N527AA (1), N527JB (1), N527UA (1), N528MQ (1), N531MQ (1), N546MQ (1), N592UA (1), N5BSAA (1), N5CBAA (1), N5CPAA (1), N5DAAA (1), N5DMAA (1), N5EAAA (1), N5EGAA (1), N5EKAA (1), N5EUAA (1), N5FEAA (1), N5FFAA (1), N5FPAA (1), N5FSAA (1), N620MQ (1), N623MQ (1), N630MQ (1), N631MQ (1), N635MQ (1), N636MQ (1), N638MQ (1), N659MQ (1), N660MQ (1), N694MQ (1), N695MQ (1), N829MQ (1), N902MQ (1), N909MQ (1), N922MQ (1), N923MQ (1), N932MQ (1)

# output for compound keys

    Code
      bad_dm() %>% dm_examine_constraints()
    Message
      ! Unsatisfied constraints:
    Output
      * Table `tbl_2`: primary key `id`, `x`: has duplicate values: 3, E (2)
      * Table `tbl_3`: primary key `id`: has duplicate values: 4 (2)
      * Table `tbl_1`: foreign key `a`, `x` into table `tbl_2`: values of `tbl_1$a`, `tbl_1$x` not in `tbl_2$id`, `tbl_2$x`: 4, E (1), 5, F (1)
      * Table `tbl_1`: foreign key `b` into table `tbl_3`: values of `tbl_1$b` not in `tbl_3$id`: 1 (1), 5 (1)

# Non-explicit PKs should be tested too

    Code
      dm_for_card() %>% dm_examine_constraints()
    Message
      ! Unsatisfied constraints:
    Output
      * Table `dc_3`: unique key `b`, `a`: has duplicate values: e, 5 (2)
      * Table `dc_4`: foreign key `b`, `a` into table `dc_3`: values of `dc_4$b`, `dc_4$a` not in `dc_3$b`, `dc_3$a`: f, 6 (1)
      * Table `dc_6`: foreign key `c` into table `dc_1`: values of `dc_6$c` not in `dc_1$a`: 6 (1)

# `dm_examine_constraints()` API

    Code
      dm_examine_constraints(dm_test_obj(), progress = FALSE)
    Condition
      Warning:
      The `progress` argument of `dm_examine_constraints()` is deprecated as of dm 1.0.0.
      i Please use the `.progress` argument instead.
    Message
      i No constraints defined.
    Code
      dm_examine_constraints(dm = dm_test_obj())
    Condition
      Warning:
      The `dm` argument of `dm_examine_constraints()` is deprecated as of dm 1.0.0.
      i Please use the `.dm` argument instead.
    Message
      i No constraints defined.

# `dm_examine_constraints()` API (2)

    Code
      dm_examine_constraints(dm_test_obj(), foo = "bar")
    Condition
      Error in `dm_examine_constraints()`:
      ! `...` must be empty.
      x Problematic argument:
      * foo = "bar"

