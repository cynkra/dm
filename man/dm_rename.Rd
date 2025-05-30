% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/select.R
\name{dm_rename}
\alias{dm_rename}
\title{Rename columns}
\usage{
dm_rename(dm, table, ...)
}
\arguments{
\item{dm}{A \code{dm} object.}

\item{table}{A table in the \code{dm}.}

\item{...}{One or more unquoted expressions separated by commas.
You can treat
variable names as if they were positions, and use expressions like \code{x:y}
to select the ranges of variables.

Use named arguments, e.g. \code{new_name = old_name}, to rename the selected variables.

The arguments in ... are automatically quoted and evaluated in a context where
column names represent column positions.
They also support unquoting and splicing.
See \code{vignette("programming", package = "dplyr")} for an introduction to those concepts.

See select helpers for more details, and the examples about \link[tidyselect:language]{tidyselect helpers}, such as \code{starts_with()}, \code{everything()}, etc.}
}
\value{
An updated \code{dm} with the columns of \code{table} renamed.
}
\description{
Rename the columns of your \code{\link{dm}} using syntax that is similar to \code{\link[dplyr:rename]{dplyr::rename()}}.
}
\details{
If key columns are renamed, then the meta-information of the \code{dm} is updated accordingly.
}
\examples{
\dontshow{if (rlang::is_installed("nycflights13")) withAutoprint(\{ # examplesIf}
dm_nycflights13() \%>\%
  dm_rename(airports, code = faa, altitude = alt)
\dontshow{\}) # examplesIf}
}
