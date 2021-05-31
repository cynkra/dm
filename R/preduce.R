preduce <- function(.l,.f, ..., .init, .dir = c("forward", "backward")) {
  .dir <- match.arg(.dir)
  reduce(transpose(.l), function(x,y) exec(.f, x, !!!y, ...), .init = .init, .dir = .dir)
}
