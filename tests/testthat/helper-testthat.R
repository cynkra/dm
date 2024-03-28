options(testthat.progress.verbose_skips = FALSE)
options(Ncpus = min(parallel::detectCores(), 4))
options(lifecycle_verbosity = "warning")
