# copy_dm_to() copies data frames from any source

    Code
      copy_dm_to(default_local_src(), dm_for_filter())
    Condition
      Error:
      ! The `dest` argument of `copy_dm_to()` must refer to a DBI connection as of dm 0.1.6.
      i Please use `collect.dm()` instead.

# copy_dm_to() rejects overwrite and types arguments

    Code
      copy_dm_to(my_test_src(), dm_for_filter(), overwrite = TRUE)
    Condition
      Error in `copy_dm_to()`:
      ! `...` must be empty.
      x Problematic argument:
      * overwrite = TRUE

---

    Code
      copy_dm_to(my_test_src(), dm_for_filter(), types = character())
    Condition
      Error in `copy_dm_to()`:
      ! `...` must be empty.
      x Problematic argument:
      * types = character()

