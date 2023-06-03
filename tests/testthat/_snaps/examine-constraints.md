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
      ! Unsatisfied constraints:
    Output
      * Table `tf_2`: foreign key `d` into table `tf_1`: Failed to collect lazy table.
      Caused by error:
      ! Lost connection to MySQL server during query [2013]
      * Table `tf_2`: foreign key `e`, `e1` into table `tf_3`: Failed to collect lazy table.
      Caused by error:
      ! Lost connection to MySQL server during query [2013]
      * Table `tf_4`: foreign key `j`, `j1` into table `tf_3`: Failed to collect lazy table.
      Caused by error:
      ! Lost connection to MySQL server during query [2013]
      * Table `tf_5`: foreign key `l` into table `tf_4`: Failed to collect lazy table.
      Caused by error:
      ! Lost connection to MySQL server during query [2013]
      * Table `tf_5`: foreign key `m` into table `tf_6`: Failed to collect lazy table.
      Caused by error:
      ! Lost connection to MySQL server during query [2013]
      * Table `tf_6`: foreign key `o` into table `tf_7`: Failed to collect lazy table.
      Caused by error:
      ! Lost connection to MySQL server during query [2013]
      * Table `tf_7`: foreign key `q` into table `tf_2`: Failed to collect lazy table.
      Caused by error:
      ! Lost connection to MySQL server during query [2013]

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

---

    Code
      dm_examine_constraints(dm_test_obj(), foo = "bar")
    Condition
      Error in `dm_examine_constraints()`:
      ! `...` must be empty.
      x Problematic argument:
      * foo = "bar"

