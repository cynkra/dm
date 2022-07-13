# check_cardinality_...() API errors

    Code
      check_card_api(data_mcard_1(), a, data_mcard_2(), b)
    Condition
      Warning:
      The `pk_column` argument of `eval()` is deprecated as of dm 1.0.0.
      Please use the `x_select` argument instead.
      * Use `y_select` instead of `fk_column`, and `x` and `y` instead of `parent_table` and `child_table`.
      * Using `by_position = TRUE` for compatibility.
    Output
      [[1]]
            a
        <dbl>
      1     1
      2     2
      3     1
      
      [[2]]
            b
        <dbl>
      1     4
      2     5
      3     6
      
      [[3]]
      [1] "data_mcard_1()"
      
      [[4]]
      [1] "data_mcard_2()"
      

---

    Code
      check_card_api(data_mcard_1(), data_mcard_2(), x_select = a, y_select = c)
    Condition
      Error in `check_card_api_impl()`:
      ! `by_position = FALSE` or `by_position = NULL` require column names in `x` to match those in `y`.

