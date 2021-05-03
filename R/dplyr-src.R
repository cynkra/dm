#' dm as data source
#'
#' @description
#' `r lifecycle::badge("deprecated")`
#'
#' These methods are deprecated because of their limited use,
#' and because the notion of a "source" seems to be getting phased out from dplyr.
#' Use other ways to access the tables in a `dm`.
#'
#' @details
#' Use [dm_get_con()] instead of `dm_get_src()` to get the DBI connetion for a
#' `dm` object
#'
#' @name dplyr_src
#' @export
#' @keywords internal
dm_get_src <- function(x) {
  deprecate_soft("0.2.0", "dm::dm_get_src()", details = "Use `dm_get_con(dm)` for databases, or `class(dm[[1]])` to get the class of a table.")

  check_not_zoomed(x)
  dm_get_src_impl(x)
}

#' @details
#' Use [`[[`][base::Extract] instead of `tbl()` to access individual tables in a `dm` object.
#' @param src A `dm` object.
#' @param from A length one character variable containing the name of the requested table
#' @param ... See original function documentation
#' @export
#' @rdname dplyr_src
#' @keywords internal
tbl.dm <- function(src, from, ...) {
  deprecate_soft("0.2.0", "dm::tbl.dm()", details = "Use `dm[[table_name]]` instead to access a specific table.")

  check_not_zoomed(src)

  # The src argument here is a dm object
  tbl_impl(src, from)
}

#' @details
#' Get the names from [dm_get_tables()] instead of calling `dm_get_src()`
#' to list the table names in a `dm` object.
#' @rdname dplyr_src
#' @keywords internal
#' @export
src_tbls.dm <- function(x, ...) {
  deprecate_soft("0.2.0", "dm::src_tbls.dm()", details = "Use `names(dm_get_tables(dm))` instead.")

  check_not_zoomed(x)

  src_tbls_impl(x)
}

#' @details
#' Use [copy_to()] on a table and then [dm_add_tbl()] instead of `copy_to()`
#' on a `dm` object.
#' @param dest For `copy_to.dm()`: The `dm` object to which a table should be copied.
#' @param df For `copy_to.dm()`: A table (can be on a different `src`)
#' @param name For `copy_to.dm()`: See [`dplyr::copy_to`]
#' @param overwrite For `copy_to.dm()`: See [`dplyr::copy_to`]; `TRUE` leads to an error
#' @param temporary For `copy_to.dm()`: If the `dm` is on a DB, the copied version of `df` will only be written temporarily to the DB.
#' After the connection is reset it will no longer be available.
#' @param repair,quiet Name repair options; cf. [`vctrs::vec_as_names`]
#' @export
#' @rdname dplyr_src
#' @keywords internal
copy_to.dm <- function(dest, df, name = deparse(substitute(df)), overwrite = FALSE, temporary = TRUE, repair = "unique", quiet = FALSE, ...) {
  deprecate_soft("0.2.0", "dm::copy_to.dm()", details = "Use `copy_to(dm_get_con(dm), ...)` and `dm_add_tbl()`.")

  check_not_zoomed(dest)

  if (!(inherits(df, "data.frame") || inherits(df, "tbl_dbi"))) abort_only_data_frames_supported()
  if (overwrite) abort_no_overwrite()
  if (length(name) != 1) abort_one_name_for_copy_to(name)
  # src: if `df` on a different src:
  # if `df_list` is on DB and `dest` is local, collect `df_list`
  # if `df_list` is local and `dest` is on DB, copy `df_list` to respective DB
  dest_src <- dm_get_src_impl(dest)
  if (is.null(dest_src)) {
    df <- as_tibble(collect(df))
  } else {
    # FIXME: should we allow `overwrite` argument?
    df <- copy_to(dest_src, df, unique_db_table_name(name), temporary = temporary, ...)
  }
  names_list <- repair_table_names(src_tbls_impl(dest), name, repair, quiet)
  # rename old tables with potentially new names
  dest <- dm_rename_tbl(dest, !!!names_list$new_old_names)
  # `repair` argument is `unique` by default
  dm_add_tbl_impl(dest, list(df), names_list$new_names)
}
