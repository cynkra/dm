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
})
