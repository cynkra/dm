c_list_of <- function(x) {
  if (length(x) == 0) {
    # vctrs internals
    return(attr(x, "ptype"))
  }

  vec_c(!!!x, .name_spec = zap())
}
