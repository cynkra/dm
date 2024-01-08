dm 1.0.9

## R CMD check results

- [x] Checked locally, R 4.3.2
- [x] Checked on CI system, R 4.3.2
- [x] Checked on win-builder, R devel

## Current CRAN check results

- [x] Checked on 2024-01-08, problems found: https://cran.r-project.org/web/checks/check_results_dm.html
- [ ] ERROR: r-devel-linux-x86_64-debian-clang
     Running ‘testthat.R’ [231s/141s]
     Running the tests in ‘tests/testthat.R’ failed.
     Complete output:
     > library(testthat)
     > 
     > # Need to use qualified call, this is checked in helper-print.R
     > testthat::test_check("dm")
     Loading required package: dm
     
     Attaching package: 'dm'
     
     The following object is masked from 'package:stats':
     
     filter
     
     Starting 2 test processes
     [ FAIL 14 | WARN 6 | SKIP 235 | PASS 1347 ]
     
     ══ Skipped tests (235) ═════════════════════════════════════════════════════════
     • COMPOUND (1): 'test-rows-dm.R:203:3'
     • Dependent on database version, find better way to record this info (1):
     'test-meta.R:19:3'
     • FIXME (2): 'test-learn.R:154:3', 'test-nest.R:2:3'
     • FIXME: Unstable on GHA? (1): 'test-dm.R:495:3'
     • Need to think about it (1): 'test-key-helpers.R:45:3'
     • On CRAN (187): 'test-zzx-deprecated.R:2:3', 'test-zzx-deprecated.R:15:3',
     'test-zzx-deprecated.R:25:3', 'test-zzx-deprecated.R:35:3',
     'test-zzx-deprecated.R:45:3', 'test-zzx-deprecated.R:58:3',
     'test-zzx-deprecated.R:81:3', 'test-zzx-deprecated.R:91:3',
     'test-zzx-deprecated.R:106:3', 'test-zzx-deprecated.R:121:3',
     'test-zzx-deprecated.R:141:3', 'test-zzx-deprecated.R:151:3',
     'test-zzx-deprecated.R:166:3', 'test-zzx-deprecated.R:185:3',
     'test-zzx-deprecated.R:221:3', 'test-zzx-deprecated.R:255:3',
     'test-zzx-deprecated.R:275:3', 'test-zzx-deprecated.R:291:3',
     'test-zzx-deprecated.R:326:3', 'test-zzx-deprecated.R:341:3',
     'test-zzx-deprecated.R:356:3', 'test-flatten.R:18:3', 'test-flatten.R:99:3',
     'test-dplyr.R:347:3', 'test-dplyr.R:506:3', 'test-dplyr.R:545:3',
     'test-dplyr.R:558:3', 'test-dplyr.R:569:3', 'test-dplyr.R:598:3',
     'test-dplyr.R:614:3', 'test-dplyr.R:806:3', 'test-draw-dm.R:17:3',
     'test-draw-dm.R:104:3', 'test-draw-dm.R:117:3', 'test-draw-dm.R:153:3',
     'test-draw-dm.R:182:3', 'test-filter-dm.R:62:3', 'test-filter-dm.R:173:3',
     'test-filter-dm.R:182:3', 'test-filter-dm.R:191:3', 'test-filter-dm.R:241:3',
     'test-bind.R:42:3', 'test-bind.R:97:3', 'test-bind.R:107:3',
     'test-bind.R:125:3', 'test-learn.R:446:3', 'test-add-tbl.R:92:3',
     'test-add-tbl.R:137:3', 'test-autoincrement.R:17:3',
     'test-autoincrement.R:26:3', 'test-rows-dm.R:2:3', 'test-rows-dm.R:28:3',
     'test-rows-dm.R:390:3', 'test-code-generation.R:7:3',
     'test-datamodelr-code.R:4:3', 'test-datamodelr-code.R:17:3',
     'test-datamodelr-code.R:37:3', 'test-datamodelr-code.R:57:3',
     'test-datamodelr-code.R:78:3', 'test-datamodelr-code.R:99:3',
     'test-datamodelr-code.R:120:3', 'test-datamodelr-code.R:133:3',
     'test-db-interface.R:35:3', 'test-check-cardinalities.R:30:3',
     'test-check-cardinalities.R:289:3', 'test-check-cardinalities.R:337:3',
     'test-check-cardinalities.R:422:3', 'test-disambiguate.R:2:3',
     'test-disentangle.R:2:3', 'test-deconstruct.R:6:3',
     'test-deconstruct.R:16:3', 'test-deconstruct.R:26:3',
     'test-deconstruct.R:55:3', 'test-deconstruct.R:72:3',
     'test-deconstruct.R:120:3', 'test-deconstruct.R:144:3',
     'test-deconstruct.R:160:3', 'test-deconstruct.R:181:3',
     'test-deconstruct.R:198:3', 'test-deconstruct.R:222:3',
     'test-deconstruct.R:246:3', 'test-deconstruct.R:270:3',
     'test-deconstruct.R:294:3', 'test-deconstruct.R:320:3',
     'test-deconstruct.R:346:3', 'test-deconstruct.R:372:3',
     'test-deconstruct.R:398:3', 'test-deconstruct.R:420:3',
     'test-deconstruct.R:479:3', 'test-deconstruct.R:492:3',
     'test-deconstruct.R:507:3', 'test-deconstruct.R:525:3',
     'test-deconstruct.R:572:3', 'test-deconstruct.R:586:3',
     'test-deconstruct.R:599:3', 'test-dm_deconstruct.R:2:3',
     'test-dm_deconstruct.R:9:3', 'test-dm.R:2:3', 'test-dm.R:70:3',
     'test-dm.R:108:3', 'test-dm.R:148:3', 'test-dm.R:194:3', 'test-dm.R:202:3',
     'test-dm.R:211:3', 'test-dm.R:217:3', 'test-dm.R:223:3', 'test-dm.R:311:3',
     'test-dm.R:508:3', 'test-dm.R:534:3', 'test-dm.R:564:3', 'test-dm.R:598:3',
     'test-dm_nest_tbl.R:17:3', 'test-dm_pixarfilms.R:2:3', 'test-duckdb.R:2:3',
     'test-enum-ops.R:11:3', 'test-enum-ops.R:30:3', 'test-enum-ops.R:103:3',
     'test-enum-ops.R:176:3', 'test-enumerate_all_paths.R:2:3',
     'test-error-helpers.R:2:3', 'test-dm_wrap.R:12:3', 'test-dm_wrap.R:79:3',
     'test-examine-cardinalities.R:2:3', 'test-examine-cardinalities.R:16:3',
     'test-examine-cardinalities.R:23:3', 'test-examine-constraints.R:68:3',
     'test-examine-constraints.R:77:3', 'test-examine-constraints.R:87:3',
     'test-examine-constraints.R:94:3', 'test-format.R:2:3', 'test-graph.R:29:3',
     'test-graph.R:38:3', 'test-json.R:5:3', 'test-json_nest.R:2:3',
     'test-json_pack.R:2:3', 'test-foreign-keys.R:16:3',
     'test-foreign-keys.R:145:3', 'test-foreign-keys.R:252:3',
     'test-foreign-keys.R:260:3', 'test-foreign-keys.R:287:3',
     'test-foreign-keys.R:306:3', 'test-maria.R:2:3', 'test-meta.R:3:3',
     'test-mssql.R:2:3', 'test-pack_join.R:5:3', 'test-key-helpers.R:4:3',
     'test-key-helpers.R:327:3', 'test-key-helpers.R:333:3',
     'test-key-helpers.R:342:3', 'test-key-helpers.R:350:3', 'test-paste.R:10:3',
     'test-paste.R:93:3', 'test-postgres.R:2:3', 'test-select-tbl.R:30:3',
     'test-select.R:2:3', 'test-select.R:10:3', 'test-select.R:18:3',
     'test-select.R:47:3', 'test-select.R:88:3', 'test-sqlite.R:2:3',
     'test-standalone-check_suggested.R:3:3',
     'test-standalone-check_suggested.R:17:3', 'test-primary-keys.R:25:3',
     'test-primary-keys.R:94:3', 'test-primary-keys.R:178:3',
     'test-primary-keys.R:198:3', 'test-primary-keys.R:217:3',
     'test-primary-keys.R:229:3', 'test-primary-keys.R:246:3',
     'test-primary-keys.R:253:3', 'test-tidyselect.R:25:3', 'test-tidyr.R:54:3',
     'test-tidyr.R:92:3', 'test-unique-keys.R:2:3', 'test-unique-keys.R:175:3',
     'test-upgrade.R:3:3', 'test-upgrade.R:15:3', 'test-upgrade.R:26:3',
     'test-upgrade.R:42:3', 'test-upgrade.R:53:3', 'test-upgrade.R:72:3',
     'test-upgrade.R:86:3', 'test-upgrade.R:102:3', 'test-upgrade.R:116:3',
     'test-waldo.R:8:3', 'test-zoom.R:30:3', 'test-zoom.R:133:3'
     • Slow test. To run, set CI=true (6): 'test-db-interface.R:7:3',
     'test-dplyr-src.R:49:3', 'test-examine-constraints.R:34:3',
     'test-examine-constraints.R:52:3', 'test-foreign-keys.R:180:3',
     'test-primary-keys.R:158:3'
     • `foo()` needs the "iurtnkjvmomweicopbt" package. (1):
     'test-standalone-check_suggested.R:30:3'
     • dm argument (1): 'test-select-tbl.R:71:3'
     • does not work on `df` (1): 'test-validate.R:201:3'
     • keyed = TRUE (1): 'test-deconstruct.R:91:3'
     • not testing deprecated cdm_nycflights13(): test too slow (1):
     'test-zzx-deprecated.R:266:3'
     • not testing deprecated learning from DB: test too slow (1):
     'test-zzx-deprecated.R:236:3'
     • only works on `db` (1): 'test-filter-dm.R:47:3'
     • only works on `duckdb` (2): 'test-duckdb.R:9:3', 'test-duckdb.R:32:3'
     • only works on `maria` (2): 'test-maria.R:9:3', 'test-maria.R:32:3'
     • only works on `mssql` (6): 'test-learn.R:206:3', 'test-learn.R:282:3',
     'test-db-helpers.R:2:3', 'test-mssql.R:9:3', 'test-mssql.R:32:3',
     'test-schema.R:129:3'
     • only works on `mssql`, `postgres` (4): 'test-db-interface.R:81:3',
     'test-db-interface.R:94:3', 'test-db-interface.R:125:3', 'test-schema.R:2:3'
     • only works on `mssql`, `postgres`, `maria` (4): 'test-learn.R:2:3',
     'test-learn.R:69:3', 'test-learn.R:366:3', 'test-meta.R:9:3'
     • only works on `postgres` (4): 'test-db-helpers.R:108:3',
     'test-postgres.R:9:3', 'test-postgres.R:32:3', 'test-schema.R:99:3'
     • only works on `postgres`, `mssql` (2): 'test-json_nest.R:14:3',
     'test-json_pack.R:13:3'
     • only works on `postgres`, `mssql`, `sqlite` (1): 'test-rows-dm.R:221:3'
     • only works on `postgres`, `sqlite`, `mssql`, `maria` (1):
     'test-db-interface.R:183:3'
     • only works on `sqlite` (3): 'test-schema.R:201:3', 'test-sqlite.R:9:3',
     'test-sqlite.R:32:3'
     
     ══ Failed tests ════════════════════════════════════════════════════════════════
     ── Error ('test-bind.R:51:3'): errors: src mismatches ──────────────────────────
     <dplyr:::mutate_error/rlang_error/error/condition>
     Error in `mutate(., name = child_table, index_name = map_chr(child_fk_cols, 
     paste, collapse = "_"), remote_name = purrr::map_chr(table_names[name], 
     ~DBI::dbQuoteIdentifier(con, .x)), remote_name_unquoted = map_chr(DBI::dbUnquoteIdentifier(con, 
     DBI::SQL(remote_name)), ~.x@name[["table"]]), index_name = make.unique(paste0(remote_name_unquoted, 
     "__", index_name), sep = "__"))`: i In argument: `remote_name_unquoted = map_chr(...)`.
     Caused by error in `map_chr()`:
     i In index: 1.
     Caused by error in `.x@name[["table"]]`:
     ! subscript out of bounds
     ── Error ('test-build_copy_queries.R:14:3'): build_copy_queries snapshot test for pixarfilms ──
     <dplyr:::mutate_error/rlang_error/error/condition>
     Error in `mutate(., name = child_table, index_name = map_chr(child_fk_cols, 
     paste, collapse = "_"), remote_name = purrr::map_chr(table_names[name], 
     ~DBI::dbQuoteIdentifier(con, .x)), remote_name_unquoted = map_chr(DBI::dbUnquoteIdentifier(con, 
     DBI::SQL(remote_name)), ~.x@name[["table"]]), index_name = make.unique(paste0(remote_name_unquoted, 
     "__", index_name), sep = "__"))`: i In argument: `remote_name_unquoted = map_chr(...)`.
     Caused by error in `map_chr()`:
     i In index: 1.
     Caused by error in `.x@name[["table"]]`:
     ! subscript out of bounds
     Backtrace:
     ▆
     1. └─testthat::expect_snapshot(...) at test-build_copy_queries.R:14:3
     2.   └─rlang::cnd_signal(state$error)
     ── Error ('test-build_copy_queries.R:33:3'): build_copy_queries snapshot test for dm_for_filter() ──
     <dplyr:::mutate_error/rlang_error/error/condition>
     Error in `mutate(., name = child_table, index_name = map_chr(child_fk_cols, 
     paste, collapse = "_"), remote_name = purrr::map_chr(table_names[name], 
     ~DBI::dbQuoteIdentifier(con, .x)), remote_name_unquoted = map_chr(DBI::dbUnquoteIdentifier(con, 
     DBI::SQL(remote_name)), ~.x@name[["table"]]), index_name = make.unique(paste0(remote_name_unquoted, 
     "__", index_name), sep = "__"))`: i In argument: `remote_name_unquoted = map_chr(...)`.
     Caused by error in `map_chr()`:
     i In index: 1.
     Caused by error in `.x@name[["table"]]`:
     ! subscript out of bounds
     Backtrace:
     ▆
     1. └─testthat::expect_snapshot(...) at test-build_copy_queries.R:33:3
     2.   └─rlang::cnd_signal(state$error)
     ── Error ('test-build_copy_queries.R:63:3'): build_copy_queries avoids duplicate indexes ──
     <dplyr:::mutate_error/rlang_error/error/condition>
     Error in `mutate(., name = child_table, index_name = map_chr(child_fk_cols, 
     paste, collapse = "_"), remote_name = purrr::map_chr(table_names[name], 
     ~DBI::dbQuoteIdentifier(con, .x)), remote_name_unquoted = map_chr(DBI::dbUnquoteIdentifier(con, 
     DBI::SQL(remote_name)), ~.x@name[["table"]]), index_name = make.unique(paste0(remote_name_unquoted, 
     "__", index_name), sep = "__"))`: i In argument: `remote_name_unquoted = map_chr(...)`.
     Caused by error in `map_chr()`:
     i In index: 1.
     Caused by error in `.x@name[["table"]]`:
     ! subscript out of bounds
     ── Error ('test-rows-dm.R:98:3'): dm_rows_update() ─────────────────────────────
     <dplyr:::mutate_error/rlang_error/error/condition>
     Error in `mutate(., name = child_table, index_name = map_chr(child_fk_cols, 
     paste, collapse = "_"), remote_name = purrr::map_chr(table_names[name], 
     ~DBI::dbQuoteIdentifier(con, .x)), remote_name_unquoted = map_chr(DBI::dbUnquoteIdentifier(con, 
     DBI::SQL(remote_name)), ~.x@name[["table"]]), index_name = make.unique(paste0(remote_name_unquoted, 
     "__", index_name), sep = "__"))`: i In argument: `remote_name_unquoted = map_chr(...)`.
     Caused by error in `map_chr()`:
     i In index: 1.
     Caused by error in `.x@name[["table"]]`:
     ! subscript out of bounds
     ── Error ('test-rows-dm.R:152:3'): dm_rows_truncate() ──────────────────────────
     <dplyr:::mutate_error/rlang_error/error/condition>
     Error in `mutate(., name = child_table, index_name = map_chr(child_fk_cols, 
     paste, collapse = "_"), remote_name = purrr::map_chr(table_names[name], 
     ~DBI::dbQuoteIdentifier(con, .x)), remote_name_unquoted = map_chr(DBI::dbUnquoteIdentifier(con, 
     DBI::SQL(remote_name)), ~.x@name[["table"]]), index_name = make.unique(paste0(remote_name_unquoted, 
     "__", index_name), sep = "__"))`: i In argument: `remote_name_unquoted = map_chr(...)`.
     Caused by error in `map_chr()`:
     i In index: 1.
     Caused by error in `.x@name[["table"]]`:
     ! subscript out of bounds
     ── Error ('test-dm.R:273:3'): 'compute.dm()' computes tables on DB ─────────────
     <dplyr:::mutate_error/rlang_error/error/condition>
     Error in `mutate(., name = child_table, index_name = map_chr(child_fk_cols, 
     paste, collapse = "_"), remote_name = purrr::map_chr(table_names[name], 
     ~DBI::dbQuoteIdentifier(con, .x)), remote_name_unquoted = map_chr(DBI::dbUnquoteIdentifier(con, 
     DBI::SQL(remote_name)), ~.x@name[["table"]]), index_name = make.unique(paste0(remote_name_unquoted, 
     "__", index_name), sep = "__"))`: i In argument: `remote_name_unquoted = map_chr(...)`.
     Caused by error in `map_chr()`:
     i In index: 1.
     Caused by error in `.x@name[["table"]]`:
     ! subscript out of bounds
     ── Error ('test-dm.R:286:3'): 'compute.dm_zoomed()' computes tables on DB ──────
     <dplyr:::mutate_error/rlang_error/error/condition>
     Error in `mutate(., name = child_table, index_name = map_chr(child_fk_cols, 
     paste, collapse = "_"), remote_name = purrr::map_chr(table_names[name], 
     ~DBI::dbQuoteIdentifier(con, .x)), remote_name_unquoted = map_chr(DBI::dbUnquoteIdentifier(con, 
     DBI::SQL(remote_name)), ~.x@name[["table"]]), index_name = make.unique(paste0(remote_name_unquoted, 
     "__", index_name), sep = "__"))`: i In argument: `remote_name_unquoted = map_chr(...)`.
     Caused by error in `map_chr()`:
     i In index: 1.
     Caused by error in `.x@name[["table"]]`:
     ! subscript out of bounds
     ── Error ('test-dm.R:487:3'): dm_get_con() works ───────────────────────────────
     <dplyr:::mutate_error/rlang_error/error/condition>
     Error in `mutate(., name = child_table, index_name = map_chr(child_fk_cols, 
     paste, collapse = "_"), remote_name = purrr::map_chr(table_names[name], 
     ~DBI::dbQuoteIdentifier(con, .x)), remote_name_unquoted = map_chr(DBI::dbUnquoteIdentifier(con, 
     DBI::SQL(remote_name)), ~.x@name[["table"]]), index_name = make.unique(paste0(remote_name_unquoted, 
     "__", index_name), sep = "__"))`: i In argument: `remote_name_unquoted = map_chr(...)`.
     Caused by error in `map_chr()`:
     i In index: 1.
     Caused by error in `.x@name[["table"]]`:
     ! subscript out of bounds
     ── Error ('test-dm_sql.R:4:3'): snapshot test ──────────────────────────────────
     <dplyr:::mutate_error/rlang_error/error/condition>
     Error in `mutate(., name = child_table, index_name = map_chr(child_fk_cols, 
     paste, collapse = "_"), remote_name = purrr::map_chr(table_names[name], 
     ~DBI::dbQuoteIdentifier(con, .x)), remote_name_unquoted = map_chr(DBI::dbUnquoteIdentifier(con, 
     DBI::SQL(remote_name)), ~.x@name[["table"]]), index_name = make.unique(paste0(remote_name_unquoted, 
     "__", index_name), sep = "__"))`: i In argument: `remote_name_unquoted = map_chr(...)`.
     Caused by error in `map_chr()`:
     i In index: 1.
     Caused by error in `.x@name[["table"]]`:
     ! subscript out of bounds
     Backtrace:
     ▆
     1. └─testthat::expect_snapshot(...) at test-dm_sql.R:4:3
     2.   └─rlang::cnd_signal(state$error)
     ── Error ('test-nest.R:41:3'): 'nest_join_dm_zoomed()' fails for DB-'dm' ───────
     <dplyr:::mutate_error/rlang_error/error/condition>
     Error in `mutate(., name = child_table, index_name = map_chr(child_fk_cols, 
     paste, collapse = "_"), remote_name = purrr::map_chr(table_names[name], 
     ~DBI::dbQuoteIdentifier(con, .x)), remote_name_unquoted = map_chr(DBI::dbUnquoteIdentifier(con, 
     DBI::SQL(remote_name)), ~.x@name[["table"]]), index_name = make.unique(paste0(remote_name_unquoted, 
     "__", index_name), sep = "__"))`: i In argument: `remote_name_unquoted = map_chr(...)`.
     Caused by error in `map_chr()`:
     i In index: 1.
     Caused by error in `.x@name[["table"]]`:
     ! subscript out of bounds
     ── Error ('test-pack_join.R:15:3'): `pack_join()` works with remote table ──────
     <dplyr:::mutate_error/rlang_error/error/condition>
     Error in `mutate(., name = child_table, index_name = map_chr(child_fk_cols, 
     paste, collapse = "_"), remote_name = purrr::map_chr(table_names[name], 
     ~DBI::dbQuoteIdentifier(con, .x)), remote_name_unquoted = map_chr(DBI::dbUnquoteIdentifier(con, 
     DBI::SQL(remote_name)), ~.x@name[["table"]]), index_name = make.unique(paste0(remote_name_unquoted, 
     "__", index_name), sep = "__"))`: i In argument: `remote_name_unquoted = map_chr(...)`.
     Caused by error in `map_chr()`:
     i In index: 1.
     Caused by error in `.x@name[["table"]]`:
     ! subscript out of bounds
     ── Error ('test-validate.R:190:3'): validator speaks up (sqlite()) ─────────────
     <dplyr:::mutate_error/rlang_error/error/condition>
     Error in `mutate(., data = if_else(table == "tf_1", list(dm_for_filter_duckdb()$tf_1), 
     data))`: i In argument: `data = if_else(table == "tf_1", list(dm_for_filter_duckdb()$tf_1), data)`.
     Caused by error in `mutate()`:
     i In argument: `remote_name_unquoted = map_chr(...)`.
     Caused by error in `map_chr()`:
     i In index: 1.
     Caused by error in `.x@name[["table"]]`:
     ! subscript out of bounds
     Backtrace:
     ▆
     1. ├─dm:::expect_dm_error(...) at test-validate.R:190:3
     2. │ └─testthat::expect_error(expr, class = dm_error(class)) at tests/testthat/helper-expectations.R:48:3
     3. │   └─testthat:::expect_condition_matching(...)
     4. │     └─testthat:::quasi_capture(...)
     5. │       ├─testthat (local) .capture(...)
     6. │       │ └─base::withCallingHandlers(...)
     7. │       └─rlang::eval_bare(quo_get_expr(.quo), quo_get_env(.quo))
     8. ├─... %>% dm_validate()
     9. ├─dm::dm_validate(.)
     10. │ └─dm:::check_dm(x)
     11. │   └─dm::is_dm(x)
     12. ├─dm:::dm_from_def(.)
     13. ├─dplyr::mutate(...)
     14. ├─dplyr:::mutate.data.frame(...)
     15. │ └─dplyr:::mutate_cols(.data, dplyr_quosures(...), by)
     16. │   ├─base::withCallingHandlers(...)
     17. │   └─dplyr:::mutate_col(dots[[i]], data, mask, new_columns)
     18. │     └─mask$eval_all_mutate(quo)
     19. │       └─dplyr (local) eval()
     20. ├─dplyr::if_else(...)
     21. ├─dm:::dm_for_filter_duckdb()
     22. ├─dm::copy_dm_to(duckdb_test_src(), dm_for_filter()) at tests/testthat/helper-src.R:26:7
     23. │ └─dm:::build_copy_queries(...)
     24. │   └─... %>% ...
     25. ├─dplyr::summarize(...)
     26. ├─dplyr::group_by(., name)
     27. ├─dplyr::mutate(...)
     28. ├─dplyr:::mutate.data.frame(...)
     29. │ └─dplyr:::mutate_cols(.data, dplyr_quosures(...), by)
     30. │   ├─base::withCallingHandlers(...)
     31. │   └─dplyr:::mutate_col(dots[[i]], data, mask, new_columns)
     32. │     └─mask$eval_all_mutate(quo)
     33. │       └─dplyr (local) eval()
     34. ├─purrr::map_chr(...)
     35. │ └─purrr:::map_("character", .x, .f, ..., .progress = .progress)
     36. │   ├─purrr:::with_indexed_errors(...)
     37. │   │ └─base::withCallingHandlers(...)
     38. │   ├─purrr:::call_with_cleanup(...)
     39. │   └─dm (local) .f(.x[[i]], ...)
     40. ├─purrr (local) `<fn>`(`<sbscOOBE>`)
     41. │ └─cli::cli_abort(...)
     42. │   └─rlang::abort(...)
     43. │     └─rlang:::signal_abort(cnd, .file)
     44. │       └─base::signalCondition(cnd)
     45. ├─dplyr (local) `<fn>`(`<prrr_rr_>`)
     46. │ └─rlang::abort(message, class = error_class, parent = parent, call = error_call)
     47. │   └─rlang:::signal_abort(cnd, .file)
     48. │     └─base::signalCondition(cnd)
     49. └─dplyr (local) `<fn>`(`<dply:::_>`)
     50.   └─rlang::abort(message, class = error_class, parent = parent, call = error_call)
     ── Error ('test_dm_from_con.R:23:3'): table identifiers are quoted ─────────────
     <purrr_error_indexed/rlang_error/error/condition>
     Error in `map(DBI::dbUnquoteIdentifier(con_db, DBI::SQL(remote_tbl_names_copied)), 
     ~.x@name[["table"]])`: i In index: 1.
     Caused by error in `.x@name[["table"]]`:
     ! subscript out of bounds
     Backtrace:
     ▆
     1. ├─... %>% ... at test_dm_from_con.R:23:3
     2. ├─dm::dm_select_tbl(...)
     3. │ └─dm:::eval_select_table(quo(c(...)), src_tbls_impl(dm))
     4. │   └─dm:::eval_select_table_indices(quo, table_names, unique = unique)
     5. │     ├─base::withCallingHandlers(...)
     6. │     └─dm:::eval_select_indices(quo, table_names, unique = unique)
     7. │       └─tidyselect::eval_select(quo, set_names(names))
     8. │         └─tidyselect:::eval_select_impl(...)
     9. │           ├─tidyselect:::with_subscript_errors(...)
     10. │           │ └─rlang::try_fetch(...)
     11. │           │   └─base::withCallingHandlers(...)
     12. │           └─tidyselect:::vars_select_eval(...)
     13. │             └─tidyselect:::walk_data_tree(expr, data_mask, context_mask)
     14. │               └─tidyselect:::eval_c(expr, data_mask, context_mask)
     15. │                 └─tidyselect:::call_expand_dots(expr, context_mask$.__current__.)
     16. │                   └─rlang::eval_bare(quote(enquos(...)), dots_mask)
     17. ├─rlang::enquos(...)
     18. │ └─rlang:::endots(...)
     19. │   └─rlang:::map(...)
     20. │     └─base::lapply(.x, .f, ...)
     21. │       └─rlang (local) FUN(X[[i]], ...)
     22. ├─purrr::map(...)
     23. │ └─purrr:::map_("list", .x, .f, ..., .progress = .progress)
     24. │   ├─purrr:::with_indexed_errors(...)
     25. │   │ └─base::withCallingHandlers(...)
     26. │   ├─purrr:::call_with_cleanup(...)
     27. │   └─dm (local) .f(.x[[i]], ...)
     28. └─purrr (local) `<fn>`(`<sbscOOBE>`)
     29.   └─cli::cli_abort(...)
     30.     └─rlang::abort(...)
     
     [ FAIL 14 | WARN 6 | SKIP 235 | PASS 1347 ]
     Deleting unused snapshots:
     • datamodelr-code/nycflights13.dot
     • datamodelr-code/nycflights13_draw_uk_1.dot
     • datamodelr-code/nycflights13_draw_uk_2.dot
     • datamodelr-code/nycflights13_draw_uk_3.dot
     • datamodelr-code/nycflights13_table_desc_1.dot
     • datamodelr-code/nycflights13_table_desc_2.dot
     • datamodelr-code/weird.dot
     • draw-dm/empty-table-in-dm.svg
     • draw-dm/nycflight-dm-types.svg
     • draw-dm/nycflight-dm.svg
     • draw-dm/single-empty-table-dm.svg
     • draw-dm/table-desc-1-dm.svg
     • draw-dm/table-desc-2-dm.svg
     • draw-dm/table-desc-3-dm.svg
     • draw-dm/table-desc-4-dm.svg
     • draw-dm/table-uk-1-dm.svg
     • draw-dm/table-uk-2-dm.svg
     Error: Test failures
     Execution halted
