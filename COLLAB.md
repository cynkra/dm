# {dm} collaboration guide

This document is intended to help contributors follow a consistent approach.

It contains (or should ultimately contain) a description of :

* The package's structure
* The principles our code should adhere to
* How to write satisfactory tests
* ...

Any comment or question should be addressed there :

https://github.com/cynkra/dm/issues/757

## Naming conventions

Naming conventions are described in : https://cynkra.github.io/dm/articles/tech-dm-naming.html

Some existing functions might not follow these rules for legacy reason but we
strive to apply them on all new functions.

## Guidelines

* We generally adhere to the tidyverse style guide and design guide
* We strive to use {rlang} and {tidyverse} functions over base ones, this means
  `sym()` over `as.name()`, `set_names()` over `setNames()`, `tibble()` over
  `data.frame()` etc
* We prefer `glue::glue()` over `paste()` and `sprintf()`

## Dependency guidelines

* All `@import` and `@importFrom` calls are located in "import.R". 
* Don't `@import` new packages without a strong reason, don't `@importFrom` new 
  functions unless they are used multiple times, use `pkg::fun` notation in these
  cases
* Don't use `pkg::fun` notation if `@import` and `@importFrom` were used
* Use `check_suggested()` to check if a suggested package is installed
  
## Test guidelines  
  
* We use {testthat}
* All exported functions should be tested
* R scripts under "tests/testthat/"" whose name start with "helper"" are loaded 
  with `devtools::load_all()` so they are available for both tests and interactive 
  debugging, but can't be found with `dm:::helper_function()`
* "helper-src.R" implements a complex mechanism so that some dm creating functions,
  such as `dm_for_filter()`, will create a remote dm in a different database
  management system depending on context. This allows tests that use those to
  be run on different setups through github actions. Additionally `my_db_test_src()`
  will return the relevant database. In order to test databases 
  locally (typically to debug if CI tests fails and we can't debug from the online log)
  we can set the environ variable "DM_TEST_SRC" to "postgres", "mariadb", "mssql", "duckdb" or "sqlite".
  You might have to setup credentials in "helper-config-db.R" to do so.
* Some useful expectations can be found in "helper-expectations.R"
* In "helper-skip.R" are some helpers to skip tests in some contexts, these might
  be useful for instance if a feature is not supported on some databases
* When using `expect_snapshot()` on a DBMS dependent call (i.e a call that uses `dm_for_filter()`
  or copies to `my_db_test_src()`), 
  the `variant` argument should be set to `my_test_src_name` (a global 
  variable created when loading helpers) so that the snapshots end up in different 
  directories.

## Before submitting a PR

* Run tests (`devtools::test()` or CTRL/CMD + SHIFT + T in RStudio)
* Run checks (`devtools::check()` or CTRL/CMD + SHIFT + E in RStudio)

