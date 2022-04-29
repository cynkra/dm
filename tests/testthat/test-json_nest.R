test_that("`json_nest()` works", {
  expect_snapshot({
    df <- tibble::tibble(x = c(1, 1, 1, 2, 2, 3), y = 1:6, z = 6:1)
    nested <- json_nest(df, data = c(y, z))
    nested
  })
})

test_that("`json_nest()` works remotely", {
  # FIXME: add "mssql" when ready
  skip_if_src_not("postgres")
  con <- my_test_src()$con

  local <- tibble(grp = c(1, 1, 2, 2), a_i = letters[1:4], a_j = LETTERS[1:4])
  remote <- test_db_src_frame(!!!local)

  expect_snapshot(variant = my_test_src_name, {
    json_nest(remote, A = starts_with("a")) %>%
      arrange(grp) %>%
      collect()
    json_nest(remote, A = starts_with("a"), .names_sep = "_") %>%
      arrange(grp) %>%
      collect()
  })

  expect_equivalent_tbl(
    local %>% json_nest(A = starts_with("a")) %>% unjson_nested(),
    remote %>% json_nest(A = starts_with("a")) %>% collect() %>% unjson_nested()
  )
})
