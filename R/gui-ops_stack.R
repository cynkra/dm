ops_stack <- function(x) {
  new_ops_stack(list(x), 1)
}

new_ops_stack <- function(list, pos) {
  stopifnot(is.list(list))
  stopifnot(pos >= 1)
  stopifnot(pos <= length(list))
  list(
    list = list,
    pos = pos
  )
}

ops_stack_current <- function(stack) {
  stack$list[[stack$pos]]
}

ops_stack_append <- function(stack, x) {
  pos <- stack$pos
  new_ops_stack(
    c(stack$list[seq_len(pos)], list(x)),
    pos + 1
  )
}

ops_stack_undo <- function(stack) {
  pos <- stack$pos
  new_ops_stack(
    stack$list,
    max(pos - 1, 1)
  )
}

ops_stack_redo <- function(stack) {
  pos <- stack$pos
  new_ops_stack(
    stack$list,
    min(pos + 1, length(stack$list))
  )
}
