# check_key() API

    Code
      check_key(tibble(a = 1), a)
      check_key(.data = tibble(a = 1), a)
    Condition
      Warning:
      The `.data` argument of `check_key()` is deprecated as of dm 1.0.0.
      Please use the `x` argument instead.
    Code
      check_key(a, .data = tibble(a = 1))
    Condition
      Warning:
      The `.data` argument of `check_key()` is deprecated as of dm 1.0.0.
      Please use the `x` argument instead.

# output

    Code
      check_subset(data_mcard_2(), a, data_mcard_1(), a)
    Output
      # A tibble: 1 x 3
            a     b     c
        <dbl> <dbl> <dbl>
      1     3     6     9
    Condition
      Error in `abort_not_subset_of()`:
      ! Column (`a`) of table `data_mcard_2()` contains values (see examples above) that are not present in column (`a`) of table `data_mcard_1()`.

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
    Condition
      Error in `abort_not_subset_of()`:
      ! Columns (`a`, `b`) of table `data_mcard_2()` contain values (see examples above) that are not present in columns (`a`, `b`) of table `data_mcard_1()`.

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
    Condition
      Error in `abort_sets_not_equal()`:
      ! Columns (`a`, `c`) of table `data_mcard_1()` contain values (see examples above) that are not present in columns (`a`, `c`) of table `data_mcard_2()`.
        Columns (`a`, `c`) of table `data_mcard_2()` contain values (see examples above) that are not present in columns (`a`, `c`) of table `data_mcard_1()`.

