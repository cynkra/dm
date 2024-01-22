all: qtest

# Quiet tests
# Run with make -j $(nproc) -O
# or with pmake
qtest: qtest-df qtest-sqlite qtest-postgres qtest-mssql qtest-duckdb qtest-maria qtest-mysql

# Progress tests
test: test-df test-sqlite test-postgres test-mssql test-duckdb test-maria test-mysql

# Testing with lazytest
ltest: ltest-df ltest-sqlite ltest-postgres ltest-mssql ltest-duckdb ltest-maria ltest-mysql

# Silent testing
stest: stest-df stest-sqlite stest-postgres stest-mssql stest-duckdb stest-maria stest-mysql

# Connectivity tests
connect: connect-sqlite connect-postgres connect-mssql connect-duckdb connect-maria connect-mysql

qtest-%:
	DM_TEST_SRC=$@ time R -q -e 'options("crayon.enabled" = TRUE); Sys.setenv(TESTTHAT_PARALLEL = FALSE); testthat::test_local(filter = "${DM_TEST_FILTER}")'

test-%:
	DM_TEST_SRC=$@ time R -q -e 'Sys.setenv(TESTTHAT_PARALLEL = TRUE); testthat::test_local(filter = "${DM_TEST_FILTER}")'

stest-%:
	DM_TEST_SRC=$@ time R -q -e 'options(testthat.progress.max_fails = 1); testthat::test_local(filter = "${DM_TEST_FILTER}", reporter = "silent")'

ltest-%:
	DM_TEST_SRC=$@ time R -q -e 'Sys.setenv(TESTTHAT_PARALLEL = TRUE); lazytest::lazytest_local()'

connect-%:
	DM_TEST_SRC=$@ R -q -e 'suppressMessages(pkgload::load_all()); my_test_con()'

db-init-maria:
	while ! R -q -e 'suppressMessages(pkgload::load_all()); DBI::dbExecute(test_src_maria(root = TRUE)$$con, "GRANT ALL ON *.* TO '"'"'compose'"'"'@'"'"'%'"'"';"); DBI::dbExecute(test_src_maria()$$con, "FLUSH PRIVILEGES")'; do sleep 1; done

db-init-mysql:
	while ! R -q -e 'suppressMessages(pkgload::load_all()); DBI::dbExecute(test_src_mysql(root = TRUE)$$con, "GRANT ALL ON *.* TO '"'"'compose'"'"'@'"'"'%'"'"';"); DBI::dbExecute(test_src_mysql()$$con, "FLUSH PRIVILEGES")'; do sleep 1; done

db-init-mssql:
	while ! R -q -e 'suppressMessages(pkgload::load_all()); DBI::dbExecute(test_src_mssql(FALSE)$$con, "CREATE DATABASE test")'; do sleep 1; done

db-init: db-init-maria db-init-mysql db-init-mssql

db-start:
	docker-compose up -d --force-recreate --wait
	$(MAKE) db-init

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
