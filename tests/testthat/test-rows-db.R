scoped_options(lifecycle_verbosity = "quiet")

verify_output("out/rows-db.txt", {
  skip_if_local_src()
  data <- test_src_frame(a = 1:3, b = letters[c(1:2, NA)], c = 0.5 + 0:2)
  data

  rows_insert(data, tibble(a = 4, b = "z"))
  rows_insert(data, test_src_frame(a = 4, b = "z"))
  suppressMessages(rows_update(data, tibble(a = 2:3, b = "w"), copy = TRUE, in_place = FALSE))
  suppressMessages(rows_update(data, tibble(a = 2:3), copy = TRUE, in_place = FALSE))

  rows_insert(data, test_src_frame(a = 4, b = "z"), in_place = TRUE)
  data %>% arrange(a)
  rows_update(data, test_src_frame(a = 2:3, b = "w"), in_place = TRUE)
  data %>% arrange(a)
  rows_update(data, test_src_frame(a = 2:3), in_place = TRUE)
  data %>% arrange(a)
})
