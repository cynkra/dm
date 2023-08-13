# utils::Rprof(paste0("~/", Sys.getpid(), ".Rprof"), line.profiling = TRUE)
#
# withr::defer(utils::Rprof(NULL), teardown_env())

local_options(
  pillar.min_title_chars = NULL,
  pillar.max_title_chars = NULL,
  pillar.max_footer_lines = NULL,
  pillar.bold = NULL,
  .frame = teardown_env()
)
