get_dm <- function(name) {
  if (name == "nycflights13") {
    return(dm::dm_nycflights13())
  }

  basename <- paste0(name, ".R")
  path <- system.file("relational", basename, package = utils::packageName(), mustWork = TRUE)
  source(path, local = TRUE)$value
}
