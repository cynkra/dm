local({
  if (file.exists("../../man")) {
    names <- c("cynkra-72.png", "energie-72.png")
    sources <- file.path("../../man/figures", names)
    target_path <- "../../pkgdown/assets/reference/figures"
    targets <- file.path(target_path, names)

    info <- file.info(c(sources, targets))
    need_copy <- info$mtime[1:2] > info$mtime[3:4]
    need_copy[is.na(need_copy)] <- TRUE
    # need_copy <- c(TRUE, TRUE)
    if (any(need_copy)) {
      message("Copying pkgdown assets")
      stopifnot(file.copy(sources[need_copy], target_path, overwrite = TRUE))
    }
  }

  sources <- c(
    "duckdb",
    "maria",
    "mssql",
    "postgres",
    "sqlite",
    NULL
  )

  # paste0("DM_TEST_FILTER='", paste(sources, collapse = "|"), "' make test") |> clipr::write_clip()

  test_files <- set_names(paste0("test-", sources, ".R"), sources)
  in_contents <- imap_chr(test_files, ~ {
    if (file.exists(.x)) {
      text <- brio::read_file(.x)
      gsub(paste0('"', .y, '"'), '"db-source"', text)
    } else {
      ""
    }
  })

  table <- sort(table(in_contents[in_contents != ""]))
  stopifnot(length(table) <= 2)
  winner <- names(table)[1]

  out_contents <- iwalk(test_files, ~ {
    text <- gsub('"db-source"', paste0('"', .y, '"'), winner)
    brio::write_file(text, .x)
  })
})
