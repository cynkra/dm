all: qtest

# Quiet tests
# Run with make -j $(nproc) -O
# or with pmake
qtest: qtest-df qtest-sqlite qtest-postgres qtest-mssql qtest-duckdb qtest-maria

# Progress tests
# Run with make -j 1 -O none test
# or with sake test
test: test-df test-sqlite test-postgres test-mssql test-duckdb test-maria

# Connectivity tests
connect: connect-sqlite connect-postgres connect-mssql connect-duckdb connect-maria

qtest-%:
	TESTTHAT_PARALLEL=FALSE DM_TEST_SRC=$@ time R -q -e 'options("crayon.enabled" = TRUE); testthat::test_local(filter = "${DM_TEST_FILTER}")'

test-%:
	DM_TEST_SRC=$@ time R -q -e 'testthat::test_local(filter = "${DM_TEST_FILTER}")'

ltest-%:
	DM_TEST_SRC=$@ time R -q -e 'lazytest::lazytest_local()'

connect-%:
	DM_TEST_SRC=$@ R -q -e 'suppressMessages(pkgload::load_all()); my_test_con()'

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
