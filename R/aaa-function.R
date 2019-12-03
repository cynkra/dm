nse <- function(fun, env = caller_env()) {
  fun
}

new_cdm_forward <- function(fwd, env = caller_env()) {
  fwd_sym <- ensym(fwd)
  fwd_name <- as_name(fwd_sym)
  old_fwd_name <- gsub("^dm_", "cdm_", fwd_name)

  args <- formals(fwd)
  fwd_args <- set_names(syms(names(args)), names(args))

  body <- expr({
    deprecate_soft("0.1.0", !!paste0("dm::", old_fwd_name, "()"))
    (!!fwd_sym)(!!!fwd_args)
  })

  new_function(args, body, env)
}

# to be used in case names are created from arguments in the `dm`-function
new_cdm_forward_2 <- function(fwd, env = caller_env()) {
  fwd_sym <- ensym(fwd)
  fwd_name <- as_name(fwd_sym)
  old_fwd_name <- gsub("^dm_", "cdm_", fwd_name)

  args <- formals(fwd)

  body <- expr({
    deprecate_soft("0.1.0", !!paste0("dm::", old_fwd_name, "()"))
    !!body(fwd)
  })

  new_function(args, body = body, env)
}
