% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/unique-keys.R
\name{dm_get_all_uks}
\alias{dm_get_all_uks}
\title{Get all unique keys of a \code{\link{dm}} object}
\usage{
dm_get_all_uks(dm, table = NULL, ...)
}
\arguments{
\item{dm}{A \code{dm} object.}

\item{table}{One or more table names, unquoted,
to return unique key information for.
The default \code{NULL} returns information for all tables.}

\item{...}{These dots are for future extensions and must be empty.}
}
\value{
A tibble with the following columns:
\describe{
\item{\code{table}}{table name,}
\item{\code{uk_col}}{column name(s) of primary key, as list of character vectors,}
\item{\code{kind}}{kind of unique key, see details.}
}
}
\description{
\code{dm_get_all_uks()} checks the \code{dm} object for unique keys
(primary keys, explicit and implicit unique keys) and returns the tables and
the respective unique key columns.
}
\details{
There are 3 kinds of unique keys:
\itemize{
\item \code{PK}: Primary key, set by \code{\link[=dm_add_pk]{dm_add_pk()}}
\item \verb{explicit UK}: Unique key, set by \code{\link[=dm_add_uk]{dm_add_uk()}}
\item \verb{implicit UK}: Unique key, not explicitly set, but referenced by a foreign key.
}
}
\examples{
\dontshow{if (rlang::is_installed("nycflights13")) withAutoprint(\{ # examplesIf}
dm_nycflights13() \%>\%
  dm_get_all_uks()
\dontshow{\}) # examplesIf}
}
\seealso{
Other primary key functions: 
\code{\link{dm_add_pk}()},
\code{\link{dm_add_uk}()},
\code{\link{dm_get_all_pks}()},
\code{\link{dm_has_pk}()},
\code{\link{dm_rm_pk}()},
\code{\link{dm_rm_uk}()},
\code{\link{enum_pk_candidates}()}
}
\concept{primary key functions}
