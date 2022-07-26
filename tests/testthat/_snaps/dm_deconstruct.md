# snapshot test

    Code
      dm <- dm_nycflights13()
      dm_deconstruct(dm)
    Message
      airlines <- pull_tbl(dm, "airlines", keyed = TRUE)
      airports <- pull_tbl(dm, "airports", keyed = TRUE)
      flights <- pull_tbl(dm, "flights", keyed = TRUE)
      planes <- pull_tbl(dm, "planes", keyed = TRUE)
      weather <- pull_tbl(dm, "weather", keyed = TRUE)

