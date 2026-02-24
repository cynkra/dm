# Creates a dm object for the pixarfilms data

Creates an example [`dm`](https://dm.cynkra.com/reference/dm.md) object
from the tables in pixarfilms, along with the references.

## Usage

``` r
dm_pixarfilms(..., color = TRUE, consistent = FALSE, version = "v1")
```

## Arguments

- ...:

  These dots are for future extensions and must be empty.

- color:

  Boolean, if `TRUE` (default), the resulting `dm` object will have
  colors assigned to different tables for visualization with
  [`dm_draw()`](https://dm.cynkra.com/reference/dm_draw.md).

- consistent:

  Boolean, In the original `dm` the `film` column in `pixar_films`
  contains missing values so cannot be made a proper primary key. Set to
  `TRUE` to remove those records.

- version:

  The version of the data to use. `"v1"` (default) uses a vendored
  snapshot of pixarfilms 0.2.1. `"latest"` uses the data from the
  installed pixarfilms package.

## Value

A `dm` object consisting of pixarfilms tables, complete with primary and
foreign keys and optionally colored.

## Examples

``` r
dm_pixarfilms()
#> ── Metadata ────────────────────────────────────────────────────────────────────
#> Tables: `pixar_films`, `pixar_people`, `academy`, `box_office`, `genres`, `public_response`
#> Columns: 23
#> Primary keys: 5
#> Foreign keys: 5
dm_pixarfilms() %>%
  dm_draw()
%0


academy
academyfilmfilm, award_typepixar_films
pixar_filmsfilmacademy:film->pixar_films:film
box_office
box_officefilmbox_office:film->pixar_films:film
genres
genresfilmfilm, genregenres:film->pixar_films:film
pixar_people
pixar_peoplefilmpixar_people:film->pixar_films:film
public_response
public_responsefilmpublic_response:film->pixar_films:film
```