- [ ] ERROR: r-devel-linux-x86_64-debian-gcc
     Running ‘testthat.R’ [176s/148s]
     Running the tests in ‘tests/testthat.R’ failed.
     Complete output:
     > library(testthat)
     > 
     > # Need to use qualified call, this is checked in helper-print.R
     > testthat::test_check("dm")
     Loading required package: dm
     
     Attaching package: 'dm'
     
     The following object is masked from 'package:stats':
     
     filter
     
     Starting 2 test processes
     [ FAIL 14 | WARN 8 | SKIP 235 | PASS 1347 ]
     
     ══ Skipped tests (235) ═════════════════════════════════════════════════════════
     • COMPOUND (1): 'test-rows-dm.R:203:3'
     • Dependent on database version, find better way to record this info (1):
     'test-meta.R:19:3'
     • FIXME (2): 'test-learn.R:154:3', 'test-nest.R:2:3'
     • FIXME: Unstable on GHA? (1): 'test-dm.R:495:3'
     • Need to think about it (1): 'test-key-helpers.R:45:3'
     • On CRAN (187): 'test-zzx-deprecated.R:2:3', 'test-zzx-deprecated.R:15:3',
     'test-zzx-deprecated.R:25:3', 'test-zzx-deprecated.R:35:3',
     'test-zzx-deprecated.R:45:3', 'test-zzx-deprecated.R:58:3',
     'test-zzx-deprecated.R:81:3', 'test-zzx-deprecated.R:91:3',
     'test-zzx-deprecated.R:106:3', 'test-zzx-deprecated.R:121:3',
     'test-zzx-deprecated.R:141:3', 'test-zzx-deprecated.R:151:3',
     'test-zzx-deprecated.R:166:3', 'test-zzx-deprecated.R:185:3',
     'test-zzx-deprecated.R:221:3', 'test-zzx-deprecated.R:255:3',
     'test-zzx-deprecated.R:275:3', 'test-zzx-deprecated.R:291:3',
     'test-zzx-deprecated.R:326:3', 'test-zzx-deprecated.R:341:3',
     'test-zzx-deprecated.R:356:3', 'test-flatten.R:18:3', 'test-flatten.R:99:3',
     'test-dplyr.R:347:3', 'test-dplyr.R:506:3', 'test-dplyr.R:545:3',
     'test-dplyr.R:558:3', 'test-dplyr.R:569:3', 'test-dplyr.R:598:3',
     'test-dplyr.R:614:3', 'test-dplyr.R:806:3', 'test-draw-dm.R:17:3',
     'test-draw-dm.R:104:3', 'test-draw-dm.R:117:3', 'test-draw-dm.R:153:3',
     'test-draw-dm.R:182:3', 'test-filter-dm.R:62:3', 'test-filter-dm.R:173:3',
     'test-filter-dm.R:182:3', 'test-filter-dm.R:191:3', 'test-filter-dm.R:241:3',
     'test-bind.R:42:3', 'test-bind.R:97:3', 'test-bind.R:107:3',
     'test-bind.R:125:3', 'test-learn.R:446:3', 'test-add-tbl.R:92:3',
     'test-add-tbl.R:137:3', 'test-autoincrement.R:17:3',
     'test-autoincrement.R:26:3', 'test-rows-dm.R:2:3', 'test-rows-dm.R:28:3',
     'test-rows-dm.R:390:3', 'test-code-generation.R:7:3',
     'test-datamodelr-code.R:4:3', 'test-datamodelr-code.R:17:3',
     'test-datamodelr-code.R:37:3', 'test-datamodelr-code.R:57:3',
     'test-datamodelr-code.R:78:3', 'test-datamodelr-code.R:99:3',
     'test-datamodelr-code.R:120:3', 'test-datamodelr-code.R:133:3',
     'test-db-interface.R:35:3', 'test-check-cardinalities.R:30:3',
     'test-check-cardinalities.R:289:3', 'test-check-cardinalities.R:337:3',
     'test-check-cardinalities.R:422:3', 'test-disambiguate.R:2:3',
     'test-disentangle.R:2:3', 'test-deconstruct.R:6:3',
     'test-deconstruct.R:16:3', 'test-deconstruct.R:26:3',
     'test-deconstruct.R:55:3', 'test-deconstruct.R:72:3',
     'test-deconstruct.R:120:3', 'test-deconstruct.R:144:3',
     'test-deconstruct.R:160:3', 'test-deconstruct.R:181:3',
     'test-deconstruct.R:198:3', 'test-deconstruct.R:222:3',
     'test-deconstruct.R:246:3', 'test-deconstruct.R:270:3',
     'test-deconstruct.R:294:3', 'test-deconstruct.R:320:3',
     'test-deconstruct.R:346:3', 'test-deconstruct.R:372:3',
     'test-deconstruct.R:398:3', 'test-deconstruct.R:420:3',
     'test-deconstruct.R:479:3', 'test-deconstruct.R:492:3',
     'test-deconstruct.R:507:3', 'test-deconstruct.R:525:3',
     'test-deconstruct.R:572:3', 'test-deconstruct.R:586:3',
     'test-deconstruct.R:599:3', 'test-dm_deconstruct.R:2:3',
     'test-dm_deconstruct.R:9:3', 'test-dm_nest_tbl.R:17:3',
     'test-dm_pixarfilms.R:2:3', 'test-dm.R:2:3', 'test-dm.R:70:3',
     'test-dm.R:108:3', 'test-dm.R:148:3', 'test-dm.R:194:3', 'test-dm.R:202:3',
     'test-dm.R:211:3', 'test-dm.R:217:3', 'test-dm.R:223:3', 'test-dm.R:311:3',
     'test-dm.R:508:3', 'test-dm.R:534:3', 'test-dm.R:564:3', 'test-dm.R:598:3',
     'test-duckdb.R:2:3', 'test-enum-ops.R:11:3', 'test-enum-ops.R:30:3',
     'test-enum-ops.R:103:3', 'test-enum-ops.R:176:3',
     'test-enumerate_all_paths.R:2:3', 'test-dm_wrap.R:12:3',
     'test-dm_wrap.R:79:3', 'test-examine-cardinalities.R:2:3',
     'test-examine-cardinalities.R:16:3', 'test-examine-cardinalities.R:23:3',
     'test-error-helpers.R:2:3', 'test-examine-constraints.R:68:3',
     'test-examine-constraints.R:77:3', 'test-examine-constraints.R:87:3',
     'test-examine-constraints.R:94:3', 'test-format.R:2:3', 'test-graph.R:29:3',
     'test-graph.R:38:3', 'test-json.R:5:3', 'test-json_nest.R:2:3',
     'test-json_pack.R:2:3', 'test-foreign-keys.R:16:3',
     'test-foreign-keys.R:145:3', 'test-foreign-keys.R:252:3',
     'test-foreign-keys.R:260:3', 'test-foreign-keys.R:287:3',
     'test-foreign-keys.R:306:3', 'test-maria.R:2:3', 'test-meta.R:3:3',
     'test-mssql.R:2:3', 'test-pack_join.R:5:3', 'test-key-helpers.R:4:3',
     'test-key-helpers.R:327:3', 'test-key-helpers.R:333:3',
     'test-key-helpers.R:342:3', 'test-key-helpers.R:350:3',
     'test-postgres.R:2:3', 'test-paste.R:10:3', 'test-paste.R:93:3',
     'test-select-tbl.R:30:3', 'test-primary-keys.R:25:3',
     'test-primary-keys.R:94:3', 'test-primary-keys.R:178:3',
     'test-primary-keys.R:198:3', 'test-primary-keys.R:217:3',
     'test-primary-keys.R:229:3', 'test-primary-keys.R:246:3',
     'test-primary-keys.R:253:3', 'test-sqlite.R:2:3',
     'test-standalone-check_suggested.R:3:3',
     'test-standalone-check_suggested.R:17:3', 'test-select.R:2:3',
     'test-select.R:10:3', 'test-select.R:18:3', 'test-select.R:47:3',
     'test-select.R:88:3', 'test-tidyselect.R:25:3', 'test-tidyr.R:54:3',
     'test-tidyr.R:92:3', 'test-unique-keys.R:2:3', 'test-unique-keys.R:175:3',
     'test-upgrade.R:3:3', 'test-upgrade.R:15:3', 'test-upgrade.R:26:3',
     'test-upgrade.R:42:3', 'test-upgrade.R:53:3', 'test-upgrade.R:72:3',
     'test-upgrade.R:86:3', 'test-upgrade.R:102:3', 'test-upgrade.R:116:3',
     'test-waldo.R:8:3', 'test-zoom.R:30:3', 'test-zoom.R:133:3'
     • Slow test. To run, set CI=true (6): 'test-db-interface.R:7:3',
     'test-dplyr-src.R:49:3', 'test-examine-constraints.R:34:3',
     'test-examine-constraints.R:52:3', 'test-foreign-keys.R:180:3',
     'test-primary-keys.R:158:3'
     • `foo()` needs the "iurtnkjvmomweicopbt" package. (1):
     'test-standalone-check_suggested.R:30:3'
     • dm argument (1): 'test-select-tbl.R:71:3'
     • does not work on `df` (1): 'test-validate.R:201:3'
     • keyed = TRUE (1): 'test-deconstruct.R:91:3'
     • not testing deprecated cdm_nycflights13(): test too slow (1):
     'test-zzx-deprecated.R:266:3'
     • not testing deprecated learning from DB: test too slow (1):
     'test-zzx-deprecated.R:236:3'
     • only works on `db` (1): 'test-filter-dm.R:47:3'
     • only works on `duckdb` (2): 'test-duckdb.R:9:3', 'test-duckdb.R:32:3'
     • only works on `maria` (2): 'test-maria.R:9:3', 'test-maria.R:32:3'
     • only works on `mssql` (6): 'test-learn.R:206:3', 'test-learn.R:282:3',
     'test-db-helpers.R:2:3', 'test-mssql.R:9:3', 'test-mssql.R:32:3',
     'test-schema.R:129:3'
     • only works on `mssql`, `postgres` (4): 'test-db-interface.R:81:3',
     'test-db-interface.R:94:3', 'test-db-interface.R:125:3', 'test-schema.R:2:3'
     • only works on `mssql`, `postgres`, `maria` (4): 'test-learn.R:2:3',
     'test-learn.R:69:3', 'test-learn.R:366:3', 'test-meta.R:9:3'
     • only works on `postgres` (4): 'test-db-helpers.R:108:3',
     'test-postgres.R:9:3', 'test-postgres.R:32:3', 'test-schema.R:99:3'
     • only works on `postgres`, `mssql` (2): 'test-json_nest.R:14:3',
     'test-json_pack.R:13:3'
     • only works on `postgres`, `mssql`, `sqlite` (1): 'test-rows-dm.R:221:3'
     • only works on `postgres`, `sqlite`, `mssql`, `maria` (1):
     'test-db-interface.R:183:3'
     • only works on `sqlite` (3): 'test-schema.R:201:3', 'test-sqlite.R:9:3',
     'test-sqlite.R:32:3'
     
     ══ Failed tests ════════════════════════════════════════════════════════════════
     ── Error ('test-bind.R:51:3'): errors: src mismatches ──────────────────────────
     <dplyr:::mutate_error/rlang_error/error/condition>
     Error in `mutate(., name = child_table, index_name = map_chr(child_fk_cols, 
     paste, collapse = "_"), remote_name = purrr::map_chr(table_names[name], 
     ~DBI::dbQuoteIdentifier(con, .x)), remote_name_unquoted = map_chr(DBI::dbUnquoteIdentifier(con, 
     DBI::SQL(remote_name)), ~.x@name[["table"]]), index_name = make.unique(paste0(remote_name_unquoted, 
     "__", index_name), sep = "__"))`: i In argument: `remote_name_unquoted = map_chr(...)`.
     Caused by error in `map_chr()`:
     i In index: 1.
     Caused by error in `.x@name[["table"]]`:
     ! subscript out of bounds
     ── Error ('test-build_copy_queries.R:14:3'): build_copy_queries snapshot test for pixarfilms ──
     <dplyr:::mutate_error/rlang_error/error/condition>
     Error in `mutate(., name = child_table, index_name = map_chr(child_fk_cols, 
     paste, collapse = "_"), remote_name = purrr::map_chr(table_names[name], 
     ~DBI::dbQuoteIdentifier(con, .x)), remote_name_unquoted = map_chr(DBI::dbUnquoteIdentifier(con, 
     DBI::SQL(remote_name)), ~.x@name[["table"]]), index_name = make.unique(paste0(remote_name_unquoted, 
     "__", index_name), sep = "__"))`: i In argument: `remote_name_unquoted = map_chr(...)`.
     Caused by error in `map_chr()`:
     i In index: 1.
     Caused by error in `.x@name[["table"]]`:
     ! subscript out of bounds
     Backtrace:
     ▆
     1. └─testthat::expect_snapshot(...) at test-build_copy_queries.R:14:3
     2.   └─rlang::cnd_signal(state$error)
     ── Error ('test-build_copy_queries.R:33:3'): build_copy_queries snapshot test for dm_for_filter() ──
     <dplyr:::mutate_error/rlang_error/error/condition>
     Error in `mutate(., name = child_table, index_name = map_chr(child_fk_cols, 
     paste, collapse = "_"), remote_name = purrr::map_chr(table_names[name], 
     ~DBI::dbQuoteIdentifier(con, .x)), remote_name_unquoted = map_chr(DBI::dbUnquoteIdentifier(con, 
     DBI::SQL(remote_name)), ~.x@name[["table"]]), index_name = make.unique(paste0(remote_name_unquoted, 
     "__", index_name), sep = "__"))`: i In argument: `remote_name_unquoted = map_chr(...)`.
     Caused by error in `map_chr()`:
     i In index: 1.
     Caused by error in `.x@name[["table"]]`:
     ! subscript out of bounds
     Backtrace:
     ▆
     1. └─testthat::expect_snapshot(...) at test-build_copy_queries.R:33:3
     2.   └─rlang::cnd_signal(state$error)
     ── Error ('test-build_copy_queries.R:63:3'): build_copy_queries avoids duplicate indexes ──
     <dplyr:::mutate_error/rlang_error/error/condition>
     Error in `mutate(., name = child_table, index_name = map_chr(child_fk_cols, 
     paste, collapse = "_"), remote_name = purrr::map_chr(table_names[name], 
     ~DBI::dbQuoteIdentifier(con, .x)), remote_name_unquoted = map_chr(DBI::dbUnquoteIdentifier(con, 
     DBI::SQL(remote_name)), ~.x@name[["table"]]), index_name = make.unique(paste0(remote_name_unquoted, 
     "__", index_name), sep = "__"))`: i In argument: `remote_name_unquoted = map_chr(...)`.
     Caused by error in `map_chr()`:
     i In index: 1.
     Caused by error in `.x@name[["table"]]`:
     ! subscript out of bounds
     ── Error ('test-rows-dm.R:98:3'): dm_rows_update() ─────────────────────────────
     <dplyr:::mutate_error/rlang_error/error/condition>
     Error in `mutate(., name = child_table, index_name = map_chr(child_fk_cols, 
     paste, collapse = "_"), remote_name = purrr::map_chr(table_names[name], 
     ~DBI::dbQuoteIdentifier(con, .x)), remote_name_unquoted = map_chr(DBI::dbUnquoteIdentifier(con, 
     DBI::SQL(remote_name)), ~.x@name[["table"]]), index_name = make.unique(paste0(remote_name_unquoted, 
     "__", index_name), sep = "__"))`: i In argument: `remote_name_unquoted = map_chr(...)`.
     Caused by error in `map_chr()`:
     i In index: 1.
     Caused by error in `.x@name[["table"]]`:
     ! subscript out of bounds
     ── Error ('test-rows-dm.R:152:3'): dm_rows_truncate() ──────────────────────────
     <dplyr:::mutate_error/rlang_error/error/condition>
     Error in `mutate(., name = child_table, index_name = map_chr(child_fk_cols, 
     paste, collapse = "_"), remote_name = purrr::map_chr(table_names[name], 
     ~DBI::dbQuoteIdentifier(con, .x)), remote_name_unquoted = map_chr(DBI::dbUnquoteIdentifier(con, 
     DBI::SQL(remote_name)), ~.x@name[["table"]]), index_name = make.unique(paste0(remote_name_unquoted, 
     "__", index_name), sep = "__"))`: i In argument: `remote_name_unquoted = map_chr(...)`.
     Caused by error in `map_chr()`:
     i In index: 1.
     Caused by error in `.x@name[["table"]]`:
     ! subscript out of bounds
     ── Error ('test-dm.R:273:3'): 'compute.dm()' computes tables on DB ─────────────
     <dplyr:::mutate_error/rlang_error/error/condition>
     Error in `mutate(., name = child_table, index_name = map_chr(child_fk_cols, 
     paste, collapse = "_"), remote_name = purrr::map_chr(table_names[name], 
     ~DBI::dbQuoteIdentifier(con, .x)), remote_name_unquoted = map_chr(DBI::dbUnquoteIdentifier(con, 
     DBI::SQL(remote_name)), ~.x@name[["table"]]), index_name = make.unique(paste0(remote_name_unquoted, 
     "__", index_name), sep = "__"))`: i In argument: `remote_name_unquoted = map_chr(...)`.
     Caused by error in `map_chr()`:
     i In index: 1.
     Caused by error in `.x@name[["table"]]`:
     ! subscript out of bounds
     ── Error ('test-dm.R:286:3'): 'compute.dm_zoomed()' computes tables on DB ──────
     <dplyr:::mutate_error/rlang_error/error/condition>
     Error in `mutate(., name = child_table, index_name = map_chr(child_fk_cols, 
     paste, collapse = "_"), remote_name = purrr::map_chr(table_names[name], 
     ~DBI::dbQuoteIdentifier(con, .x)), remote_name_unquoted = map_chr(DBI::dbUnquoteIdentifier(con, 
     DBI::SQL(remote_name)), ~.x@name[["table"]]), index_name = make.unique(paste0(remote_name_unquoted, 
     "__", index_name), sep = "__"))`: i In argument: `remote_name_unquoted = map_chr(...)`.
     Caused by error in `map_chr()`:
     i In index: 1.
     Caused by error in `.x@name[["table"]]`:
     ! subscript out of bounds
     ── Error ('test-dm.R:487:3'): dm_get_con() works ───────────────────────────────
     <dplyr:::mutate_error/rlang_error/error/condition>
     Error in `mutate(., name = child_table, index_name = map_chr(child_fk_cols, 
     paste, collapse = "_"), remote_name = purrr::map_chr(table_names[name], 
     ~DBI::dbQuoteIdentifier(con, .x)), remote_name_unquoted = map_chr(DBI::dbUnquoteIdentifier(con, 
     DBI::SQL(remote_name)), ~.x@name[["table"]]), index_name = make.unique(paste0(remote_name_unquoted, 
     "__", index_name), sep = "__"))`: i In argument: `remote_name_unquoted = map_chr(...)`.
     Caused by error in `map_chr()`:
     i In index: 1.
     Caused by error in `.x@name[["table"]]`:
     ! subscript out of bounds
     ── Error ('test-dm_sql.R:4:3'): snapshot test ──────────────────────────────────
     <dplyr:::mutate_error/rlang_error/error/condition>
     Error in `mutate(., name = child_table, index_name = map_chr(child_fk_cols, 
     paste, collapse = "_"), remote_name = purrr::map_chr(table_names[name], 
     ~DBI::dbQuoteIdentifier(con, .x)), remote_name_unquoted = map_chr(DBI::dbUnquoteIdentifier(con, 
     DBI::SQL(remote_name)), ~.x@name[["table"]]), index_name = make.unique(paste0(remote_name_unquoted, 
     "__", index_name), sep = "__"))`: i In argument: `remote_name_unquoted = map_chr(...)`.
     Caused by error in `map_chr()`:
     i In index: 1.
     Caused by error in `.x@name[["table"]]`:
     ! subscript out of bounds
     Backtrace:
     ▆
     1. └─testthat::expect_snapshot(...) at test-dm_sql.R:4:3
     2.   └─rlang::cnd_signal(state$error)
     ── Error ('test-nest.R:41:3'): 'nest_join_dm_zoomed()' fails for DB-'dm' ───────
     <dplyr:::mutate_error/rlang_error/error/condition>
     Error in `mutate(., name = child_table, index_name = map_chr(child_fk_cols, 
     paste, collapse = "_"), remote_name = purrr::map_chr(table_names[name], 
     ~DBI::dbQuoteIdentifier(con, .x)), remote_name_unquoted = map_chr(DBI::dbUnquoteIdentifier(con, 
     DBI::SQL(remote_name)), ~.x@name[["table"]]), index_name = make.unique(paste0(remote_name_unquoted, 
     "__", index_name), sep = "__"))`: i In argument: `remote_name_unquoted = map_chr(...)`.
     Caused by error in `map_chr()`:
     i In index: 1.
     Caused by error in `.x@name[["table"]]`:
     ! subscript out of bounds
     ── Error ('test-pack_join.R:15:3'): `pack_join()` works with remote table ──────
     <dplyr:::mutate_error/rlang_error/error/condition>
     Error in `mutate(., name = child_table, index_name = map_chr(child_fk_cols, 
     paste, collapse = "_"), remote_name = purrr::map_chr(table_names[name], 
     ~DBI::dbQuoteIdentifier(con, .x)), remote_name_unquoted = map_chr(DBI::dbUnquoteIdentifier(con, 
     DBI::SQL(remote_name)), ~.x@name[["table"]]), index_name = make.unique(paste0(remote_name_unquoted, 
     "__", index_name), sep = "__"))`: i In argument: `remote_name_unquoted = map_chr(...)`.
     Caused by error in `map_chr()`:
     i In index: 1.
     Caused by error in `.x@name[["table"]]`:
     ! subscript out of bounds
     ── Error ('test-validate.R:190:3'): validator speaks up (sqlite()) ─────────────
     <dplyr:::mutate_error/rlang_error/error/condition>
     Error in `mutate(., data = if_else(table == "tf_1", list(dm_for_filter_duckdb()$tf_1), 
     data))`: i In argument: `data = if_else(table == "tf_1", list(dm_for_filter_duckdb()$tf_1), data)`.
     Caused by error in `mutate()`:
     i In argument: `remote_name_unquoted = map_chr(...)`.
     Caused by error in `map_chr()`:
     i In index: 1.
     Caused by error in `.x@name[["table"]]`:
     ! subscript out of bounds
     Backtrace:
     ▆
     1. ├─dm:::expect_dm_error(...) at test-validate.R:190:3
     2. │ └─testthat::expect_error(expr, class = dm_error(class)) at tests/testthat/helper-expectations.R:48:3
     3. │   └─testthat:::expect_condition_matching(...)
     4. │     └─testthat:::quasi_capture(...)
     5. │       ├─testthat (local) .capture(...)
     6. │       │ └─base::withCallingHandlers(...)
     7. │       └─rlang::eval_bare(quo_get_expr(.quo), quo_get_env(.quo))
     8. ├─... %>% dm_validate()
     9. ├─dm::dm_validate(.)
     10. │ └─dm:::check_dm(x)
     11. │   └─dm::is_dm(x)
     12. ├─dm:::dm_from_def(.)
     13. ├─dplyr::mutate(...)
     14. ├─dplyr:::mutate.data.frame(...)
     15. │ └─dplyr:::mutate_cols(.data, dplyr_quosures(...), by)
     16. │   ├─base::withCallingHandlers(...)
     17. │   └─dplyr:::mutate_col(dots[[i]], data, mask, new_columns)
     18. │     └─mask$eval_all_mutate(quo)
     19. │       └─dplyr (local) eval()
     20. ├─dplyr::if_else(...)
     21. ├─dm:::dm_for_filter_duckdb()
     22. ├─dm::copy_dm_to(duckdb_test_src(), dm_for_filter()) at tests/testthat/helper-src.R:26:7
     23. │ └─dm:::build_copy_queries(...)
     24. │   └─... %>% ...
     25. ├─dplyr::summarize(...)
     26. ├─dplyr::group_by(., name)
     27. ├─dplyr::mutate(...)
     28. ├─dplyr:::mutate.data.frame(...)
     29. │ └─dplyr:::mutate_cols(.data, dplyr_quosures(...), by)
     30. │   ├─base::withCallingHandlers(...)
     31. │   └─dplyr:::mutate_col(dots[[i]], data, mask, new_columns)
     32. │     └─mask$eval_all_mutate(quo)
     33. │       └─dplyr (local) eval()
     34. ├─purrr::map_chr(...)
     35. │ └─purrr:::map_("character", .x, .f, ..., .progress = .progress)
     36. │   ├─purrr:::with_indexed_errors(...)
     37. │   │ └─base::withCallingHandlers(...)
     38. │   ├─purrr:::call_with_cleanup(...)
     39. │   └─dm (local) .f(.x[[i]], ...)
     40. ├─purrr (local) `<fn>`(`<sbscOOBE>`)
     41. │ └─cli::cli_abort(...)
     42. │   └─rlang::abort(...)
     43. │     └─rlang:::signal_abort(cnd, .file)
     44. │       └─base::signalCondition(cnd)
     45. ├─dplyr (local) `<fn>`(`<prrr_rr_>`)
     46. │ └─rlang::abort(message, class = error_class, parent = parent, call = error_call)
     47. │   └─rlang:::signal_abort(cnd, .file)
     48. │     └─base::signalCondition(cnd)
     49. └─dplyr (local) `<fn>`(`<dply:::_>`)
     50.   └─rlang::abort(message, class = error_class, parent = parent, call = error_call)
     ── Error ('test_dm_from_con.R:23:3'): table identifiers are quoted ─────────────
     <purrr_error_indexed/rlang_error/error/condition>
     Error in `map(DBI::dbUnquoteIdentifier(con_db, DBI::SQL(remote_tbl_names_copied)), 
     ~.x@name[["table"]])`: i In index: 1.
     Caused by error in `.x@name[["table"]]`:
     ! subscript out of bounds
     Backtrace:
     ▆
     1. ├─... %>% ... at test_dm_from_con.R:23:3
     2. ├─dm::dm_select_tbl(...)
     3. │ └─dm:::eval_select_table(quo(c(...)), src_tbls_impl(dm))
     4. │   └─dm:::eval_select_table_indices(quo, table_names, unique = unique)
     5. │     ├─base::withCallingHandlers(...)
     6. │     └─dm:::eval_select_indices(quo, table_names, unique = unique)
     7. │       └─tidyselect::eval_select(quo, set_names(names))
     8. │         └─tidyselect:::eval_select_impl(...)
     9. │           ├─tidyselect:::with_subscript_errors(...)
     10. │           │ └─rlang::try_fetch(...)
     11. │           │   └─base::withCallingHandlers(...)
     12. │           └─tidyselect:::vars_select_eval(...)
     13. │             └─tidyselect:::walk_data_tree(expr, data_mask, context_mask)
     14. │               └─tidyselect:::eval_c(expr, data_mask, context_mask)
     15. │                 └─tidyselect:::call_expand_dots(expr, context_mask$.__current__.)
     16. │                   └─rlang::eval_bare(quote(enquos(...)), dots_mask)
     17. ├─rlang::enquos(...)
     18. │ └─rlang:::endots(...)
     19. │   └─rlang:::map(...)
     20. │     └─base::lapply(.x, .f, ...)
     21. │       └─rlang (local) FUN(X[[i]], ...)
     22. ├─purrr::map(...)
     23. │ └─purrr:::map_("list", .x, .f, ..., .progress = .progress)
     24. │   ├─purrr:::with_indexed_errors(...)
     25. │   │ └─base::withCallingHandlers(...)
     26. │   ├─purrr:::call_with_cleanup(...)
     27. │   └─dm (local) .f(.x[[i]], ...)
     28. └─purrr (local) `<fn>`(`<sbscOOBE>`)
     29.   └─cli::cli_abort(...)
     30.     └─rlang::abort(...)
     
     [ FAIL 14 | WARN 8 | SKIP 235 | PASS 1347 ]
     Deleting unused snapshots:
     • datamodelr-code/nycflights13.dot
     • datamodelr-code/nycflights13_draw_uk_1.dot
     • datamodelr-code/nycflights13_draw_uk_2.dot
     • datamodelr-code/nycflights13_draw_uk_3.dot
     • datamodelr-code/nycflights13_table_desc_1.dot
     • datamodelr-code/nycflights13_table_desc_2.dot
     • datamodelr-code/weird.dot
     • draw-dm/empty-table-in-dm.svg
     • draw-dm/nycflight-dm-types.svg
     • draw-dm/nycflight-dm.svg
     • draw-dm/single-empty-table-dm.svg
     • draw-dm/table-desc-1-dm.svg
     • draw-dm/table-desc-2-dm.svg
     • draw-dm/table-desc-3-dm.svg
     • draw-dm/table-desc-4-dm.svg
     • draw-dm/table-uk-1-dm.svg
     • draw-dm/table-uk-2-dm.svg
     Error: Test failures
     Execution halted
