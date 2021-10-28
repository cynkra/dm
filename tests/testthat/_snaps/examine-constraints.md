# output for compound keys

    Code
      bad_dm() %>% dm_examine_constraints()
    Message <cliMessage>
      ! Unsatisfied constraints:
    Output
      * Table `tbl_2`: primary key `id`, `x` : has duplicate values: 3, E (2)
      * Table `tbl_3`: primary key `id`: has duplicate values: 4 (2)
      * Table `tbl_1`: foreign key `a`, `x` into table `tbl_2`: values of `tbl_1$a`, `tbl_1$x` not in `tbl_2$id`, `tbl_2$x`: 4, E (1), 5, F (1)
      * Table `tbl_1`: foreign key `b` into table `tbl_3`: values of `tbl_1$b` not in `tbl_3$id`: 1 (1), 5 (1)

