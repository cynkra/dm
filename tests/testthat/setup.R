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
  has_tbl_sum <- exists("tbl_sum.tbl_sql", envir = asNamespace("dbplyr"))
  bindings <- compact(list(
    tbl_sum.tbl_sql = if (has_tbl_sum) function(x, ...) c(),
    tbl_format_header.tbl_sql = function(x, ...) invisible()
  ))
  local_mocked_bindings(!!!bindings, .package = "dbplyr", .env = teardown_env())
}