- [ ] ERROR: r-devel-linux-x86_64-fedora-clang
     Running ‘testthat.R’ [266s/142s]
     Running the tests in ‘tests/testthat.R’ failed.
     Complete output:
     > library(testthat)
     > 
     > # Need to use qualified call, this is checked in helper-print.R
     > testthat::test_check("dm")
     Loading required package: dm
     
     Attaching package: 'dm'
     
     The following object is masked from 'package:stats':
     
     filter
     
     Starting 2 test processes
     [ FAIL 14 | WARN 6 | SKIP 235 | PASS 1347 ]
     
     ══ Skipped tests (235) ═════════════════════════════════════════════════════════
     • COMPOUND (1): 'test-rows-dm.R:203:3'
     • Dependent on database version, find better way to record this info (1):
     'test-meta.R:19:3'
     • FIXME (2): 'test-learn.R:154:3', 'test-nest.R:2:3'
     • FIXME: Unstable on GHA? (1): 'test-dm.R:495:3'
     • Need to think about it (1): 'test-key-helpers.R:45:3'
     • On CRAN (187): 'test-zzx-deprecated.R:2:3', 'test-zzx-deprecated.R:15:3',
     'test-zzx-deprecated.R:25:3', 'test-zzx-deprecated.R:35:3',
     'test-zzx-deprecated.R:45:3', 'test-zzx-deprecated.R:58:3',
     'test-zzx-deprecated.R:81:3', 'test-zzx-deprecated.R:91:3',
     'test-zzx-deprecated.R:106:3', 'test-zzx-deprecated.R:121:3',
     'test-zzx-deprecated.R:141:3', 'test-zzx-deprecated.R:151:3',
     'test-zzx-deprecated.R:166:3', 'test-zzx-deprecated.R:185:3',
     'test-zzx-deprecated.R:221:3', 'test-zzx-deprecated.R:255:3',
     'test-zzx-deprecated.R:275:3', 'test-zzx-deprecated.R:291:3',
     'test-zzx-deprecated.R:326:3', 'test-zzx-deprecated.R:341:3',
     'test-zzx-deprecated.R:356:3', 'test-flatten.R:18:3', 'test-flatten.R:99:3',
     'test-dplyr.R:347:3', 'test-dplyr.R:506:3', 'test-dplyr.R:545:3',
     'test-dplyr.R:558:3', 'test-dplyr.R:569:3', 'test-dplyr.R:598:3',
     'test-dplyr.R:614:3', 'test-dplyr.R:806:3', 'test-draw-dm.R:17:3',
     'test-draw-dm.R:104:3', 'test-draw-dm.R:117:3', 'test-draw-dm.R:153:3',
     'test-draw-dm.R:182:3', 'test-filter-dm.R:62:3', 'test-filter-dm.R:173:3',
     'test-filter-dm.R:182:3', 'test-filter-dm.R:191:3', 'test-filter-dm.R:241:3',
     'test-bind.R:42:3', 'test-bind.R:97:3', 'test-bind.R:107:3',
     'test-bind.R:125:3', 'test-learn.R:446:3', 'test-add-tbl.R:92:3',
     'test-add-tbl.R:137:3', 'test-autoincrement.R:17:3',
     'test-autoincrement.R:26:3', 'test-rows-dm.R:2:3', 'test-rows-dm.R:28:3',
     'test-rows-dm.R:390:3', 'test-code-generation.R:7:3',
     'test-datamodelr-code.R:4:3', 'test-datamodelr-code.R:17:3',
     'test-datamodelr-code.R:37:3', 'test-datamodelr-code.R:57:3',
     'test-datamodelr-code.R:78:3', 'test-datamodelr-code.R:99:3',
     'test-datamodelr-code.R:120:3', 'test-datamodelr-code.R:133:3',
     'test-db-interface.R:35:3', 'test-check-cardinalities.R:30:3',
     'test-check-cardinalities.R:289:3', 'test-check-cardinalities.R:337:3',
     'test-check-cardinalities.R:422:3', 'test-disambiguate.R:2:3',
     'test-disentangle.R:2:3', 'test-deconstruct.R:6:3',
     'test-deconstruct.R:16:3', 'test-deconstruct.R:26:3',
     'test-deconstruct.R:55:3', 'test-deconstruct.R:72:3',
     'test-deconstruct.R:120:3', 'test-deconstruct.R:144:3',
     'test-deconstruct.R:160:3', 'test-deconstruct.R:181:3',
     'test-deconstruct.R:198:3', 'test-deconstruct.R:222:3',
     'test-deconstruct.R:246:3', 'test-deconstruct.R:270:3',
     'test-deconstruct.R:294:3', 'test-deconstruct.R:320:3',
     'test-deconstruct.R:346:3', 'test-deconstruct.R:372:3',
     'test-deconstruct.R:398:3', 'test-deconstruct.R:420:3',
     'test-deconstruct.R:479:3', 'test-deconstruct.R:492:3',
     'test-deconstruct.R:507:3', 'test-deconstruct.R:525:3',
     'test-deconstruct.R:572:3', 'test-deconstruct.R:586:3',
     'test-deconstruct.R:599:3', 'test-dm_deconstruct.R:2:3',
     'test-dm_deconstruct.R:9:3', 'test-dm.R:2:3', 'test-dm.R:70:3',
     'test-dm.R:108:3', 'test-dm.R:148:3', 'test-dm.R:194:3', 'test-dm.R:202:3',
     'test-dm.R:211:3', 'test-dm.R:217:3', 'test-dm.R:223:3', 'test-dm.R:311:3',
     'test-dm.R:508:3', 'test-dm.R:534:3', 'test-dm.R:564:3', 'test-dm.R:598:3',
     'test-dm_nest_tbl.R:17:3', 'test-dm_pixarfilms.R:2:3', 'test-duckdb.R:2:3',
     'test-enum-ops.R:11:3', 'test-enum-ops.R:30:3', 'test-enum-ops.R:103:3',
     'test-enum-ops.R:176:3', 'test-enumerate_all_paths.R:2:3',
     'test-error-helpers.R:2:3', 'test-dm_wrap.R:12:3', 'test-dm_wrap.R:79:3',
     'test-examine-cardinalities.R:2:3', 'test-examine-cardinalities.R:16:3',
     'test-examine-cardinalities.R:23:3', 'test-examine-constraints.R:68:3',
     'test-examine-constraints.R:77:3', 'test-examine-constraints.R:87:3',
     'test-examine-constraints.R:94:3', 'test-format.R:2:3', 'test-graph.R:29:3',
     'test-graph.R:38:3', 'test-json.R:5:3', 'test-json_nest.R:2:3',
     'test-json_pack.R:2:3', 'test-foreign-keys.R:16:3',
     'test-foreign-keys.R:145:3', 'test-foreign-keys.R:252:3',
     'test-foreign-keys.R:260:3', 'test-foreign-keys.R:287:3',
     'test-foreign-keys.R:306:3', 'test-maria.R:2:3', 'test-meta.R:3:3',
     'test-mssql.R:2:3', 'test-pack_join.R:5:3', 'test-key-helpers.R:4:3',
     'test-key-helpers.R:327:3', 'test-key-helpers.R:333:3',
     'test-key-helpers.R:342:3', 'test-key-helpers.R:350:3', 'test-paste.R:10:3',
     'test-paste.R:93:3', 'test-postgres.R:2:3', 'test-select-tbl.R:30:3',
     'test-select.R:2:3', 'test-select.R:10:3', 'test-select.R:18:3',
     'test-select.R:47:3', 'test-select.R:88:3', 'test-sqlite.R:2:3',
     'test-primary-keys.R:25:3', 'test-primary-keys.R:94:3',
     'test-primary-keys.R:178:3', 'test-primary-keys.R:198:3',
     'test-primary-keys.R:217:3', 'test-primary-keys.R:229:3',
     'test-primary-keys.R:246:3', 'test-primary-keys.R:253:3',
     'test-standalone-check_suggested.R:3:3',
     'test-standalone-check_suggested.R:17:3', 'test-tidyselect.R:25:3',
     'test-tidyr.R:54:3', 'test-tidyr.R:92:3', 'test-unique-keys.R:2:3',
     'test-unique-keys.R:175:3', 'test-upgrade.R:3:3', 'test-upgrade.R:15:3',
     'test-upgrade.R:26:3', 'test-upgrade.R:42:3', 'test-upgrade.R:53:3',
     'test-upgrade.R:72:3', 'test-upgrade.R:86:3', 'test-upgrade.R:102:3',
     'test-upgrade.R:116:3', 'test-waldo.R:8:3', 'test-zoom.R:30:3',
     'test-zoom.R:133:3'
     • Slow test. To run, set CI=true (6): 'test-db-interface.R:7:3',
     'test-dplyr-src.R:49:3', 'test-examine-constraints.R:34:3',
     'test-examine-constraints.R:52:3', 'test-foreign-keys.R:180:3',
     'test-primary-keys.R:158:3'
     • `foo()` needs the "iurtnkjvmomweicopbt" package. (1):
     'test-standalone-check_suggested.R:30:3'
     • dm argument (1): 'test-select-tbl.R:71:3'
     • does not work on `df` (1): 'test-validate.R:201:3'
     • keyed = TRUE (1): 'test-deconstruct.R:91:3'
     • not testing deprecated cdm_nycflights13(): test too slow (1):
     'test-zzx-deprecated.R:266:3'
     • not testing deprecated learning from DB: test too slow (1):
     'test-zzx-deprecated.R:236:3'
     • only works on `db` (1): 'test-filter-dm.R:47:3'
     • only works on `duckdb` (2): 'test-duckdb.R:9:3', 'test-duckdb.R:32:3'
     • only works on `maria` (2): 'test-maria.R:9:3', 'test-maria.R:32:3'
     • only works on `mssql` (6): 'test-learn.R:206:3', 'test-learn.R:282:3',
     'test-db-helpers.R:2:3', 'test-mssql.R:9:3', 'test-mssql.R:32:3',
     'test-schema.R:129:3'
     • only works on `mssql`, `postgres` (4): 'test-db-interface.R:81:3',
     'test-db-interface.R:94:3', 'test-db-interface.R:125:3', 'test-schema.R:2:3'
     • only works on `mssql`, `postgres`, `maria` (4): 'test-learn.R:2:3',
     'test-learn.R:69:3', 'test-learn.R:366:3', 'test-meta.R:9:3'
     • only works on `postgres` (4): 'test-db-helpers.R:108:3',
     'test-postgres.R:9:3', 'test-postgres.R:32:3', 'test-schema.R:99:3'
     • only works on `postgres`, `mssql` (2): 'test-json_nest.R:14:3',
     'test-json_pack.R:13:3'
     • only works on `postgres`, `mssql`, `sqlite` (1): 'test-rows-dm.R:221:3'
     • only works on `postgres`, `sqlite`, `mssql`, `maria` (1):
     'test-db-interface.R:183:3'
     • only works on `sqlite` (3): 'test-schema.R:201:3', 'test-sqlite.R:9:3',
     'test-sqlite.R:32:3'
     
     ══ Failed tests ════════════════════════════════════════════════════════════════
     ── Error ('test-bind.R:51:3'): errors: src mismatches ──────────────────────────
     <dplyr:::mutate_error/rlang_error/error/condition>
     Error in `mutate(., name = child_table, index_name = map_chr(child_fk_cols, 
     paste, collapse = "_"), remote_name = purrr::map_chr(table_names[name], 
     ~DBI::dbQuoteIdentifier(con, .x)), remote_name_unquoted = map_chr(DBI::dbUnquoteIdentifier(con, 
     DBI::SQL(remote_name)), ~.x@name[["table"]]), index_name = make.unique(paste0(remote_name_unquoted, 
     "__", index_name), sep = "__"))`: i In argument: `remote_name_unquoted = map_chr(...)`.
     Caused by error in `map_chr()`:
     i In index: 1.
     Caused by error in `.x@name[["table"]]`:
     ! subscript out of bounds
     ── Error ('test-build_copy_queries.R:14:3'): build_copy_queries snapshot test for pixarfilms ──
     <dplyr:::mutate_error/rlang_error/error/condition>
     Error in `mutate(., name = child_table, index_name = map_chr(child_fk_cols, 
     paste, collapse = "_"), remote_name = purrr::map_chr(table_names[name], 
     ~DBI::dbQuoteIdentifier(con, .x)), remote_name_unquoted = map_chr(DBI::dbUnquoteIdentifier(con, 
     DBI::SQL(remote_name)), ~.x@name[["table"]]), index_name = make.unique(paste0(remote_name_unquoted, 
     "__", index_name), sep = "__"))`: i In argument: `remote_name_unquoted = map_chr(...)`.
     Caused by error in `map_chr()`:
     i In index: 1.
     Caused by error in `.x@name[["table"]]`:
     ! subscript out of bounds
     Backtrace:
     ▆
     1. └─testthat::expect_snapshot(...) at test-build_copy_queries.R:14:3
     2.   └─rlang::cnd_signal(state$error)
     ── Error ('test-build_copy_queries.R:33:3'): build_copy_queries snapshot test for dm_for_filter() ──
     <dplyr:::mutate_error/rlang_error/error/condition>
     Error in `mutate(., name = child_table, index_name = map_chr(child_fk_cols, 
     paste, collapse = "_"), remote_name = purrr::map_chr(table_names[name], 
     ~DBI::dbQuoteIdentifier(con, .x)), remote_name_unquoted = map_chr(DBI::dbUnquoteIdentifier(con, 
     DBI::SQL(remote_name)), ~.x@name[["table"]]), index_name = make.unique(paste0(remote_name_unquoted, 
     "__", index_name), sep = "__"))`: i In argument: `remote_name_unquoted = map_chr(...)`.
     Caused by error in `map_chr()`:
     i In index: 1.
     Caused by error in `.x@name[["table"]]`:
     ! subscript out of bounds
     Backtrace:
     ▆
     1. └─testthat::expect_snapshot(...) at test-build_copy_queries.R:33:3
     2.   └─rlang::cnd_signal(state$error)
     ── Error ('test-build_copy_queries.R:63:3'): build_copy_queries avoids duplicate indexes ──
     <dplyr:::mutate_error/rlang_error/error/condition>
     Error in `mutate(., name = child_table, index_name = map_chr(child_fk_cols, 
     paste, collapse = "_"), remote_name = purrr::map_chr(table_names[name], 
     ~DBI::dbQuoteIdentifier(con, .x)), remote_name_unquoted = map_chr(DBI::dbUnquoteIdentifier(con, 
     DBI::SQL(remote_name)), ~.x@name[["table"]]), index_name = make.unique(paste0(remote_name_unquoted, 
     "__", index_name), sep = "__"))`: i In argument: `remote_name_unquoted = map_chr(...)`.
     Caused by error in `map_chr()`:
     i In index: 1.
     Caused by error in `.x@name[["table"]]`:
     ! subscript out of bounds
     ── Error ('test-rows-dm.R:98:3'): dm_rows_update() ─────────────────────────────
     <dplyr:::mutate_error/rlang_error/error/condition>
     Error in `mutate(., name = child_table, index_name = map_chr(child_fk_cols, 
     paste, collapse = "_"), remote_name = purrr::map_chr(table_names[name], 
     ~DBI::dbQuoteIdentifier(con, .x)), remote_name_unquoted = map_chr(DBI::dbUnquoteIdentifier(con, 
     DBI::SQL(remote_name)), ~.x@name[["table"]]), index_name = make.unique(paste0(remote_name_unquoted, 
     "__", index_name), sep = "__"))`: i In argument: `remote_name_unquoted = map_chr(...)`.
     Caused by error in `map_chr()`:
     i In index: 1.
     Caused by error in `.x@name[["table"]]`:
     ! subscript out of bounds
     ── Error ('test-rows-dm.R:152:3'): dm_rows_truncate() ──────────────────────────
     <dplyr:::mutate_error/rlang_error/error/condition>
     Error in `mutate(., name = child_table, index_name = map_chr(child_fk_cols, 
     paste, collapse = "_"), remote_name = purrr::map_chr(table_names[name], 
     ~DBI::dbQuoteIdentifier(con, .x)), remote_name_unquoted = map_chr(DBI::dbUnquoteIdentifier(con, 
     DBI::SQL(remote_name)), ~.x@name[["table"]]), index_name = make.unique(paste0(remote_name_unquoted, 
     "__", index_name), sep = "__"))`: i In argument: `remote_name_unquoted = map_chr(...)`.
     Caused by error in `map_chr()`:
     i In index: 1.
     Caused by error in `.x@name[["table"]]`:
     ! subscript out of bounds
     ── Error ('test-dm.R:273:3'): 'compute.dm()' computes tables on DB ─────────────
     <dplyr:::mutate_error/rlang_error/error/condition>
     Error in `mutate(., name = child_table, index_name = map_chr(child_fk_cols, 
     paste, collapse = "_"), remote_name = purrr::map_chr(table_names[name], 
     ~DBI::dbQuoteIdentifier(con, .x)), remote_name_unquoted = map_chr(DBI::dbUnquoteIdentifier(con, 
     DBI::SQL(remote_name)), ~.x@name[["table"]]), index_name = make.unique(paste0(remote_name_unquoted, 
     "__", index_name), sep = "__"))`: i In argument: `remote_name_unquoted = map_chr(...)`.
     Caused by error in `map_chr()`:
     i In index: 1.
     Caused by error in `.x@name[["table"]]`:
     ! subscript out of bounds
     ── Error ('test-dm.R:286:3'): 'compute.dm_zoomed()' computes tables on DB ──────
     <dplyr:::mutate_error/rlang_error/error/condition>
     Error in `mutate(., name = child_table, index_name = map_chr(child_fk_cols, 
     paste, collapse = "_"), remote_name = purrr::map_chr(table_names[name], 
     ~DBI::dbQuoteIdentifier(con, .x)), remote_name_unquoted = map_chr(DBI::dbUnquoteIdentifier(con, 
     DBI::SQL(remote_name)), ~.x@name[["table"]]), index_name = make.unique(paste0(remote_name_unquoted, 
     "__", index_name), sep = "__"))`: i In argument: `remote_name_unquoted = map_chr(...)`.
     Caused by error in `map_chr()`:
     i In index: 1.
     Caused by error in `.x@name[["table"]]`:
     ! subscript out of bounds
     ── Error ('test-dm.R:487:3'): dm_get_con() works ───────────────────────────────
     <dplyr:::mutate_error/rlang_error/error/condition>
     Error in `mutate(., name = child_table, index_name = map_chr(child_fk_cols, 
     paste, collapse = "_"), remote_name = purrr::map_chr(table_names[name], 
     ~DBI::dbQuoteIdentifier(con, .x)), remote_name_unquoted = map_chr(DBI::dbUnquoteIdentifier(con, 
     DBI::SQL(remote_name)), ~.x@name[["table"]]), index_name = make.unique(paste0(remote_name_unquoted, 
     "__", index_name), sep = "__"))`: i In argument: `remote_name_unquoted = map_chr(...)`.
     Caused by error in `map_chr()`:
     i In index: 1.
     Caused by error in `.x@name[["table"]]`:
     ! subscript out of bounds
     ── Error ('test-dm_sql.R:4:3'): snapshot test ──────────────────────────────────
     <dplyr:::mutate_error/rlang_error/error/condition>
     Error in `mutate(., name = child_table, index_name = map_chr(child_fk_cols, 
     paste, collapse = "_"), remote_name = purrr::map_chr(table_names[name], 
     ~DBI::dbQuoteIdentifier(con, .x)), remote_name_unquoted = map_chr(DBI::dbUnquoteIdentifier(con, 
     DBI::SQL(remote_name)), ~.x@name[["table"]]), index_name = make.unique(paste0(remote_name_unquoted, 
     "__", index_name), sep = "__"))`: i In argument: `remote_name_unquoted = map_chr(...)`.
     Caused by error in `map_chr()`:
     i In index: 1.
     Caused by error in `.x@name[["table"]]`:
     ! subscript out of bounds
     Backtrace:
     ▆
     1. └─testthat::expect_snapshot(...) at test-dm_sql.R:4:3
     2.   └─rlang::cnd_signal(state$error)
     ── Error ('test-nest.R:41:3'): 'nest_join_dm_zoomed()' fails for DB-'dm' ───────
     <dplyr:::mutate_error/rlang_error/error/condition>
     Error in `mutate(., name = child_table, index_name = map_chr(child_fk_cols, 
     paste, collapse = "_"), remote_name = purrr::map_chr(table_names[name], 
     ~DBI::dbQuoteIdentifier(con, .x)), remote_name_unquoted = map_chr(DBI::dbUnquoteIdentifier(con, 
     DBI::SQL(remote_name)), ~.x@name[["table"]]), index_name = make.unique(paste0(remote_name_unquoted, 
     "__", index_name), sep = "__"))`: i In argument: `remote_name_unquoted = map_chr(...)`.
     Caused by error in `map_chr()`:
     i In index: 1.
     Caused by error in `.x@name[["table"]]`:
     ! subscript out of bounds
     ── Error ('test-pack_join.R:15:3'): `pack_join()` works with remote table ──────
     <dplyr:::mutate_error/rlang_error/error/condition>
     Error in `mutate(., name = child_table, index_name = map_chr(child_fk_cols, 
     paste, collapse = "_"), remote_name = purrr::map_chr(table_names[name], 
     ~DBI::dbQuoteIdentifier(con, .x)), remote_name_unquoted = map_chr(DBI::dbUnquoteIdentifier(con, 
     DBI::SQL(remote_name)), ~.x@name[["table"]]), index_name = make.unique(paste0(remote_name_unquoted, 
     "__", index_name), sep = "__"))`: i In argument: `remote_name_unquoted = map_chr(...)`.
     Caused by error in `map_chr()`:
     i In index: 1.
     Caused by error in `.x@name[["table"]]`:
     ! subscript out of bounds
     ── Error ('test-validate.R:190:3'): validator speaks up (sqlite()) ─────────────
     <dplyr:::mutate_error/rlang_error/error/condition>
     Error in `mutate(., data = if_else(table == "tf_1", list(dm_for_filter_duckdb()$tf_1), 
     data))`: i In argument: `data = if_else(table == "tf_1", list(dm_for_filter_duckdb()$tf_1), data)`.
     Caused by error in `mutate()`:
     i In argument: `remote_name_unquoted = map_chr(...)`.
     Caused by error in `map_chr()`:
     i In index: 1.
     Caused by error in `.x@name[["table"]]`:
     ! subscript out of bounds
     Backtrace:
     ▆
     1. ├─dm:::expect_dm_error(...) at test-validate.R:190:3
     2. │ └─testthat::expect_error(expr, class = dm_error(class)) at tests/testthat/helper-expectations.R:48:3
     3. │   └─testthat:::expect_condition_matching(...)
     4. │     └─testthat:::quasi_capture(...)
     5. │       ├─testthat (local) .capture(...)
     6. │       │ └─base::withCallingHandlers(...)
     7. │       └─rlang::eval_bare(quo_get_expr(.quo), quo_get_env(.quo))
     8. ├─... %>% dm_validate()
     9. ├─dm::dm_validate(.)
     10. │ └─dm:::check_dm(x)
     11. │   └─dm::is_dm(x)
     12. ├─dm:::dm_from_def(.)
     13. ├─dplyr::mutate(...)
     14. ├─dplyr:::mutate.data.frame(...)
     15. │ └─dplyr:::mutate_cols(.data, dplyr_quosures(...), by)
     16. │   ├─base::withCallingHandlers(...)
     17. │   └─dplyr:::mutate_col(dots[[i]], data, mask, new_columns)
     18. │     └─mask$eval_all_mutate(quo)
     19. │       └─dplyr (local) eval()
     20. ├─dplyr::if_else(...)
     21. ├─dm:::dm_for_filter_duckdb()
     22. ├─dm::copy_dm_to(duckdb_test_src(), dm_for_filter()) at tests/testthat/helper-src.R:26:7
     23. │ └─dm:::build_copy_queries(...)
     24. │   └─... %>% ...
     25. ├─dplyr::summarize(...)
     26. ├─dplyr::group_by(., name)
     27. ├─dplyr::mutate(...)
     28. ├─dplyr:::mutate.data.frame(...)
     29. │ └─dplyr:::mutate_cols(.data, dplyr_quosures(...), by)
     30. │   ├─base::withCallingHandlers(...)
     31. │   └─dplyr:::mutate_col(dots[[i]], data, mask, new_columns)
     32. │     └─mask$eval_all_mutate(quo)
     33. │       └─dplyr (local) eval()
     34. ├─purrr::map_chr(...)
     35. │ └─purrr:::map_("character", .x, .f, ..., .progress = .progress)
     36. │   ├─purrr:::with_indexed_errors(...)
     37. │   │ └─base::withCallingHandlers(...)
     38. │   ├─purrr:::call_with_cleanup(...)
     39. │   └─dm (local) .f(.x[[i]], ...)
     40. ├─purrr (local) `<fn>`(`<sbscOOBE>`)
     41. │ └─cli::cli_abort(...)
     42. │   └─rlang::abort(...)
     43. │     └─rlang:::signal_abort(cnd, .file)
     44. │       └─base::signalCondition(cnd)
     45. ├─dplyr (local) `<fn>`(`<prrr_rr_>`)
     46. │ └─rlang::abort(message, class = error_class, parent = parent, call = error_call)
     47. │   └─rlang:::signal_abort(cnd, .file)
     48. │     └─base::signalCondition(cnd)
     49. └─dplyr (local) `<fn>`(`<dply:::_>`)
     50.   └─rlang::abort(message, class = error_class, parent = parent, call = error_call)
     ── Error ('test_dm_from_con.R:23:3'): table identifiers are quoted ─────────────
     <purrr_error_indexed/rlang_error/error/condition>
     Error in `map(DBI::dbUnquoteIdentifier(con_db, DBI::SQL(remote_tbl_names_copied)), 
     ~.x@name[["table"]])`: i In index: 1.
     Caused by error in `.x@name[["table"]]`:
     ! subscript out of bounds
     Backtrace:
     ▆
     1. ├─... %>% ... at test_dm_from_con.R:23:3
     2. ├─dm::dm_select_tbl(...)
     3. │ └─dm:::eval_select_table(quo(c(...)), src_tbls_impl(dm))
     4. │   └─dm:::eval_select_table_indices(quo, table_names, unique = unique)
     5. │     ├─base::withCallingHandlers(...)
     6. │     └─dm:::eval_select_indices(quo, table_names, unique = unique)
     7. │       └─tidyselect::eval_select(quo, set_names(names))
     8. │         └─tidyselect:::eval_select_impl(...)
     9. │           ├─tidyselect:::with_subscript_errors(...)
     10. │           │ └─rlang::try_fetch(...)
     11. │           │   └─base::withCallingHandlers(...)
     12. │           └─tidyselect:::vars_select_eval(...)
     13. │             └─tidyselect:::walk_data_tree(expr, data_mask, context_mask)
     14. │               └─tidyselect:::eval_c(expr, data_mask, context_mask)
     15. │                 └─tidyselect:::call_expand_dots(expr, context_mask$.__current__.)
     16. │                   └─rlang::eval_bare(quote(enquos(...)), dots_mask)
     17. ├─rlang::enquos(...)
     18. │ └─rlang:::endots(...)
     19. │   └─rlang:::map(...)
     20. │     └─base::lapply(.x, .f, ...)
     21. │       └─rlang (local) FUN(X[[i]], ...)
     22. ├─purrr::map(...)
     23. │ └─purrr:::map_("list", .x, .f, ..., .progress = .progress)
     24. │   ├─purrr:::with_indexed_errors(...)
     25. │   │ └─base::withCallingHandlers(...)
     26. │   ├─purrr:::call_with_cleanup(...)
     27. │   └─dm (local) .f(.x[[i]], ...)
     28. └─purrr (local) `<fn>`(`<sbscOOBE>`)
     29.   └─cli::cli_abort(...)
     30.     └─rlang::abort(...)
     
     [ FAIL 14 | WARN 6 | SKIP 235 | PASS 1347 ]
     Deleting unused snapshots:
     • datamodelr-code/nycflights13.dot
     • datamodelr-code/nycflights13_draw_uk_1.dot
     • datamodelr-code/nycflights13_draw_uk_2.dot
     • datamodelr-code/nycflights13_draw_uk_3.dot
     • datamodelr-code/nycflights13_table_desc_1.dot
     • datamodelr-code/nycflights13_table_desc_2.dot
     • datamodelr-code/weird.dot
     • draw-dm/empty-table-in-dm.svg
     • draw-dm/nycflight-dm-types.svg
     • draw-dm/nycflight-dm.svg
     • draw-dm/single-empty-table-dm.svg
     • draw-dm/table-desc-1-dm.svg
     • draw-dm/table-desc-2-dm.svg
     • draw-dm/table-desc-3-dm.svg
     • draw-dm/table-desc-4-dm.svg
     • draw-dm/table-uk-1-dm.svg
     • draw-dm/table-uk-2-dm.svg
     Error: Test failures
     Execution halted
