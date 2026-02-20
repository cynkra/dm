data <- list(
  pixar_films = pixarfilms::pixar_films,
  pixar_people = pixarfilms::pixar_people,
  academy = pixarfilms::academy,
  box_office = pixarfilms::box_office,
  genres = pixarfilms::genres,
  public_response = pixarfilms::public_response
)

dir.create("inst/extdata", showWarnings = FALSE)
saveRDS(data, "inst/extdata/pixarfilms-v1.rds", compress = "gzip", version = 2)
