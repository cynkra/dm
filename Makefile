all: test-sqlite test-postgres test-mssql

test-%:
	DM_TEST_SRC=$@ R -q -e 'devtools::test()'