- [ ] ERROR: r-devel-linux-x86_64-fedora-gcc
     Running ‘testthat.R’ [268s/146s]
     Running the tests in ‘tests/testthat.R’ failed.
     Complete output:
     > library(testthat)
     > 
     > # Need to use qualified call, this is checked in helper-print.R
     > testthat::test_check("dm")
     Loading required package: dm
     
     Attaching package: 'dm'
     
     The following object is masked from 'package:stats':
     
     filter
     
     Starting 2 test processes
     [ FAIL 14 | WARN 6 | SKIP 235 | PASS 1347 ]
     
     ══ Skipped tests (235) ═════════════════════════════════════════════════════════
     • COMPOUND (1): 'test-rows-dm.R:203:3'
     • Dependent on database version, find better way to record this info (1):
     'test-meta.R:19:3'
     • FIXME (2): 'test-learn.R:154:3', 'test-nest.R:2:3'
     • FIXME: Unstable on GHA? (1): 'test-dm.R:495:3'
     • Need to think about it (1): 'test-key-helpers.R:45:3'
     • On CRAN (187): 'test-zzx-deprecated.R:2:3', 'test-zzx-deprecated.R:15:3',
     'test-zzx-deprecated.R:25:3', 'test-zzx-deprecated.R:35:3',
     'test-zzx-deprecated.R:45:3', 'test-zzx-deprecated.R:58:3',
     'test-zzx-deprecated.R:81:3', 'test-zzx-deprecated.R:91:3',
     'test-zzx-deprecated.R:106:3', 'test-zzx-deprecated.R:121:3',
     'test-zzx-deprecated.R:141:3', 'test-zzx-deprecated.R:151:3',
     'test-zzx-deprecated.R:166:3', 'test-zzx-deprecated.R:185:3',
     'test-zzx-deprecated.R:221:3', 'test-zzx-deprecated.R:255:3',
     'test-zzx-deprecated.R:275:3', 'test-zzx-deprecated.R:291:3',
     'test-zzx-deprecated.R:326:3', 'test-zzx-deprecated.R:341:3',
     'test-zzx-deprecated.R:356:3', 'test-flatten.R:18:3', 'test-flatten.R:99:3',
     'test-dplyr.R:347:3', 'test-dplyr.R:506:3', 'test-dplyr.R:545:3',
     'test-dplyr.R:558:3', 'test-dplyr.R:569:3', 'test-dplyr.R:598:3',
     'test-dplyr.R:614:3', 'test-dplyr.R:806:3', 'test-draw-dm.R:17:3',
     'test-draw-dm.R:104:3', 'test-draw-dm.R:117:3', 'test-draw-dm.R:153:3',
     'test-draw-dm.R:182:3', 'test-filter-dm.R:62:3', 'test-filter-dm.R:173:3',
     'test-filter-dm.R:182:3', 'test-filter-dm.R:191:3', 'test-filter-dm.R:241:3',
     'test-bind.R:42:3', 'test-bind.R:97:3', 'test-bind.R:107:3',
     'test-bind.R:125:3', 'test-learn.R:446:3', 'test-add-tbl.R:92:3',
     'test-add-tbl.R:137:3', 'test-autoincrement.R:17:3',
     'test-autoincrement.R:26:3', 'test-rows-dm.R:2:3', 'test-rows-dm.R:28:3',
     'test-rows-dm.R:390:3', 'test-code-generation.R:7:3',
     'test-datamodelr-code.R:4:3', 'test-datamodelr-code.R:17:3',
     'test-datamodelr-code.R:37:3', 'test-datamodelr-code.R:57:3',
     'test-datamodelr-code.R:78:3', 'test-datamodelr-code.R:99:3',
     'test-datamodelr-code.R:120:3', 'test-datamodelr-code.R:133:3',
     'test-db-interface.R:35:3', 'test-check-cardinalities.R:30:3',
     'test-check-cardinalities.R:289:3', 'test-check-cardinalities.R:337:3',
     'test-check-cardinalities.R:422:3', 'test-disambiguate.R:2:3',
     'test-disentangle.R:2:3', 'test-deconstruct.R:6:3',
     'test-deconstruct.R:16:3', 'test-deconstruct.R:26:3',
     'test-deconstruct.R:55:3', 'test-deconstruct.R:72:3',
     'test-deconstruct.R:120:3', 'test-deconstruct.R:144:3',
     'test-deconstruct.R:160:3', 'test-deconstruct.R:181:3',
     'test-deconstruct.R:198:3', 'test-deconstruct.R:222:3',
     'test-deconstruct.R:246:3', 'test-deconstruct.R:270:3',
     'test-deconstruct.R:294:3', 'test-deconstruct.R:320:3',
     'test-deconstruct.R:346:3', 'test-deconstruct.R:372:3',
     'test-deconstruct.R:398:3', 'test-deconstruct.R:420:3',
     'test-deconstruct.R:479:3', 'test-deconstruct.R:492:3',
     'test-deconstruct.R:507:3', 'test-deconstruct.R:525:3',
     'test-deconstruct.R:572:3', 'test-deconstruct.R:586:3',
     'test-deconstruct.R:599:3', 'test-dm_deconstruct.R:2:3',
     'test-dm_deconstruct.R:9:3', 'test-dm_nest_tbl.R:17:3',
     'test-dm_pixarfilms.R:2:3', 'test-dm.R:2:3', 'test-dm.R:70:3',
     'test-dm.R:108:3', 'test-dm.R:148:3', 'test-dm.R:194:3', 'test-dm.R:202:3',
     'test-dm.R:211:3', 'test-dm.R:217:3', 'test-dm.R:223:3', 'test-dm.R:311:3',
     'test-dm.R:508:3', 'test-dm.R:534:3', 'test-dm.R:564:3', 'test-dm.R:598:3',
     'test-duckdb.R:2:3', 'test-enum-ops.R:11:3', 'test-enum-ops.R:30:3',
     'test-enum-ops.R:103:3', 'test-enum-ops.R:176:3',
     'test-enumerate_all_paths.R:2:3', 'test-error-helpers.R:2:3',
     'test-dm_wrap.R:12:3', 'test-dm_wrap.R:79:3',
     'test-examine-cardinalities.R:2:3', 'test-examine-cardinalities.R:16:3',
     'test-examine-cardinalities.R:23:3', 'test-examine-constraints.R:68:3',
     'test-examine-constraints.R:77:3', 'test-examine-constraints.R:87:3',
     'test-examine-constraints.R:94:3', 'test-format.R:2:3', 'test-graph.R:29:3',
     'test-graph.R:38:3', 'test-json.R:5:3', 'test-json_nest.R:2:3',
     'test-json_pack.R:2:3', 'test-foreign-keys.R:16:3',
     'test-foreign-keys.R:145:3', 'test-foreign-keys.R:252:3',
     'test-foreign-keys.R:260:3', 'test-foreign-keys.R:287:3',
     'test-foreign-keys.R:306:3', 'test-maria.R:2:3', 'test-meta.R:3:3',
     'test-mssql.R:2:3', 'test-pack_join.R:5:3', 'test-paste.R:10:3',
     'test-paste.R:93:3', 'test-postgres.R:2:3', 'test-key-helpers.R:4:3',
     'test-key-helpers.R:327:3', 'test-key-helpers.R:333:3',
     'test-key-helpers.R:342:3', 'test-key-helpers.R:350:3',
     'test-select-tbl.R:30:3', 'test-primary-keys.R:25:3',
     'test-primary-keys.R:94:3', 'test-primary-keys.R:178:3',
     'test-primary-keys.R:198:3', 'test-primary-keys.R:217:3',
     'test-primary-keys.R:229:3', 'test-primary-keys.R:246:3',
     'test-primary-keys.R:253:3', 'test-sqlite.R:2:3',
     'test-standalone-check_suggested.R:3:3',
     'test-standalone-check_suggested.R:17:3', 'test-select.R:2:3',
     'test-select.R:10:3', 'test-select.R:18:3', 'test-select.R:47:3',
     'test-select.R:88:3', 'test-tidyselect.R:25:3', 'test-tidyr.R:54:3',
     'test-tidyr.R:92:3', 'test-unique-keys.R:2:3', 'test-unique-keys.R:175:3',
     'test-upgrade.R:3:3', 'test-upgrade.R:15:3', 'test-upgrade.R:26:3',
     'test-upgrade.R:42:3', 'test-upgrade.R:53:3', 'test-upgrade.R:72:3',
     'test-upgrade.R:86:3', 'test-upgrade.R:102:3', 'test-upgrade.R:116:3',
     'test-waldo.R:8:3', 'test-zoom.R:30:3', 'test-zoom.R:133:3'
     • Slow test. To run, set CI=true (6): 'test-db-interface.R:7:3',
     'test-dplyr-src.R:49:3', 'test-examine-constraints.R:34:3',
     'test-examine-constraints.R:52:3', 'test-foreign-keys.R:180:3',
     'test-primary-keys.R:158:3'
     • `foo()` needs the "iurtnkjvmomweicopbt" package. (1):
     'test-standalone-check_suggested.R:30:3'
     • dm argument (1): 'test-select-tbl.R:71:3'
     • does not work on `df` (1): 'test-validate.R:201:3'
     • keyed = TRUE (1): 'test-deconstruct.R:91:3'
     • not testing deprecated cdm_nycflights13(): test too slow (1):
     'test-zzx-deprecated.R:266:3'
     • not testing deprecated learning from DB: test too slow (1):
     'test-zzx-deprecated.R:236:3'
     • only works on `db` (1): 'test-filter-dm.R:47:3'
     • only works on `duckdb` (2): 'test-duckdb.R:9:3', 'test-duckdb.R:32:3'
     • only works on `maria` (2): 'test-maria.R:9:3', 'test-maria.R:32:3'
     • only works on `mssql` (6): 'test-learn.R:206:3', 'test-learn.R:282:3',
     'test-db-helpers.R:2:3', 'test-mssql.R:9:3', 'test-mssql.R:32:3',
     'test-schema.R:129:3'
     • only works on `mssql`, `postgres` (4): 'test-db-interface.R:81:3',
     'test-db-interface.R:94:3', 'test-db-interface.R:125:3', 'test-schema.R:2:3'
     • only works on `mssql`, `postgres`, `maria` (4): 'test-learn.R:2:3',
     'test-learn.R:69:3', 'test-learn.R:366:3', 'test-meta.R:9:3'
     • only works on `postgres` (4): 'test-db-helpers.R:108:3',
     'test-postgres.R:9:3', 'test-postgres.R:32:3', 'test-schema.R:99:3'
     • only works on `postgres`, `mssql` (2): 'test-json_nest.R:14:3',
     'test-json_pack.R:13:3'
     • only works on `postgres`, `mssql`, `sqlite` (1): 'test-rows-dm.R:221:3'
     • only works on `postgres`, `sqlite`, `mssql`, `maria` (1):
     'test-db-interface.R:183:3'
     • only works on `sqlite` (3): 'test-schema.R:201:3', 'test-sqlite.R:9:3',
     'test-sqlite.R:32:3'
     
     ══ Failed tests ════════════════════════════════════════════════════════════════
     ── Error ('test-bind.R:51:3'): errors: src mismatches ──────────────────────────
     <dplyr:::mutate_error/rlang_error/error/condition>
     Error in `mutate(., name = child_table, index_name = map_chr(child_fk_cols, 
     paste, collapse = "_"), remote_name = purrr::map_chr(table_names[name], 
     ~DBI::dbQuoteIdentifier(con, .x)), remote_name_unquoted = map_chr(DBI::dbUnquoteIdentifier(con, 
     DBI::SQL(remote_name)), ~.x@name[["table"]]), index_name = make.unique(paste0(remote_name_unquoted, 
     "__", index_name), sep = "__"))`: i In argument: `remote_name_unquoted = map_chr(...)`.
     Caused by error in `map_chr()`:
     i In index: 1.
     Caused by error in `.x@name[["table"]]`:
     ! subscript out of bounds
     ── Error ('test-build_copy_queries.R:14:3'): build_copy_queries snapshot test for pixarfilms ──
     <dplyr:::mutate_error/rlang_error/error/condition>
     Error in `mutate(., name = child_table, index_name = map_chr(child_fk_cols, 
     paste, collapse = "_"), remote_name = purrr::map_chr(table_names[name], 
     ~DBI::dbQuoteIdentifier(con, .x)), remote_name_unquoted = map_chr(DBI::dbUnquoteIdentifier(con, 
     DBI::SQL(remote_name)), ~.x@name[["table"]]), index_name = make.unique(paste0(remote_name_unquoted, 
     "__", index_name), sep = "__"))`: i In argument: `remote_name_unquoted = map_chr(...)`.
     Caused by error in `map_chr()`:
     i In index: 1.
     Caused by error in `.x@name[["table"]]`:
     ! subscript out of bounds
     Backtrace:
     ▆
     1. └─testthat::expect_snapshot(...) at test-build_copy_queries.R:14:3
     2.   └─rlang::cnd_signal(state$error)
     ── Error ('test-build_copy_queries.R:33:3'): build_copy_queries snapshot test for dm_for_filter() ──
     <dplyr:::mutate_error/rlang_error/error/condition>
     Error in `mutate(., name = child_table, index_name = map_chr(child_fk_cols, 
     paste, collapse = "_"), remote_name = purrr::map_chr(table_names[name], 
     ~DBI::dbQuoteIdentifier(con, .x)), remote_name_unquoted = map_chr(DBI::dbUnquoteIdentifier(con, 
     DBI::SQL(remote_name)), ~.x@name[["table"]]), index_name = make.unique(paste0(remote_name_unquoted, 
     "__", index_name), sep = "__"))`: i In argument: `remote_name_unquoted = map_chr(...)`.
     Caused by error in `map_chr()`:
     i In index: 1.
     Caused by error in `.x@name[["table"]]`:
     ! subscript out of bounds
     Backtrace:
     ▆
     1. └─testthat::expect_snapshot(...) at test-build_copy_queries.R:33:3
     2.   └─rlang::cnd_signal(state$error)
     ── Error ('test-build_copy_queries.R:63:3'): build_copy_queries avoids duplicate indexes ──
     <dplyr:::mutate_error/rlang_error/error/condition>
     Error in `mutate(., name = child_table, index_name = map_chr(child_fk_cols, 
     paste, collapse = "_"), remote_name = purrr::map_chr(table_names[name], 
     ~DBI::dbQuoteIdentifier(con, .x)), remote_name_unquoted = map_chr(DBI::dbUnquoteIdentifier(con, 
     DBI::SQL(remote_name)), ~.x@name[["table"]]), index_name = make.unique(paste0(remote_name_unquoted, 
     "__", index_name), sep = "__"))`: i In argument: `remote_name_unquoted = map_chr(...)`.
     Caused by error in `map_chr()`:
     i In index: 1.
     Caused by error in `.x@name[["table"]]`:
     ! subscript out of bounds
     ── Error ('test-rows-dm.R:98:3'): dm_rows_update() ─────────────────────────────
     <dplyr:::mutate_error/rlang_error/error/condition>
     Error in `mutate(., name = child_table, index_name = map_chr(child_fk_cols, 
     paste, collapse = "_"), remote_name = purrr::map_chr(table_names[name], 
     ~DBI::dbQuoteIdentifier(con, .x)), remote_name_unquoted = map_chr(DBI::dbUnquoteIdentifier(con, 
     DBI::SQL(remote_name)), ~.x@name[["table"]]), index_name = make.unique(paste0(remote_name_unquoted, 
     "__", index_name), sep = "__"))`: i In argument: `remote_name_unquoted = map_chr(...)`.
     Caused by error in `map_chr()`:
     i In index: 1.
     Caused by error in `.x@name[["table"]]`:
     ! subscript out of bounds
     ── Error ('test-rows-dm.R:152:3'): dm_rows_truncate() ──────────────────────────
     <dplyr:::mutate_error/rlang_error/error/condition>
     Error in `mutate(., name = child_table, index_name = map_chr(child_fk_cols, 
     paste, collapse = "_"), remote_name = purrr::map_chr(table_names[name], 
     ~DBI::dbQuoteIdentifier(con, .x)), remote_name_unquoted = map_chr(DBI::dbUnquoteIdentifier(con, 
     DBI::SQL(remote_name)), ~.x@name[["table"]]), index_name = make.unique(paste0(remote_name_unquoted, 
     "__", index_name), sep = "__"))`: i In argument: `remote_name_unquoted = map_chr(...)`.
     Caused by error in `map_chr()`:
     i In index: 1.
     Caused by error in `.x@name[["table"]]`:
     ! subscript out of bounds
     ── Error ('test-dm.R:273:3'): 'compute.dm()' computes tables on DB ─────────────
     <dplyr:::mutate_error/rlang_error/error/condition>
     Error in `mutate(., name = child_table, index_name = map_chr(child_fk_cols, 
     paste, collapse = "_"), remote_name = purrr::map_chr(table_names[name], 
     ~DBI::dbQuoteIdentifier(con, .x)), remote_name_unquoted = map_chr(DBI::dbUnquoteIdentifier(con, 
     DBI::SQL(remote_name)), ~.x@name[["table"]]), index_name = make.unique(paste0(remote_name_unquoted, 
     "__", index_name), sep = "__"))`: i In argument: `remote_name_unquoted = map_chr(...)`.
     Caused by error in `map_chr()`:
     i In index: 1.
     Caused by error in `.x@name[["table"]]`:
     ! subscript out of bounds
     ── Error ('test-dm.R:286:3'): 'compute.dm_zoomed()' computes tables on DB ──────
     <dplyr:::mutate_error/rlang_error/error/condition>
     Error in `mutate(., name = child_table, index_name = map_chr(child_fk_cols, 
     paste, collapse = "_"), remote_name = purrr::map_chr(table_names[name], 
     ~DBI::dbQuoteIdentifier(con, .x)), remote_name_unquoted = map_chr(DBI::dbUnquoteIdentifier(con, 
     DBI::SQL(remote_name)), ~.x@name[["table"]]), index_name = make.unique(paste0(remote_name_unquoted, 
     "__", index_name), sep = "__"))`: i In argument: `remote_name_unquoted = map_chr(...)`.
     Caused by error in `map_chr()`:
     i In index: 1.
     Caused by error in `.x@name[["table"]]`:
     ! subscript out of bounds
     ── Error ('test-dm.R:487:3'): dm_get_con() works ───────────────────────────────
     <dplyr:::mutate_error/rlang_error/error/condition>
     Error in `mutate(., name = child_table, index_name = map_chr(child_fk_cols, 
     paste, collapse = "_"), remote_name = purrr::map_chr(table_names[name], 
     ~DBI::dbQuoteIdentifier(con, .x)), remote_name_unquoted = map_chr(DBI::dbUnquoteIdentifier(con, 
     DBI::SQL(remote_name)), ~.x@name[["table"]]), index_name = make.unique(paste0(remote_name_unquoted, 
     "__", index_name), sep = "__"))`: i In argument: `remote_name_unquoted = map_chr(...)`.
     Caused by error in `map_chr()`:
     i In index: 1.
     Caused by error in `.x@name[["table"]]`:
     ! subscript out of bounds
     ── Error ('test-dm_sql.R:4:3'): snapshot test ──────────────────────────────────
     <dplyr:::mutate_error/rlang_error/error/condition>
     Error in `mutate(., name = child_table, index_name = map_chr(child_fk_cols, 
     paste, collapse = "_"), remote_name = purrr::map_chr(table_names[name], 
     ~DBI::dbQuoteIdentifier(con, .x)), remote_name_unquoted = map_chr(DBI::dbUnquoteIdentifier(con, 
     DBI::SQL(remote_name)), ~.x@name[["table"]]), index_name = make.unique(paste0(remote_name_unquoted, 
     "__", index_name), sep = "__"))`: i In argument: `remote_name_unquoted = map_chr(...)`.
     Caused by error in `map_chr()`:
     i In index: 1.
     Caused by error in `.x@name[["table"]]`:
     ! subscript out of bounds
     Backtrace:
     ▆
     1. └─testthat::expect_snapshot(...) at test-dm_sql.R:4:3
     2.   └─rlang::cnd_signal(state$error)
     ── Error ('test-nest.R:41:3'): 'nest_join_dm_zoomed()' fails for DB-'dm' ───────
     <dplyr:::mutate_error/rlang_error/error/condition>
     Error in `mutate(., name = child_table, index_name = map_chr(child_fk_cols, 
     paste, collapse = "_"), remote_name = purrr::map_chr(table_names[name], 
     ~DBI::dbQuoteIdentifier(con, .x)), remote_name_unquoted = map_chr(DBI::dbUnquoteIdentifier(con, 
     DBI::SQL(remote_name)), ~.x@name[["table"]]), index_name = make.unique(paste0(remote_name_unquoted, 
     "__", index_name), sep = "__"))`: i In argument: `remote_name_unquoted = map_chr(...)`.
     Caused by error in `map_chr()`:
     i In index: 1.
     Caused by error in `.x@name[["table"]]`:
     ! subscript out of bounds
     ── Error ('test-pack_join.R:15:3'): `pack_join()` works with remote table ──────
     <dplyr:::mutate_error/rlang_error/error/condition>
     Error in `mutate(., name = child_table, index_name = map_chr(child_fk_cols, 
     paste, collapse = "_"), remote_name = purrr::map_chr(table_names[name], 
     ~DBI::dbQuoteIdentifier(con, .x)), remote_name_unquoted = map_chr(DBI::dbUnquoteIdentifier(con, 
     DBI::SQL(remote_name)), ~.x@name[["table"]]), index_name = make.unique(paste0(remote_name_unquoted, 
     "__", index_name), sep = "__"))`: i In argument: `remote_name_unquoted = map_chr(...)`.
     Caused by error in `map_chr()`:
     i In index: 1.
     Caused by error in `.x@name[["table"]]`:
     ! subscript out of bounds
     ── Error ('test-validate.R:190:3'): validator speaks up (sqlite()) ─────────────
     <dplyr:::mutate_error/rlang_error/error/condition>
     Error in `mutate(., data = if_else(table == "tf_1", list(dm_for_filter_duckdb()$tf_1), 
     data))`: i In argument: `data = if_else(table == "tf_1", list(dm_for_filter_duckdb()$tf_1), data)`.
     Caused by error in `mutate()`:
     i In argument: `remote_name_unquoted = map_chr(...)`.
     Caused by error in `map_chr()`:
     i In index: 1.
     Caused by error in `.x@name[["table"]]`:
     ! subscript out of bounds
     Backtrace:
     ▆
     1. ├─dm:::expect_dm_error(...) at test-validate.R:190:3
     2. │ └─testthat::expect_error(expr, class = dm_error(class)) at tests/testthat/helper-expectations.R:48:3
     3. │   └─testthat:::expect_condition_matching(...)
     4. │     └─testthat:::quasi_capture(...)
     5. │       ├─testthat (local) .capture(...)
     6. │       │ └─base::withCallingHandlers(...)
     7. │       └─rlang::eval_bare(quo_get_expr(.quo), quo_get_env(.quo))
     8. ├─... %>% dm_validate()
     9. ├─dm::dm_validate(.)
     10. │ └─dm:::check_dm(x)
     11. │   └─dm::is_dm(x)
     12. ├─dm:::dm_from_def(.)
     13. ├─dplyr::mutate(...)
     14. ├─dplyr:::mutate.data.frame(...)
     15. │ └─dplyr:::mutate_cols(.data, dplyr_quosures(...), by)
     16. │   ├─base::withCallingHandlers(...)
     17. │   └─dplyr:::mutate_col(dots[[i]], data, mask, new_columns)
     18. │     └─mask$eval_all_mutate(quo)
     19. │       └─dplyr (local) eval()
     20. ├─dplyr::if_else(...)
     21. ├─dm:::dm_for_filter_duckdb()
     22. ├─dm::copy_dm_to(duckdb_test_src(), dm_for_filter()) at tests/testthat/helper-src.R:26:7
     23. │ └─dm:::build_copy_queries(...)
     24. │   └─... %>% ...
     25. ├─dplyr::summarize(...)
     26. ├─dplyr::group_by(., name)
     27. ├─dplyr::mutate(...)
     28. ├─dplyr:::mutate.data.frame(...)
     29. │ └─dplyr:::mutate_cols(.data, dplyr_quosures(...), by)
     30. │   ├─base::withCallingHandlers(...)
     31. │   └─dplyr:::mutate_col(dots[[i]], data, mask, new_columns)
     32. │     └─mask$eval_all_mutate(quo)
     33. │       └─dplyr (local) eval()
     34. ├─purrr::map_chr(...)
     35. │ └─purrr:::map_("character", .x, .f, ..., .progress = .progress)
     36. │   ├─purrr:::with_indexed_errors(...)
     37. │   │ └─base::withCallingHandlers(...)
     38. │   ├─purrr:::call_with_cleanup(...)
     39. │   └─dm (local) .f(.x[[i]], ...)
     40. ├─purrr (local) `<fn>`(`<sbscOOBE>`)
     41. │ └─cli::cli_abort(...)
     42. │   └─rlang::abort(...)
     43. │     └─rlang:::signal_abort(cnd, .file)
     44. │       └─base::signalCondition(cnd)
     45. ├─dplyr (local) `<fn>`(`<prrr_rr_>`)
     46. │ └─rlang::abort(message, class = error_class, parent = parent, call = error_call)
     47. │   └─rlang:::signal_abort(cnd, .file)
     48. │     └─base::signalCondition(cnd)
     49. └─dplyr (local) `<fn>`(`<dply:::_>`)
     50.   └─rlang::abort(message, class = error_class, parent = parent, call = error_call)
     ── Error ('test_dm_from_con.R:23:3'): table identifiers are quoted ─────────────
     <purrr_error_indexed/rlang_error/error/condition>
     Error in `map(DBI::dbUnquoteIdentifier(con_db, DBI::SQL(remote_tbl_names_copied)), 
     ~.x@name[["table"]])`: i In index: 1.
     Caused by error in `.x@name[["table"]]`:
     ! subscript out of bounds
     Backtrace:
     ▆
     1. ├─... %>% ... at test_dm_from_con.R:23:3
     2. ├─dm::dm_select_tbl(...)
     3. │ └─dm:::eval_select_table(quo(c(...)), src_tbls_impl(dm))
     4. │   └─dm:::eval_select_table_indices(quo, table_names, unique = unique)
     5. │     ├─base::withCallingHandlers(...)
     6. │     └─dm:::eval_select_indices(quo, table_names, unique = unique)
     7. │       └─tidyselect::eval_select(quo, set_names(names))
     8. │         └─tidyselect:::eval_select_impl(...)
     9. │           ├─tidyselect:::with_subscript_errors(...)
     10. │           │ └─rlang::try_fetch(...)
     11. │           │   └─base::withCallingHandlers(...)
     12. │           └─tidyselect:::vars_select_eval(...)
     13. │             └─tidyselect:::walk_data_tree(expr, data_mask, context_mask)
     14. │               └─tidyselect:::eval_c(expr, data_mask, context_mask)
     15. │                 └─tidyselect:::call_expand_dots(expr, context_mask$.__current__.)
     16. │                   └─rlang::eval_bare(quote(enquos(...)), dots_mask)
     17. ├─rlang::enquos(...)
     18. │ └─rlang:::endots(...)
     19. │   └─rlang:::map(...)
     20. │     └─base::lapply(.x, .f, ...)
     21. │       └─rlang (local) FUN(X[[i]], ...)
     22. ├─purrr::map(...)
     23. │ └─purrr:::map_("list", .x, .f, ..., .progress = .progress)
     24. │   ├─purrr:::with_indexed_errors(...)
     25. │   │ └─base::withCallingHandlers(...)
     26. │   ├─purrr:::call_with_cleanup(...)
     27. │   └─dm (local) .f(.x[[i]], ...)
     28. └─purrr (local) `<fn>`(`<sbscOOBE>`)
     29.   └─cli::cli_abort(...)
     30.     └─rlang::abort(...)
     
     [ FAIL 14 | WARN 6 | SKIP 235 | PASS 1347 ]
     Deleting unused snapshots:
     • datamodelr-code/nycflights13.dot
     • datamodelr-code/nycflights13_draw_uk_1.dot
     • datamodelr-code/nycflights13_draw_uk_2.dot
     • datamodelr-code/nycflights13_draw_uk_3.dot
     • datamodelr-code/nycflights13_table_desc_1.dot
     • datamodelr-code/nycflights13_table_desc_2.dot
     • datamodelr-code/weird.dot
     • draw-dm/empty-table-in-dm.svg
     • draw-dm/nycflight-dm-types.svg
     • draw-dm/nycflight-dm.svg
     • draw-dm/single-empty-table-dm.svg
     • draw-dm/table-desc-1-dm.svg
     • draw-dm/table-desc-2-dm.svg
     • draw-dm/table-desc-3-dm.svg
     • draw-dm/table-desc-4-dm.svg
     • draw-dm/table-uk-1-dm.svg
     • draw-dm/table-uk-2-dm.svg
     Error: Test failures
     Execution halted
