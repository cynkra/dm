context("test-filter-dm")

output_1 <- list(
  t1 = tibble(a = c(4:7), b = LETTERS[4:7]),
  t2 = tibble(c = c("seal", "worm", "dog", "cat"), d = 4:7, e = c("F", "G", "E", "F")),
  t3 = tibble(f = LETTERS[5:7], g = c("four", "five", "six")),
  t4 = tibble(h = letters[3:5], i = c("five", "six", "seven"), j = c("E", "F", "F")),
  t5 = tibble(k = 2:4,
              l = letters[3:5],
              m = c("tree", "streetlamp", "streetlamp")),
  t6 = tibble(n = c("tree", "streetlamp"),
              o = c("f", "h"))
)

test_that("cdm_filter() works as intended?", {
  map(.x = dm_for_filter_src,
      ~ expect_identical(
        cdm_filter(.x, t1, a < 8, a > 3) %>% cdm_get_tables() %>% map(.x = ., collect),
        output_1)
      )
})
