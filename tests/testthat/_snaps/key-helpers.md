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

# check_set_equality() checks properly if 2 sets of values are equal?

    Code
      check_set_equality(data_mcard_1(), a, data_mcard_2(), a)
    Output
      # A tibble: 1 x 3
            a     b     c
        <dbl> <dbl> <dbl>
      1     3     6     9
    Error <dm_error_sets_not_equal>
      Column(s) (`a`) of table `data_mcard_2()` contains values (see examples above) that are not present in column(s) (`a`) of table `data_mcard_1()`.

