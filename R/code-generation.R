new_cg_block <- function(cg_input_object = list(), cg_f_list = list()) {
  structure(list(cg_input_object = cg_input_object, cg_f_list = cg_f_list), class = "cg_code_block")
}

cg_add_call <- function(cg_block, fn_call) {
  fn <- function(.) NULL
  body(fn) <- enexpr(fn_call)
  new_cg_block(cg_block$cg_input_object, append(cg_block$cg_f_list, fn))
}

#' @export
format.cg_code_block <- function(x, ...) {
  c(
    cg_format_input_object(x, is_empty(x$cg_f_list)),
    cg_format_f_list(x$cg_f_list)
  )
}

#' @export
print.cg_code_block <- function(x, ...) {
  writeLines(format(x, ...))
  invisible(x)
}

cg_format_input_object <- function(x, has_no_f_call) {
  if (has_no_f_call) {
    if (!is_empty(x$cg_input_object)) {
      cg_clean_in_obj_text(x)
    }
  } else {
    paste0(cg_clean_in_obj_text(x), " %>%\n")
  }
}

cg_format_f_list <- function(x) {
  if (is_empty(x)) {
    character()
  } else {
    purrr::map_chr(x, ~ body(.) %>% call_to_char()) %>%
      paste0("  ", ., collapse = " %>%\n")
  }
}

call_to_char <- function(body) {
  trimws(expr_deparse(body)) %>% paste0(collapse = "\n  ")
}

cg_eval_block <- function(cg_block) {
  if (is_empty(cg_block$cg_f_list)) {
    eval_tidy(cg_block$cg_input_object)
  } else {
    freduce(eval_tidy(cg_block$cg_input_object), cg_block$cg_f_list)
  }
}

cg_clean_in_obj_text <- function(x) {
  gsub("\033[39m", "", trimws(expr_deparse(x$cg_input_object)), fixed = TRUE) %>%
    gsub("\\^", "", .)
}
