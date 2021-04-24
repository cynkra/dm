all: qtest

# Quiet tests
# Run with make -j $(nproc) -O
# or with pmake
qtest: qtest-sqlite qtest-postgres qtest-mssql

# Progress tests
# Run with make -j 1 -O none test-sqlite
# or with sake test-sqlite
test: test-sqlite test-postgres test-mssql

qtest-%:
	TESTTHAT_PARALLEL=FALSE DM_TEST_SRC=$@ time R -q -e 'options("crayon.enabled" = TRUE); testthat::test_local(filter = "${DM_TEST_FILTER}")'

test-%:
	DM_TEST_SRC=$@ time R -q -e 'testthat::test_local(filter = "${DM_TEST_FILTER}")'
