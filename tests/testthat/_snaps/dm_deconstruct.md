# snapshot test

    Code
      dm <- dm_nycflights13()
    Condition
      Warning:
      `flatten()` is deprecated as of rlang 1.1.0.
      i Please use `purrr::list_flatten()` or `purrr::list_c()`.
      Warning:
      `flatten_chr()` is deprecated as of rlang 1.1.0.
      i Please use `purrr::list_flatten()` and/or `purrr::list_c()`.
    Code
      dm_deconstruct(dm)
    Message
      airlines <- pull_tbl(dm, "airlines", keyed = TRUE)
      airports <- pull_tbl(dm, "airports", keyed = TRUE)
      flights <- pull_tbl(dm, "flights", keyed = TRUE)
      planes <- pull_tbl(dm, "planes", keyed = TRUE)
      weather <- pull_tbl(dm, "weather", keyed = TRUE)

# non-syntactic names

    Code
      dm <- dm(`if` = tibble(a = 1), `a b` = tibble(b = 1))
    Condition
      Warning:
      `flatten()` is deprecated as of rlang 1.1.0.
      i Please use `purrr::list_flatten()` or `purrr::list_c()`.
      Warning:
      `flatten_chr()` is deprecated as of rlang 1.1.0.
      i Please use `purrr::list_flatten()` and/or `purrr::list_c()`.
    Code
      dm_deconstruct(dm)
    Message
      `if` <- pull_tbl(dm, "if", keyed = TRUE)
      `a b` <- pull_tbl(dm, "a b", keyed = TRUE)

