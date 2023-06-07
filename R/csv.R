#' @name dm_import_csv
#'
#' @title Import CSV files as dm object
#'
#' @description
#' By specifying `path` to a directory of csv files, files are read and
#' `dm` object is created.
#'
#' @param path Path to directory from where csv files has to be read.
#'   For `dm_export_csv` it is a path where csv files will be written to.
#' @param pk Specification of primary keys, not yet implemented.
#' @param fk Specification of foreign keys, not yet implemented.
#' @param x A `dm` object to be exported to csv files.
#'
#' @return For `dm_import_csv` a `dm` object.
#'
#' @seealso
#'
#' - [dm_nycflights13()]  for creating an example `dm` object
#'
#' @export
#' @examples
#' ## extract example dm into csv files
#' x <- dm_nycflights13()
#' dm_export_csv(x, path="csv")
#' list.files("csv")
#' ## read csv files into db
#' dm <- dm_import_csv("csv")
#' dm
dm_import_csv <- function(path = ".", pk=NULL, fk=NULL) {
  if (!dir.exists(path))
    stop("Argument 'path' must point to an existing directory")

  files <- list.files(path=path, pattern="\\.csv$", full.names=TRUE)
  if (!length(files))
    stop("There must be at least one csv file in directory specified by 'path' argument")

  nmfiles <- stats::setNames(files, tools::file_path_sans_ext(basename(files)))
  dm <- new_dm(
    lapply(nmfiles, utils::read.table, header=TRUE, sep=",")
  )

  if (!is.null(pk)) {
    .NotYetImplemented()
  }
  if (!is.null(fk)) {
    .NotYetImplemented()
  }

  return(dm)
}

#' @rdname dm_import_csv
#' @description
#' `dm_export_csv` is a helper function to easily save existing `dm` object
#' into csv files.
#' @return For `dm_export_csv` `NULL` invisibly.
#' @export
dm_export_csv <- function(x, path) {
  # not precisely on the roadmap but useful to not produce required csv by hand
  # could also generate single metadata file, or csvy, to store pk, fk, etc., but we are not really looking after exporting

  if (!is_dm(x))
    stop("'x' must be dm object")
  if (missing(path))
    stop("'path' to export must be provided")
  if (!dir.exists(path))
    dir.create(path, recursive=TRUE)

  tbls <- names(x)
  tbl_export_csv <- function(tbl, dm) {
    file <- file.path(path, paste(tbl, "csv", sep="."))
    cat("writing ", file, "\n", sep="")
    utils::write.table(dm[[tbl]], file=file, sep=",", row.names=FALSE)
  }

  lapply(tbls, tbl_export_csv, x)
  invisible(NULL)
}
