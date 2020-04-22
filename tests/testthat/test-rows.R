scoped_options(lifecycle_verbosity = "quiet")

verify_output("out/rows.txt", {
  data <- tibble(a = 1:3, b = letters[c(1:2, NA)], c = 0.5 + 0:2)

  rows_insert(data, a, a = 4, b = "z")
  rows_update(data, a, a = 2:3, b = "z")
  rows_patch(data, a, a = 2:3, b = "z")
  rows_upsert(data, a, a = 2:4, b = "z")
  rows_delete(data, a, a = 2:4)
  rows_truncate(data)
})
