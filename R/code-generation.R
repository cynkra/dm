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

show_cg_input_object <- function(x, has_no_f_call) {
  if (has_no_f_call) {
    if (!is_empty(x$cg_input_object)) {
      cat(cg_clean_in_obj_text(x))
    }
  } else {
    cat(paste0(cg_clean_in_obj_text(x), " %>%\n"))
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
