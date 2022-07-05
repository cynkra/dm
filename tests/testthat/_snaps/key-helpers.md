# output

    Code
      check_subset(data_mcard_2(), a, data_mcard_1(), a)
    Condition
      Error:
      ! object 't1' not found

# output for compound keys

    Code
      check_subset(data_mcard_2(), c(a, b), data_mcard_1(), c(a, b))
    Condition
      Error:
      ! object 't1' not found

