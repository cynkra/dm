# `dm_pixarfilms()` works

    Code
      dm_examine_constraints(dm_pixarfilms(consistent = FALSE))
    Message
      ! Unsatisfied constraints:
    Output
      * Table `pixar_films`: primary key `film`: has 1 missing values

---

    Code
      dm_examine_constraints(dm_pixarfilms(consistent = TRUE))
    Message
      i All constraints satisfied.

