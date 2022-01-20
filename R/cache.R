cache_attach <- function(algo = "sha512", base_attach = attach, name = paste0(utils::packageName(), "_cache")) {
  force(algo)

  if (!is_attached(name)) {
    env <- new_environment(list(...cache = new_environment()))
    base_attach(env, pos = length(search()) - 1, name = name)
  }
  cache <- search_env(name)$...cache

  cache_reset <- function() {
    rm(list = ls(cache), envir = cache)
  }

  cache_set <- function(key, value) {
    assign(key, value, envir = cache)
  }

  cache_get <- function(key) {
    get(key, envir = cache, inherits = FALSE)
  }

  cache_has_key <- function(key) {
    exists(key, envir = cache, inherits = FALSE)
  }

  list(
    digest = function(...) digest::digest(..., algo = algo),
    reset = cache_reset,
    set = cache_set,
    get = cache_get,
    has_key = cache_has_key,
    keys = function() ls(cache)
  )
}
