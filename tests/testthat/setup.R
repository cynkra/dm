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

if (rlang::is_installed("dbplyr")) {
  local_mocked_bindings(
    tbl_sum.tbl_sql = function(x, ...) c(),
    tbl_format_header.tbl_sql = function(x, ...) invisible(),
    .package = "dbplyr",
    .env = teardown_env()
  )
}
