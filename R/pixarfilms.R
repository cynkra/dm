#' Creates a dm object for the \pkg{pixarfilms} data
#'
#' @description
#' Creates an example [`dm`] object from the tables in
#' \pkg{pixarfilms}, along with the references.
#'
#' @inheritParams rlang::args_dots_empty
#' @param color Boolean, if `TRUE` (default), the resulting `dm` object will
#'   have colors assigned to different tables for visualization with
#'   `dm_draw()`.
#' @param consistent Boolean, In the original `dm`  the  `film` column in
#' `pixar_films` contains missing values so cannot be made a proper primary key.
#' Set to `TRUE` to remove those records.
#' @param version The version of the data to use.
#'   `"v1"` (default) uses a vendored snapshot of \pkg{pixarfilms} 0.2.1.
#'   `"latest"` uses the data from the installed \pkg{pixarfilms} package.
#'
#' @return A `dm` object consisting of \pkg{pixarfilms} tables, complete with
#'   primary and foreign keys and optionally colored.
#'
#' @export
#' @autoglobal
#' @examplesIf rlang::is_installed("DiagrammeR")
#' dm_pixarfilms()
#' dm_pixarfilms() %>%
#'   dm_draw()
dm_pixarfilms <- function(..., color = TRUE, consistent = FALSE, version = "v1") {
  check_dots_empty()

  version <- arg_match(version, c("v1", "latest"))

  # Extract data objects
  if (version == "latest") {
    # Check for data package installed
    check_suggested("pixarfilms", "dm_pixarfilms")

    pixar_films <- pixarfilms::pixar_films
    pixar_people <- pixarfilms::pixar_people
    academy <- pixarfilms::academy
    box_office <- pixarfilms::box_office
    genres <- pixarfilms::genres
    public_response <- pixarfilms::public_response
  } else {
    data <- pixarfilms_v1()
    pixar_films <- data$pixar_films
    pixar_people <- data$pixar_people
    academy <- data$academy
    box_office <- data$box_office
    genres <- data$genres
    public_response <- data$public_response
  }

  if (consistent) {
    pixar_films <- filter(pixar_films, !is.na(film))
  }

  # Create dm object
  dm <- dm(
    pixar_films,
    pixar_people,
    academy,
    box_office,
    genres,
    public_response
  )

  # Add primary keys
  dm <-
    dm %>%
    dm_add_pk(pixar_films, film) %>%
    dm_add_pk(academy, c(film, award_type)) %>%
    dm_add_pk(box_office, film) %>%
    dm_add_pk(genres, c(film, genre)) %>%
    dm_add_pk(public_response, film)

  # Add foreign keys between tables
  dm <-
    dm %>%
    dm_add_fk(pixar_people, film, pixar_films) %>%
    dm_add_fk(academy, film, pixar_films) %>%
    dm_add_fk(box_office, film, pixar_films) %>%
    dm_add_fk(genres, film, pixar_films) %>%
    dm_add_fk(public_response, film, pixar_films)

  # Set colors for relationship diagram
  if (color) {
    dm <-
      dm %>%
      dm_set_colors(
        "#5B9BD5" = pixar_films,
        "#ED7D31" = c(
          academy,
          box_office,
          genres,
          public_response
        ),
        "#70AD47" = pixar_people
      )
  }

  dm
}

pixarfilms_v1 <- function() {
  readRDS(system.file("extdata/pixarfilms-v1.rds", package = "dm"))
}
