old <- fs::dir_ls("R", glob = "R/gui-*.R")
fs::file_delete(old)

input <- setdiff(fs::dir_ls("../dmSVG/R"), "../dmSVG/R/dm-private.R")

new_names <- paste0("gui-", fs::path_file(input))
new_paths <- fs::path("R", new_names)
fs::file_copy(input, new_paths)

if (fs::dir_exists("inst/htmlwidgets")) {
  fs::dir_delete("inst/htmlwidgets")
}

fs::dir_copy("../dmSVG/inst/htmlwidgets", "inst")
