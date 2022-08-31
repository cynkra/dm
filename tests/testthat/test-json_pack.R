test_that("`json_pack()` works", {
  expect_snapshot({
    df <- tibble::tibble(x1 = 1:3, x2 = 4:6, x3 = 7:9, y = 1:3)
    packed <- json_pack(df, x = c(x1, x2, x3), y = y)
    packed
  })
})

test_that("`json_pack()` works remotely", {
  skip_if_src_not("postgres", "mssql")
  con <- my_test_src()$con

  local <- tibble(grp = c(1, 1, 2, 2), a_i = letters[1:4], a_j = LETTERS[1:4])
  remote <- test_db_src_frame(!!!local)

  expect_snapshot(variant = my_test_src_name, {
    json_pack(remote, a = starts_with("a"))
    json_pack(remote, a = starts_with("a"), .names_sep = "_")
  })

  expect_identical(
    local %>% json_pack(a = starts_with("a")) %>% unjson_nested(),
    remote %>% json_pack(a = starts_with("a")) %>% collect() %>% unjson_nested()
  )
})
