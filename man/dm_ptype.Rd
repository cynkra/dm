% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/ptype.R
\name{dm_ptype}
\alias{dm_ptype}
\title{Prototype for a dm object}
\usage{
dm_ptype(dm)
}
\arguments{
\item{dm}{A \code{dm} object.}
}
\description{
The prototype contains all tables, all primary and foreign keys,
but no data.
All tables are truncated and converted to zero-row tibbles,
also for remote data models.
Columns retain their type.
This is useful for performing creation and population of a database
in separate steps.
}
\examples{
\dontshow{if (dm:::dm_has_financial()) withAutoprint(\{ # examplesIf}
dm_financial() \%>\%
  dm_ptype()

dm_financial() \%>\%
  dm_ptype() \%>\%
  dm_nrow()
\dontshow{\}) # examplesIf}
}
