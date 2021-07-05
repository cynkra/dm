expect_error_obj <- function(object, regexp = NULL, class = NULL, ...,
                             info = NULL, label = NULL) {
  testthat::expect_error(
    obj <- rlang::eval_tidy({{ object }}),
    regexp = regexp,
    class = class,
    ...,
    all = all,
    info = info,
    label = label)
  invisible(obj)
}

expect_warning_obj <- function(object, regexp = NULL, class = NULL, ...,
                               info = NULL, label = NULL) {
  testthat::expect_warning(
    obj <- rlang::eval_tidy({{ object }}),
    regexp = regexp,
    class = class,
    ...,
    info = info,
    label = label)
  invisible(obj)
}

expect_message_obj <- function(object, regexp = NULL, class = NULL, ...,
                               info = NULL, label = NULL) {
  testthat::expect_message(
    obj <- rlang::eval_tidy({{ object }}),
    regexp = regexp,
    class = class,
    ...,
    info = info,
    label = label)
  invisible(obj)
}

expect_condition_obj <- function(object, regexp = NULL, class = NULL, ...,
                                 info = NULL, label = NULL) {
  testthat::expect_condition(
    obj <- rlang::eval_tidy({{ object }}),
    regexp = regexp,
    class = class,
    ...,
    info = info,
    label = label)
  invisible(obj)
}

expect_deprecated_obj <- function(object, regexp = NULL, ...,
                                  info = NULL, label = NULL) {
  lifecycle::expect_deprecated(
    obj <- rlang::eval_tidy({{ object }}),
    regexp = regexp,
    ...,
    info = info,
    label = label)
  invisible(obj)
}
