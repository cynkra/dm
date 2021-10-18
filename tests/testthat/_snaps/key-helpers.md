# output

    Code
      check_subset(data_mcard_2(), a, data_mcard_1(), a)
    Output
      # A tibble: 1 x 3
            a     b     c
        <dbl> <dbl> <dbl>
      1     3     6     9
    Error <dm_error_not_subset_of>
      Column(s) (`a`) of table `data_mcard_2()` contains values (see examples above) that are not present in column(s) (`a`) of table `data_mcard_1()`.

# output for compound keys

    Code
      check_subset(data_mcard_2(), c(a, b), data_mcard_1(), c(a, b))
    Output
      # A tibble: 3 x 3
            a     b     c
        <dbl> <dbl> <dbl>
      1     1     4     7
      2     2     5     8
      3     3     6     9
    Error <dm_error_not_subset_of>
      Column(s) (`a`, `b`) of table `data_mcard_2()` contains values (see examples above) that are not present in column(s) (`a`, `b`) of table `data_mcard_1()`.

# check_set_equality() checks properly if 2 sets of values are equal?

    Code
      check_set_equality(data_mcard_1(), c(a, c), data_mcard_2(), c(a, c))
    Output
      # A tibble: 2 x 3
            a     b     c
        <dbl> <dbl> <dbl>
      1     1     1     5
      2     2     4     6
      # A tibble: 2 x 3
            a     b     c
        <dbl> <dbl> <dbl>
      1     2     5     8
      2     3     6     9
    Error <dm_error_sets_not_equal>
      Column(s) (`a`, `c`) of table `data_mcard_1()` contains values (see examples above) that are not present in column(s) (`a`, `c`) of table `data_mcard_2()`.
        Column(s) (`a`, `c`) of table `data_mcard_2()` contains values (see examples above) that are not present in column(s) (`a`, `c`) of table `data_mcard_1()`.

