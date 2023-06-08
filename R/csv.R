#' @name dm_duckdb_csv
#'
#' @title Create dm object based on remote csv files
#'
#' @description
#' Function takes path to directory where multiple tables are stored in csv
#' files and creates `dm` from those tables. It uses `duckdb` to create remote
#' `tbl` objects which are then used as tables for `dm` object.
#'
#' @details
#' Function operates on remote tables, therefore data are not being loaded to R.
#' The are following consequences of that:
#' \itemize{
#'   \item{ Size of data can exceed machine's memory limit. }
#'   \item{ Queries run against csv are likely to be slower than if data are
#'   loaded into R's memory. }
#'   \item{ Performance of queries can be improved by partitioning csv files. }
#'   \item{ Data can be inserted or updated in csv files directly and changes will be
#'   reflected on the next query. There is no need to reload data. }
#' }
#'
#' @param path Path to directory from where csv files has to be read from.
#'   Directory can have sub-directories in case of partitioned data.
#' @param conn Connection object to duckdb. See [duckdb::duckdb()] for details.
#'
#' @section Partitioning:
#' Tables provided in csv files can be partitioned. This will likely bring
#' significant performance improvement in case when queries do not need to
#' access data from all partitions. Structure for partitioned data in csv files
#' must follow \href{https://duckdb.org/docs/data/partitioning/hive_partitioning}{duckdb's Hive Partitioning} documentation.
#' Partitioning can support nested partitioning, but not recursively nested.
#' So the following are supported:
#' \preformatted{
#'   path/flights/year=2013/*.csv
#'   path/flights/year=2014/*.csv
#'
#'   path/transactions/year=2013/month=1/*.csv
#'   path/transactions/year=2013/month=2/*.csv
#' }
#'
#' @return A `dm` object.
#'
#' @export
#' @examples
#' ## create exanple source data directory
#' path <- file.path(tempdir(), "data")
#' dir.create(path, showWarnings=FALSE)
#' x <- dm_nycflights13()
#' tbl_export_csv <- function(tbl, dm) {
#'   file <- file.path(path, paste(tbl, "csv", sep="."))
#'   utils::write.csv(dm[[tbl]], file=file, row.names=FALSE)
#' }
#' invisible(lapply(names(x), tbl_export_csv, x))
#' list.files(path)
#'
#' ## create dm from remote csv files via duckdb
#' conn <- DBI::dbConnect(duckdb::duckdb(), dbdir=":memory:")
#' d <- dm_duckdb_csv(path, conn)
#' d
#'
#' ## cleanup db connection
#' DBI::dbDisconnect(conn)
dm_duckdb_csv <- function(path = ".", conn) {
  if (!is.character(path) || length(path)!=1L || is.na(path))
    stop("Argument 'path' must be non-NA scalar character")
  if (!dir.exists(path))
    stop("Argument 'path' must point to an existing directory")
  if (!inherits(conn, "duckdb_connection"))
    stop("Argument 'conn' must be an object of 'duckdb_connection' class")

  ## single csv per table: path/table.csv
  files <- list.files(path=path, pattern="\\.csv$")
  ## hive partitioned csv table:
  ## path/table/year=2012/*.csv
  ## path/table/year=2012/month=1/*.csv
  dirs <- list.dirs(path=path, recursive=FALSE, full.names=FALSE)
  if (!(length(files) + length(dirs)))
    stop("In provided 'path' there are no csv files neither sub-directories of partitioned csv files")

  ## partitions handling
  ## validate structure, dir names, csv files
  ## determine if there is nested partitioning: year=2001/month=1
  if (length(dirs)) {
    validate.partition.names <- function(p) {
      p1 <- strsplit(p, "=", fixed=TRUE)
      if (any(lengths(p1)!=2L)) ## when not: LHS=RHS
        stop("Partition sub-directories must be named as column=value")
      if (length(unique(sapply(p1, `[[`, 1L)))!=1L) ## when: year=2012, jahr=2013
        stop("Partition sub-directories must specify same column for all partitions")
    }
    get.partition.level <- function(p, d, path) {
      p1.path <- file.path(path, d, p)
      part2 <- list.dirs(path=p1.path, recursive=FALSE, full.names=FALSE)
      if (!length(part2)) {
        ## no nested partitions, expect csv file(s)
        p1.files <- list.files(path=p1.path, pattern="\\.csv$")
        ## lets assume empty partitions are fine, but there must be at least one non-empty to obtain table schema
        if (!length(p1.files))
          stop("There must be at least one csv file in partitions sub-directory in ", p1.path)
        1L
      } else {
        ## expect nested partitions sub-dirs, no csv
        p1.files <- list.files(path=p1.path, pattern="\\.csv$")
        if (length(p1.files))
          stop("There must be no csv files when there exists nested partitions sub-directories in ", p1.path)
        validate.partition.names(part2)
        p2.path = file.path(p1.path, part2)
        p2.files <- list.files(path=p2.path, pattern="\\.csv$")
        if (!length(p2.files))
          stop("There must be at least one csv file in partitions sub-directory in ", p2.path)
        2L
      }
    }

    p.levels <- vapply(stats::setNames(nm=dirs), function(d, path) {
      tbl.path <- file.path(path, d)
      part1 <- list.dirs(path=tbl.path, recursive=FALSE, full.names=FALSE)
      if (!length(part1))
        stop("There must be partitions sub-directories in", tbl.path)
      validate.partition.names(part1)
      tbl.partitions <- vapply(stats::setNames(nm=part1), get.partition.level, 0L, d, path)
      ## mixed levels nested partitioning for one table not allowed
      ## when: flights/year=2013/data.csv, flights/year=2014/month=1/data.csv
      lvl = unique(tbl.partitions)
      if (length(lvl)!=1L)
        stop("Mixed levels of nested partitioning for one table are not allowed, fix structure for ", d)
      lvl
    }, 0L, path)
  } else {
    p.levels = integer()
  }

  ## source structure metadata table
  df <- as.data.frame(list(
    tbl = c(tools::file_path_sans_ext(basename(files)), dirs),
    partitioning = c(rep.int(0L, length(files)), p.levels),
    path = file.path(path, c(
      files,
      file.path(dirs, "*", ifelse(p.levels==1L, "*.csv", file.path("*","*.csv")))
    ))
  ))
  df$duckdb_src <- paste0("read_csv('", df$path, "', hive_partitioning=", ifelse(df$partitioning > 0L, 1L, 0L), ", delim=',', header=True, auto_detect=True)")
  df <- df[order(df$tbl), , drop=FALSE]

  new_dm(lapply(stats::setNames(df$duckdb_src, df$tbl), dplyr::tbl, src=conn))
}