- [ ] ERROR: r-devel-windows-x86_64
     Running 'testthat.R' [74s]
     Running the tests in 'tests/testthat.R' failed.
     Complete output:
     > library(testthat)
     > 
     > # Need to use qualified call, this is checked in helper-print.R
     > testthat::test_check("dm")
     Loading required package: dm
     
     Attaching package: 'dm'
     
     The following object is masked from 'package:stats':
     
     filter
     
     Starting 2 test processes
     [ FAIL 14 | WARN 6 | SKIP 235 | PASS 1347 ]
     
     ══ Skipped tests (235) ═════════════════════════════════════════════════════════
     • COMPOUND (1): 'test-rows-dm.R:203:3'
     • Dependent on database version, find better way to record this info (1):
     'test-meta.R:19:3'
     • FIXME (2): 'test-learn.R:154:3', 'test-nest.R:2:3'
     • FIXME: Unstable on GHA? (1): 'test-dm.R:495:3'
     • Need to think about it (1): 'test-key-helpers.R:45:3'
     • On CRAN (187): 'test-zzx-deprecated.R:2:3', 'test-zzx-deprecated.R:15:3',
     'test-zzx-deprecated.R:25:3', 'test-zzx-deprecated.R:35:3',
     'test-zzx-deprecated.R:45:3', 'test-zzx-deprecated.R:58:3',
     'test-zzx-deprecated.R:81:3', 'test-zzx-deprecated.R:91:3',
     'test-zzx-deprecated.R:106:3', 'test-zzx-deprecated.R:121:3',
     'test-zzx-deprecated.R:141:3', 'test-zzx-deprecated.R:151:3',
     'test-zzx-deprecated.R:166:3', 'test-zzx-deprecated.R:185:3',
     'test-zzx-deprecated.R:221:3', 'test-zzx-deprecated.R:255:3',
     'test-zzx-deprecated.R:275:3', 'test-zzx-deprecated.R:291:3',
     'test-zzx-deprecated.R:326:3', 'test-zzx-deprecated.R:341:3',
     'test-zzx-deprecated.R:356:3', 'test-flatten.R:18:3', 'test-flatten.R:99:3',
     'test-dplyr.R:347:3', 'test-dplyr.R:506:3', 'test-dplyr.R:545:3',
     'test-dplyr.R:558:3', 'test-dplyr.R:569:3', 'test-dplyr.R:598:3',
     'test-dplyr.R:614:3', 'test-dplyr.R:806:3', 'test-draw-dm.R:17:3',
     'test-draw-dm.R:104:3', 'test-draw-dm.R:117:3', 'test-draw-dm.R:153:3',
     'test-draw-dm.R:182:3', 'test-filter-dm.R:62:3', 'test-filter-dm.R:173:3',
     'test-filter-dm.R:182:3', 'test-filter-dm.R:191:3', 'test-filter-dm.R:241:3',
     'test-bind.R:42:3', 'test-bind.R:97:3', 'test-bind.R:107:3',
     'test-bind.R:125:3', 'test-learn.R:446:3', 'test-add-tbl.R:92:3',
     'test-add-tbl.R:137:3', 'test-autoincrement.R:17:3',
     'test-autoincrement.R:26:3', 'test-rows-dm.R:2:3', 'test-rows-dm.R:28:3',
     'test-rows-dm.R:390:3', 'test-code-generation.R:7:3',
     'test-datamodelr-code.R:4:3', 'test-datamodelr-code.R:17:3',
     'test-datamodelr-code.R:37:3', 'test-datamodelr-code.R:57:3',
     'test-datamodelr-code.R:78:3', 'test-datamodelr-code.R:99:3',
     'test-datamodelr-code.R:120:3', 'test-datamodelr-code.R:133:3',
     'test-db-interface.R:35:3', 'test-check-cardinalities.R:30:3',
     'test-check-cardinalities.R:289:3', 'test-check-cardinalities.R:337:3',
     'test-check-cardinalities.R:422:3', 'test-disambiguate.R:2:3',
     'test-disentangle.R:2:3', 'test-deconstruct.R:6:3',
     'test-deconstruct.R:16:3', 'test-deconstruct.R:26:3',
     'test-deconstruct.R:55:3', 'test-deconstruct.R:72:3',
     'test-deconstruct.R:120:3', 'test-deconstruct.R:144:3',
     'test-deconstruct.R:160:3', 'test-deconstruct.R:181:3',
     'test-deconstruct.R:198:3', 'test-deconstruct.R:222:3',
     'test-deconstruct.R:246:3', 'test-deconstruct.R:270:3',
     'test-deconstruct.R:294:3', 'test-deconstruct.R:320:3',
     'test-deconstruct.R:346:3', 'test-deconstruct.R:372:3',
     'test-deconstruct.R:398:3', 'test-deconstruct.R:420:3',
     'test-deconstruct.R:479:3', 'test-deconstruct.R:492:3',
     'test-deconstruct.R:507:3', 'test-deconstruct.R:525:3',
     'test-deconstruct.R:572:3', 'test-deconstruct.R:586:3',
     'test-deconstruct.R:599:3', 'test-dm_deconstruct.R:2:3',
     'test-dm_deconstruct.R:9:3', 'test-dm.R:2:3', 'test-dm.R:70:3',
     'test-dm.R:108:3', 'test-dm.R:148:3', 'test-dm.R:194:3', 'test-dm.R:202:3',
     'test-dm.R:211:3', 'test-dm.R:217:3', 'test-dm.R:223:3', 'test-dm.R:311:3',
     'test-dm.R:508:3', 'test-dm.R:534:3', 'test-dm.R:564:3', 'test-dm.R:598:3',
     'test-dm_nest_tbl.R:17:3', 'test-dm_pixarfilms.R:2:3', 'test-duckdb.R:2:3',
     'test-enum-ops.R:11:3', 'test-enum-ops.R:30:3', 'test-enum-ops.R:103:3',
     'test-enum-ops.R:176:3', 'test-enumerate_all_paths.R:2:3',
     'test-error-helpers.R:2:3', 'test-dm_wrap.R:12:3', 'test-dm_wrap.R:79:3',
     'test-examine-cardinalities.R:2:3', 'test-examine-cardinalities.R:16:3',
     'test-examine-cardinalities.R:23:3', 'test-examine-constraints.R:68:3',
     'test-examine-constraints.R:77:3', 'test-examine-constraints.R:87:3',
     'test-examine-constraints.R:94:3', 'test-format.R:2:3', 'test-graph.R:29:3',
     'test-graph.R:38:3', 'test-json.R:5:3', 'test-json_nest.R:2:3',
     'test-json_pack.R:2:3', 'test-foreign-keys.R:16:3',
     'test-foreign-keys.R:145:3', 'test-foreign-keys.R:252:3',
     'test-foreign-keys.R:260:3', 'test-foreign-keys.R:287:3',
     'test-foreign-keys.R:306:3', 'test-maria.R:2:3', 'test-meta.R:3:3',
     'test-mssql.R:2:3', 'test-pack_join.R:5:3', 'test-paste.R:10:3',
     'test-paste.R:93:3', 'test-postgres.R:2:3', 'test-key-helpers.R:4:3',
     'test-key-helpers.R:327:3', 'test-key-helpers.R:333:3',
     'test-key-helpers.R:342:3', 'test-key-helpers.R:350:3',
     'test-select-tbl.R:30:3', 'test-primary-keys.R:25:3',
     'test-primary-keys.R:94:3', 'test-primary-keys.R:178:3',
     'test-primary-keys.R:198:3', 'test-primary-keys.R:217:3',
     'test-primary-keys.R:229:3', 'test-primary-keys.R:246:3',
     'test-primary-keys.R:253:3', 'test-select.R:2:3', 'test-select.R:10:3',
     'test-select.R:18:3', 'test-select.R:47:3', 'test-select.R:88:3',
     'test-sqlite.R:2:3', 'test-standalone-check_suggested.R:3:3',
     'test-standalone-check_suggested.R:17:3', 'test-tidyselect.R:25:3',
     'test-tidyr.R:54:3', 'test-tidyr.R:92:3', 'test-unique-keys.R:2:3',
     'test-unique-keys.R:175:3', 'test-upgrade.R:3:3', 'test-upgrade.R:15:3',
     'test-upgrade.R:26:3', 'test-upgrade.R:42:3', 'test-upgrade.R:53:3',
     'test-upgrade.R:72:3', 'test-upgrade.R:86:3', 'test-upgrade.R:102:3',
     'test-upgrade.R:116:3', 'test-waldo.R:8:3', 'test-zoom.R:30:3',
     'test-zoom.R:133:3'
     • Slow test. To run, set CI=true (6): 'test-db-interface.R:7:3',
     'test-dplyr-src.R:49:3', 'test-examine-constraints.R:34:3',
     'test-examine-constraints.R:52:3', 'test-foreign-keys.R:180:3',
     'test-primary-keys.R:158:3'
     • `foo()` needs the "iurtnkjvmomweicopbt" package. (1):
     'test-standalone-check_suggested.R:30:3'
     • dm argument (1): 'test-select-tbl.R:71:3'
     • does not work on `df` (1): 'test-validate.R:201:3'
     • keyed = TRUE (1): 'test-deconstruct.R:91:3'
     • not testing deprecated cdm_nycflights13(): test too slow (1):
     'test-zzx-deprecated.R:266:3'
     • not testing deprecated learning from DB: test too slow (1):
     'test-zzx-deprecated.R:236:3'
     • only works on `db` (1): 'test-filter-dm.R:47:3'
     • only works on `duckdb` (2): 'test-duckdb.R:9:3', 'test-duckdb.R:32:3'
     • only works on `maria` (2): 'test-maria.R:9:3', 'test-maria.R:32:3'
     • only works on `mssql` (6): 'test-learn.R:206:3', 'test-learn.R:282:3',
     'test-db-helpers.R:2:3', 'test-mssql.R:9:3', 'test-mssql.R:32:3',
     'test-schema.R:129:3'
     • only works on `mssql`, `postgres` (4): 'test-db-interface.R:81:3',
     'test-db-interface.R:94:3', 'test-db-interface.R:125:3', 'test-schema.R:2:3'
     • only works on `mssql`, `postgres`, `maria` (4): 'test-learn.R:2:3',
     'test-learn.R:69:3', 'test-learn.R:366:3', 'test-meta.R:9:3'
     • only works on `postgres` (4): 'test-db-helpers.R:108:3',
     'test-postgres.R:9:3', 'test-postgres.R:32:3', 'test-schema.R:99:3'
     • only works on `postgres`, `mssql` (2): 'test-json_nest.R:14:3',
     'test-json_pack.R:13:3'
     • only works on `postgres`, `mssql`, `sqlite` (1): 'test-rows-dm.R:221:3'
     • only works on `postgres`, `sqlite`, `mssql`, `maria` (1):
     'test-db-interface.R:183:3'
     • only works on `sqlite` (3): 'test-schema.R:201:3', 'test-sqlite.R:9:3',
     'test-sqlite.R:32:3'
     
     ══ Failed tests ════════════════════════════════════════════════════════════════
     ── Error ('test-bind.R:51:3'): errors: src mismatches ──────────────────────────
     <dplyr:::mutate_error/rlang_error/error/condition>
     Error in `mutate(., name = child_table, index_name = map_chr(child_fk_cols, 
     paste, collapse = "_"), remote_name = purrr::map_chr(table_names[name], 
     ~DBI::dbQuoteIdentifier(con, .x)), remote_name_unquoted = map_chr(DBI::dbUnquoteIdentifier(con, 
     DBI::SQL(remote_name)), ~.x@name[["table"]]), index_name = make.unique(paste0(remote_name_unquoted, 
     "__", index_name), sep = "__"))`: i In argument: `remote_name_unquoted = map_chr(...)`.
     Caused by error in `map_chr()`:
     i In index: 1.
     Caused by error in `.x@name[["table"]]`:
     ! subscript out of bounds
     ── Error ('test-build_copy_queries.R:14:3'): build_copy_queries snapshot test for pixarfilms ──
     <dplyr:::mutate_error/rlang_error/error/condition>
     Error in `mutate(., name = child_table, index_name = map_chr(child_fk_cols, 
     paste, collapse = "_"), remote_name = purrr::map_chr(table_names[name], 
     ~DBI::dbQuoteIdentifier(con, .x)), remote_name_unquoted = map_chr(DBI::dbUnquoteIdentifier(con, 
     DBI::SQL(remote_name)), ~.x@name[["table"]]), index_name = make.unique(paste0(remote_name_unquoted, 
     "__", index_name), sep = "__"))`: i In argument: `remote_name_unquoted = map_chr(...)`.
     Caused by error in `map_chr()`:
     i In index: 1.
     Caused by error in `.x@name[["table"]]`:
     ! subscript out of bounds
     Backtrace:
     ▆
     1. └─testthat::expect_snapshot(...) at test-build_copy_queries.R:14:3
     2.   └─rlang::cnd_signal(state$error)
     ── Error ('test-build_copy_queries.R:33:3'): build_copy_queries snapshot test for dm_for_filter() ──
     <dplyr:::mutate_error/rlang_error/error/condition>
     Error in `mutate(., name = child_table, index_name = map_chr(child_fk_cols, 
     paste, collapse = "_"), remote_name = purrr::map_chr(table_names[name], 
     ~DBI::dbQuoteIdentifier(con, .x)), remote_name_unquoted = map_chr(DBI::dbUnquoteIdentifier(con, 
     DBI::SQL(remote_name)), ~.x@name[["table"]]), index_name = make.unique(paste0(remote_name_unquoted, 
     "__", index_name), sep = "__"))`: i In argument: `remote_name_unquoted = map_chr(...)`.
     Caused by error in `map_chr()`:
     i In index: 1.
     Caused by error in `.x@name[["table"]]`:
     ! subscript out of bounds
     Backtrace:
     ▆
     1. └─testthat::expect_snapshot(...) at test-build_copy_queries.R:33:3
     2.   └─rlang::cnd_signal(state$error)
     ── Error ('test-build_copy_queries.R:63:3'): build_copy_queries avoids duplicate indexes ──
     <dplyr:::mutate_error/rlang_error/error/condition>
     Error in `mutate(., name = child_table, index_name = map_chr(child_fk_cols, 
     paste, collapse = "_"), remote_name = purrr::map_chr(table_names[name], 
     ~DBI::dbQuoteIdentifier(con, .x)), remote_name_unquoted = map_chr(DBI::dbUnquoteIdentifier(con, 
     DBI::SQL(remote_name)), ~.x@name[["table"]]), index_name = make.unique(paste0(remote_name_unquoted, 
     "__", index_name), sep = "__"))`: i In argument: `remote_name_unquoted = map_chr(...)`.
     Caused by error in `map_chr()`:
     i In index: 1.
     Caused by error in `.x@name[["table"]]`:
     ! subscript out of bounds
     ── Error ('test-rows-dm.R:98:3'): dm_rows_update() ─────────────────────────────
     <dplyr:::mutate_error/rlang_error/error/condition>
     Error in `mutate(., name = child_table, index_name = map_chr(child_fk_cols, 
     paste, collapse = "_"), remote_name = purrr::map_chr(table_names[name], 
     ~DBI::dbQuoteIdentifier(con, .x)), remote_name_unquoted = map_chr(DBI::dbUnquoteIdentifier(con, 
     DBI::SQL(remote_name)), ~.x@name[["table"]]), index_name = make.unique(paste0(remote_name_unquoted, 
     "__", index_name), sep = "__"))`: i In argument: `remote_name_unquoted = map_chr(...)`.
     Caused by error in `map_chr()`:
     i In index: 1.
     Caused by error in `.x@name[["table"]]`:
     ! subscript out of bounds
     ── Error ('test-rows-dm.R:152:3'): dm_rows_truncate() ──────────────────────────
     <dplyr:::mutate_error/rlang_error/error/condition>
     Error in `mutate(., name = child_table, index_name = map_chr(child_fk_cols, 
     paste, collapse = "_"), remote_name = purrr::map_chr(table_names[name], 
     ~DBI::dbQuoteIdentifier(con, .x)), remote_name_unquoted = map_chr(DBI::dbUnquoteIdentifier(con, 
     DBI::SQL(remote_name)), ~.x@name[["table"]]), index_name = make.unique(paste0(remote_name_unquoted, 
     "__", index_name), sep = "__"))`: i In argument: `remote_name_unquoted = map_chr(...)`.
     Caused by error in `map_chr()`:
     i In index: 1.
     Caused by error in `.x@name[["table"]]`:
     ! subscript out of bounds
     ── Error ('test-dm.R:273:3'): 'compute.dm()' computes tables on DB ─────────────
     <dplyr:::mutate_error/rlang_error/error/condition>
     Error in `mutate(., name = child_table, index_name = map_chr(child_fk_cols, 
     paste, collapse = "_"), remote_name = purrr::map_chr(table_names[name], 
     ~DBI::dbQuoteIdentifier(con, .x)), remote_name_unquoted = map_chr(DBI::dbUnquoteIdentifier(con, 
     DBI::SQL(remote_name)), ~.x@name[["table"]]), index_name = make.unique(paste0(remote_name_unquoted, 
     "__", index_name), sep = "__"))`: i In argument: `remote_name_unquoted = map_chr(...)`.
     Caused by error in `map_chr()`:
     i In index: 1.
     Caused by error in `.x@name[["table"]]`:
     ! subscript out of bounds
     ── Error ('test-dm.R:286:3'): 'compute.dm_zoomed()' computes tables on DB ──────
     <dplyr:::mutate_error/rlang_error/error/condition>
     Error in `mutate(., name = child_table, index_name = map_chr(child_fk_cols, 
     paste, collapse = "_"), remote_name = purrr::map_chr(table_names[name], 
     ~DBI::dbQuoteIdentifier(con, .x)), remote_name_unquoted = map_chr(DBI::dbUnquoteIdentifier(con, 
     DBI::SQL(remote_name)), ~.x@name[["table"]]), index_name = make.unique(paste0(remote_name_unquoted, 
     "__", index_name), sep = "__"))`: i In argument: `remote_name_unquoted = map_chr(...)`.
     Caused by error in `map_chr()`:
     i In index: 1.
     Caused by error in `.x@name[["table"]]`:
     ! subscript out of bounds
     ── Error ('test-dm.R:487:3'): dm_get_con() works ───────────────────────────────
     <dplyr:::mutate_error/rlang_error/error/condition>
     Error in `mutate(., name = child_table, index_name = map_chr(child_fk_cols, 
     paste, collapse = "_"), remote_name = purrr::map_chr(table_names[name], 
     ~DBI::dbQuoteIdentifier(con, .x)), remote_name_unquoted = map_chr(DBI::dbUnquoteIdentifier(con, 
     DBI::SQL(remote_name)), ~.x@name[["table"]]), index_name = make.unique(paste0(remote_name_unquoted, 
     "__", index_name), sep = "__"))`: i In argument: `remote_name_unquoted = map_chr(...)`.
     Caused by error in `map_chr()`:
     i In index: 1.
     Caused by error in `.x@name[["table"]]`:
     ! subscript out of bounds
     ── Error ('test-dm_sql.R:4:3'): snapshot test ──────────────────────────────────
     <dplyr:::mutate_error/rlang_error/error/condition>
     Error in `mutate(., name = child_table, index_name = map_chr(child_fk_cols, 
     paste, collapse = "_"), remote_name = purrr::map_chr(table_names[name], 
     ~DBI::dbQuoteIdentifier(con, .x)), remote_name_unquoted = map_chr(DBI::dbUnquoteIdentifier(con, 
     DBI::SQL(remote_name)), ~.x@name[["table"]]), index_name = make.unique(paste0(remote_name_unquoted, 
     "__", index_name), sep = "__"))`: i In argument: `remote_name_unquoted = map_chr(...)`.
     Caused by error in `map_chr()`:
     i In index: 1.
     Caused by error in `.x@name[["table"]]`:
     ! subscript out of bounds
     Backtrace:
     ▆
     1. └─testthat::expect_snapshot(...) at test-dm_sql.R:4:3
     2.   └─rlang::cnd_signal(state$error)
     ── Error ('test-nest.R:41:3'): 'nest_join_dm_zoomed()' fails for DB-'dm' ───────
     <dplyr:::mutate_error/rlang_error/error/condition>
     Error in `mutate(., name = child_table, index_name = map_chr(child_fk_cols, 
     paste, collapse = "_"), remote_name = purrr::map_chr(table_names[name], 
     ~DBI::dbQuoteIdentifier(con, .x)), remote_name_unquoted = map_chr(DBI::dbUnquoteIdentifier(con, 
     DBI::SQL(remote_name)), ~.x@name[["table"]]), index_name = make.unique(paste0(remote_name_unquoted, 
     "__", index_name), sep = "__"))`: i In argument: `remote_name_unquoted = map_chr(...)`.
     Caused by error in `map_chr()`:
     i In index: 1.
     Caused by error in `.x@name[["table"]]`:
     ! subscript out of bounds
     ── Error ('test-pack_join.R:15:3'): `pack_join()` works with remote table ──────
     <dplyr:::mutate_error/rlang_error/error/condition>
     Error in `mutate(., name = child_table, index_name = map_chr(child_fk_cols, 
     paste, collapse = "_"), remote_name = purrr::map_chr(table_names[name], 
     ~DBI::dbQuoteIdentifier(con, .x)), remote_name_unquoted = map_chr(DBI::dbUnquoteIdentifier(con, 
     DBI::SQL(remote_name)), ~.x@name[["table"]]), index_name = make.unique(paste0(remote_name_unquoted, 
     "__", index_name), sep = "__"))`: i In argument: `remote_name_unquoted = map_chr(...)`.
     Caused by error in `map_chr()`:
     i In index: 1.
     Caused by error in `.x@name[["table"]]`:
     ! subscript out of bounds
     ── Error ('test-validate.R:190:3'): validator speaks up (sqlite()) ─────────────
     <dplyr:::mutate_error/rlang_error/error/condition>
     Error in `mutate(., data = if_else(table == "tf_1", list(dm_for_filter_duckdb()$tf_1), 
     data))`: i In argument: `data = if_else(table == "tf_1", list(dm_for_filter_duckdb()$tf_1), data)`.
     Caused by error in `mutate()`:
     i In argument: `remote_name_unquoted = map_chr(...)`.
     Caused by error in `map_chr()`:
     i In index: 1.
     Caused by error in `.x@name[["table"]]`:
     ! subscript out of bounds
     Backtrace:
     ▆
     1. ├─dm:::expect_dm_error(...) at test-validate.R:190:3
     2. │ └─testthat::expect_error(expr, class = dm_error(class)) at D:\RCompile\CRANpkg\local\4.4\dm.Rcheck\tests\testthat\helper-expectations.R:48:3
     3. │   └─testthat:::expect_condition_matching(...)
     4. │     └─testthat:::quasi_capture(...)
     5. │       ├─testthat (local) .capture(...)
     6. │       │ └─base::withCallingHandlers(...)
     7. │       └─rlang::eval_bare(quo_get_expr(.quo), quo_get_env(.quo))
     8. ├─... %>% dm_validate()
     9. ├─dm::dm_validate(.)
     10. │ └─dm:::check_dm(x)
     11. │   └─dm::is_dm(x)
     12. ├─dm:::dm_from_def(.)
     13. ├─dplyr::mutate(...)
     14. ├─dplyr:::mutate.data.frame(...)
     15. │ └─dplyr:::mutate_cols(.data, dplyr_quosures(...), by)
     16. │   ├─base::withCallingHandlers(...)
     17. │   └─dplyr:::mutate_col(dots[[i]], data, mask, new_columns)
     18. │     └─mask$eval_all_mutate(quo)
     19. │       └─dplyr (local) eval()
     20. ├─dplyr::if_else(...)
     21. ├─dm:::dm_for_filter_duckdb()
     22. ├─dm::copy_dm_to(duckdb_test_src(), dm_for_filter()) at D:\RCompile\CRANpkg\local\4.4\dm.Rcheck\tests\testthat\helper-src.R:26:7
     23. │ └─dm:::build_copy_queries(...)
     24. │   └─... %>% ...
     25. ├─dplyr::summarize(...)
     26. ├─dplyr::group_by(., name)
     27. ├─dplyr::mutate(...)
     28. ├─dplyr:::mutate.data.frame(...)
     29. │ └─dplyr:::mutate_cols(.data, dplyr_quosures(...), by)
     30. │   ├─base::withCallingHandlers(...)
     31. │   └─dplyr:::mutate_col(dots[[i]], data, mask, new_columns)
     32. │     └─mask$eval_all_mutate(quo)
     33. │       └─dplyr (local) eval()
     34. ├─purrr::map_chr(...)
     35. │ └─purrr:::map_("character", .x, .f, ..., .progress = .progress)
     36. │   ├─purrr:::with_indexed_errors(...)
     37. │   │ └─base::withCallingHandlers(...)
     38. │   ├─purrr:::call_with_cleanup(...)
     39. │   └─dm (local) .f(.x[[i]], ...)
     40. ├─purrr (local) `<fn>`(`<sbscOOBE>`)
     41. │ └─cli::cli_abort(...)
     42. │   └─rlang::abort(...)
     43. │     └─rlang:::signal_abort(cnd, .file)
     44. │       └─base::signalCondition(cnd)
     45. ├─dplyr (local) `<fn>`(`<prrr_rr_>`)
     46. │ └─rlang::abort(message, class = error_class, parent = parent, call = error_call)
     47. │   └─rlang:::signal_abort(cnd, .file)
     48. │     └─base::signalCondition(cnd)
     49. └─dplyr (local) `<fn>`(`<dply:::_>`)
     50.   └─rlang::abort(message, class = error_class, parent = parent, call = error_call)
     ── Error ('test_dm_from_con.R:23:3'): table identifiers are quoted ─────────────
     <purrr_error_indexed/rlang_error/error/condition>
     Error in `map(DBI::dbUnquoteIdentifier(con_db, DBI::SQL(remote_tbl_names_copied)), 
     ~.x@name[["table"]])`: i In index: 1.
     Caused by error in `.x@name[["table"]]`:
     ! subscript out of bounds
     Backtrace:
     ▆
     1. ├─... %>% ... at test_dm_from_con.R:23:3
     2. ├─dm::dm_select_tbl(...)
     3. │ └─dm:::eval_select_table(quo(c(...)), src_tbls_impl(dm))
     4. │   └─dm:::eval_select_table_indices(quo, table_names, unique = unique)
     5. │     ├─base::withCallingHandlers(...)
     6. │     └─dm:::eval_select_indices(quo, table_names, unique = unique)
     7. │       └─tidyselect::eval_select(quo, set_names(names))
     8. │         └─tidyselect:::eval_select_impl(...)
     9. │           ├─tidyselect:::with_subscript_errors(...)
     10. │           │ └─rlang::try_fetch(...)
     11. │           │   └─base::withCallingHandlers(...)
     12. │           └─tidyselect:::vars_select_eval(...)
     13. │             └─tidyselect:::walk_data_tree(expr, data_mask, context_mask)
     14. │               └─tidyselect:::eval_c(expr, data_mask, context_mask)
     15. │                 └─tidyselect:::call_expand_dots(expr, context_mask$.__current__.)
     16. │                   └─rlang::eval_bare(quote(enquos(...)), dots_mask)
     17. ├─rlang::enquos(...)
     18. │ └─rlang:::endots(...)
     19. │   └─rlang:::map(...)
     20. │     └─base::lapply(.x, .f, ...)
     21. │       └─rlang (local) FUN(X[[i]], ...)
     22. ├─purrr::map(...)
     23. │ └─purrr:::map_("list", .x, .f, ..., .progress = .progress)
     24. │   ├─purrr:::with_indexed_errors(...)
     25. │   │ └─base::withCallingHandlers(...)
     26. │   ├─purrr:::call_with_cleanup(...)
     27. │   └─dm (local) .f(.x[[i]], ...)
     28. └─purrr (local) `<fn>`(`<sbscOOBE>`)
     29.   └─cli::cli_abort(...)
     30.     └─rlang::abort(...)
     
     [ FAIL 14 | WARN 6 | SKIP 235 | PASS 1347 ]
     Deleting unused snapshots:
     • datamodelr-code/nycflights13.dot
     • datamodelr-code/nycflights13_draw_uk_1.dot
     • datamodelr-code/nycflights13_draw_uk_2.dot
     • datamodelr-code/nycflights13_draw_uk_3.dot
     • datamodelr-code/nycflights13_table_desc_1.dot
     • datamodelr-code/nycflights13_table_desc_2.dot
     • datamodelr-code/weird.dot
     • draw-dm/empty-table-in-dm.svg
     • draw-dm/nycflight-dm-types.svg
     • draw-dm/nycflight-dm.svg
     • draw-dm/single-empty-table-dm.svg
     • draw-dm/table-desc-1-dm.svg
     • draw-dm/table-desc-2-dm.svg
     • draw-dm/table-desc-3-dm.svg
     • draw-dm/table-desc-4-dm.svg
     • draw-dm/table-uk-1-dm.svg
     • draw-dm/table-uk-2-dm.svg
     Error: Test failures
     Execution halted
- [ ] NOTE: r-patched-linux-x86_64
     Package suggested but not available for checking: ‘duckdb’
