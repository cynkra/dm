% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/dm_deconstruct.R
\name{dm_deconstruct}
\alias{dm_deconstruct}
\title{Create code to deconstruct a dm object}
\usage{
dm_deconstruct(dm, dm_name = NULL)
}
\arguments{
\item{dm}{A \code{dm} object.}

\item{dm_name}{The code to use to access the dm object,
by default the expression passed to this function.}
}
\value{
This function is called for its side effect of printing
generated code.
}
\description{
\ifelse{html}{\href{https://lifecycle.r-lib.org/articles/stages.html#experimental}{\figure{lifecycle-experimental.svg}{options: alt='[Experimental]'}}}{\strong{[Experimental]}}

Emits code that assigns each table in the dm to a variable,
using \code{\link[=pull_tbl]{pull_tbl()}} with \code{keyed = TRUE}.
These tables retain information about primary and foreign keys,
even after data transformations,
and can be converted back to a dm object with \code{\link[=dm]{dm()}}.
}
\examples{
\dontshow{if (rlang::is_installed("DiagrammeR")) withAutoprint(\{ # examplesIf}
dm <- dm_nycflights13()
dm_deconstruct(dm)
airlines <- pull_tbl(dm, "airlines", keyed = TRUE)
airports <- pull_tbl(dm, "airports", keyed = TRUE)
flights <- pull_tbl(dm, "flights", keyed = TRUE)
planes <- pull_tbl(dm, "planes", keyed = TRUE)
weather <- pull_tbl(dm, "weather", keyed = TRUE)
by_origin <-
  flights \%>\%
  group_by(origin) \%>\%
  summarize(mean_arr_delay = mean(arr_delay, na.rm = TRUE)) \%>\%
  ungroup()

by_origin
dm(airlines, airports, flights, planes, weather, by_origin) \%>\%
  dm_draw()
\dontshow{\}) # examplesIf}
}
