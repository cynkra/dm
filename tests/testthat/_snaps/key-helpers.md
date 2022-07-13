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
    Condition
      Warning:
      The `c1` argument of `check_subset()` is deprecated as of dm 1.0.0.
      Please use the `x_select` argument instead.
      * Use `y_select` instead of `c2`, and `x` and `y` instead of `t1` and `t2`.
      * Using `by_position = TRUE` for compatibility.
    Output
      # A tibble: 1 x 1
            a
        <dbl>
      1     3
    Condition
      Error in `abort_not_subset_of()`:
      ! Column (`a`) of table `data_mcard_2()` contains values (see examples above) that are not present in column (`a`) of table `data_mcard_1()`.

# output for compound keys

    Code
      check_subset(data_mcard_2(), c(a, b), data_mcard_1(), c(a, b))
    Condition
      Warning:
      The `c1` argument of `check_subset()` is deprecated as of dm 1.0.0.
      Please use the `x_select` argument instead.
      * Use `y_select` instead of `c2`, and `x` and `y` instead of `t1` and `t2`.
      * Using `by_position = TRUE` for compatibility.
    Output
      # A tibble: 3 x 2
            a     b
        <dbl> <dbl>
      1     1     4
      2     2     5
      3     3     6
    Condition
      Error in `abort_not_subset_of()`:
      ! Columns (`a`, `b`) of table `data_mcard_2()` contain values (see examples above) that are not present in columns (`a`, `b`) of table `data_mcard_1()`.

# check_set_equality() checks properly if 2 sets of values are equal?

    Code
      check_set_equality(data_mcard_1(), c(a, c), data_mcard_2(), c(a, c))
    Condition
      Warning:
      The `c1` argument of `check_set_equality()` is deprecated as of dm 1.0.0.
      Please use the `x_select` argument instead.
      * Use `y_select` instead of `c2`, and `x` and `y` instead of `t1` and `t2`.
      * Using `by_position = TRUE` for compatibility.
    Output
      # A tibble: 2 x 2
            a     c
        <dbl> <dbl>
      1     1     5
      2     2     6
      # A tibble: 2 x 2
            a     c
        <dbl> <dbl>
      1     2     8
      2     3     9
    Condition
      Error in `abort_sets_not_equal()`:
      ! Columns (`a`, `c`) of table `data_mcard_1()` contain values (see examples above) that are not present in columns (`a`, `c`) of table `data_mcard_2()`.
        Columns (`a`, `c`) of table `data_mcard_2()` contain values (see examples above) that are not present in columns (`a`, `c`) of table `data_mcard_1()`.

