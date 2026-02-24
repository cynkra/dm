# Shiny app for defining dm objects

**\[experimental\]**

This function starts a Shiny application that allows to define `dm`
objects from a database or from local data frames. The application
generates R code that can be inserted or copy-pasted into an R script or
function.

## Usage

``` r
dm_gui(..., dm = NULL, select_tables = TRUE, debug = FALSE)
```

## Arguments

- ...:

  These dots are for future extensions and must be empty.

- dm:

  An initial dm object, currently required.

- select_tables:

  Show selectize input to select tables?

- debug:

  Set to `TRUE` to simplify debugging of the app.

## Details

In a future release, the app will also allow composing `dm` objects
directly from database connections or data frames.

The signature of this function is subject to change without notice. This
should not pose too many problems, because it will usually be run
interactively.

## Examples

``` r
if (FALSE) { # \dontrun{
dm <- dm_nycflights13(cycle = TRUE)
dm_gui(dm = dm)
} # }
```
