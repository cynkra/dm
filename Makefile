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
	DM_TEST_SRC=$@ time R -q -e 'options("testthat.summary.omit_skips" = TRUE, "crayon.enabled" = TRUE); devtools::test(filter = "${DM_TEST_FILTER}", reporter = c("summary", "fail"))'

test-%:
	DM_TEST_SRC=$@ time R -q -e 'devtools::test(filter = "${DM_TEST_FILTER}", reporter = c("progress", "summary", "fail"))'
