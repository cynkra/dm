#' Test if column (combination) is primary key of table
#'
#' @description `check_key()` accepts a data frame and optionally columns and throws an error,
#' if the given columns (or all columns if none specified) are NOT a primary key of the data frame.
#' If the columns given in the ellipsis ARE a primary key, the data frame itself is returned silently for piping convenience.
#'
#' @param .data Data frame whose columns should be tested for key properties.
#' @param ... Names of columns to be checked. If none specified all columns together are tested for key property.
#'
#' @export
#' @examples
#' \dontrun{
#' data <- tibble(a = c(1, 2, 1), b = c(1, 4, 1), c = c(5, 6, 7))
#' # this is failing:
#' check_key(data, a, b)
#'
#' # this is passing:
#' check_key(data, a, c)
#' }
check_key <- function(.data, ...) {

  data_q <- enquo(.data)

  duplicate_rows <-
    .data %>%
    as_tibble() %>% # as_tibble works only, if as_tibble.sf()-method is available
    count(...) %>%
    filter(n != 1)

  if (nrow(duplicate_rows) != 0) {
   stop(paste0("(",
               paste(purrr::map_chr(quos(...), rlang::as_label), collapse = ", "),
               ") is not a primary key of ",
               rlang::as_label(data_q)), call. = FALSE)
  }

  invisible(.data)
}


#' Test foreign key properties for two tables and two columns (NOT column combinations) in both directions
#'
#' @description `check_overlap()` is a wrapper of `check_foreign_key()`. It tests the foreign key property in both directions.
#'
#' @param t1 First data frame whose column `c1` should be tested for key properties.
#' @param c1 Column of first data frame which should be tested for foreign key property w.r.t. the second table,
#' i.e. if all values of `c1` are also values of `c2`.
#' @param t2 Second data frame whose column should be tested for key properties.
#' @param c2 Column of second data frame which should be tested for foreign key property w.r.t. the first table,
#' i.e. if all values of `c2` are also values of `c1`.
#'
#' @export
#' @examples
#' \dontrun{
#' data_1 <- tibble(a = c(1, 2, 1), b = c(1, 4, 1), c = c(5, 6, 7))
#' data_2 <- tibble(a = c(1, 2, 3), b = c(4, 5, 6), c = c(7, 8, 9))
#' # this is failing:
#' check_overlap(data_1, a, data_2, a)
#'
#' data_3 <- tibble(a = c(2, 1, 2), b = c(4, 5, 6), c = c(7, 8, 9))
#' # this is passing:
#' check_overlap(data_1, a, data_3, a)
#' }
check_overlap <- function(t1, c1, t2, c2) {
  t1q <- enquo(t1)
  c1q <- enquo(c1)

  t2q <- enexpr(t2)
  c2q <- enexpr(c2)

  catcher_1 <- tryCatch({
    check_foreign_key(!!t1q, !!c1q, !!t2q, !!c2q)
    NULL},
    error = identity
  )

  catcher_2 <- tryCatch({
    check_foreign_key(!!t2q, !!c2q, !!t1q, !!c1q)
    NULL},
    error = identity
  )

  catchers <- compact(list(catcher_1, catcher_2))

  if (length(catchers) > 0) {
    stop(paste0(map_chr(catchers, conditionMessage), collapse = "\n  "))
  }

  invisible(t1)
}

#' Test foreign key property for two tables and two columns (NOT column combinations) in one direction
#'
#' @description `check_foreign_key()` tests, if the chosen column `c1` of data frame `t1` is a foreign key for
#' data frame `t2` (when checked against column `c2`).
#'
#' @param t1 First data frame whose column `c1` should be tested for foreign key properties.
#' @param c1 Column of first data frame which should be tested for foreign key property w.r.t. the second table,
#' i.e. if all values of `c1` are also values of `c2`.
#' @param t2 Second data frame.
#' @param c2 Column of second data frame which has to contain all values of `c1` to avoid an error.
#'
#' @export
#' @examples
#' \dontrun{
#' data_1 <- tibble(a = c(1, 2, 1), b = c(1, 4, 1), c = c(5, 6, 7))
#' data_2 <- tibble(a = c(1, 2, 3), b = c(4, 5, 6), c = c(7, 8, 9))
#' # this is passing:
#' check_foreign_key(data_1, a, data_2, a)
#'
#' # this is failing:
#' check_foreign_key(data_2, a, data_1, a)
#' }
check_foreign_key <- function(t1, c1, t2, c2) {
  t1q <- enquo(t1)
  t2q <- enquo(t2)

  c1q <- enexpr(c1)
  c2q <- enexpr(c2)

  # Hier kann nicht t1 direkt verwendet werden, da das für den Aufruf
  # check_overlap_uni(!!t1q, !!c1q, !!t2q, !!c2q) der Auswertung des Ausdrucks !!t1q
  # entsprechen würde; dies ist nicht erlaubt.
  # Siehe eval-bang.R für ein Minimalbeispiel.
  v1 <- pull(rlang::eval_tidy(t1q), !!c1q)
  v2 <- pull(rlang::eval_tidy(t2q), !!c2q)

  if (!all(v1 %in% v2)) {
    print(rlang::eval_tidy(t1q) %>% filter(!(!!v1 %in% !!v2)))
    stop(paste0("Foreign key constraint: Column `",
                rlang::as_label(c1q),
                "` in table `",
                rlang::as_label(t1q),
                "` contains values (see above) that are not present in column `",
                rlang::as_label(c2q),
                "` in table `",
                rlang::as_label(t2q),
                "`"),
         call. = FALSE)
    #rlang::abort(paste0("Key constraint: ", rlang::as_label(t1q)))
  }

  invisible(rlang::eval_tidy(t1q))

}
