test_that("output", {
  expect_snapshot({
    commas(character())
    commas(letters[1])
    commas(letters[1:2])
    commas(letters[1:3])
    commas(letters[seq_len(MAX_COMMAS - 1)])
    commas(letters[seq_len(MAX_COMMAS)])
    commas(letters[seq_len(MAX_COMMAS + 1)])
    commas(letters[1:4], max_commas = 3)
    commas(letters, capped = TRUE)
    commas(letters, fun = tick)
  })
})