- [ ] ERROR: r-release-linux-x86_64
     Running ‘testthat.R’ [229s/138s]
     Running the tests in ‘tests/testthat.R’ failed.
     Complete output:
     > library(testthat)
     > 
     > # Need to use qualified call, this is checked in helper-print.R
     > testthat::test_check("dm")
     Loading required package: dm
     
     Attaching package: 'dm'
     
     The following object is masked from 'package:stats':
     
     filter
     
     Starting 2 test processes
     [ FAIL 14 | WARN 8 | SKIP 235 | PASS 1347 ]
     
     ══ Skipped tests (235) ═════════════════════════════════════════════════════════
     • COMPOUND (1): 'test-rows-dm.R:203:3'
     • Dependent on database version, find better way to record this info (1):
     'test-meta.R:19:3'
     • FIXME (2): 'test-learn.R:154:3', 'test-nest.R:2:3'
     • FIXME: Unstable on GHA? (1): 'test-dm.R:495:3'
     • Need to think about it (1): 'test-key-helpers.R:45:3'
     • On CRAN (187): 'test-zzx-deprecated.R:2:3', 'test-zzx-deprecated.R:15:3',
     'test-zzx-deprecated.R:25:3', 'test-zzx-deprecated.R:35:3',
     'test-zzx-deprecated.R:45:3', 'test-zzx-deprecated.R:58:3',
     'test-zzx-deprecated.R:81:3', 'test-zzx-deprecated.R:91:3',
     'test-zzx-deprecated.R:106:3', 'test-zzx-deprecated.R:121:3',
     'test-zzx-deprecated.R:141:3', 'test-zzx-deprecated.R:151:3',
     'test-zzx-deprecated.R:166:3', 'test-zzx-deprecated.R:185:3',
     'test-zzx-deprecated.R:221:3', 'test-zzx-deprecated.R:255:3',
     'test-zzx-deprecated.R:275:3', 'test-zzx-deprecated.R:291:3',
     'test-zzx-deprecated.R:326:3', 'test-zzx-deprecated.R:341:3',
     'test-zzx-deprecated.R:356:3', 'test-flatten.R:18:3', 'test-flatten.R:99:3',
     'test-dplyr.R:347:3', 'test-dplyr.R:506:3', 'test-dplyr.R:545:3',
     'test-dplyr.R:558:3', 'test-dplyr.R:569:3', 'test-dplyr.R:598:3',
     'test-dplyr.R:614:3', 'test-dplyr.R:806:3', 'test-draw-dm.R:17:3',
     'test-draw-dm.R:104:3', 'test-draw-dm.R:117:3', 'test-draw-dm.R:153:3',
     'test-draw-dm.R:182:3', 'test-bind.R:42:3', 'test-bind.R:97:3',
     'test-bind.R:107:3', 'test-bind.R:125:3', 'test-filter-dm.R:62:3',
     'test-filter-dm.R:173:3', 'test-filter-dm.R:182:3', 'test-filter-dm.R:191:3',
     'test-filter-dm.R:241:3', 'test-learn.R:446:3', 'test-add-tbl.R:92:3',
     'test-add-tbl.R:137:3', 'test-autoincrement.R:17:3',
     'test-autoincrement.R:26:3', 'test-rows-dm.R:2:3', 'test-rows-dm.R:28:3',
     'test-rows-dm.R:390:3', 'test-code-generation.R:7:3',
     'test-datamodelr-code.R:4:3', 'test-datamodelr-code.R:17:3',
     'test-datamodelr-code.R:37:3', 'test-datamodelr-code.R:57:3',
     'test-datamodelr-code.R:78:3', 'test-datamodelr-code.R:99:3',
     'test-datamodelr-code.R:120:3', 'test-datamodelr-code.R:133:3',
     'test-db-interface.R:35:3', 'test-check-cardinalities.R:30:3',
     'test-check-cardinalities.R:289:3', 'test-check-cardinalities.R:337:3',
     'test-check-cardinalities.R:422:3', 'test-disambiguate.R:2:3',
     'test-disentangle.R:2:3', 'test-dm.R:2:3', 'test-dm.R:70:3',
     'test-dm.R:108:3', 'test-dm.R:148:3', 'test-dm.R:194:3', 'test-dm.R:202:3',
     'test-dm.R:211:3', 'test-dm.R:217:3', 'test-dm.R:223:3', 'test-dm.R:311:3',
     'test-dm.R:508:3', 'test-dm.R:534:3', 'test-dm.R:564:3', 'test-dm.R:598:3',
     'test-dm_deconstruct.R:2:3', 'test-dm_deconstruct.R:9:3',
     'test-dm_nest_tbl.R:17:3', 'test-deconstruct.R:6:3',
     'test-deconstruct.R:16:3', 'test-deconstruct.R:26:3',
     'test-deconstruct.R:55:3', 'test-deconstruct.R:72:3',
     'test-deconstruct.R:120:3', 'test-deconstruct.R:144:3',
     'test-deconstruct.R:160:3', 'test-deconstruct.R:181:3',
     'test-deconstruct.R:198:3', 'test-deconstruct.R:222:3',
     'test-deconstruct.R:246:3', 'test-deconstruct.R:270:3',
     'test-deconstruct.R:294:3', 'test-deconstruct.R:320:3',
     'test-deconstruct.R:346:3', 'test-deconstruct.R:372:3',
     'test-deconstruct.R:398:3', 'test-deconstruct.R:420:3',
     'test-deconstruct.R:479:3', 'test-deconstruct.R:492:3',
     'test-deconstruct.R:507:3', 'test-deconstruct.R:525:3',
     'test-deconstruct.R:572:3', 'test-deconstruct.R:586:3',
     'test-deconstruct.R:599:3', 'test-dm_pixarfilms.R:2:3', 'test-duckdb.R:2:3',
     'test-enum-ops.R:11:3', 'test-enum-ops.R:30:3', 'test-enum-ops.R:103:3',
     'test-enum-ops.R:176:3', 'test-enumerate_all_paths.R:2:3',
     'test-error-helpers.R:2:3', 'test-dm_wrap.R:12:3', 'test-dm_wrap.R:79:3',
     'test-examine-cardinalities.R:2:3', 'test-examine-cardinalities.R:16:3',
     'test-examine-cardinalities.R:23:3', 'test-examine-constraints.R:68:3',
     'test-examine-constraints.R:77:3', 'test-examine-constraints.R:87:3',
     'test-examine-constraints.R:94:3', 'test-format.R:2:3', 'test-graph.R:29:3',
     'test-graph.R:38:3', 'test-json.R:5:3', 'test-json_nest.R:2:3',
     'test-json_pack.R:2:3', 'test-foreign-keys.R:16:3',
     'test-foreign-keys.R:145:3', 'test-foreign-keys.R:252:3',
     'test-foreign-keys.R:260:3', 'test-foreign-keys.R:287:3',
     'test-foreign-keys.R:306:3', 'test-maria.R:2:3', 'test-meta.R:3:3',
     'test-mssql.R:2:3', 'test-pack_join.R:5:3', 'test-paste.R:10:3',
     'test-paste.R:93:3', 'test-postgres.R:2:3', 'test-key-helpers.R:4:3',
     'test-key-helpers.R:327:3', 'test-key-helpers.R:333:3',
     'test-key-helpers.R:342:3', 'test-key-helpers.R:350:3',
     'test-select-tbl.R:30:3', 'test-select.R:2:3', 'test-select.R:10:3',
     'test-select.R:18:3', 'test-select.R:47:3', 'test-select.R:88:3',
     'test-sqlite.R:2:3', 'test-standalone-check_suggested.R:3:3',
     'test-standalone-check_suggested.R:17:3', 'test-primary-keys.R:25:3',
     'test-primary-keys.R:94:3', 'test-primary-keys.R:178:3',
     'test-primary-keys.R:198:3', 'test-primary-keys.R:217:3',
     'test-primary-keys.R:229:3', 'test-primary-keys.R:246:3',
     'test-primary-keys.R:253:3', 'test-tidyselect.R:25:3', 'test-tidyr.R:54:3',
     'test-tidyr.R:92:3', 'test-unique-keys.R:2:3', 'test-unique-keys.R:175:3',
     'test-upgrade.R:3:3', 'test-upgrade.R:15:3', 'test-upgrade.R:26:3',
     'test-upgrade.R:42:3', 'test-upgrade.R:53:3', 'test-upgrade.R:72:3',
     'test-upgrade.R:86:3', 'test-upgrade.R:102:3', 'test-upgrade.R:116:3',
     'test-waldo.R:8:3', 'test-zoom.R:30:3', 'test-zoom.R:133:3'
     • Slow test. To run, set CI=true (6): 'test-db-interface.R:7:3',
     'test-dplyr-src.R:49:3', 'test-examine-constraints.R:34:3',
     'test-examine-constraints.R:52:3', 'test-foreign-keys.R:180:3',
     'test-primary-keys.R:158:3'
     • `foo()` needs the "iurtnkjvmomweicopbt" package. (1):
     'test-standalone-check_suggested.R:30:3'
     • dm argument (1): 'test-select-tbl.R:71:3'
     • does not work on `df` (1): 'test-validate.R:201:3'
     • keyed = TRUE (1): 'test-deconstruct.R:91:3'
     • not testing deprecated cdm_nycflights13(): test too slow (1):
     'test-zzx-deprecated.R:266:3'
     • not testing deprecated learning from DB: test too slow (1):
     'test-zzx-deprecated.R:236:3'
     • only works on `db` (1): 'test-filter-dm.R:47:3'
     • only works on `duckdb` (2): 'test-duckdb.R:9:3', 'test-duckdb.R:32:3'
     • only works on `maria` (2): 'test-maria.R:9:3', 'test-maria.R:32:3'
     • only works on `mssql` (6): 'test-learn.R:206:3', 'test-learn.R:282:3',
     'test-db-helpers.R:2:3', 'test-mssql.R:9:3', 'test-mssql.R:32:3',
     'test-schema.R:129:3'
     • only works on `mssql`, `postgres` (4): 'test-db-interface.R:81:3',
     'test-db-interface.R:94:3', 'test-db-interface.R:125:3', 'test-schema.R:2:3'
     • only works on `mssql`, `postgres`, `maria` (4): 'test-learn.R:2:3',
     'test-learn.R:69:3', 'test-learn.R:366:3', 'test-meta.R:9:3'
     • only works on `postgres` (4): 'test-db-helpers.R:108:3',
     'test-postgres.R:9:3', 'test-postgres.R:32:3', 'test-schema.R:99:3'
     • only works on `postgres`, `mssql` (2): 'test-json_nest.R:14:3',
     'test-json_pack.R:13:3'
     • only works on `postgres`, `mssql`, `sqlite` (1): 'test-rows-dm.R:221:3'
     • only works on `postgres`, `sqlite`, `mssql`, `maria` (1):
     'test-db-interface.R:183:3'
     • only works on `sqlite` (3): 'test-schema.R:201:3', 'test-sqlite.R:9:3',
     'test-sqlite.R:32:3'
     
     ══ Failed tests ════════════════════════════════════════════════════════════════
     ── Error ('test-bind.R:51:3'): errors: src mismatches ──────────────────────────
     <dplyr:::mutate_error/rlang_error/error/condition>
     Error in `mutate(., name = child_table, index_name = map_chr(child_fk_cols, 
     paste, collapse = "_"), remote_name = purrr::map_chr(table_names[name], 
     ~DBI::dbQuoteIdentifier(con, .x)), remote_name_unquoted = map_chr(DBI::dbUnquoteIdentifier(con, 
     DBI::SQL(remote_name)), ~.x@name[["table"]]), index_name = make.unique(paste0(remote_name_unquoted, 
     "__", index_name), sep = "__"))`: i In argument: `remote_name_unquoted = map_chr(...)`.
     Caused by error in `map_chr()`:
     i In index: 1.
     Caused by error in `.x@name[["table"]]`:
     ! subscript out of bounds
     ── Error ('test-build_copy_queries.R:14:3'): build_copy_queries snapshot test for pixarfilms ──
     <dplyr:::mutate_error/rlang_error/error/condition>
     Error in `mutate(., name = child_table, index_name = map_chr(child_fk_cols, 
     paste, collapse = "_"), remote_name = purrr::map_chr(table_names[name], 
     ~DBI::dbQuoteIdentifier(con, .x)), remote_name_unquoted = map_chr(DBI::dbUnquoteIdentifier(con, 
     DBI::SQL(remote_name)), ~.x@name[["table"]]), index_name = make.unique(paste0(remote_name_unquoted, 
     "__", index_name), sep = "__"))`: i In argument: `remote_name_unquoted = map_chr(...)`.
     Caused by error in `map_chr()`:
     i In index: 1.
     Caused by error in `.x@name[["table"]]`:
     ! subscript out of bounds
     Backtrace:
     ▆
     1. └─testthat::expect_snapshot(...) at test-build_copy_queries.R:14:3
     2.   └─rlang::cnd_signal(state$error)
     ── Error ('test-build_copy_queries.R:33:3'): build_copy_queries snapshot test for dm_for_filter() ──
     <dplyr:::mutate_error/rlang_error/error/condition>
     Error in `mutate(., name = child_table, index_name = map_chr(child_fk_cols, 
     paste, collapse = "_"), remote_name = purrr::map_chr(table_names[name], 
     ~DBI::dbQuoteIdentifier(con, .x)), remote_name_unquoted = map_chr(DBI::dbUnquoteIdentifier(con, 
     DBI::SQL(remote_name)), ~.x@name[["table"]]), index_name = make.unique(paste0(remote_name_unquoted, 
     "__", index_name), sep = "__"))`: i In argument: `remote_name_unquoted = map_chr(...)`.
     Caused by error in `map_chr()`:
     i In index: 1.
     Caused by error in `.x@name[["table"]]`:
     ! subscript out of bounds
     Backtrace:
     ▆
     1. └─testthat::expect_snapshot(...) at test-build_copy_queries.R:33:3
     2.   └─rlang::cnd_signal(state$error)
     ── Error ('test-build_copy_queries.R:63:3'): build_copy_queries avoids duplicate indexes ──
     <dplyr:::mutate_error/rlang_error/error/condition>
     Error in `mutate(., name = child_table, index_name = map_chr(child_fk_cols, 
     paste, collapse = "_"), remote_name = purrr::map_chr(table_names[name], 
     ~DBI::dbQuoteIdentifier(con, .x)), remote_name_unquoted = map_chr(DBI::dbUnquoteIdentifier(con, 
     DBI::SQL(remote_name)), ~.x@name[["table"]]), index_name = make.unique(paste0(remote_name_unquoted, 
     "__", index_name), sep = "__"))`: i In argument: `remote_name_unquoted = map_chr(...)`.
     Caused by error in `map_chr()`:
     i In index: 1.
     Caused by error in `.x@name[["table"]]`:
     ! subscript out of bounds
     ── Error ('test-rows-dm.R:98:3'): dm_rows_update() ─────────────────────────────
     <dplyr:::mutate_error/rlang_error/error/condition>
     Error in `mutate(., name = child_table, index_name = map_chr(child_fk_cols, 
     paste, collapse = "_"), remote_name = purrr::map_chr(table_names[name], 
     ~DBI::dbQuoteIdentifier(con, .x)), remote_name_unquoted = map_chr(DBI::dbUnquoteIdentifier(con, 
     DBI::SQL(remote_name)), ~.x@name[["table"]]), index_name = make.unique(paste0(remote_name_unquoted, 
     "__", index_name), sep = "__"))`: i In argument: `remote_name_unquoted = map_chr(...)`.
     Caused by error in `map_chr()`:
     i In index: 1.
     Caused by error in `.x@name[["table"]]`:
     ! subscript out of bounds
     ── Error ('test-rows-dm.R:152:3'): dm_rows_truncate() ──────────────────────────
     <dplyr:::mutate_error/rlang_error/error/condition>
     Error in `mutate(., name = child_table, index_name = map_chr(child_fk_cols, 
     paste, collapse = "_"), remote_name = purrr::map_chr(table_names[name], 
     ~DBI::dbQuoteIdentifier(con, .x)), remote_name_unquoted = map_chr(DBI::dbUnquoteIdentifier(con, 
     DBI::SQL(remote_name)), ~.x@name[["table"]]), index_name = make.unique(paste0(remote_name_unquoted, 
     "__", index_name), sep = "__"))`: i In argument: `remote_name_unquoted = map_chr(...)`.
     Caused by error in `map_chr()`:
     i In index: 1.
     Caused by error in `.x@name[["table"]]`:
     ! subscript out of bounds
     ── Error ('test-dm.R:273:3'): 'compute.dm()' computes tables on DB ─────────────
     <dplyr:::mutate_error/rlang_error/error/condition>
     Error in `mutate(., name = child_table, index_name = map_chr(child_fk_cols, 
     paste, collapse = "_"), remote_name = purrr::map_chr(table_names[name], 
     ~DBI::dbQuoteIdentifier(con, .x)), remote_name_unquoted = map_chr(DBI::dbUnquoteIdentifier(con, 
     DBI::SQL(remote_name)), ~.x@name[["table"]]), index_name = make.unique(paste0(remote_name_unquoted, 
     "__", index_name), sep = "__"))`: i In argument: `remote_name_unquoted = map_chr(...)`.
     Caused by error in `map_chr()`:
     i In index: 1.
     Caused by error in `.x@name[["table"]]`:
     ! subscript out of bounds
     ── Error ('test-dm.R:286:3'): 'compute.dm_zoomed()' computes tables on DB ──────
     <dplyr:::mutate_error/rlang_error/error/condition>
     Error in `mutate(., name = child_table, index_name = map_chr(child_fk_cols, 
     paste, collapse = "_"), remote_name = purrr::map_chr(table_names[name], 
     ~DBI::dbQuoteIdentifier(con, .x)), remote_name_unquoted = map_chr(DBI::dbUnquoteIdentifier(con, 
     DBI::SQL(remote_name)), ~.x@name[["table"]]), index_name = make.unique(paste0(remote_name_unquoted, 
     "__", index_name), sep = "__"))`: i In argument: `remote_name_unquoted = map_chr(...)`.
     Caused by error in `map_chr()`:
     i In index: 1.
     Caused by error in `.x@name[["table"]]`:
     ! subscript out of bounds
     ── Error ('test-dm.R:487:3'): dm_get_con() works ───────────────────────────────
     <dplyr:::mutate_error/rlang_error/error/condition>
     Error in `mutate(., name = child_table, index_name = map_chr(child_fk_cols, 
     paste, collapse = "_"), remote_name = purrr::map_chr(table_names[name], 
     ~DBI::dbQuoteIdentifier(con, .x)), remote_name_unquoted = map_chr(DBI::dbUnquoteIdentifier(con, 
     DBI::SQL(remote_name)), ~.x@name[["table"]]), index_name = make.unique(paste0(remote_name_unquoted, 
     "__", index_name), sep = "__"))`: i In argument: `remote_name_unquoted = map_chr(...)`.
     Caused by error in `map_chr()`:
     i In index: 1.
     Caused by error in `.x@name[["table"]]`:
     ! subscript out of bounds
     ── Error ('test-dm_sql.R:4:3'): snapshot test ──────────────────────────────────
     <dplyr:::mutate_error/rlang_error/error/condition>
     Error in `mutate(., name = child_table, index_name = map_chr(child_fk_cols, 
     paste, collapse = "_"), remote_name = purrr::map_chr(table_names[name], 
     ~DBI::dbQuoteIdentifier(con, .x)), remote_name_unquoted = map_chr(DBI::dbUnquoteIdentifier(con, 
     DBI::SQL(remote_name)), ~.x@name[["table"]]), index_name = make.unique(paste0(remote_name_unquoted, 
     "__", index_name), sep = "__"))`: i In argument: `remote_name_unquoted = map_chr(...)`.
     Caused by error in `map_chr()`:
     i In index: 1.
     Caused by error in `.x@name[["table"]]`:
     ! subscript out of bounds
     Backtrace:
     ▆
     1. └─testthat::expect_snapshot(...) at test-dm_sql.R:4:3
     2.   └─rlang::cnd_signal(state$error)
     ── Error ('test-nest.R:41:3'): 'nest_join_dm_zoomed()' fails for DB-'dm' ───────
     <dplyr:::mutate_error/rlang_error/error/condition>
     Error in `mutate(., name = child_table, index_name = map_chr(child_fk_cols, 
     paste, collapse = "_"), remote_name = purrr::map_chr(table_names[name], 
     ~DBI::dbQuoteIdentifier(con, .x)), remote_name_unquoted = map_chr(DBI::dbUnquoteIdentifier(con, 
     DBI::SQL(remote_name)), ~.x@name[["table"]]), index_name = make.unique(paste0(remote_name_unquoted, 
     "__", index_name), sep = "__"))`: i In argument: `remote_name_unquoted = map_chr(...)`.
     Caused by error in `map_chr()`:
     i In index: 1.
     Caused by error in `.x@name[["table"]]`:
     ! subscript out of bounds
     ── Error ('test-pack_join.R:15:3'): `pack_join()` works with remote table ──────
     <dplyr:::mutate_error/rlang_error/error/condition>
     Error in `mutate(., name = child_table, index_name = map_chr(child_fk_cols, 
     paste, collapse = "_"), remote_name = purrr::map_chr(table_names[name], 
     ~DBI::dbQuoteIdentifier(con, .x)), remote_name_unquoted = map_chr(DBI::dbUnquoteIdentifier(con, 
     DBI::SQL(remote_name)), ~.x@name[["table"]]), index_name = make.unique(paste0(remote_name_unquoted, 
     "__", index_name), sep = "__"))`: i In argument: `remote_name_unquoted = map_chr(...)`.
     Caused by error in `map_chr()`:
     i In index: 1.
     Caused by error in `.x@name[["table"]]`:
     ! subscript out of bounds
     ── Error ('test-validate.R:190:3'): validator speaks up (sqlite()) ─────────────
     <dplyr:::mutate_error/rlang_error/error/condition>
     Error in `mutate(., data = if_else(table == "tf_1", list(dm_for_filter_duckdb()$tf_1), 
     data))`: i In argument: `data = if_else(table == "tf_1", list(dm_for_filter_duckdb()$tf_1), data)`.
     Caused by error in `mutate()`:
     i In argument: `remote_name_unquoted = map_chr(...)`.
     Caused by error in `map_chr()`:
     i In index: 1.
     Caused by error in `.x@name[["table"]]`:
     ! subscript out of bounds
     Backtrace:
     ▆
     1. ├─dm:::expect_dm_error(...) at test-validate.R:190:3
     2. │ └─testthat::expect_error(expr, class = dm_error(class)) at tests/testthat/helper-expectations.R:48:3
     3. │   └─testthat:::expect_condition_matching(...)
     4. │     └─testthat:::quasi_capture(...)
     5. │       ├─testthat (local) .capture(...)
     6. │       │ └─base::withCallingHandlers(...)
     7. │       └─rlang::eval_bare(quo_get_expr(.quo), quo_get_env(.quo))
     8. ├─... %>% dm_validate()
     9. ├─dm::dm_validate(.)
     10. │ └─dm:::check_dm(x)
     11. │   └─dm::is_dm(x)
     12. ├─dm:::dm_from_def(.)
     13. ├─dplyr::mutate(...)
     14. ├─dplyr:::mutate.data.frame(...)
     15. │ └─dplyr:::mutate_cols(.data, dplyr_quosures(...), by)
     16. │   ├─base::withCallingHandlers(...)
     17. │   └─dplyr:::mutate_col(dots[[i]], data, mask, new_columns)
     18. │     └─mask$eval_all_mutate(quo)
     19. │       └─dplyr (local) eval()
     20. ├─dplyr::if_else(...)
     21. ├─dm:::dm_for_filter_duckdb()
     22. ├─dm::copy_dm_to(duckdb_test_src(), dm_for_filter()) at tests/testthat/helper-src.R:26:7
     23. │ └─dm:::build_copy_queries(...)
     24. │   └─... %>% ...
     25. ├─dplyr::summarize(...)
     26. ├─dplyr::group_by(., name)
     27. ├─dplyr::mutate(...)
     28. ├─dplyr:::mutate.data.frame(...)
     29. │ └─dplyr:::mutate_cols(.data, dplyr_quosures(...), by)
     30. │   ├─base::withCallingHandlers(...)
     31. │   └─dplyr:::mutate_col(dots[[i]], data, mask, new_columns)
     32. │     └─mask$eval_all_mutate(quo)
     33. │       └─dplyr (local) eval()
     34. ├─purrr::map_chr(...)
     35. │ └─purrr:::map_("character", .x, .f, ..., .progress = .progress)
     36. │   ├─purrr:::with_indexed_errors(...)
     37. │   │ └─base::withCallingHandlers(...)
     38. │   ├─purrr:::call_with_cleanup(...)
     39. │   └─dm (local) .f(.x[[i]], ...)
     40. ├─purrr (local) `<fn>`(`<sbscOOBE>`)
     41. │ └─cli::cli_abort(...)
     42. │   └─rlang::abort(...)
     43. │     └─rlang:::signal_abort(cnd, .file)
     44. │       └─base::signalCondition(cnd)
     45. ├─dplyr (local) `<fn>`(`<prrr_rr_>`)
     46. │ └─rlang::abort(message, class = error_class, parent = parent, call = error_call)
     47. │   └─rlang:::signal_abort(cnd, .file)
     48. │     └─base::signalCondition(cnd)
     49. └─dplyr (local) `<fn>`(`<dply:::_>`)
     50.   └─rlang::abort(message, class = error_class, parent = parent, call = error_call)
     ── Error ('test_dm_from_con.R:23:3'): table identifiers are quoted ─────────────
     <purrr_error_indexed/rlang_error/error/condition>
     Error in `map(DBI::dbUnquoteIdentifier(con_db, DBI::SQL(remote_tbl_names_copied)), 
     ~.x@name[["table"]])`: i In index: 1.
     Caused by error in `.x@name[["table"]]`:
     ! subscript out of bounds
     Backtrace:
     ▆
     1. ├─... %>% ... at test_dm_from_con.R:23:3
     2. ├─dm::dm_select_tbl(...)
     3. │ └─dm:::eval_select_table(quo(c(...)), src_tbls_impl(dm))
     4. │   └─dm:::eval_select_table_indices(quo, table_names, unique = unique)
     5. │     ├─base::withCallingHandlers(...)
     6. │     └─dm:::eval_select_indices(quo, table_names, unique = unique)
     7. │       └─tidyselect::eval_select(quo, set_names(names))
     8. │         └─tidyselect:::eval_select_impl(...)
     9. │           ├─tidyselect:::with_subscript_errors(...)
     10. │           │ └─rlang::try_fetch(...)
     11. │           │   └─base::withCallingHandlers(...)
     12. │           └─tidyselect:::vars_select_eval(...)
     13. │             └─tidyselect:::walk_data_tree(expr, data_mask, context_mask)
     14. │               └─tidyselect:::eval_c(expr, data_mask, context_mask)
     15. │                 └─tidyselect:::call_expand_dots(expr, context_mask$.__current__.)
     16. │                   └─rlang::eval_bare(quote(enquos(...)), dots_mask)
     17. ├─rlang::enquos(...)
     18. │ └─rlang:::endots(...)
     19. │   └─rlang:::map(...)
     20. │     └─base::lapply(.x, .f, ...)
     21. │       └─rlang (local) FUN(X[[i]], ...)
     22. ├─purrr::map(...)
     23. │ └─purrr:::map_("list", .x, .f, ..., .progress = .progress)
     24. │   ├─purrr:::with_indexed_errors(...)
     25. │   │ └─base::withCallingHandlers(...)
     26. │   ├─purrr:::call_with_cleanup(...)
     27. │   └─dm (local) .f(.x[[i]], ...)
     28. └─purrr (local) `<fn>`(`<sbscOOBE>`)
     29.   └─cli::cli_abort(...)
     30.     └─rlang::abort(...)
     
     [ FAIL 14 | WARN 8 | SKIP 235 | PASS 1347 ]
     Deleting unused snapshots:
     • datamodelr-code/nycflights13.dot
     • datamodelr-code/nycflights13_draw_uk_1.dot
     • datamodelr-code/nycflights13_draw_uk_2.dot
     • datamodelr-code/nycflights13_draw_uk_3.dot
     • datamodelr-code/nycflights13_table_desc_1.dot
     • datamodelr-code/nycflights13_table_desc_2.dot
     • datamodelr-code/weird.dot
     • draw-dm/empty-table-in-dm.svg
     • draw-dm/nycflight-dm-types.svg
     • draw-dm/nycflight-dm.svg
     • draw-dm/single-empty-table-dm.svg
     • draw-dm/table-desc-1-dm.svg
     • draw-dm/table-desc-2-dm.svg
     • draw-dm/table-desc-3-dm.svg
     • draw-dm/table-desc-4-dm.svg
     • draw-dm/table-uk-1-dm.svg
     • draw-dm/table-uk-2-dm.svg
     Error: Test failures
     Execution halted
