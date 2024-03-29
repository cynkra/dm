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
#'
#' @return A `dm` object consisting of \pkg{pixarfilms} tables, complete with
#'   primary and foreign keys and optionally colored.
#'
#' @export
#' @autoglobal
#' @examplesIf rlang::is_installed(c("pixarfilms", "DiagrammeR"))
#' dm_pixarfilms()
#' dm_pixarfilms() %>%
#'   dm_draw()
dm_pixarfilms <- function(..., color = TRUE, consistent = FALSE) {
  check_dots_empty()

  # Check for data package installed
  check_suggested("pixarfilms", "dm_pixarfilms")

  # Extract data objects
  pixar_films <- pixarfilms::pixar_films
  if (consistent) pixar_films <- filter(pixar_films, !is.na(film))

  pixar_people <- pixarfilms::pixar_people
  academy <- pixarfilms::academy
  box_office <- pixarfilms::box_office
  genres <- pixarfilms::genres
  public_response <- pixarfilms::public_response

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
