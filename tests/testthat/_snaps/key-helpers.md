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
      Warning in `data_mcard_1()`:
      restarting interrupted promise evaluation
      Error in `my_test_src()`:
      ! Data source not known: mysql

---

    Code
      check_subset(data_mcard_2(), data_mcard_1(), x_select = a)
    Condition
      Error in `my_test_src()`:
      ! Data source not known: mysql

# output for compound keys

    Code
      check_subset(data_mcard_2(), data_mcard_1(), x_select = c(a, b))
    Condition
      Warning in `data_mcard_2()`:
      restarting interrupted promise evaluation
      Error in `my_test_src()`:
      ! Data source not known: mysql

