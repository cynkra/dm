input <- fs::dir_ls("R", glob = "R/gui-*.R")

new_names <- gsub("^gui-", "", fs::path_file(input))
new_paths <- fs::path("../dmSVG/R", new_names)
fs::file_copy(input, new_paths, overwrite = TRUE)
