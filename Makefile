all: test-sqlite test-postgres test-mssql

test-%:
	R -q -e 'target <- "$@"; Sys.setenv(DM_TEST_SRC = gsub("^test-", "", target)); devtools::test()'
