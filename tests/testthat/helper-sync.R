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

  test_files <- set_names(paste0("test-", sources, ".R"), sources)
  in_contents <- imap_chr(test_files, ~ {
    if (file.exists(.x)) {
      lines <- brio::read_lines(.x)
      lines[1:10] <- gsub(.y, "db-source", lines[1:10])
      paste(lines, collapse = "\n")
    } else {
      ""
    }
  })

  table <- table(in_contents[in_contents != ""])
  stopifnot(length(table) <= 2)
  winner <- names(table)[1]

  out_contents <- iwalk(test_files, ~ {
    lines <- strsplit(winner, "\n", fixed = TRUE)[[1]]
    lines[1:10] <- gsub("db-source", .y, lines[1:10])
    brio::write_lines(lines, .x)
  })
})