- [ ] ERROR: r-release-windows-x86_64
     Running 'testthat.R' [92s]
     Running the tests in 'tests/testthat.R' failed.
     Complete output:
     > library(testthat)
     > 
     > # Need to use qualified call, this is checked in helper-print.R
     > testthat::test_check("dm")
     Loading required package: dm
     
     Attaching package: 'dm'
     
     The following object is masked from 'package:stats':
     
     filter
     
     Starting 2 test processes
     [ FAIL 14 | WARN 6 | SKIP 235 | PASS 1347 ]
     
     ══ Skipped tests (235) ═════════════════════════════════════════════════════════
     • COMPOUND (1): 'test-rows-dm.R:203:3'
     • Dependent on database version, find better way to record this info (1):
     'test-meta.R:19:3'
     • FIXME (2): 'test-learn.R:154:3', 'test-nest.R:2:3'
     • FIXME: Unstable on GHA? (1): 'test-dm.R:495:3'
     • Need to think about it (1): 'test-key-helpers.R:45:3'
     • On CRAN (187): 'test-zzx-deprecated.R:2:3', 'test-zzx-deprecated.R:15:3',
     'test-zzx-deprecated.R:25:3', 'test-zzx-deprecated.R:35:3',
     'test-zzx-deprecated.R:45:3', 'test-zzx-deprecated.R:58:3',
     'test-zzx-deprecated.R:81:3', 'test-zzx-deprecated.R:91:3',
     'test-zzx-deprecated.R:106:3', 'test-zzx-deprecated.R:121:3',
     'test-zzx-deprecated.R:141:3', 'test-zzx-deprecated.R:151:3',
     'test-zzx-deprecated.R:166:3', 'test-zzx-deprecated.R:185:3',
     'test-zzx-deprecated.R:221:3', 'test-zzx-deprecated.R:255:3',
     'test-zzx-deprecated.R:275:3', 'test-zzx-deprecated.R:291:3',
     'test-zzx-deprecated.R:326:3', 'test-zzx-deprecated.R:341:3',
     'test-zzx-deprecated.R:356:3', 'test-flatten.R:18:3', 'test-flatten.R:99:3',
     'test-dplyr.R:347:3', 'test-dplyr.R:506:3', 'test-dplyr.R:545:3',
     'test-dplyr.R:558:3', 'test-dplyr.R:569:3', 'test-dplyr.R:598:3',
     'test-dplyr.R:614:3', 'test-dplyr.R:806:3', 'test-draw-dm.R:17:3',
     'test-draw-dm.R:104:3', 'test-draw-dm.R:117:3', 'test-draw-dm.R:153:3',
     'test-draw-dm.R:182:3', 'test-filter-dm.R:62:3', 'test-filter-dm.R:173:3',
     'test-filter-dm.R:182:3', 'test-filter-dm.R:191:3', 'test-filter-dm.R:241:3',
     'test-bind.R:42:3', 'test-bind.R:97:3', 'test-bind.R:107:3',
     'test-bind.R:125:3', 'test-learn.R:446:3', 'test-add-tbl.R:92:3',
     'test-add-tbl.R:137:3', 'test-autoincrement.R:17:3',
     'test-autoincrement.R:26:3', 'test-rows-dm.R:2:3', 'test-rows-dm.R:28:3',
     'test-rows-dm.R:390:3', 'test-code-generation.R:7:3',
     'test-datamodelr-code.R:4:3', 'test-datamodelr-code.R:17:3',
     'test-datamodelr-code.R:37:3', 'test-datamodelr-code.R:57:3',
     'test-datamodelr-code.R:78:3', 'test-datamodelr-code.R:99:3',
     'test-datamodelr-code.R:120:3', 'test-datamodelr-code.R:133:3',
     'test-db-interface.R:35:3', 'test-check-cardinalities.R:30:3',
     'test-check-cardinalities.R:289:3', 'test-check-cardinalities.R:337:3',
     'test-check-cardinalities.R:422:3', 'test-disambiguate.R:2:3',
     'test-disentangle.R:2:3', 'test-deconstruct.R:6:3',
     'test-deconstruct.R:16:3', 'test-deconstruct.R:26:3',
     'test-deconstruct.R:55:3', 'test-deconstruct.R:72:3',
     'test-deconstruct.R:120:3', 'test-deconstruct.R:144:3',
     'test-deconstruct.R:160:3', 'test-deconstruct.R:181:3',
     'test-deconstruct.R:198:3', 'test-deconstruct.R:222:3',
     'test-deconstruct.R:246:3', 'test-deconstruct.R:270:3',
     'test-deconstruct.R:294:3', 'test-deconstruct.R:320:3',
     'test-deconstruct.R:346:3', 'test-deconstruct.R:372:3',
     'test-deconstruct.R:398:3', 'test-deconstruct.R:420:3',
     'test-deconstruct.R:479:3', 'test-deconstruct.R:492:3',
     'test-deconstruct.R:507:3', 'test-deconstruct.R:525:3',
     'test-deconstruct.R:572:3', 'test-deconstruct.R:586:3',
     'test-deconstruct.R:599:3', 'test-dm.R:2:3', 'test-dm.R:70:3',
     'test-dm.R:108:3', 'test-dm.R:148:3', 'test-dm.R:194:3', 'test-dm.R:202:3',
     'test-dm.R:211:3', 'test-dm.R:217:3', 'test-dm.R:223:3', 'test-dm.R:311:3',
     'test-dm.R:508:3', 'test-dm.R:534:3', 'test-dm.R:564:3', 'test-dm.R:598:3',
     'test-dm_deconstruct.R:2:3', 'test-dm_deconstruct.R:9:3',
     'test-dm_pixarfilms.R:2:3', 'test-dm_nest_tbl.R:17:3', 'test-duckdb.R:2:3',
     'test-enum-ops.R:11:3', 'test-enum-ops.R:30:3', 'test-enum-ops.R:103:3',
     'test-enum-ops.R:176:3', 'test-enumerate_all_paths.R:2:3',
     'test-error-helpers.R:2:3', 'test-dm_wrap.R:12:3', 'test-dm_wrap.R:79:3',
     'test-examine-cardinalities.R:2:3', 'test-examine-cardinalities.R:16:3',
     'test-examine-cardinalities.R:23:3', 'test-examine-constraints.R:68:3',
     'test-examine-constraints.R:77:3', 'test-examine-constraints.R:87:3',
     'test-examine-constraints.R:94:3', 'test-format.R:2:3', 'test-graph.R:29:3',
     'test-graph.R:38:3', 'test-json.R:5:3', 'test-json_nest.R:2:3',
     'test-json_pack.R:2:3', 'test-foreign-keys.R:16:3',
     'test-foreign-keys.R:145:3', 'test-foreign-keys.R:252:3',
     'test-foreign-keys.R:260:3', 'test-foreign-keys.R:287:3',
     'test-foreign-keys.R:306:3', 'test-maria.R:2:3', 'test-meta.R:3:3',
     'test-mssql.R:2:3', 'test-pack_join.R:5:3', 'test-paste.R:10:3',
     'test-paste.R:93:3', 'test-postgres.R:2:3', 'test-key-helpers.R:4:3',
     'test-key-helpers.R:327:3', 'test-key-helpers.R:333:3',
     'test-key-helpers.R:342:3', 'test-key-helpers.R:350:3',
     'test-select-tbl.R:30:3', 'test-select.R:2:3', 'test-select.R:10:3',
     'test-select.R:18:3', 'test-select.R:47:3', 'test-select.R:88:3',
     'test-sqlite.R:2:3', 'test-standalone-check_suggested.R:3:3',
     'test-standalone-check_suggested.R:17:3', 'test-primary-keys.R:25:3',
     'test-primary-keys.R:94:3', 'test-primary-keys.R:178:3',
     'test-primary-keys.R:198:3', 'test-primary-keys.R:217:3',
     'test-primary-keys.R:229:3', 'test-primary-keys.R:246:3',
     'test-primary-keys.R:253:3', 'test-tidyselect.R:25:3', 'test-tidyr.R:54:3',
     'test-tidyr.R:92:3', 'test-unique-keys.R:2:3', 'test-unique-keys.R:175:3',
     'test-upgrade.R:3:3', 'test-upgrade.R:15:3', 'test-upgrade.R:26:3',
     'test-upgrade.R:42:3', 'test-upgrade.R:53:3', 'test-upgrade.R:72:3',
     'test-upgrade.R:86:3', 'test-upgrade.R:102:3', 'test-upgrade.R:116:3',
     'test-waldo.R:8:3', 'test-zoom.R:30:3', 'test-zoom.R:133:3'
     • Slow test. To run, set CI=true (6): 'test-db-interface.R:7:3',
     'test-dplyr-src.R:49:3', 'test-examine-constraints.R:34:3',
     'test-examine-constraints.R:52:3', 'test-foreign-keys.R:180:3',
     'test-primary-keys.R:158:3'
     • `foo()` needs the "iurtnkjvmomweicopbt" package. (1):
     'test-standalone-check_suggested.R:30:3'
     • dm argument (1): 'test-select-tbl.R:71:3'
     • does not work on `df` (1): 'test-validate.R:201:3'
     • keyed = TRUE (1): 'test-deconstruct.R:91:3'
     • not testing deprecated cdm_nycflights13(): test too slow (1):
     'test-zzx-deprecated.R:266:3'
     • not testing deprecated learning from DB: test too slow (1):
     'test-zzx-deprecated.R:236:3'
     • only works on `db` (1): 'test-filter-dm.R:47:3'
     • only works on `duckdb` (2): 'test-duckdb.R:9:3', 'test-duckdb.R:32:3'
     • only works on `maria` (2): 'test-maria.R:9:3', 'test-maria.R:32:3'
     • only works on `mssql` (6): 'test-learn.R:206:3', 'test-learn.R:282:3',
     'test-db-helpers.R:2:3', 'test-mssql.R:9:3', 'test-mssql.R:32:3',
     'test-schema.R:129:3'
     • only works on `mssql`, `postgres` (4): 'test-db-interface.R:81:3',
     'test-db-interface.R:94:3', 'test-db-interface.R:125:3', 'test-schema.R:2:3'
     • only works on `mssql`, `postgres`, `maria` (4): 'test-learn.R:2:3',
     'test-learn.R:69:3', 'test-learn.R:366:3', 'test-meta.R:9:3'
     • only works on `postgres` (4): 'test-db-helpers.R:108:3',
     'test-postgres.R:9:3', 'test-postgres.R:32:3', 'test-schema.R:99:3'
     • only works on `postgres`, `mssql` (2): 'test-json_nest.R:14:3',
     'test-json_pack.R:13:3'
     • only works on `postgres`, `mssql`, `sqlite` (1): 'test-rows-dm.R:221:3'
     • only works on `postgres`, `sqlite`, `mssql`, `maria` (1):
     'test-db-interface.R:183:3'
     • only works on `sqlite` (3): 'test-schema.R:201:3', 'test-sqlite.R:9:3',
     'test-sqlite.R:32:3'
     
     ══ Failed tests ════════════════════════════════════════════════════════════════
     ── Error ('test-bind.R:51:3'): errors: src mismatches ──────────────────────────
     <dplyr:::mutate_error/rlang_error/error/condition>
     Error in `mutate(., name = child_table, index_name = map_chr(child_fk_cols, 
     paste, collapse = "_"), remote_name = purrr::map_chr(table_names[name], 
     ~DBI::dbQuoteIdentifier(con, .x)), remote_name_unquoted = map_chr(DBI::dbUnquoteIdentifier(con, 
     DBI::SQL(remote_name)), ~.x@name[["table"]]), index_name = make.unique(paste0(remote_name_unquoted, 
     "__", index_name), sep = "__"))`: i In argument: `remote_name_unquoted = map_chr(...)`.
     Caused by error in `map_chr()`:
     i In index: 1.
     Caused by error in `.x@name[["table"]]`:
     ! subscript out of bounds
     ── Error ('test-build_copy_queries.R:14:3'): build_copy_queries snapshot test for pixarfilms ──
     <dplyr:::mutate_error/rlang_error/error/condition>
     Error in `mutate(., name = child_table, index_name = map_chr(child_fk_cols, 
     paste, collapse = "_"), remote_name = purrr::map_chr(table_names[name], 
     ~DBI::dbQuoteIdentifier(con, .x)), remote_name_unquoted = map_chr(DBI::dbUnquoteIdentifier(con, 
     DBI::SQL(remote_name)), ~.x@name[["table"]]), index_name = make.unique(paste0(remote_name_unquoted, 
     "__", index_name), sep = "__"))`: i In argument: `remote_name_unquoted = map_chr(...)`.
     Caused by error in `map_chr()`:
     i In index: 1.
     Caused by error in `.x@name[["table"]]`:
     ! subscript out of bounds
     Backtrace:
     ▆
     1. └─testthat::expect_snapshot(...) at test-build_copy_queries.R:14:3
     2.   └─rlang::cnd_signal(state$error)
     ── Error ('test-build_copy_queries.R:33:3'): build_copy_queries snapshot test for dm_for_filter() ──
     <dplyr:::mutate_error/rlang_error/error/condition>
     Error in `mutate(., name = child_table, index_name = map_chr(child_fk_cols, 
     paste, collapse = "_"), remote_name = purrr::map_chr(table_names[name], 
     ~DBI::dbQuoteIdentifier(con, .x)), remote_name_unquoted = map_chr(DBI::dbUnquoteIdentifier(con, 
     DBI::SQL(remote_name)), ~.x@name[["table"]]), index_name = make.unique(paste0(remote_name_unquoted, 
     "__", index_name), sep = "__"))`: i In argument: `remote_name_unquoted = map_chr(...)`.
     Caused by error in `map_chr()`:
     i In index: 1.
     Caused by error in `.x@name[["table"]]`:
     ! subscript out of bounds
     Backtrace:
     ▆
     1. └─testthat::expect_snapshot(...) at test-build_copy_queries.R:33:3
     2.   └─rlang::cnd_signal(state$error)
     ── Error ('test-build_copy_queries.R:63:3'): build_copy_queries avoids duplicate indexes ──
     <dplyr:::mutate_error/rlang_error/error/condition>
     Error in `mutate(., name = child_table, index_name = map_chr(child_fk_cols, 
     paste, collapse = "_"), remote_name = purrr::map_chr(table_names[name], 
     ~DBI::dbQuoteIdentifier(con, .x)), remote_name_unquoted = map_chr(DBI::dbUnquoteIdentifier(con, 
     DBI::SQL(remote_name)), ~.x@name[["table"]]), index_name = make.unique(paste0(remote_name_unquoted, 
     "__", index_name), sep = "__"))`: i In argument: `remote_name_unquoted = map_chr(...)`.
     Caused by error in `map_chr()`:
     i In index: 1.
     Caused by error in `.x@name[["table"]]`:
     ! subscript out of bounds
     ── Error ('test-rows-dm.R:98:3'): dm_rows_update() ─────────────────────────────
     <dplyr:::mutate_error/rlang_error/error/condition>
     Error in `mutate(., name = child_table, index_name = map_chr(child_fk_cols, 
     paste, collapse = "_"), remote_name = purrr::map_chr(table_names[name], 
     ~DBI::dbQuoteIdentifier(con, .x)), remote_name_unquoted = map_chr(DBI::dbUnquoteIdentifier(con, 
     DBI::SQL(remote_name)), ~.x@name[["table"]]), index_name = make.unique(paste0(remote_name_unquoted, 
     "__", index_name), sep = "__"))`: i In argument: `remote_name_unquoted = map_chr(...)`.
     Caused by error in `map_chr()`:
     i In index: 1.
     Caused by error in `.x@name[["table"]]`:
     ! subscript out of bounds
     ── Error ('test-rows-dm.R:152:3'): dm_rows_truncate() ──────────────────────────
     <dplyr:::mutate_error/rlang_error/error/condition>
     Error in `mutate(., name = child_table, index_name = map_chr(child_fk_cols, 
     paste, collapse = "_"), remote_name = purrr::map_chr(table_names[name], 
     ~DBI::dbQuoteIdentifier(con, .x)), remote_name_unquoted = map_chr(DBI::dbUnquoteIdentifier(con, 
     DBI::SQL(remote_name)), ~.x@name[["table"]]), index_name = make.unique(paste0(remote_name_unquoted, 
     "__", index_name), sep = "__"))`: i In argument: `remote_name_unquoted = map_chr(...)`.
     Caused by error in `map_chr()`:
     i In index: 1.
     Caused by error in `.x@name[["table"]]`:
     ! subscript out of bounds
     ── Error ('test-dm.R:273:3'): 'compute.dm()' computes tables on DB ─────────────
     <dplyr:::mutate_error/rlang_error/error/condition>
     Error in `mutate(., name = child_table, index_name = map_chr(child_fk_cols, 
     paste, collapse = "_"), remote_name = purrr::map_chr(table_names[name], 
     ~DBI::dbQuoteIdentifier(con, .x)), remote_name_unquoted = map_chr(DBI::dbUnquoteIdentifier(con, 
     DBI::SQL(remote_name)), ~.x@name[["table"]]), index_name = make.unique(paste0(remote_name_unquoted, 
     "__", index_name), sep = "__"))`: i In argument: `remote_name_unquoted = map_chr(...)`.
     Caused by error in `map_chr()`:
     i In index: 1.
     Caused by error in `.x@name[["table"]]`:
     ! subscript out of bounds
     ── Error ('test-dm.R:286:3'): 'compute.dm_zoomed()' computes tables on DB ──────
     <dplyr:::mutate_error/rlang_error/error/condition>
     Error in `mutate(., name = child_table, index_name = map_chr(child_fk_cols, 
     paste, collapse = "_"), remote_name = purrr::map_chr(table_names[name], 
     ~DBI::dbQuoteIdentifier(con, .x)), remote_name_unquoted = map_chr(DBI::dbUnquoteIdentifier(con, 
     DBI::SQL(remote_name)), ~.x@name[["table"]]), index_name = make.unique(paste0(remote_name_unquoted, 
     "__", index_name), sep = "__"))`: i In argument: `remote_name_unquoted = map_chr(...)`.
     Caused by error in `map_chr()`:
     i In index: 1.
     Caused by error in `.x@name[["table"]]`:
     ! subscript out of bounds
     ── Error ('test-dm.R:487:3'): dm_get_con() works ───────────────────────────────
     <dplyr:::mutate_error/rlang_error/error/condition>
     Error in `mutate(., name = child_table, index_name = map_chr(child_fk_cols, 
     paste, collapse = "_"), remote_name = purrr::map_chr(table_names[name], 
     ~DBI::dbQuoteIdentifier(con, .x)), remote_name_unquoted = map_chr(DBI::dbUnquoteIdentifier(con, 
     DBI::SQL(remote_name)), ~.x@name[["table"]]), index_name = make.unique(paste0(remote_name_unquoted, 
     "__", index_name), sep = "__"))`: i In argument: `remote_name_unquoted = map_chr(...)`.
     Caused by error in `map_chr()`:
     i In index: 1.
     Caused by error in `.x@name[["table"]]`:
     ! subscript out of bounds
     ── Error ('test-dm_sql.R:4:3'): snapshot test ──────────────────────────────────
     <dplyr:::mutate_error/rlang_error/error/condition>
     Error in `mutate(., name = child_table, index_name = map_chr(child_fk_cols, 
     paste, collapse = "_"), remote_name = purrr::map_chr(table_names[name], 
     ~DBI::dbQuoteIdentifier(con, .x)), remote_name_unquoted = map_chr(DBI::dbUnquoteIdentifier(con, 
     DBI::SQL(remote_name)), ~.x@name[["table"]]), index_name = make.unique(paste0(remote_name_unquoted, 
     "__", index_name), sep = "__"))`: i In argument: `remote_name_unquoted = map_chr(...)`.
     Caused by error in `map_chr()`:
     i In index: 1.
     Caused by error in `.x@name[["table"]]`:
     ! subscript out of bounds
     Backtrace:
     ▆
     1. └─testthat::expect_snapshot(...) at test-dm_sql.R:4:3
     2.   └─rlang::cnd_signal(state$error)
     ── Error ('test-nest.R:41:3'): 'nest_join_dm_zoomed()' fails for DB-'dm' ───────
     <dplyr:::mutate_error/rlang_error/error/condition>
     Error in `mutate(., name = child_table, index_name = map_chr(child_fk_cols, 
     paste, collapse = "_"), remote_name = purrr::map_chr(table_names[name], 
     ~DBI::dbQuoteIdentifier(con, .x)), remote_name_unquoted = map_chr(DBI::dbUnquoteIdentifier(con, 
     DBI::SQL(remote_name)), ~.x@name[["table"]]), index_name = make.unique(paste0(remote_name_unquoted, 
     "__", index_name), sep = "__"))`: i In argument: `remote_name_unquoted = map_chr(...)`.
     Caused by error in `map_chr()`:
     i In index: 1.
     Caused by error in `.x@name[["table"]]`:
     ! subscript out of bounds
     ── Error ('test-pack_join.R:15:3'): `pack_join()` works with remote table ──────
     <dplyr:::mutate_error/rlang_error/error/condition>
     Error in `mutate(., name = child_table, index_name = map_chr(child_fk_cols, 
     paste, collapse = "_"), remote_name = purrr::map_chr(table_names[name], 
     ~DBI::dbQuoteIdentifier(con, .x)), remote_name_unquoted = map_chr(DBI::dbUnquoteIdentifier(con, 
     DBI::SQL(remote_name)), ~.x@name[["table"]]), index_name = make.unique(paste0(remote_name_unquoted, 
     "__", index_name), sep = "__"))`: i In argument: `remote_name_unquoted = map_chr(...)`.
     Caused by error in `map_chr()`:
     i In index: 1.
     Caused by error in `.x@name[["table"]]`:
     ! subscript out of bounds
     ── Error ('test-validate.R:190:3'): validator speaks up (sqlite()) ─────────────
     <dplyr:::mutate_error/rlang_error/error/condition>
     Error in `mutate(., data = if_else(table == "tf_1", list(dm_for_filter_duckdb()$tf_1), 
     data))`: i In argument: `data = if_else(table == "tf_1", list(dm_for_filter_duckdb()$tf_1), data)`.
     Caused by error in `mutate()`:
     i In argument: `remote_name_unquoted = map_chr(...)`.
     Caused by error in `map_chr()`:
     i In index: 1.
     Caused by error in `.x@name[["table"]]`:
     ! subscript out of bounds
     Backtrace:
     ▆
     1. ├─dm:::expect_dm_error(...) at test-validate.R:190:3
     2. │ └─testthat::expect_error(expr, class = dm_error(class)) at D:\RCompile\CRANpkg\local\4.3\dm.Rcheck\tests\testthat\helper-expectations.R:48:3
     3. │   └─testthat:::expect_condition_matching(...)
     4. │     └─testthat:::quasi_capture(...)
     5. │       ├─testthat (local) .capture(...)
     6. │       │ └─base::withCallingHandlers(...)
     7. │       └─rlang::eval_bare(quo_get_expr(.quo), quo_get_env(.quo))
     8. ├─... %>% dm_validate()
     9. ├─dm::dm_validate(.)
     10. │ └─dm:::check_dm(x)
     11. │   └─dm::is_dm(x)
     12. ├─dm:::dm_from_def(.)
     13. ├─dplyr::mutate(...)
     14. ├─dplyr:::mutate.data.frame(...)
     15. │ └─dplyr:::mutate_cols(.data, dplyr_quosures(...), by)
     16. │   ├─base::withCallingHandlers(...)
     17. │   └─dplyr:::mutate_col(dots[[i]], data, mask, new_columns)
     18. │     └─mask$eval_all_mutate(quo)
     19. │       └─dplyr (local) eval()
     20. ├─dplyr::if_else(...)
     21. ├─dm:::dm_for_filter_duckdb()
     22. ├─dm::copy_dm_to(duckdb_test_src(), dm_for_filter()) at D:\RCompile\CRANpkg\local\4.3\dm.Rcheck\tests\testthat\helper-src.R:26:7
     23. │ └─dm:::build_copy_queries(...)
     24. │   └─... %>% ...
     25. ├─dplyr::summarize(...)
     26. ├─dplyr::group_by(., name)
     27. ├─dplyr::mutate(...)
     28. ├─dplyr:::mutate.data.frame(...)
     29. │ └─dplyr:::mutate_cols(.data, dplyr_quosures(...), by)
     30. │   ├─base::withCallingHandlers(...)
     31. │   └─dplyr:::mutate_col(dots[[i]], data, mask, new_columns)
     32. │     └─mask$eval_all_mutate(quo)
     33. │       └─dplyr (local) eval()
     34. ├─purrr::map_chr(...)
     35. │ └─purrr:::map_("character", .x, .f, ..., .progress = .progress)
     36. │   ├─purrr:::with_indexed_errors(...)
     37. │   │ └─base::withCallingHandlers(...)
     38. │   ├─purrr:::call_with_cleanup(...)
     39. │   └─dm (local) .f(.x[[i]], ...)
     40. ├─purrr (local) `<fn>`(`<sbscOOBE>`)
     41. │ └─cli::cli_abort(...)
     42. │   └─rlang::abort(...)
     43. │     └─rlang:::signal_abort(cnd, .file)
     44. │       └─base::signalCondition(cnd)
     45. ├─dplyr (local) `<fn>`(`<prrr_rr_>`)
     46. │ └─rlang::abort(message, class = error_class, parent = parent, call = error_call)
     47. │   └─rlang:::signal_abort(cnd, .file)
     48. │     └─base::signalCondition(cnd)
     49. └─dplyr (local) `<fn>`(`<dply:::_>`)
     50.   └─rlang::abort(message, class = error_class, parent = parent, call = error_call)
     ── Error ('test_dm_from_con.R:23:3'): table identifiers are quoted ─────────────
     <purrr_error_indexed/rlang_error/error/condition>
     Error in `map(DBI::dbUnquoteIdentifier(con_db, DBI::SQL(remote_tbl_names_copied)), 
     ~.x@name[["table"]])`: i In index: 1.
     Caused by error in `.x@name[["table"]]`:
     ! subscript out of bounds
     Backtrace:
     ▆
     1. ├─... %>% ... at test_dm_from_con.R:23:3
     2. ├─dm::dm_select_tbl(...)
     3. │ └─dm:::eval_select_table(quo(c(...)), src_tbls_impl(dm))
     4. │   └─dm:::eval_select_table_indices(quo, table_names, unique = unique)
     5. │     ├─base::withCallingHandlers(...)
     6. │     └─dm:::eval_select_indices(quo, table_names, unique = unique)
     7. │       └─tidyselect::eval_select(quo, set_names(names))
     8. │         └─tidyselect:::eval_select_impl(...)
     9. │           ├─tidyselect:::with_subscript_errors(...)
     10. │           │ └─rlang::try_fetch(...)
     11. │           │   └─base::withCallingHandlers(...)
     12. │           └─tidyselect:::vars_select_eval(...)
     13. │             └─tidyselect:::walk_data_tree(expr, data_mask, context_mask)
     14. │               └─tidyselect:::eval_c(expr, data_mask, context_mask)
     15. │                 └─tidyselect:::call_expand_dots(expr, context_mask$.__current__.)
     16. │                   └─rlang::eval_bare(quote(enquos(...)), dots_mask)
     17. ├─rlang::enquos(...)
     18. │ └─rlang:::endots(...)
     19. │   └─rlang:::map(...)
     20. │     └─base::lapply(.x, .f, ...)
     21. │       └─rlang (local) FUN(X[[i]], ...)
     22. ├─purrr::map(...)
     23. │ └─purrr:::map_("list", .x, .f, ..., .progress = .progress)
     24. │   ├─purrr:::with_indexed_errors(...)
     25. │   │ └─base::withCallingHandlers(...)
     26. │   ├─purrr:::call_with_cleanup(...)
     27. │   └─dm (local) .f(.x[[i]], ...)
     28. └─purrr (local) `<fn>`(`<sbscOOBE>`)
     29.   └─cli::cli_abort(...)
     30.     └─rlang::abort(...)
     
     [ FAIL 14 | WARN 6 | SKIP 235 | PASS 1347 ]
     Deleting unused snapshots:
     • datamodelr-code/nycflights13.dot
     • datamodelr-code/nycflights13_draw_uk_1.dot
     • datamodelr-code/nycflights13_draw_uk_2.dot
     • datamodelr-code/nycflights13_draw_uk_3.dot
     • datamodelr-code/nycflights13_table_desc_1.dot
     • datamodelr-code/nycflights13_table_desc_2.dot
     • datamodelr-code/weird.dot
     • draw-dm/empty-table-in-dm.svg
     • draw-dm/nycflight-dm-types.svg
     • draw-dm/nycflight-dm.svg
     • draw-dm/single-empty-table-dm.svg
     • draw-dm/table-desc-1-dm.svg
     • draw-dm/table-desc-2-dm.svg
     • draw-dm/table-desc-3-dm.svg
     • draw-dm/table-desc-4-dm.svg
     • draw-dm/table-uk-1-dm.svg
     • draw-dm/table-uk-2-dm.svg
     Error: Test failures
     Execution halted
