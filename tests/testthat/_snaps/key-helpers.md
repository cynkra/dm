# check_key() API

    Code
      check_key(tibble(a = 1), a)
      check_key(.data = tibble(a = 1), a)
    Condition
      Warning:
      The `.data` argument of `check_key()` is deprecated as of dm 1.0.0.
      i Please use the `x` argument instead.
    Code
      check_key(a, .data = tibble(a = 1))
    Condition
      Warning:
      The `.data` argument of `check_key()` is deprecated as of dm 1.0.0.
      i Please use the `x` argument instead.

# output for legacy API

    Code
      check_subset(data_mcard_1(), a, data_mcard_2(), a)
    Condition
      Warning:
      The `c1` argument of `check_subset()` is deprecated as of dm 1.0.0.
      i Please use the `x_select` argument instead.
      i Use `y_select` instead of `c2`, and `x` and `y` instead of `t1` and `t2`.
      i Using `by_position = TRUE` for compatibility.

# output

    Code
      check_subset(data_mcard_1(), data_mcard_2(), x_select = c(x = a))
    Condition
      Error in `check_api_impl()`:
      ! `by_position = FALSE` or `by_position = NULL` require column names in `x` to match those in `y`.

---

    Code
      check_subset(data_mcard_2(), data_mcard_1(), x_select = a)
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
      check_subset(data_mcard_2(), data_mcard_1(), x_select = c(a, b))
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
      check_set_equality(data_mcard_1(), data_mcard_2(), x_select = c(a, c))
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

