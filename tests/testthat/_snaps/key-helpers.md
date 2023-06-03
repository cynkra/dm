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

# output

    Code
      check_subset(data_mcard_1(), data_mcard_2(), x_select = c(x = a))
    Condition
      Error in `check_api_impl()`:
      ! `by_position = FALSE` or `by_position = NULL` require column names in `x` to match those in `y`.

---

    Code
      check_subset(data_mcard_2(), data_mcard_1(), x_select = a)
    Condition
      Error in `collect()`:
      ! Failed to collect lazy table.
      Caused by error:
      ! Lost connection to MySQL server during query [2013]

# output for compound keys

    Code
      check_subset(data_mcard_2(), data_mcard_1(), x_select = c(a, b))
    Condition
      Error in `collect()`:
      ! Failed to collect lazy table.
      Caused by error:
      ! Lost connection to MySQL server during query [2013]

