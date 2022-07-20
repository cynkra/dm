#' Create a new state for the code-generation middleware
#'
#' @param dm A dm object, e.g. `dm_nycflights13()`.
#' @noRd
new_mw_cg <- function(dm) {
  structure(
    list(
      dm = dm,
      cg = new_cg_block(quo(dm))
    ),
    class = "dm_mw_cg"
  )
}

#' Run a command for the code-generation middleware
#'
#' @param mw_cg A state object as created by [new_mw_cg()] or a previous
#'   `mw_cg_run()` call.
#' @param op_name An operation name as string, see `mw_cg_make()` for the
#'   supported ones.
#' @param ... Named arguments as required by the individual `mw_cg_make_...()`
#'   functions.
#' @param confirmation_function A function or function-like with one argument
#'   that contains a confirmation message to show.
#'   This function is called whenever the middleware requests confirmation
#'   from the user.
#'   This function must return a scalar logical that indicates whether to
#'   proceed.
#'   Processed with [rlang::as_function()].
#' @param abort_function A function or function-like with one argument
#'   that contains an error message to show.
#'   This function is called whenever the middleware encounters a failure and
#'   must abort the operation.
#'   Processed with [rlang::as_function()].
#' @noRd
mw_cg_run <- function(mw_cg, op_name, ...,
                      confirmation_function = abort_function,
                      abort_function = abort) {
  confirmation_function <- as_function(confirmation_function)
  abort_function <- as_function(abort_function)

  recipe <- tryCatch(
    mw_cg_make(mw_cg$dm, op_name = op_name, ...),
    error = function(e) {
      abort_function(paste0("Error from `mw_cg_make()`: ", conditionMessage(e)))
      NULL
    }
  )
  if (is.null(recipe)) {
    return(mw_cg)
  }

  if (!is.null(recipe$confirmation_message)) {
    out <- confirmation_function(recipe$confirmation_message)
    if (!is_scalar_logical(out)) {
      abort_function(paste0("Internal error in `mw_cg_run()`: `confirmation_function()` doesn't return a scalar logical."))
    }
    if (!isTRUE(out)) {
      return(mw_cg)
    }
  }

  mw_cg$cg <- purrr::reduce(recipe, ~ cg_add_call(..1, ..2), .init = mw_cg$cg)
  tryCatch(
    mw_cg$dm <- cg_eval_block(mw_cg$cg),
    error = function(e) {
      abort_function(paste0("Unexpected error in `mw_cg_run()`: ", conditionMessage(e)))
    }
  )
  mw_cg
}

mw_cg_make <- function(dm, op_name, ...) {
  # FIXME: Add more operations, call e.g. use_cg_make("dm_select_tbl")
  # to create templates
  switch(op_name,
    "dm_select_tbl" = mw_cg_make_dm_select_tbl(dm, ...),
    "dm_add_pk" = mw_cg_make_dm_add_pk(dm, ...),
    "dm_add_fk" = mw_cg_make_dm_add_fk(dm, ...),
    "dm_rename" = mw_cg_make_dm_rename(dm, ...),
    "dm_rm_fk" = mw_cg_make_dm_rm_fk(dm, ...),
    "dm_set_colors" = mw_cg_make_dm_set_colors(dm, ...),
    "dm_disentangle" = mw_cg_make_dm_disentangle(dm, ...),
    "dm_select" = mw_cg_make_dm_select(dm, ...),
    abort(paste0("Unknown op in `mw_cg_make()`: ", op))
  )
}

use_cg_make <- function(name) {
  r_name <- paste0("mw_cg_make_", name, ".R")
  test_name <- paste0("test-", r_name)

  usethis::use_template(
    "test-mw_cg_make.R", file.path("tests/testthat", test_name),
    list(name = name),
    package = utils::packageName(),
    open = TRUE
  )

  usethis::use_template(
    "mw_cg_make.R", file.path("R", r_name),
    list(name = name),
    package = utils::packageName(),
    open = TRUE
  )
}
