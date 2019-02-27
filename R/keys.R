
#' @export
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

#' @export
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

#' @export
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
