# output

    Code
      dm(x = tibble(a = c(1, 1))) %>% dm_add_pk(x, a, check = TRUE)
    Error <dm_error_not_unique_key>
      (`a`) not a unique key of `x`.