- [ ] ERROR: r-oldrel-windows-x86_64
     Running 'testthat.R' [82s]
     Running the tests in 'tests/testthat.R' failed.
     Complete output:
     > library(testthat)
     > 
     > # Need to use qualified call, this is checked in helper-print.R
     > testthat::test_check("dm")
     Loading required package: dm
     
     Attaching package: 'dm'
     
     The following object is masked from 'package:stats':
     
     filter
     
     Starting 2 test processes
     [ FAIL 14 | WARN 8 | SKIP 235 | PASS 1347 ]
     
     ══ Skipped tests (235) ═════════════════════════════════════════════════════════
     • COMPOUND (1): 'test-rows-dm.R:203:3'
     • Dependent on database version, find better way to record this info (1):
     'test-meta.R:19:3'
     • FIXME (2): 'test-learn.R:154:3', 'test-nest.R:2:3'
     • FIXME: Unstable on GHA? (1): 'test-dm.R:495:3'
     • Need to think about it (1): 'test-key-helpers.R:45:3'
     • On CRAN (187): 'test-zzx-deprecated.R:2:3', 'test-zzx-deprecated.R:15:3',
     'test-zzx-deprecated.R:25:3', 'test-zzx-deprecated.R:35:3',
     'test-zzx-deprecated.R:45:3', 'test-zzx-deprecated.R:58:3',
     'test-zzx-deprecated.R:81:3', 'test-zzx-deprecated.R:91:3',
     'test-zzx-deprecated.R:106:3', 'test-zzx-deprecated.R:121:3',
     'test-zzx-deprecated.R:141:3', 'test-zzx-deprecated.R:151:3',
     'test-zzx-deprecated.R:166:3', 'test-zzx-deprecated.R:185:3',
     'test-zzx-deprecated.R:221:3', 'test-zzx-deprecated.R:255:3',
     'test-zzx-deprecated.R:275:3', 'test-zzx-deprecated.R:291:3',
     'test-zzx-deprecated.R:326:3', 'test-zzx-deprecated.R:341:3',
     'test-zzx-deprecated.R:356:3', 'test-flatten.R:18:3', 'test-flatten.R:99:3',
     'test-dplyr.R:347:3', 'test-dplyr.R:506:3', 'test-dplyr.R:545:3',
     'test-dplyr.R:558:3', 'test-dplyr.R:569:3', 'test-dplyr.R:598:3',
     'test-dplyr.R:614:3', 'test-dplyr.R:806:3', 'test-draw-dm.R:17:3',
     'test-draw-dm.R:104:3', 'test-draw-dm.R:117:3', 'test-draw-dm.R:153:3',
     'test-draw-dm.R:182:3', 'test-filter-dm.R:62:3', 'test-filter-dm.R:173:3',
     'test-filter-dm.R:182:3', 'test-filter-dm.R:191:3', 'test-filter-dm.R:241:3',
     'test-bind.R:42:3', 'test-bind.R:97:3', 'test-bind.R:107:3',
     'test-bind.R:125:3', 'test-learn.R:446:3', 'test-add-tbl.R:92:3',
     'test-add-tbl.R:137:3', 'test-autoincrement.R:17:3',
     'test-autoincrement.R:26:3', 'test-rows-dm.R:2:3', 'test-rows-dm.R:28:3',
     'test-rows-dm.R:390:3', 'test-code-generation.R:7:3',
     'test-datamodelr-code.R:4:3', 'test-datamodelr-code.R:17:3',
     'test-datamodelr-code.R:37:3', 'test-datamodelr-code.R:57:3',
     'test-datamodelr-code.R:78:3', 'test-datamodelr-code.R:99:3',
     'test-datamodelr-code.R:120:3', 'test-datamodelr-code.R:133:3',
     'test-db-interface.R:35:3', 'test-check-cardinalities.R:30:3',
     'test-check-cardinalities.R:289:3', 'test-check-cardinalities.R:337:3',
     'test-check-cardinalities.R:422:3', 'test-disambiguate.R:2:3',
     'test-disentangle.R:2:3', 'test-deconstruct.R:6:3',
     'test-deconstruct.R:16:3', 'test-deconstruct.R:26:3',
     'test-deconstruct.R:55:3', 'test-deconstruct.R:72:3',
     'test-deconstruct.R:120:3', 'test-deconstruct.R:144:3',
     'test-deconstruct.R:160:3', 'test-deconstruct.R:181:3',
     'test-deconstruct.R:198:3', 'test-deconstruct.R:222:3',
     'test-deconstruct.R:246:3', 'test-deconstruct.R:270:3',
     'test-deconstruct.R:294:3', 'test-deconstruct.R:320:3',
     'test-deconstruct.R:346:3', 'test-deconstruct.R:372:3',
     'test-deconstruct.R:398:3', 'test-deconstruct.R:420:3',
     'test-deconstruct.R:479:3', 'test-deconstruct.R:492:3',
     'test-deconstruct.R:507:3', 'test-deconstruct.R:525:3',
     'test-deconstruct.R:572:3', 'test-deconstruct.R:586:3',
     'test-deconstruct.R:599:3', 'test-dm_deconstruct.R:2:3',
     'test-dm_deconstruct.R:9:3', 'test-dm_nest_tbl.R:17:3',
     'test-dm_pixarfilms.R:2:3', 'test-dm.R:2:3', 'test-dm.R:70:3',
     'test-dm.R:108:3', 'test-dm.R:148:3', 'test-dm.R:194:3', 'test-dm.R:202:3',
     'test-dm.R:211:3', 'test-dm.R:217:3', 'test-dm.R:223:3', 'test-dm.R:311:3',
     'test-dm.R:508:3', 'test-dm.R:534:3', 'test-dm.R:564:3', 'test-dm.R:598:3',
     'test-duckdb.R:2:3', 'test-enum-ops.R:11:3', 'test-enum-ops.R:30:3',
     'test-enum-ops.R:103:3', 'test-enum-ops.R:176:3',
     'test-enumerate_all_paths.R:2:3', 'test-error-helpers.R:2:3',
     'test-dm_wrap.R:12:3', 'test-dm_wrap.R:79:3',
     'test-examine-cardinalities.R:2:3', 'test-examine-cardinalities.R:16:3',
     'test-examine-cardinalities.R:23:3', 'test-examine-constraints.R:68:3',
     'test-examine-constraints.R:77:3', 'test-examine-constraints.R:87:3',
     'test-examine-constraints.R:94:3', 'test-format.R:2:3', 'test-graph.R:29:3',
     'test-graph.R:38:3', 'test-json.R:5:3', 'test-json_nest.R:2:3',
     'test-json_pack.R:2:3', 'test-foreign-keys.R:16:3',
     'test-foreign-keys.R:145:3', 'test-foreign-keys.R:252:3',
     'test-foreign-keys.R:260:3', 'test-foreign-keys.R:287:3',
     'test-foreign-keys.R:306:3', 'test-maria.R:2:3', 'test-meta.R:3:3',
     'test-mssql.R:2:3', 'test-pack_join.R:5:3', 'test-paste.R:10:3',
     'test-paste.R:93:3', 'test-postgres.R:2:3', 'test-key-helpers.R:4:3',
     'test-key-helpers.R:327:3', 'test-key-helpers.R:333:3',
     'test-key-helpers.R:342:3', 'test-key-helpers.R:350:3',
     'test-select-tbl.R:30:3', 'test-primary-keys.R:25:3',
     'test-primary-keys.R:94:3', 'test-primary-keys.R:178:3',
     'test-primary-keys.R:198:3', 'test-primary-keys.R:217:3',
     'test-primary-keys.R:229:3', 'test-primary-keys.R:246:3',
     'test-primary-keys.R:253:3', 'test-select.R:2:3', 'test-select.R:10:3',
     'test-select.R:18:3', 'test-select.R:47:3', 'test-select.R:88:3',
     'test-sqlite.R:2:3', 'test-standalone-check_suggested.R:3:3',
     'test-standalone-check_suggested.R:17:3', 'test-tidyselect.R:25:3',
     'test-tidyr.R:54:3', 'test-tidyr.R:92:3', 'test-unique-keys.R:2:3',
     'test-unique-keys.R:175:3', 'test-upgrade.R:3:3', 'test-upgrade.R:15:3',
     'test-upgrade.R:26:3', 'test-upgrade.R:42:3', 'test-upgrade.R:53:3',
     'test-upgrade.R:72:3', 'test-upgrade.R:86:3', 'test-upgrade.R:102:3',
     'test-upgrade.R:116:3', 'test-waldo.R:8:3', 'test-zoom.R:30:3',
     'test-zoom.R:133:3'
     • Slow test. To run, set CI=true (6): 'test-db-interface.R:7:3',
     'test-dplyr-src.R:49:3', 'test-examine-constraints.R:34:3',
     'test-examine-constraints.R:52:3', 'test-foreign-keys.R:180:3',
     'test-primary-keys.R:158:3'
     • `foo()` needs the "iurtnkjvmomweicopbt" package. (1):
     'test-standalone-check_suggested.R:30:3'
     • dm argument (1): 'test-select-tbl.R:71:3'
     • does not work on `df` (1): 'test-validate.R:201:3'
     • keyed = TRUE (1): 'test-deconstruct.R:91:3'
     • not testing deprecated cdm_nycflights13(): test too slow (1):
     'test-zzx-deprecated.R:266:3'
     • not testing deprecated learning from DB: test too slow (1):
     'test-zzx-deprecated.R:236:3'
     • only works on `db` (1): 'test-filter-dm.R:47:3'
     • only works on `duckdb` (2): 'test-duckdb.R:9:3', 'test-duckdb.R:32:3'
     • only works on `maria` (2): 'test-maria.R:9:3', 'test-maria.R:32:3'
     • only works on `mssql` (6): 'test-learn.R:206:3', 'test-learn.R:282:3',
     'test-db-helpers.R:2:3', 'test-mssql.R:9:3', 'test-mssql.R:32:3',
     'test-schema.R:129:3'
     • only works on `mssql`, `postgres` (4): 'test-db-interface.R:81:3',
     'test-db-interface.R:94:3', 'test-db-interface.R:125:3', 'test-schema.R:2:3'
     • only works on `mssql`, `postgres`, `maria` (4): 'test-learn.R:2:3',
     'test-learn.R:69:3', 'test-learn.R:366:3', 'test-meta.R:9:3'
     • only works on `postgres` (4): 'test-db-helpers.R:108:3',
     'test-postgres.R:9:3', 'test-postgres.R:32:3', 'test-schema.R:99:3'
     • only works on `postgres`, `mssql` (2): 'test-json_nest.R:14:3',
     'test-json_pack.R:13:3'
     • only works on `postgres`, `mssql`, `sqlite` (1): 'test-rows-dm.R:221:3'
     • only works on `postgres`, `sqlite`, `mssql`, `maria` (1):
     'test-db-interface.R:183:3'
     • only works on `sqlite` (3): 'test-schema.R:201:3', 'test-sqlite.R:9:3',
     'test-sqlite.R:32:3'
     
     ══ Failed tests ════════════════════════════════════════════════════════════════
     ── Error ('test-bind.R:51:3'): errors: src mismatches ──────────────────────────
     <dplyr:::mutate_error/rlang_error/error/condition>
     Error in `mutate(., name = child_table, index_name = map_chr(child_fk_cols, 
     paste, collapse = "_"), remote_name = purrr::map_chr(table_names[name], 
     ~DBI::dbQuoteIdentifier(con, .x)), remote_name_unquoted = map_chr(DBI::dbUnquoteIdentifier(con, 
     DBI::SQL(remote_name)), ~.x@name[["table"]]), index_name = make.unique(paste0(remote_name_unquoted, 
     "__", index_name), sep = "__"))`: i In argument: `remote_name_unquoted = map_chr(...)`.
     Caused by error in `map_chr()`:
     i In index: 1.
     Caused by error in `.x@name[["table"]]`:
     ! subscript out of bounds
     ── Error ('test-build_copy_queries.R:14:3'): build_copy_queries snapshot test for pixarfilms ──
     <dplyr:::mutate_error/rlang_error/error/condition>
     Error in `mutate(., name = child_table, index_name = map_chr(child_fk_cols, 
     paste, collapse = "_"), remote_name = purrr::map_chr(table_names[name], 
     ~DBI::dbQuoteIdentifier(con, .x)), remote_name_unquoted = map_chr(DBI::dbUnquoteIdentifier(con, 
     DBI::SQL(remote_name)), ~.x@name[["table"]]), index_name = make.unique(paste0(remote_name_unquoted, 
     "__", index_name), sep = "__"))`: i In argument: `remote_name_unquoted = map_chr(...)`.
     Caused by error in `map_chr()`:
     i In index: 1.
     Caused by error in `.x@name[["table"]]`:
     ! subscript out of bounds
     Backtrace:
     ▆
     1. └─testthat::expect_snapshot(...) at test-build_copy_queries.R:14:3
     2.   └─rlang::cnd_signal(state$error)
     ── Error ('test-build_copy_queries.R:33:3'): build_copy_queries snapshot test for dm_for_filter() ──
     <dplyr:::mutate_error/rlang_error/error/condition>
     Error in `mutate(., name = child_table, index_name = map_chr(child_fk_cols, 
     paste, collapse = "_"), remote_name = purrr::map_chr(table_names[name], 
     ~DBI::dbQuoteIdentifier(con, .x)), remote_name_unquoted = map_chr(DBI::dbUnquoteIdentifier(con, 
     DBI::SQL(remote_name)), ~.x@name[["table"]]), index_name = make.unique(paste0(remote_name_unquoted, 
     "__", index_name), sep = "__"))`: i In argument: `remote_name_unquoted = map_chr(...)`.
     Caused by error in `map_chr()`:
     i In index: 1.
     Caused by error in `.x@name[["table"]]`:
     ! subscript out of bounds
     Backtrace:
     ▆
     1. └─testthat::expect_snapshot(...) at test-build_copy_queries.R:33:3
     2.   └─rlang::cnd_signal(state$error)
     ── Error ('test-build_copy_queries.R:63:3'): build_copy_queries avoids duplicate indexes ──
     <dplyr:::mutate_error/rlang_error/error/condition>
     Error in `mutate(., name = child_table, index_name = map_chr(child_fk_cols, 
     paste, collapse = "_"), remote_name = purrr::map_chr(table_names[name], 
     ~DBI::dbQuoteIdentifier(con, .x)), remote_name_unquoted = map_chr(DBI::dbUnquoteIdentifier(con, 
     DBI::SQL(remote_name)), ~.x@name[["table"]]), index_name = make.unique(paste0(remote_name_unquoted, 
     "__", index_name), sep = "__"))`: i In argument: `remote_name_unquoted = map_chr(...)`.
     Caused by error in `map_chr()`:
     i In index: 1.
     Caused by error in `.x@name[["table"]]`:
     ! subscript out of bounds
     ── Error ('test-rows-dm.R:98:3'): dm_rows_update() ─────────────────────────────
     <dplyr:::mutate_error/rlang_error/error/condition>
     Error in `mutate(., name = child_table, index_name = map_chr(child_fk_cols, 
     paste, collapse = "_"), remote_name = purrr::map_chr(table_names[name], 
     ~DBI::dbQuoteIdentifier(con, .x)), remote_name_unquoted = map_chr(DBI::dbUnquoteIdentifier(con, 
     DBI::SQL(remote_name)), ~.x@name[["table"]]), index_name = make.unique(paste0(remote_name_unquoted, 
     "__", index_name), sep = "__"))`: i In argument: `remote_name_unquoted = map_chr(...)`.
     Caused by error in `map_chr()`:
     i In index: 1.
     Caused by error in `.x@name[["table"]]`:
     ! subscript out of bounds
     ── Error ('test-rows-dm.R:152:3'): dm_rows_truncate() ──────────────────────────
     <dplyr:::mutate_error/rlang_error/error/condition>
     Error in `mutate(., name = child_table, index_name = map_chr(child_fk_cols, 
     paste, collapse = "_"), remote_name = purrr::map_chr(table_names[name], 
     ~DBI::dbQuoteIdentifier(con, .x)), remote_name_unquoted = map_chr(DBI::dbUnquoteIdentifier(con, 
     DBI::SQL(remote_name)), ~.x@name[["table"]]), index_name = make.unique(paste0(remote_name_unquoted, 
     "__", index_name), sep = "__"))`: i In argument: `remote_name_unquoted = map_chr(...)`.
     Caused by error in `map_chr()`:
     i In index: 1.
     Caused by error in `.x@name[["table"]]`:
     ! subscript out of bounds
     ── Error ('test-dm_sql.R:4:3'): snapshot test ──────────────────────────────────
     <dplyr:::mutate_error/rlang_error/error/condition>
     Error in `mutate(., name = child_table, index_name = map_chr(child_fk_cols, 
     paste, collapse = "_"), remote_name = purrr::map_chr(table_names[name], 
     ~DBI::dbQuoteIdentifier(con, .x)), remote_name_unquoted = map_chr(DBI::dbUnquoteIdentifier(con, 
     DBI::SQL(remote_name)), ~.x@name[["table"]]), index_name = make.unique(paste0(remote_name_unquoted, 
     "__", index_name), sep = "__"))`: i In argument: `remote_name_unquoted = map_chr(...)`.
     Caused by error in `map_chr()`:
     i In index: 1.
     Caused by error in `.x@name[["table"]]`:
     ! subscript out of bounds
     Backtrace:
     ▆
     1. └─testthat::expect_snapshot(...) at test-dm_sql.R:4:3
     2.   └─rlang::cnd_signal(state$error)
     ── Error ('test-dm.R:273:3'): 'compute.dm()' computes tables on DB ─────────────
     <dplyr:::mutate_error/rlang_error/error/condition>
     Error in `mutate(., name = child_table, index_name = map_chr(child_fk_cols, 
     paste, collapse = "_"), remote_name = purrr::map_chr(table_names[name], 
     ~DBI::dbQuoteIdentifier(con, .x)), remote_name_unquoted = map_chr(DBI::dbUnquoteIdentifier(con, 
     DBI::SQL(remote_name)), ~.x@name[["table"]]), index_name = make.unique(paste0(remote_name_unquoted, 
     "__", index_name), sep = "__"))`: i In argument: `remote_name_unquoted = map_chr(...)`.
     Caused by error in `map_chr()`:
     i In index: 1.
     Caused by error in `.x@name[["table"]]`:
     ! subscript out of bounds
     ── Error ('test-dm.R:286:3'): 'compute.dm_zoomed()' computes tables on DB ──────
     <dplyr:::mutate_error/rlang_error/error/condition>
     Error in `mutate(., name = child_table, index_name = map_chr(child_fk_cols, 
     paste, collapse = "_"), remote_name = purrr::map_chr(table_names[name], 
     ~DBI::dbQuoteIdentifier(con, .x)), remote_name_unquoted = map_chr(DBI::dbUnquoteIdentifier(con, 
     DBI::SQL(remote_name)), ~.x@name[["table"]]), index_name = make.unique(paste0(remote_name_unquoted, 
     "__", index_name), sep = "__"))`: i In argument: `remote_name_unquoted = map_chr(...)`.
     Caused by error in `map_chr()`:
     i In index: 1.
     Caused by error in `.x@name[["table"]]`:
     ! subscript out of bounds
     ── Error ('test-dm.R:487:3'): dm_get_con() works ───────────────────────────────
     <dplyr:::mutate_error/rlang_error/error/condition>
     Error in `mutate(., name = child_table, index_name = map_chr(child_fk_cols, 
     paste, collapse = "_"), remote_name = purrr::map_chr(table_names[name], 
     ~DBI::dbQuoteIdentifier(con, .x)), remote_name_unquoted = map_chr(DBI::dbUnquoteIdentifier(con, 
     DBI::SQL(remote_name)), ~.x@name[["table"]]), index_name = make.unique(paste0(remote_name_unquoted, 
     "__", index_name), sep = "__"))`: i In argument: `remote_name_unquoted = map_chr(...)`.
     Caused by error in `map_chr()`:
     i In index: 1.
     Caused by error in `.x@name[["table"]]`:
     ! subscript out of bounds
     ── Error ('test-nest.R:41:3'): 'nest_join_dm_zoomed()' fails for DB-'dm' ───────
     <dplyr:::mutate_error/rlang_error/error/condition>
     Error in `mutate(., name = child_table, index_name = map_chr(child_fk_cols, 
     paste, collapse = "_"), remote_name = purrr::map_chr(table_names[name], 
     ~DBI::dbQuoteIdentifier(con, .x)), remote_name_unquoted = map_chr(DBI::dbUnquoteIdentifier(con, 
     DBI::SQL(remote_name)), ~.x@name[["table"]]), index_name = make.unique(paste0(remote_name_unquoted, 
     "__", index_name), sep = "__"))`: i In argument: `remote_name_unquoted = map_chr(...)`.
     Caused by error in `map_chr()`:
     i In index: 1.
     Caused by error in `.x@name[["table"]]`:
     ! subscript out of bounds
     ── Error ('test-pack_join.R:15:3'): `pack_join()` works with remote table ──────
     <dplyr:::mutate_error/rlang_error/error/condition>
     Error in `mutate(., name = child_table, index_name = map_chr(child_fk_cols, 
     paste, collapse = "_"), remote_name = purrr::map_chr(table_names[name], 
     ~DBI::dbQuoteIdentifier(con, .x)), remote_name_unquoted = map_chr(DBI::dbUnquoteIdentifier(con, 
     DBI::SQL(remote_name)), ~.x@name[["table"]]), index_name = make.unique(paste0(remote_name_unquoted, 
     "__", index_name), sep = "__"))`: i In argument: `remote_name_unquoted = map_chr(...)`.
     Caused by error in `map_chr()`:
     i In index: 1.
     Caused by error in `.x@name[["table"]]`:
     ! subscript out of bounds
     ── Error ('test-validate.R:190:3'): validator speaks up (sqlite()) ─────────────
     <dplyr:::mutate_error/rlang_error/error/condition>
     Error in `mutate(., data = if_else(table == "tf_1", list(dm_for_filter_duckdb()$tf_1), 
     data))`: i In argument: `data = if_else(table == "tf_1", list(dm_for_filter_duckdb()$tf_1), data)`.
     Caused by error in `mutate()`:
     i In argument: `remote_name_unquoted = map_chr(...)`.
     Caused by error in `map_chr()`:
     i In index: 1.
     Caused by error in `.x@name[["table"]]`:
     ! subscript out of bounds
     Backtrace:
     ▆
     1. ├─dm:::expect_dm_error(...) at test-validate.R:190:3
     2. │ └─testthat::expect_error(expr, class = dm_error(class)) at D:\RCompile\CRANpkg\local\4.2\dm.Rcheck\tests\testthat\helper-expectations.R:48:3
     3. │   └─testthat:::expect_condition_matching(...)
     4. │     └─testthat:::quasi_capture(...)
     5. │       ├─testthat (local) .capture(...)
     6. │       │ └─base::withCallingHandlers(...)
     7. │       └─rlang::eval_bare(quo_get_expr(.quo), quo_get_env(.quo))
     8. ├─... %>% dm_validate()
     9. ├─dm::dm_validate(.)
     10. │ └─dm:::check_dm(x)
     11. │   └─dm::is_dm(x)
     12. ├─dm:::dm_from_def(.)
     13. ├─dplyr::mutate(...)
     14. ├─dplyr:::mutate.data.frame(...)
     15. │ └─dplyr:::mutate_cols(.data, dplyr_quosures(...), by)
     16. │   ├─base::withCallingHandlers(...)
     17. │   └─dplyr:::mutate_col(dots[[i]], data, mask, new_columns)
     18. │     └─mask$eval_all_mutate(quo)
     19. │       └─dplyr (local) eval()
     20. ├─dplyr::if_else(...)
     21. ├─dm:::dm_for_filter_duckdb()
     22. ├─dm::copy_dm_to(duckdb_test_src(), dm_for_filter()) at D:\RCompile\CRANpkg\local\4.2\dm.Rcheck\tests\testthat\helper-src.R:26:7
     23. │ └─dm:::build_copy_queries(...)
     24. │   └─... %>% ...
     25. ├─dplyr::summarize(...)
     26. ├─dplyr::group_by(., name)
     27. ├─dplyr::mutate(...)
     28. ├─dplyr:::mutate.data.frame(...)
     29. │ └─dplyr:::mutate_cols(.data, dplyr_quosures(...), by)
     30. │   ├─base::withCallingHandlers(...)
     31. │   └─dplyr:::mutate_col(dots[[i]], data, mask, new_columns)
     32. │     └─mask$eval_all_mutate(quo)
     33. │       └─dplyr (local) eval()
     34. ├─purrr::map_chr(...)
     35. │ └─purrr:::map_("character", .x, .f, ..., .progress = .progress)
     36. │   ├─purrr:::with_indexed_errors(...)
     37. │   │ └─base::withCallingHandlers(...)
     38. │   ├─purrr:::call_with_cleanup(...)
     39. │   └─dm (local) .f(.x[[i]], ...)
     40. ├─purrr (local) `<fn>`(`<sbscOOBE>`)
     41. │ └─cli::cli_abort(...)
     42. │   └─rlang::abort(...)
     43. │     └─rlang:::signal_abort(cnd, .file)
     44. │       └─base::signalCondition(cnd)
     45. ├─dplyr (local) `<fn>`(`<prrr_rr_>`)
     46. │ └─rlang::abort(message, class = error_class, parent = parent, call = error_call)
     47. │   └─rlang:::signal_abort(cnd, .file)
     48. │     └─base::signalCondition(cnd)
     49. └─dplyr (local) `<fn>`(`<dply:::_>`)
     50.   └─rlang::abort(message, class = error_class, parent = parent, call = error_call)
     ── Error ('test_dm_from_con.R:23:3'): table identifiers are quoted ─────────────
     <purrr_error_indexed/rlang_error/error/condition>
     Error in `map(DBI::dbUnquoteIdentifier(con_db, DBI::SQL(remote_tbl_names_copied)), 
     ~.x@name[["table"]])`: i In index: 1.
     Caused by error in `.x@name[["table"]]`:
     ! subscript out of bounds
     Backtrace:
     ▆
     1. ├─... %>% ... at test_dm_from_con.R:23:3
     2. ├─dm::dm_select_tbl(...)
     3. │ └─dm:::eval_select_table(quo(c(...)), src_tbls_impl(dm))
     4. │   └─dm:::eval_select_table_indices(quo, table_names, unique = unique)
     5. │     ├─base::withCallingHandlers(...)
     6. │     └─dm:::eval_select_indices(quo, table_names, unique = unique)
     7. │       └─tidyselect::eval_select(quo, set_names(names))
     8. │         └─tidyselect:::eval_select_impl(...)
     9. │           ├─tidyselect:::with_subscript_errors(...)
     10. │           │ └─rlang::try_fetch(...)
     11. │           │   └─base::withCallingHandlers(...)
     12. │           └─tidyselect:::vars_select_eval(...)
     13. │             └─tidyselect:::walk_data_tree(expr, data_mask, context_mask)
     14. │               └─tidyselect:::eval_c(expr, data_mask, context_mask)
     15. │                 └─tidyselect:::call_expand_dots(expr, context_mask$.__current__.)
     16. │                   └─rlang::eval_bare(quote(enquos(...)), dots_mask)
     17. ├─rlang::enquos(...)
     18. │ └─rlang:::endots(...)
     19. │   └─rlang:::map(...)
     20. │     └─base::lapply(.x, .f, ...)
     21. │       └─rlang (local) FUN(X[[i]], ...)
     22. ├─purrr::map(...)
     23. │ └─purrr:::map_("list", .x, .f, ..., .progress = .progress)
     24. │   ├─purrr:::with_indexed_errors(...)
     25. │   │ └─base::withCallingHandlers(...)
     26. │   ├─purrr:::call_with_cleanup(...)
     27. │   └─dm (local) .f(.x[[i]], ...)
     28. └─purrr (local) `<fn>`(`<sbscOOBE>`)
     29.   └─cli::cli_abort(...)
     30.     └─rlang::abort(...)
     
     [ FAIL 14 | WARN 8 | SKIP 235 | PASS 1347 ]
     Deleting unused snapshots:
     • datamodelr-code/nycflights13.dot
     • datamodelr-code/nycflights13_draw_uk_1.dot
     • datamodelr-code/nycflights13_draw_uk_2.dot
     • datamodelr-code/nycflights13_draw_uk_3.dot
     • datamodelr-code/nycflights13_table_desc_1.dot
     • datamodelr-code/nycflights13_table_desc_2.dot
     • datamodelr-code/weird.dot
     • draw-dm/empty-table-in-dm.svg
     • draw-dm/nycflight-dm-types.svg
     • draw-dm/nycflight-dm.svg
     • draw-dm/single-empty-table-dm.svg
     • draw-dm/table-desc-1-dm.svg
     • draw-dm/table-desc-2-dm.svg
     • draw-dm/table-desc-3-dm.svg
     • draw-dm/table-desc-4-dm.svg
     • draw-dm/table-uk-1-dm.svg
     • draw-dm/table-uk-2-dm.svg
     Error: Test failures
     Execution halted

Check results at: https://cran.r-project.org/web/checks/check_results_dm.html
