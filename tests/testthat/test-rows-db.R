scoped_options(lifecycle_verbosity = "quiet")

verify_output("out/rows-db.txt", {
  data <- memdb_frame(a = 1:3, b = letters[c(1:2, NA)], c = 0.5 + 0:2)

  rows_insert(data, a, a = 4, b = "z")
  rows_insert(data, a, a = 4, b = "z", .copy = TRUE)
  rows_update(data, a, a = 2:3, b = "w", .copy = TRUE, .persist = FALSE)

  rows_insert(data, a, memdb_frame(a = 4, b = "z"), .persist = TRUE)
  data
  rows_update(data, a, memdb_frame(a = 2:3, b = "w"), .persist = TRUE)
  data
})
