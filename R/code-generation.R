new_cg_block <- function(cg_input_object = list(), cg_f_list = list()) {
  structure(list(cg_input_object = cg_input_object, cg_f_list = cg_f_list), class = "cg_code_block")
}

cg_add_call <- function(cg_block, fn_call) {
  fn <- function(.) NULL
  body(fn) <- enexpr(fn_call)
  new_cg_block(cg_block$cg_input_object, append(cg_block$cg_f_list, fn))
}

#' @export
print.cg_code_block <- function(x, ...) {
  show_cg_input_object(x, is_empty(x$cg_f_list))
  show_cg_f_list(x$cg_f_list)
}

show_cg_input_object <- function(x, has_f_call) {
  if (has_f_call) {
    if (!is_empty(x$cg_input_object)) {
      cat(trimws(expr_deparse(x$cg_input_object)))
    }
  } else {
    cat(paste0(trimws(expr_deparse(x$cg_input_object)), " %>%\n"))
  }
}

show_cg_f_list <- function(x) {
  if (is_empty(x)) {
    invisible(x)
  } else {
    purrr::map_chr(x, ~ body(.) %>% call_to_char()) %>%
      paste0("  ", ., collapse = " %>%\n") %>%
      cat()
    invisible(x)
  }
}

call_to_char <- function(body) {
  trimws(expr_deparse(body)) %>% paste0(collapse = "\n  ")
}

cg_eval_block <- function(cg_block) {
  freduce(eval(cg_block$cg_input_object), cg_block$cg_f_list)
}
