% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/schema.R
\name{db_schema_create}
\alias{db_schema_create}
\title{Create a schema on a database}
\usage{
db_schema_create(con, schema, ...)
}
\arguments{
\item{con}{An object of class \code{"src"} or \code{"DBIConnection"}.}

\item{schema}{Class \code{character} or \code{SQL} (cf. Details), name of the schema}

\item{...}{Passed on to the individual methods.}
}
\value{
\code{NULL} invisibly.
}
\description{
\ifelse{html}{\href{https://lifecycle.r-lib.org/articles/stages.html#experimental}{\figure{lifecycle-experimental.svg}{options: alt='[Experimental]'}}}{\strong{[Experimental]}}

\code{db_schema_create()} creates a schema on the database.
}
\details{
Methods are not available for all DBMS.

An error is thrown if a schema of that name already exists.

The argument \code{schema} (and \code{dbname} for MSSQL) can be provided as \code{SQL} objects.
Keep in mind, that in this case it is assumed that they are already correctly quoted as identifiers
using \code{\link[DBI:dbQuoteIdentifier]{DBI::dbQuoteIdentifier()}}.

Additional arguments are:
\itemize{
\item \code{dbname}: supported for MSSQL. Create a schema in a different
database on the connected MSSQL-server; default: database addressed by \code{con}.
}
}
\seealso{
Other schema handling functions: 
\code{\link{db_schema_drop}()},
\code{\link{db_schema_exists}()},
\code{\link{db_schema_list}()}
}
\concept{schema handling functions}
