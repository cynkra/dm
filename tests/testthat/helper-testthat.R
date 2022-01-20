options(testthat.progress.verbose_skips = FALSE)
options(Ncpus = min(parallel::detectCores(), 4))
options(tidyselect_verbosity = "verbose")
