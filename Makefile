all: qtest

# Quiet tests
# Run with make -j $(nproc) -O
# or with pmake
qtest: qtest-df qtest-sqlite qtest-postgres qtest-mssql qtest-duckdb qtest-maria

# Progress tests
test: test-df test-sqlite test-postgres test-mssql test-duckdb test-maria

# Testing with lazytest
ltest: ltest-df ltest-sqlite ltest-postgres ltest-mssql ltest-duckdb ltest-maria

# Silent testing
stest: stest-df stest-sqlite stest-postgres stest-mssql stest-duckdb stest-maria

# Connectivity tests
connect: connect-sqlite connect-postgres connect-mssql connect-duckdb connect-maria

qtest-%:
	time R -q -e 'options("crayon.enabled" = TRUE); Sys.setenv(TESTTHAT_PARALLEL = FALSE); testthat::test_local(filter = "${DM_TEST_FILTER}|$@")'

test-%:
	time R -q -e 'Sys.setenv(TESTTHAT_PARALLEL = TRUE); testthat::test_local(filter = "${DM_TEST_FILTER}|$@")'

stest-%:
	time R -q -e 'options(testthat.progress.max_fails = 1); testthat::test_local(filter = "${DM_TEST_FILTER}|$@", reporter = "silent")'

ltest-%:
	time R -q -e 'Sys.setenv(TESTTHAT_PARALLEL = TRUE); lazytest::lazytest_local()'

connect-%:
	R -q -e 'suppressMessages(pkgload::load_all()); test_src_$@()$$con'

db-start:
	docker-compose up -d --force-recreate
	R -q -e 'suppressMessages(pkgload::load_all()); DBI::dbExecute(test_src_maria(root = TRUE)$$con, "GRANT ALL ON *.* TO '"'"'compose'"'"'@'"'"'%'"'"';"); DBI::dbExecute(test_src_maria()$$con, "FLUSH PRIVILEGES")'
	R -q -e 'suppressMessages(pkgload::load_all()); DBI::dbExecute(test_src_mssql(FALSE)$$con, "CREATE DATABASE test")'

db-restart:
	docker-compose up -d

db-stop:
	docker-compose down

docker-build:
	docker build --platform linux/amd64 -t ghcr.io/cynkra/dm:main .

docker-pull:
	docker pull --platform linux/amd64 ghcr.io/cynkra/dm:main

docker-shell:
	docker run --rm -ti --platform linux/amd64 -e DM_TEST_DOCKER_HOST=$$(Rscript -e 'cat(Sys.getenv("DM_TEST_DOCKER_HOST"))' | tail -n 1) -e TESTTHAT_CPUS=4 -v $$(pwd):/root/workspace ghcr.io/cynkra/dm:main

docker-connect:
	docker run --rm -ti --platform linux/amd64 -e DM_TEST_DOCKER_HOST=$$(Rscript -e 'cat(Sys.getenv("DM_TEST_DOCKER_HOST"))' | tail -n 1) -e TESTTHAT_CPUS=4 -v $$(pwd):/root/workspace ghcr.io/cynkra/dm:main make connect

docker-test:
	docker run --rm -ti --platform linux/amd64 -e DM_TEST_DOCKER_HOST=$$(Rscript -e 'cat(Sys.getenv("DM_TEST_DOCKER_HOST"))' | tail -n 1) -e TESTTHAT_CPUS=4 -v $$(pwd):/root/workspace ghcr.io/cynkra/dm:main make test

.NOTPARALLEL: test ltest stest
