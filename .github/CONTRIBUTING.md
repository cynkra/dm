# Contributing to dm

This outlines how to propose a change to dm. 
For more detailed info about contributing to this, and other tidyverse packages, please see the
[**development contributing guide**](https://rstd.io/tidy-contrib). 

## Fixing typos

You can fix typos, spelling mistakes, or grammatical errors in the documentation directly using the GitHub web interface, as long as the changes are made in the _source_ file. 
This generally means you'll need to edit [roxygen2 comments](https://roxygen2.r-lib.org/articles/roxygen2.html) in an `.R`, not a `.Rd` file. 
You can find the `.R` file that generates the `.Rd` by reading the comment in the first line.

## Bigger changes

If you want to make a bigger change, it's a good idea to first file an issue and make sure someone from the team agrees that it’s needed. 
If you’ve found a bug, please file an issue that illustrates the bug with a minimal 
[reprex](https://www.tidyverse.org/help/#reprex) (this will also help you write a unit test, if needed).

### Pull request process

*   Fork the package and clone onto your computer. If you haven't done this before, we recommend using `usethis::create_from_github("cynkra/dm", fork = TRUE)`.

*   Install all development dependencies with `devtools::install_dev_deps()`, and then make sure the package passes R CMD check by running `devtools::check()`. 
    If R CMD check doesn't pass cleanly, it's a good idea to ask for help before continuing. 
*   Create a Git branch for your pull request (PR). We recommend using `usethis::pr_init("brief-description-of-change")`.

*   Make your changes, commit to git, and then create a PR by running `usethis::pr_push()`, and following the prompts in your browser.
    The title of your PR should briefly describe the change.
    The body of your PR should contain `Fixes #issue-number`.

*  For user-facing changes, add a bullet to the top of `NEWS.md` (i.e. just below the first header). Follow the style described in <https://style.tidyverse.org/news.html>.

### Code style

*   New code should follow the tidyverse [style guide](https://style.tidyverse.org). 
    You can use the [styler](https://CRAN.R-project.org/package=styler) package to apply these styles, but please don't restyle code that has nothing to do with your PR.  

*  We use [roxygen2](https://cran.r-project.org/package=roxygen2), with [Markdown syntax](https://cran.r-project.org/web/packages/roxygen2/vignettes/rd-formatting.html), for documentation.  

*  We use [testthat](https://cran.r-project.org/package=testthat) for unit tests. 
   Contributions with test cases included are easier to accept.  

## Code of Conduct

Please note that the dm project is released with a
[Contributor Code of Conduct](CODE_OF_CONDUCT.md). By contributing to this
project you agree to abide by its terms.
# Contributing to dm

This outlines how to propose a change to dm. 

## Fixing typos

You can fix typos, spelling mistakes, or grammatical errors in the documentation directly using the GitHub web interface, as long as the changes are made in the _source_ file. 
This generally means you'll need to edit [roxygen2 comments](https://roxygen2.r-lib.org/articles/roxygen2.html) in an `.R`, not a `.Rd` file. 
You can find the `.R` file that generates the `.Rd` by reading the comment in the first line.

## Bigger changes

If you want to make a bigger change, it's a good idea to first file an issue and make sure someone from the team agrees that it’s needed. 
If you’ve found a bug, please file an issue that illustrates the bug with a minimal 
[reprex](https://www.tidyverse.org/help/#reprex) (this will also help you write a unit test, if needed).

### Pull request process

*   Fork the package and clone onto your computer. If you haven't done this before, we recommend using `usethis::create_from_github("cynkra/dm", fork = TRUE)`.

*   Install all development dependencies with `devtools::install_dev_deps()`, and then make sure the package passes R CMD check by running `devtools::check()`. 
    If R CMD check doesn't pass cleanly, it's a good idea to ask for help before continuing. 
*   Create a Git branch for your pull request (PR). We recommend using `usethis::pr_init("brief-description-of-change")`.

*   Make your changes, commit to git, and then create a PR by running `usethis::pr_push()`, and following the prompts in your browser.
    The title of your PR should briefly describe the change.
    The body of your PR should contain `Fixes #issue-number`.

*  For user-facing changes, add a bullet to the top of `NEWS.md` (i.e. just below the first header). Follow the style described in <https://style.tidyverse.org/news.html>.

## Code style & design

### General remarks

*   New code should follow the tidyverse [style guide](https://style.tidyverse.org). 
    You can use the [styler](https://CRAN.R-project.org/package=styler) package to apply these styles, but please don't restyle code that has nothing to do with your PR.  

*  We use [roxygen2](https://cran.r-project.org/package=roxygen2), with [Markdown syntax](https://cran.r-project.org/web/packages/roxygen2/vignettes/rd-formatting.html), for documentation.  

* We use a specific [branch of downlit](https://github.com/r-lib/downlit/tree/f-readme-document) for knitting the README.

### Testing
  
* We use {testthat}.

* All exported functions should be tested.

* R scripts under "tests/testthat/"" whose name start with ["helper"](https://blog.r-hub.io/2020/11/18/testthat-utility-belt/#code-called-in-your-tests) are loaded with `devtools::load_all()` so they are available for both tests and interactive  debugging, but can't be found with `:::`.
  
* "helper-src.R" implements a complex mechanism so that some dm creating functions, such as `dm_for_filter()`, 
will create a remote dm in a different database management system depending on context. 
This allows tests that use those to be run on different setups through github actions. 
Additionally `my_db_test_src()` will return the relevant database. 
In order to test databases locally (typically to debug if CI tests fails and we can't debug from the online log)
  we can set the environ variable "DM_TEST_SRC" to "postgres", "mariadb", "mssql", "duckdb" or "sqlite".
  You might have to setup credentials in "helper-config-db.R" to do so.
* Some useful expectations can be found in "helper-expectations.R".
* In "helper-skip.R" are some helpers to skip tests in some contexts, these might be useful for instance if a feature is not supported on some databases.
* When using `expect_snapshot()` on a DBMS dependent call (i.e a call that uses `dm_for_filter()` or copies to `my_db_test_src()`), 
  the `variant` argument should be   set to `my_test_src_name` (a global  variable created when loading helpers) so that the snapshots end up in different directories.
    
### Function naming

See vignette [function naming logic](https://cynkra.github.io/dm/articles/tech-dm-naming.html).

### Error messages

We strive to standardise error messages in {dm}. A failure should be triggered by `abort()` through a function defined in "error-helpers.R" where the error class is defined with `dm_error_full()` and the error message is created by a separate function. Please follow the pattern used in `"error-helpers.R"`.  Exceptions might exist but they are mostly waiting to be harmonised.

## Code of Conduct

Please note that the dm project is released with a
[Contributor Code of Conduct](CODE_OF_CONDUCT.md). By contributing to this
project you agree to abide by its terms.
