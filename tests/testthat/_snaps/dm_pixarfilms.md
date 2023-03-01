# `dm_pixarfilms()` works

    Code
      dm_examine_constraints(dm_pixarfilms(consistent = FALSE))
    Condition
      Warning:
      `flatten()` is deprecated as of rlang 1.1.0.
      i Please use `purrr::list_flatten()` or `purrr::list_c()`.
      Warning:
      `flatten_chr()` is deprecated as of rlang 1.1.0.
      i Please use `purrr::list_flatten()` and/or `purrr::list_c()`.
    Message
      ! Unsatisfied constraints:
    Output
      * Table `pixar_films`: primary key `film`: has 1 missing values

---

    Code
      dm_examine_constraints(dm_pixarfilms(consistent = TRUE))
    Condition
      Warning:
      `flatten()` is deprecated as of rlang 1.1.0.
      i Please use `purrr::list_flatten()` or `purrr::list_c()`.
      Warning:
      `flatten_chr()` is deprecated as of rlang 1.1.0.
      i Please use `purrr::list_flatten()` and/or `purrr::list_c()`.
    Message
      i All constraints satisfied.

