# Changelog

## dm 1.0.12.9016

### Bug fixes

- `dm_from_con(learn_keys = TRUE, .names = )` applies the specified
  table naming pattern
  ([@owenjonesuob](https://github.com/owenjonesuob),
  [\#2213](https://github.com/cynkra/dm/issues/2213),
  [\#2214](https://github.com/cynkra/dm/issues/2214)).

- [`dm_from_con()`](https://dm.cynkra.com/dev/reference/dm_from_con.md)
  no longer learns tables from all schemas by default for Postgres,
  MSSQL, and MariaDB; instead, `"public"`, `"dbo"` and the current
  database, respectively, are used
  ([@mgirlich](https://github.com/mgirlich),
  [\#1440](https://github.com/cynkra/dm/issues/1440),
  [\#1448](https://github.com/cynkra/dm/issues/1448)).

- Ensure compatibility with upcoming update of the pixarfilms package
  ([@erictleung](https://github.com/erictleung),
  erictleung/pixarfilms#39,
  [\#2256](https://github.com/cynkra/dm/issues/2256)).

- Fix [`dm_paste()`](https://dm.cynkra.com/dev/reference/dm_paste.md)
  pipe length issue by implementing operation chunking
  ([\#2301](https://github.com/cynkra/dm/issues/2301)).

### Features

- Add `.max_value` parameter to
  [`dm_examine_constraints()`](https://dm.cynkra.com/dev/reference/dm_examine_constraints.md)
  ([\#2200](https://github.com/cynkra/dm/issues/2200),
  [\#2387](https://github.com/cynkra/dm/issues/2387)).

- Introduce `dm_draw(backend_opts = list())`, soft-deprecate
  backend-specific arguments
  ([\#2381](https://github.com/cynkra/dm/issues/2381)).

- Learn keys from SQLite databases
  ([@gadenbuie](https://github.com/gadenbuie),
  [\#352](https://github.com/cynkra/dm/issues/352)).

- Use
  [`cli::cli_inform()`](https://cli.r-lib.org/reference/cli_abort.html)
  with native formatting
  ([\#2374](https://github.com/cynkra/dm/issues/2374)).

- Follow all updates from dplyr 1.2.0
  ([\#2361](https://github.com/cynkra/dm/issues/2361),
  [\#2362](https://github.com/cynkra/dm/issues/2362)).

- Vendor pixarfilms data and add `version` argument to
  [`dm_pixarfilms()`](https://dm.cynkra.com/dev/reference/dm_pixarfilms.md)
  ([\#2368](https://github.com/cynkra/dm/issues/2368),
  [\#2369](https://github.com/cynkra/dm/issues/2369)).

### Chore

- Comment.

- Adapt to dplyr 1.2.0.

- Restore recent soft-deprecation.

- Bump deprecation level
  ([\#2395](https://github.com/cynkra/dm/issues/2395)).

- Wrap all igraph functions
  ([\#2390](https://github.com/cynkra/dm/issues/2390)).

- Tweak [`dm_draw()`](https://dm.cynkra.com/dev/reference/dm_draw.md):
  rename `column_arrow` backend opt and validate `backend_opts`
  ([\#2383](https://github.com/cynkra/dm/issues/2383),
  [\#2384](https://github.com/cynkra/dm/issues/2384)).

- Wrap all igraph functions
  ([\#2382](https://github.com/cynkra/dm/issues/2382)).

- Wrap all igraph functions
  ([\#2382](https://github.com/cynkra/dm/issues/2382)).

- Require R \>= 4.0.

### Continuous integration

- Remove Docker image build, centralized now.

## dm 1.0.12.9015

### Bug fixes

- Fix bogus message for
  [`dm_rm_fk()`](https://dm.cynkra.com/dev/reference/dm_rm_fk.md) in
  presence of FKs to non-PKs
  ([\#1270](https://github.com/cynkra/dm/issues/1270),
  [\#2367](https://github.com/cynkra/dm/issues/2367)).

### Chore

- Don’t refer to removed `dplyr::src_dbi()`
  ([@DavisVaughan](https://github.com/DavisVaughan),
  [\#2356](https://github.com/cynkra/dm/issues/2356)).

### Continuous integration

- Use robust way to show payload.

## dm 1.0.12.9014

### Continuous integration

- Tweaks ([\#2354](https://github.com/cynkra/dm/issues/2354)).

## dm 1.0.12.9013

### Continuous integration

- Install odbc from GitHub remote to avoid failures on older versions of
  R.

## dm 1.0.12.9012

### Chore

- Better traceback location for selection errors
  ([\#2351](https://github.com/cynkra/dm/issues/2351)).

## dm 1.0.12.9011

### Continuous integration

- Install binaries from r-universe for dev workflow
  ([\#2348](https://github.com/cynkra/dm/issues/2348)).

## dm 1.0.12.9010

### Continuous integration

- Fix reviewdog and add commenting workflow
  ([\#2345](https://github.com/cynkra/dm/issues/2345)).

## dm 1.0.12.9009

### Continuous integration

- Use workflows for fledge
  ([\#2343](https://github.com/cynkra/dm/issues/2343)).

## dm 1.0.12.9008

### Continuous integration

- Sync ([\#2341](https://github.com/cynkra/dm/issues/2341)).

## dm 1.0.12.9007

### Chore

- Format with air with line length 100
  ([\#2335](https://github.com/cynkra/dm/issues/2335)).

### Continuous integration

- Fix dev pkgdown.

### Documentation

- Agent docs and updated instructions.

### claude

- Fix config.

## dm 1.0.12.9006

### Chore

- Adapt to igraph \>= 2.2.0
  ([\#2289](https://github.com/cynkra/dm/issues/2289)).

## dm 1.0.12.9005

### Continuous integration

- Use reviewdog for external PRs
  ([\#2323](https://github.com/cynkra/dm/issues/2323)).

## dm 1.0.12.9004

### Chore

- Auto-update from GitHub Actions
  ([\#2321](https://github.com/cynkra/dm/issues/2321)).

## dm 1.0.12.9003

### Continuous integration

- Cleanup and fix macOS
  ([\#2317](https://github.com/cynkra/dm/issues/2317)).

## dm 1.0.12.9002

### Testing

- Add tests for
  [`check_key()`](https://dm.cynkra.com/dev/reference/check_key.md)
  ([\#2298](https://github.com/cynkra/dm/issues/2298)).

## dm 1.0.12.9001

### Bug fixes

- [`check_key()`](https://dm.cynkra.com/dev/reference/check_key.md)
  returns input data frame when key is valid
  ([\#2221](https://github.com/cynkra/dm/issues/2221),
  [\#2303](https://github.com/cynkra/dm/issues/2303)).

- Correct deprecation warning message for
  [`dm_squash_to_tbl()`](https://dm.cynkra.com/dev/reference/deprecated.md)
  ([\#1364](https://github.com/cynkra/dm/issues/1364),
  [\#2302](https://github.com/cynkra/dm/issues/2302)).

### Chore

- Use summary reporter.

- Support SQL Server, needs image update.

- Fully support MariaDB.

- Support new `DM_TEST_*_HOST` env vars.

- Add MariaDB, do not connect yet.

- Add Postgres to devcontainer.

- Claude settings.

- Claude and Copilot settings.

- Add devcontainer.

- Add Claude Code GitHub Workflow.

### Continuous integration

- Format with air, check detritus, better handling of `extra-packages`
  ([\#2308](https://github.com/cynkra/dm/issues/2308)).

### Testing

- Add snapshot test for
  [`dm_squash_to_tbl()`](https://dm.cynkra.com/dev/reference/deprecated.md)
  ([\#1364](https://github.com/cynkra/dm/issues/1364),
  [\#2299](https://github.com/cynkra/dm/issues/2299)).

### Uncategorized

- Feat!:
  [`copy_dm_to()`](https://dm.cynkra.com/dev/reference/copy_dm_to.md)
  uses [`dm_sql()`](https://dm.cynkra.com/dev/reference/dm_sql.md).
  Unique keys and autoincrement primary keys
  ([\#1725](https://github.com/cynkra/dm/issues/1725)) are created on
  the database. Data models with cyclic references are supported on
  databases that allow adding constraints in `ALTER TABLE` statements
  (at this time, all except DuckDB and SQLite,
  [\#664](https://github.com/cynkra/dm/issues/664))
  ([\#2022](https://github.com/cynkra/dm/issues/2022))
  ([@krlmlr](https://github.com/krlmlr),
  [@41898282](https://github.com/41898282)+github-actions\[bot\],
  [\#1887](https://github.com/cynkra/dm/issues/1887)).

## dm 1.0.12.9000

### fledge

- CRAN release v1.0.12
  ([\#2295](https://github.com/cynkra/dm/issues/2295)).

## dm 1.0.12

CRAN release: 2025-07-02

### Bug fixes

- Improve detection of foreign-key relationships in Postgres
  ([\#1879](https://github.com/cynkra/dm/issues/1879),
  [\#2286](https://github.com/cynkra/dm/issues/2286)).

- Avoid including constraints from a different `constraint_schema` when
  learning from a database
  ([\#2228](https://github.com/cynkra/dm/issues/2228),
  [\#2275](https://github.com/cynkra/dm/issues/2275)).

### Features

- Add support for Redshift connections
  ([@owenjonesuob](https://github.com/owenjonesuob),
  [\#2215](https://github.com/cynkra/dm/issues/2215)).

### Chore

- Remove fansi.

- Suggest package used in demo.

- Bump RMariaDB version
  ([\#2244](https://github.com/cynkra/dm/issues/2244)).

- Drop crayon and mockr dependencies
  ([@olivroy](https://github.com/olivroy),
  [\#2220](https://github.com/cynkra/dm/issues/2220)).

### Documentation

- Add cynkra ROR ([\#2282](https://github.com/cynkra/dm/issues/2282)).

- Fix intended links
  ([@guspan-tanadi](https://github.com/guspan-tanadi),
  [\#2278](https://github.com/cynkra/dm/issues/2278)).

- Restore empty space removed by styler
  ([\#2269](https://github.com/cynkra/dm/issues/2269)).

- Use `index.md`.

- Tweak formatting ([@salim-b](https://github.com/salim-b),
  [\#2232](https://github.com/cynkra/dm/issues/2232)).

- Fix typo ([@salim-b](https://github.com/salim-b),
  [\#2218](https://github.com/cynkra/dm/issues/2218)).

### Testing

- Stabilize learning tests
  ([\#2291](https://github.com/cynkra/dm/issues/2291)).

- Fix compatibility with waldo \>= 0.6.0
  ([\#2240](https://github.com/cynkra/dm/issues/2240)).

## dm 1.0.11

CRAN release: 2024-11-25

### Features

- Add support for Redshift connections
  ([@owenjonesuob](https://github.com/owenjonesuob),
  [\#2215](https://github.com/cynkra/dm/issues/2215)).

### Chore

- Drop crayon and mockr dependencies
  ([@olivroy](https://github.com/olivroy),
  [\#2220](https://github.com/cynkra/dm/issues/2220)).

### Documentation

- Use `index.md`.

- Tweak formatting ([@salim-b](https://github.com/salim-b),
  [\#2232](https://github.com/cynkra/dm/issues/2232)).

- Fix typo ([@salim-b](https://github.com/salim-b),
  [\#2218](https://github.com/cynkra/dm/issues/2218)).

### Testing

- Fix compatibility with waldo \>= 0.6.0
  ([\#2240](https://github.com/cynkra/dm/issues/2240)).

## dm 1.0.10

CRAN release: 2024-01-21

### Chore

- Establish compatibility with igraph \>= 2.0.0
  ([\#2187](https://github.com/cynkra/dm/issues/2187)) and withr 3.0.0
  ([\#2184](https://github.com/cynkra/dm/issues/2184)).

- Reexport
  [`tibble::glimpse()`](https://pillar.r-lib.org/reference/glimpse.html)
  instead of
  [`pillar::glimpse()`](https://pillar.r-lib.org/reference/glimpse.html)
  to avoid pillar dependency with roxygen2 7.3.0
  ([\#2179](https://github.com/cynkra/dm/issues/2179)).

## dm 1.0.9

CRAN release: 2024-01-08

### Features

- [`dm_sql()`](https://dm.cynkra.com/dev/reference/dm_sql.md) now
  processes `table_names` with
  [`dbplyr::escape()`](https://dbplyr.tidyverse.org/reference/escape.html),
  therefore also accepting dbplyr objects
  ([\#2129](https://github.com/cynkra/dm/issues/2129)).

### Chore

- Adapt to DBI \>= 1.2.0
  ([\#2148](https://github.com/cynkra/dm/issues/2148),
  [\#2155](https://github.com/cynkra/dm/issues/2155)).

## dm 1.0.8

CRAN release: 2023-11-02

### Bug fixes

- [`copy_dm_to()`](https://dm.cynkra.com/dev/reference/copy_dm_to.md)
  creates string columns of necessary lengths for MariaDB and SQL
  Server. This worked before for SQL Server in dm 1.0.5, now also works
  on MariaDB ([\#311](https://github.com/cynkra/dm/issues/311),
  [\#2066](https://github.com/cynkra/dm/issues/2066),
  [\#2082](https://github.com/cynkra/dm/issues/2082)).

### Features

- Explicitly fail on `compute(temporary = TRUE)`, which never worked
  correctly ([\#2059](https://github.com/cynkra/dm/issues/2059),
  [\#2103](https://github.com/cynkra/dm/issues/2103)).

- Warn about DuckDB not supporting autoincrementing primary keys
  ([\#2099](https://github.com/cynkra/dm/issues/2099)).

### Chore

- Make `check_suggested()` a standalone
  ([\#2054](https://github.com/cynkra/dm/issues/2054)).

### Documentation

- Tweak vignette for `compute(temporary = TRUE)`.

- Update documentation of `check_suggested()`
  ([@olivroy](https://github.com/olivroy),
  [\#2055](https://github.com/cynkra/dm/issues/2055)).

### Performance

- Speed up [`dm()`](https://dm.cynkra.com/dev/reference/dm.md),
  [`new_dm()`](https://dm.cynkra.com/dev/reference/dm.md),
  [`as_dm()`](https://dm.cynkra.com/dev/reference/dm.md) and
  [`dm_validate()`](https://dm.cynkra.com/dev/reference/dm_validate.md).
  [`dm()`](https://dm.cynkra.com/dev/reference/dm.md) and
  [`as_dm()`](https://dm.cynkra.com/dev/reference/dm.md) no longer call
  [`dm_validate()`](https://dm.cynkra.com/dev/reference/dm_validate.md)
  ([\#2108](https://github.com/cynkra/dm/issues/2108)).

### Testing

- Add test for `copy_dm_to(table_names = )`
  ([\#250](https://github.com/cynkra/dm/issues/250),
  [\#2101](https://github.com/cynkra/dm/issues/2101)).

- Work around test failures for dbplyr 2.4.0.

- Remove most skips from tests
  ([\#2052](https://github.com/cynkra/dm/issues/2052)).

## dm 1.0.7

CRAN release: 2023-10-24

### Features

- [`copy_dm_to()`](https://dm.cynkra.com/dev/reference/copy_dm_to.md)
  now warns unconditionally on unsupported arguments, and fails if
  `copy_to` is provided
  ([\#1944](https://github.com/cynkra/dm/issues/1944)). Use the new
  [`dm_sql()`](https://dm.cynkra.com/dev/reference/dm_sql.md) function
  as a replacement for `copy_dm_to(copy_to = )`
  ([\#1915](https://github.com/cynkra/dm/issues/1915),
  [\#2011](https://github.com/cynkra/dm/issues/2011),
  [@jangorecki](https://github.com/jangorecki)).

- New
  [`json_unnest()`](https://dm.cynkra.com/dev/reference/json_unnest.md)
  and
  [`json_unpack()`](https://dm.cynkra.com/dev/reference/json_unpack.md),
  currently implemented for data frames only
  ([\#991](https://github.com/cynkra/dm/issues/991),
  [\#997](https://github.com/cynkra/dm/issues/997)).

- [`dm_rows_append()`](https://dm.cynkra.com/dev/reference/rows-dm.md)
  also works for local dm, with support for autoincrement primary keys
  ([\#1727](https://github.com/cynkra/dm/issues/1727),
  [\#1745](https://github.com/cynkra/dm/issues/1745)).

- Breaking change: Add `check_dots_empty()` calls
  ([\#1929](https://github.com/cynkra/dm/issues/1929),
  [\#1943](https://github.com/cynkra/dm/issues/1943)).

- Test MySQL on GHA
  ([\#1940](https://github.com/cynkra/dm/issues/1940)).

- Improve MySQL compatibility regarding learning of database schemas and
  checking of constraints
  ([\#1938](https://github.com/cynkra/dm/issues/1938)).

### Breaking changes

- Breaking change: Add `check_dots_empty()` calls
  ([\#1929](https://github.com/cynkra/dm/issues/1929),
  [\#1943](https://github.com/cynkra/dm/issues/1943)).

### Bug fixes

- Compatibility with duckdb 0.9.1.

- Minor fixes in
  [`dm_pack_tbl()`](https://dm.cynkra.com/dev/reference/dm_pack_tbl.md)
  and
  [`dm_unwrap_tbl()`](https://dm.cynkra.com/dev/reference/dm_unwrap_tbl.md)
  ([\#1947](https://github.com/cynkra/dm/issues/1947)).

### Documentation

- Use
  [`rlang::check_installed()`](https://rlang.r-lib.org/reference/is_installed.html)
  internally to install missing suggested packages on the fly
  ([@olivroy](https://github.com/olivroy),
  [\#1348](https://github.com/cynkra/dm/issues/1348),
  [\#2036](https://github.com/cynkra/dm/issues/2036),
  [\#2039](https://github.com/cynkra/dm/issues/2039),
  [\#2040](https://github.com/cynkra/dm/issues/2040)).

- Use vectorized
  [`rlang::is_installed()`](https://rlang.r-lib.org/reference/is_installed.html)to
  decide if examples should be run
  ([@olivroy](https://github.com/olivroy),
  [\#2043](https://github.com/cynkra/dm/issues/2043)).

- Recategorize and describe function reference.

- Better error and information messages when querying keys.

- `collect.zoomed_dm()` shows a more helpful error message
  ([\#1929](https://github.com/cynkra/dm/issues/1929),
  [\#1945](https://github.com/cynkra/dm/issues/1945)).

- Add information on default font size to
  [`?dm_draw`](https://dm.cynkra.com/dev/reference/dm_draw.md)
  ([\#1935](https://github.com/cynkra/dm/issues/1935)).

- Add `db-*` rules to Makefile to simplify Docker-based database setup.

- Remove curly braces, add `\pkg`
  ([@olivroy](https://github.com/olivroy),
  [\#2042](https://github.com/cynkra/dm/issues/2042)).

### Performance

- Replace
  [`tibble()`](https://tibble.tidyverse.org/reference/tibble.html) by
  `fast_tibble()` ([@mgirlich](https://github.com/mgirlich),
  [\#1928](https://github.com/cynkra/dm/issues/1928)).

- Replace superseded
  [`dplyr::recode()`](https://dplyr.tidyverse.org/reference/recode.html)
  ([@mgirlich](https://github.com/mgirlich),
  [\#1927](https://github.com/cynkra/dm/issues/1927)).

### Testing

- Remove most skips from tests
  ([\#2052](https://github.com/cynkra/dm/issues/2052)).

- Add explicit unique key to `dm_for_filter()`.

- Add Postgres test for
  [`dm_sql()`](https://dm.cynkra.com/dev/reference/dm_sql.md).

- Switch internal testing to MariaDB.

- Fast offline checks with new `"DM_OFFLINE"` environment variable.

- New GHA checks for the case of missing suggested packages
  ([\#1952](https://github.com/cynkra/dm/issues/1952)).

### Chore

- Make `check_suggested()` a standalone
  ([\#2054](https://github.com/cynkra/dm/issues/2054)).

- Backport changes from attempted CRAN release
  ([\#2046](https://github.com/cynkra/dm/issues/2046)).

- Move magrittr ([\#1975](https://github.com/cynkra/dm/issues/1975),
  [\#1983](https://github.com/cynkra/dm/issues/1983)), DBI
  ([\#1974](https://github.com/cynkra/dm/issues/1974)), and pillar
  ([\#1976](https://github.com/cynkra/dm/issues/1976)) to `"Suggests"`.

- Require RMariaDB 1.3.0, work around tidyverse/dbplyr#1190 and
  tidyverse/dbplyr#1195
  ([\#1989](https://github.com/cynkra/dm/issues/1989)).

### Internal

- Prefer `map*()` over [`lapply()`](https://rdrr.io/r/base/lapply.html)
  and [`vapply()`](https://rdrr.io/r/base/lapply.html).

- `styler::style_pkg(scope = "tokens")`.

- Rename internal `new_dm3()` to `dm_from_def()`
  ([\#1225](https://github.com/cynkra/dm/issues/1225),
  [\#1949](https://github.com/cynkra/dm/issues/1949)).

- Remove dead code ([\#979](https://github.com/cynkra/dm/issues/979),
  [\#1950](https://github.com/cynkra/dm/issues/1950),
  [\#1871](https://github.com/cynkra/dm/issues/1871)).

- Reorganize `build_copy_queries()`
  ([\#1923](https://github.com/cynkra/dm/issues/1923)).

- Avoid
  [`dbplyr::ident_q()`](https://dbplyr.tidyverse.org/reference/ident_q.html)
  ([\#1788](https://github.com/cynkra/dm/issues/1788)).

- Add ellipsis to `tbl_sum()` signature
  ([\#1941](https://github.com/cynkra/dm/issues/1941)).

## dm 1.0.6

CRAN release: 2023-07-21

### Bug fixes

- Compare version returned by
  [`getRversion()`](https://rdrr.io/r/base/numeric_version.html) with
  string instead of number.

- Work around vctrs bug in jsonlite 1.8.5.

### Features

- [`dm_from_con()`](https://dm.cynkra.com/dev/reference/dm_from_con.md)
  gains `.names` argument for pattern-based construction of table names
  in the dm object ([@owenjonesuob](https://github.com/owenjonesuob),
  [\#1790](https://github.com/cynkra/dm/issues/1790)).

- New `dm_set_table_descriptions()`, `dm_get_table_descriptions()` and
  `dm_reset_table_descriptions()` to set table labels as persistent
  attributes of the table object
  ([\#1888](https://github.com/cynkra/dm/issues/1888)).

- [`dm_from_con()`](https://dm.cynkra.com/dev/reference/dm_from_con.md)
  can retrieve multiple schemas, pass a character vector to the `schema`
  argument ([@owenjonesuob](https://github.com/owenjonesuob),
  [\#1533](https://github.com/cynkra/dm/issues/1533),
  [\#1789](https://github.com/cynkra/dm/issues/1789)).

- `build_copy_queries()` and `db_learn_from_db()` improvements
  ([@samssann](https://github.com/samssann),
  [\#1642](https://github.com/cynkra/dm/issues/1642),
  [\#1677](https://github.com/cynkra/dm/issues/1677),
  [\#1739](https://github.com/cynkra/dm/issues/1739)).

- UK support for
  [`dm_draw()`](https://dm.cynkra.com/dev/reference/dm_draw.md)
  ([\#1731](https://github.com/cynkra/dm/issues/1731),
  [\#1877](https://github.com/cynkra/dm/issues/1877)).

- Allow for additional description of tables in dm_draw()
  ([\#1875](https://github.com/cynkra/dm/issues/1875),
  [\#1876](https://github.com/cynkra/dm/issues/1876)).

### Chore

- Establish compatibility with dbplyr 2.3.3 and 2.4.0
  ([@mgirlich](https://github.com/mgirlich),
  [\#1919](https://github.com/cynkra/dm/issues/1919)).

- In
  [`copy_dm_to()`](https://dm.cynkra.com/dev/reference/copy_dm_to.md),
  call [`collect()`](https://dplyr.tidyverse.org/reference/compute.html)
  only when copying data, table by table
  ([@jangorecki](https://github.com/jangorecki),
  [\#1900](https://github.com/cynkra/dm/issues/1900)).

- Use roxyglobals ([\#1838](https://github.com/cynkra/dm/issues/1838)).

- Require purrr \>= 1.0.0 for `list_c()`
  ([\#1847](https://github.com/cynkra/dm/issues/1847),
  [\#1848](https://github.com/cynkra/dm/issues/1848)).

### Documentation

- Add table description to diagram in README.

- Tweak testing instructions. Mention `Makefile` in CONTRIBUTING.md.
  Describe Docker setup
  ([\#1898](https://github.com/cynkra/dm/issues/1898)).

- Vignette corrections
  ([@MikeJohnPage](https://github.com/MikeJohnPage),
  [\#1882](https://github.com/cynkra/dm/issues/1882)).

- Avoid tidyverse package.

### Testing

- Fix local tests ([\#1921](https://github.com/cynkra/dm/issues/1921)).

## dm 1.0.5

CRAN release: 2023-03-16

### Features

- Progress bars for
  [`dm_wrap_tbl()`](https://dm.cynkra.com/dev/reference/dm_wrap_tbl.md)
  and
  [`dm_unwrap_tbl()`](https://dm.cynkra.com/dev/reference/dm_unwrap_tbl.md)
  ([\#835](https://github.com/cynkra/dm/issues/835),
  [\#1450](https://github.com/cynkra/dm/issues/1450)).

### Documentation

- Add cheat sheet as a vignette
  ([\#1653](https://github.com/cynkra/dm/issues/1653)).

- Suggest creating a function for your database `dm` object
  ([\#1827](https://github.com/cynkra/dm/issues/1827),
  [\#1828](https://github.com/cynkra/dm/issues/1828)).

- Add alternative text to author images for pkgdown website
  ([\#1804](https://github.com/cynkra/dm/issues/1804)).

### Chore

- Compatibility with dev jsonlite
  ([\#1837](https://github.com/cynkra/dm/issues/1837)).

- Remove tidyverse dependency
  ([\#1798](https://github.com/cynkra/dm/issues/1798),
  [\#1834](https://github.com/cynkra/dm/issues/1834)).

- Minimal patch to fix multiple match updates
  ([@DavisVaughan](https://github.com/DavisVaughan),
  [\#1806](https://github.com/cynkra/dm/issues/1806)).

- Adapt to rlang 1.1.0 changes
  ([\#1817](https://github.com/cynkra/dm/issues/1817)).

- Make sure [dm](https://dm.cynkra.com/) passes “noSuggests” workflow
  ([\#1659](https://github.com/cynkra/dm/issues/1659)).

## dm 1.0.4

CRAN release: 2023-02-11

### Features

- [`dm_add_pk()`](https://dm.cynkra.com/dev/reference/dm_add_pk.md)
  gains `autoincrement` argument
  ([\#1689](https://github.com/cynkra/dm/issues/1689)), autoincrement
  primary keys are configured on the database with
  [`copy_dm_to()`](https://dm.cynkra.com/dev/reference/copy_dm_to.md)
  ([\#1696](https://github.com/cynkra/dm/issues/1696)).

- New [`dm_add_uk()`](https://dm.cynkra.com/dev/reference/dm_add_uk.md),
  [`dm_rm_uk()`](https://dm.cynkra.com/dev/reference/dm_rm_uk.md) and
  [`dm_get_all_uks()`](https://dm.cynkra.com/dev/reference/dm_get_all_uks.md)
  functions for explicit support of unique keys
  ([\#622](https://github.com/cynkra/dm/issues/622),
  [\#1716](https://github.com/cynkra/dm/issues/1716)).

- [`dm_get_all_pks()`](https://dm.cynkra.com/dev/reference/dm_get_all_pks.md)
  and
  [`dm_get_all_fks()`](https://dm.cynkra.com/dev/reference/dm_get_all_fks.md)
  return output in the order of `table` or `parent_table` argument
  ([\#1707](https://github.com/cynkra/dm/issues/1707)).

- Improve error message for
  [`dm_add_pk()`](https://dm.cynkra.com/dev/reference/dm_add_pk.md) when
  the `columns` argument is missing
  ([\#1644](https://github.com/cynkra/dm/issues/1644),
  [\#1646](https://github.com/cynkra/dm/issues/1646)).

### Breaking changes

- [`dm_get_all_pks()`](https://dm.cynkra.com/dev/reference/dm_get_all_pks.md),
  [`dm_get_all_fks()`](https://dm.cynkra.com/dev/reference/dm_get_all_fks.md),
  and
  [`dm_get_all_uks()`](https://dm.cynkra.com/dev/reference/dm_get_all_uks.md)
  require unquoted table names as input, for consistency with other
  parts of the API ([\#1741](https://github.com/cynkra/dm/issues/1741)).

### Bug fixes

- [`dm_examine_constraints()`](https://dm.cynkra.com/dev/reference/dm_examine_constraints.md)
  works for `dm` objects on the database with compound keys
  ([\#1713](https://github.com/cynkra/dm/issues/1713)).

### Documentation

- Update pkgdown URL to <https://dm.cynkra.com/>
  ([\#1652](https://github.com/cynkra/dm/issues/1652)).

- Fix link rot ([\#1671](https://github.com/cynkra/dm/issues/1671)).

### Internal

- Require dplyr \>= 1.1.0 and lifecycle \>= 1.0.3
  ([\#1771](https://github.com/cynkra/dm/issues/1771),
  [\#1637](https://github.com/cynkra/dm/issues/1637)).

- Checks pass if all suggested packages are missing
  ([\#1659](https://github.com/cynkra/dm/issues/1659)).

- Fix r-devel builds
  ([\#1776](https://github.com/cynkra/dm/issues/1776)).

- [`dm_unpack_tbl()`](https://dm.cynkra.com/dev/reference/dm_unpack_tbl.md)
  sets PK before FK
  ([\#1715](https://github.com/cynkra/dm/issues/1715)).

- Clean up
  [`dm_rows_append()`](https://dm.cynkra.com/dev/reference/rows-dm.md)
  implementation ([\#1714](https://github.com/cynkra/dm/issues/1714)).

- [`dm()`](https://dm.cynkra.com/dev/reference/dm.md) accepts tables
  that are of class `"tbl_sql"` but not `"tbl_dbi"`
  ([\#1695](https://github.com/cynkra/dm/issues/1695),
  [\#1710](https://github.com/cynkra/dm/issues/1710)).

- Use correctly typed missing value for lists
  ([@DavisVaughan](https://github.com/DavisVaughan),
  [\#1686](https://github.com/cynkra/dm/issues/1686)).

## dm 1.0.3

CRAN release: 2022-10-12

### Chore

- Avoid running example without database connection.

## dm 1.0.2

CRAN release: 2022-09-20

### Features

- [`dm_from_con()`](https://dm.cynkra.com/dev/reference/dm_from_con.md)
  can use multiple schemata ([@mgirlich](https://github.com/mgirlich),
  [\#1441](https://github.com/cynkra/dm/issues/1441),
  [\#1449](https://github.com/cynkra/dm/issues/1449)).

- `pack_join(keep = TRUE)` preserves order of packed columns
  ([\#1513](https://github.com/cynkra/dm/issues/1513),
  [\#1514](https://github.com/cynkra/dm/issues/1514)).

- `pack_join(keep = TRUE)` keeps keys of `y` in the resulting packed
  column ([\#1451](https://github.com/cynkra/dm/issues/1451),
  [\#1452](https://github.com/cynkra/dm/issues/1452)).

- New `json_pack.tbl_lazy()` and `json_nest.tbl_lazy()`
  ([\#969](https://github.com/cynkra/dm/issues/969),
  [\#975](https://github.com/cynkra/dm/issues/975)).

### Bug fixes

- [`dm_paste()`](https://dm.cynkra.com/dev/reference/dm_paste.md) gives
  correct output for factor columns with many levels
  ([\#1510](https://github.com/cynkra/dm/issues/1510),
  [\#1511](https://github.com/cynkra/dm/issues/1511)).

### Chore

- Fix compatibility with duckdb 0.5.0
  ([\#1509](https://github.com/cynkra/dm/issues/1509),
  [\#1518](https://github.com/cynkra/dm/issues/1518)).

- Refactor
  [`dm_unwrap_tbl()`](https://dm.cynkra.com/dev/reference/dm_unwrap_tbl.md)
  so it builds a “unwrap plan” first
  ([\#1446](https://github.com/cynkra/dm/issues/1446),
  [\#1447](https://github.com/cynkra/dm/issues/1447)).

- Reenable
  [`dm_rows_update()`](https://dm.cynkra.com/dev/reference/rows-dm.md)
  test ([\#1437](https://github.com/cynkra/dm/issues/1437)).

## dm 1.0.1

CRAN release: 2022-08-06

### Features

- New
  [`dm_deconstruct()`](https://dm.cynkra.com/dev/reference/dm_deconstruct.md)
  creates code to deconstruct a `dm` object into individual keyed tables
  via `pull_tbl(keyed = TRUE)`
  ([\#1354](https://github.com/cynkra/dm/issues/1354)).

### Bug fixes

- Use [`dm_ptype()`](https://dm.cynkra.com/dev/reference/dm_ptype.md) in
  [`dm_gui()`](https://dm.cynkra.com/dev/reference/dm_gui.md), generate
  better code ([\#1353](https://github.com/cynkra/dm/issues/1353)).

## dm 1.0.0

CRAN release: 2022-07-21

### Features

- New [`dm_gui()`](https://dm.cynkra.com/dev/reference/dm_gui.md) for
  interactive editing of `dm` objects
  ([\#1076](https://github.com/cynkra/dm/issues/1076),
  [\#1319](https://github.com/cynkra/dm/issues/1319)).

- [`dm_get_tables()`](https://dm.cynkra.com/dev/reference/dm_get_tables.md)
  and [`pull_tbl()`](https://dm.cynkra.com/dev/reference/pull_tbl.md)
  gain a new `keyed = FALSE` argument. If set to `TRUE`, table objects
  of class `"dm_keyed_tbl"` are returned. These objects inherit from the
  underlying data structure (tibble or lazy table), keep track of
  primary and foreign keys, and can be used later on in a call to
  [`dm()`](https://dm.cynkra.com/dev/reference/dm.md) to recreate a dm
  object with the keys
  ([\#1187](https://github.com/cynkra/dm/issues/1187)).

- New `by_position` argument to
  [`check_subset()`](https://dm.cynkra.com/dev/reference/check_subset.md),
  [`check_set_equality()`](https://dm.cynkra.com/dev/reference/check_set_equality.md),
  [`check_cardinality_...()`](https://dm.cynkra.com/dev/reference/examine_cardinality.md)
  and
  [`examine_cardinality()`](https://dm.cynkra.com/dev/reference/examine_cardinality.md)
  ([\#1253](https://github.com/cynkra/dm/issues/1253)).

- [`dm()`](https://dm.cynkra.com/dev/reference/dm.md) accepts dm objects
  ([\#1226](https://github.com/cynkra/dm/issues/1226)).

- [`dm_examine_constraints()`](https://dm.cynkra.com/dev/reference/dm_examine_constraints.md)
  honors implicit unique keys defined by foreign keys
  ([\#1131](https://github.com/cynkra/dm/issues/1131),
  [\#1209](https://github.com/cynkra/dm/issues/1209)).

### Breaking changes

- [`dm_filter()`](https://dm.cynkra.com/dev/reference/dm_filter.md) is
  now stable, with a new API that avoids exposing an intermediate state
  with filters not yet applied, with a compatibility wrapper
  ([\#424](https://github.com/cynkra/dm/issues/424),
  [\#426](https://github.com/cynkra/dm/issues/426),
  [\#1236](https://github.com/cynkra/dm/issues/1236)).

- [`check_cardinality_...()`](https://dm.cynkra.com/dev/reference/examine_cardinality.md),
  [`examine_cardinality()`](https://dm.cynkra.com/dev/reference/examine_cardinality.md),
  [`check_subset()`](https://dm.cynkra.com/dev/reference/check_subset.md)
  and
  [`check_set_equality()`](https://dm.cynkra.com/dev/reference/check_set_equality.md)
  are now stable and consistently use a common interface with arguments
  named `x`, `y`, `x_select` and `y_select`, with compatibility wrappers
  ([\#1194](https://github.com/cynkra/dm/issues/1194),
  [\#1229](https://github.com/cynkra/dm/issues/1229)).

- [`dm_examine_cardinalities()`](https://dm.cynkra.com/dev/reference/dm_examine_cardinalities.md)
  and
  [`dm_examine_constraints()`](https://dm.cynkra.com/dev/reference/dm_examine_constraints.md)
  are now stable with a new signature and a compatibility wrapper
  ([\#1193](https://github.com/cynkra/dm/issues/1193),
  [\#1195](https://github.com/cynkra/dm/issues/1195)).

- [`dm_apply_filters()`](https://dm.cynkra.com/dev/reference/deprecated.md),
  [`dm_apply_filters_to_tbl()`](https://dm.cynkra.com/dev/reference/deprecated.md)
  and
  [`dm_get_filters()`](https://dm.cynkra.com/dev/reference/deprecated.md)
  are deprecated ([\#424](https://github.com/cynkra/dm/issues/424),
  [\#426](https://github.com/cynkra/dm/issues/426),
  [\#1236](https://github.com/cynkra/dm/issues/1236)).

- [`dm_disambiguate_cols()`](https://dm.cynkra.com/dev/reference/dm_disambiguate_cols.md)
  adds table names as a suffix by default, and gains a `.position`
  argument to restore the original behavior. Arguments `sep` and `quiet`
  are renamed to `.sep` and `.quiet`
  ([\#1293](https://github.com/cynkra/dm/issues/1293),
  [\#1327](https://github.com/cynkra/dm/issues/1327)).

- [`dm_squash_to_tbl()`](https://dm.cynkra.com/dev/reference/deprecated.md)
  is deprecated in favor of the new `.recursive` argument to
  [`dm_flatten_to_tbl()`](https://dm.cynkra.com/dev/reference/dm_flatten_to_tbl.md).
  Arguments `start` and `join` are renamed to `.start` and `.join`
  ([\#1272](https://github.com/cynkra/dm/issues/1272),
  [\#1324](https://github.com/cynkra/dm/issues/1324)).

- [`dm_rm_tbl()`](https://dm.cynkra.com/dev/reference/deprecated.md) is
  deprecated in favor of
  [`dm_select_tbl()`](https://dm.cynkra.com/dev/reference/dm_select_tbl.md)
  ([\#1275](https://github.com/cynkra/dm/issues/1275)).

- [`dm_bind()`](https://dm.cynkra.com/dev/reference/deprecated.md) and
  [`dm_add_tbl()`](https://dm.cynkra.com/dev/reference/deprecated.md)
  are deprecated in favor of
  [`dm()`](https://dm.cynkra.com/dev/reference/dm.md)
  ([\#1226](https://github.com/cynkra/dm/issues/1226)).

- [`rows_truncate()`](https://dm.cynkra.com/dev/reference/deprecated.md)
  and
  [`dm_rows_truncate()`](https://dm.cynkra.com/dev/reference/deprecated.md)
  are deprecated, because they use DDL as opposed to all other verbs
  that use DML ([\#1031](https://github.com/cynkra/dm/issues/1031),
  [\#1321](https://github.com/cynkra/dm/issues/1321)).

- All internal S3 classes now use the `"dm_"` prefix
  ([\#1285](https://github.com/cynkra/dm/issues/1285),
  [\#1339](https://github.com/cynkra/dm/issues/1339)).

- Add ellipses to all generics
  ([\#1298](https://github.com/cynkra/dm/issues/1298)).

### API

- Reexport
  [`tibble()`](https://tibble.tidyverse.org/reference/tibble.html)
  ([\#1279](https://github.com/cynkra/dm/issues/1279)).

- [`dm_ptype()`](https://dm.cynkra.com/dev/reference/dm_ptype.md),
  [`dm_financial()`](https://dm.cynkra.com/dev/reference/dm_financial.md)
  and
  [`dm_pixarfilms()`](https://dm.cynkra.com/dev/reference/dm_pixarfilms.md)
  are stable now ([\#1254](https://github.com/cynkra/dm/issues/1254)).

- Turn all “questioning” functions to “experimental”
  ([\#1030](https://github.com/cynkra/dm/issues/1030),
  [\#1237](https://github.com/cynkra/dm/issues/1237)).

### Performance

- `is_unique_key()`uses
  [`vctrs::vec_count()`](https://vctrs.r-lib.org/reference/vec_count.html)
  on local data frames for speed ([@eutwt](https://github.com/eutwt),
  [\#1247](https://github.com/cynkra/dm/issues/1247)).

- [`check_key()`](https://dm.cynkra.com/dev/reference/check_key.md) uses
  [`vctrs::vec_duplicate_any()`](https://vctrs.r-lib.org/reference/vec_duplicate.html)
  on local data frames for speed ([@eutwt](https://github.com/eutwt),
  [\#1234](https://github.com/cynkra/dm/issues/1234)).

### Bug fixes

- [`dm_draw()`](https://dm.cynkra.com/dev/reference/dm_draw.md) works if
  a table name has a space
  ([\#1219](https://github.com/cynkra/dm/issues/1219)).

- Don’t print rule in
  [`glimpse.dm()`](https://dm.cynkra.com/dev/reference/glimpse.dm.md)
  for empty [`dm()`](https://dm.cynkra.com/dev/reference/dm.md)
  ([\#1208](https://github.com/cynkra/dm/issues/1208)).

### Documentation

- Work around ANSI escape issues in CRAN rendering of vignette
  ([\#1156](https://github.com/cynkra/dm/issues/1156),
  [\#1330](https://github.com/cynkra/dm/issues/1330)).

- Fix column names in
  [`?dm_get_all_pks`](https://dm.cynkra.com/dev/reference/dm_get_all_pks.md)
  ([\#1245](https://github.com/cynkra/dm/issues/1245)).

- Improve contrast for display of
  [`dm_financial()`](https://dm.cynkra.com/dev/reference/dm_financial.md)
  ([\#1073](https://github.com/cynkra/dm/issues/1073),
  [\#1250](https://github.com/cynkra/dm/issues/1250)).

- Add contributing guide
  ([\#1222](https://github.com/cynkra/dm/issues/1222)).

### Internal

- Use sensible node and edge IDs, corresponding to the data model, in
  SVG graph ([\#1214](https://github.com/cynkra/dm/issues/1214)).

- Tests for datamodelr code
  ([\#1215](https://github.com/cynkra/dm/issues/1215)).

## dm 0.3.0

CRAN release: 2022-07-06

### Features

- Implement
  [`glimpse()`](https://pillar.r-lib.org/reference/glimpse.html) for
  `zoomed_df` ([@IndrajeetPatil](https://github.com/IndrajeetPatil),
  [\#1003](https://github.com/cynkra/dm/issues/1003),
  [\#1161](https://github.com/cynkra/dm/issues/1161)).

- Remove message about automated key selection with the `select`
  argument in joins on `zoomed_df`
  ([@IndrajeetPatil](https://github.com/IndrajeetPatil),
  [\#1113](https://github.com/cynkra/dm/issues/1113),
  [\#1176](https://github.com/cynkra/dm/issues/1176)).

- `dm_from_con(learn_keys = TRUE)` works for MariaDB
  ([\#1106](https://github.com/cynkra/dm/issues/1106),
  [\#1123](https://github.com/cynkra/dm/issues/1123),
  [\#1169](https://github.com/cynkra/dm/issues/1169),
  [@maelle](https://github.com/maelle)), and for compound keys in
  Postgres ([\#342](https://github.com/cynkra/dm/issues/342),
  [\#1006](https://github.com/cynkra/dm/issues/1006),
  [\#1016](https://github.com/cynkra/dm/issues/1016)) and SQL Server
  ([\#342](https://github.com/cynkra/dm/issues/342)).

- New
  [`json_pack_join()`](https://dm.cynkra.com/dev/reference/json_pack_join.md),
  [`json_nest_join()`](https://dm.cynkra.com/dev/reference/json_nest_join.md),
  [`json_pack()`](https://dm.cynkra.com/dev/reference/json_pack.md) and
  [`json_nest()`](https://dm.cynkra.com/dev/reference/json_nest.md),
  similar to
  [`pack_join()`](https://dm.cynkra.com/dev/reference/pack_join.md),
  [`dplyr::nest_join()`](https://dplyr.tidyverse.org/reference/nest_join.html),
  [`tidyr::pack()`](https://tidyr.tidyverse.org/reference/pack.html) and
  [`tidyr::nest()`](https://tidyr.tidyverse.org/reference/nest.html),
  but create character columns
  ([\#917](https://github.com/cynkra/dm/issues/917),
  [\#918](https://github.com/cynkra/dm/issues/918),
  [\#973](https://github.com/cynkra/dm/issues/973),
  [\#974](https://github.com/cynkra/dm/issues/974)).

- [`nest_join()`](https://dplyr.tidyverse.org/reference/nest_join.html)
  and [`pack_join()`](https://dm.cynkra.com/dev/reference/pack_join.md)
  support `zoomed_df` objects
  ([\#1119](https://github.com/cynkra/dm/issues/1119),
  [@IndrajeetPatil](https://github.com/IndrajeetPatil)).

### API

- Marked stable functions as stable, in particular
  [`dm()`](https://dm.cynkra.com/dev/reference/dm.md) and related
  functions ([\#1032](https://github.com/cynkra/dm/issues/1032),
  [\#1040](https://github.com/cynkra/dm/issues/1040)).

- Remove own `rows_*()` implementation for lazy tables, they are now
  available in dbplyr \>= 2.2.0
  ([\#912](https://github.com/cynkra/dm/issues/912),
  [\#1024](https://github.com/cynkra/dm/issues/1024),
  [\#1028](https://github.com/cynkra/dm/issues/1028)).

- Deprecate
  [`dm_join_to_tbl()`](https://dm.cynkra.com/dev/reference/deprecated.md),
  [`dm_is_referenced()`](https://dm.cynkra.com/dev/reference/deprecated.md)
  and
  [`dm_get_referencing_tables()`](https://dm.cynkra.com/dev/reference/deprecated.md)
  ([\#1038](https://github.com/cynkra/dm/issues/1038)).

- New
  [`dm_validate()`](https://dm.cynkra.com/dev/reference/dm_validate.md)
  replaces now deprecated
  [`validate_dm()`](https://dm.cynkra.com/dev/reference/deprecated.md)
  ([\#1033](https://github.com/cynkra/dm/issues/1033)).

- [`dm_get_con()`](https://dm.cynkra.com/dev/reference/dm_get_con.md)
  and
  [`dm_get_filters()`](https://dm.cynkra.com/dev/reference/deprecated.md)
  use `dm` as argument name
  ([\#1034](https://github.com/cynkra/dm/issues/1034),
  [\#1036](https://github.com/cynkra/dm/issues/1036)).

- Mark `...` in
  [`dm_flatten_to_tbl()`](https://dm.cynkra.com/dev/reference/dm_flatten_to_tbl.md)
  as experimental ([\#1037](https://github.com/cynkra/dm/issues/1037)).

- Add ellipses to
  [`dm_disambiguate_cols()`](https://dm.cynkra.com/dev/reference/dm_disambiguate_cols.md),
  [`dm_draw()`](https://dm.cynkra.com/dev/reference/dm_draw.md),
  [`dm_examine_constraints()`](https://dm.cynkra.com/dev/reference/dm_examine_constraints.md),
  [`dm_nycflights13()`](https://dm.cynkra.com/dev/reference/dm_nycflights13.md)
  and
  [`dm_pixarfilms()`](https://dm.cynkra.com/dev/reference/dm_pixarfilms.md)
  ([\#1035](https://github.com/cynkra/dm/issues/1035)).

- New
  [`dm_from_con()`](https://dm.cynkra.com/dev/reference/dm_from_con.md),
  soft-deprecated
  [`dm_from_src()`](https://dm.cynkra.com/dev/reference/dm_from_src.md)
  ([\#1014](https://github.com/cynkra/dm/issues/1014),
  [\#1018](https://github.com/cynkra/dm/issues/1018),
  [\#1044](https://github.com/cynkra/dm/issues/1044)).

- Moved
  [`pack_join()`](https://dm.cynkra.com/dev/reference/pack_join.md)
  arguments past the ellipsis for consistency
  ([\#920](https://github.com/cynkra/dm/issues/920),
  [\#921](https://github.com/cynkra/dm/issues/921)).

### Bug fixes

- Compatibility fix for writing to SQL Server tables with dbplyr \>=
  2.2.0.

### Documentation

- The pkgdown site now uses BS5 for greater readability
  ([\#1067](https://github.com/cynkra/dm/issues/1067),
  [@maelle](https://github.com/maelle)).

- Better message for
  [`dm_rows_...()`](https://dm.cynkra.com/dev/reference/rows-dm.md)
  functions if the `in_place` argument is missing
  ([@IndrajeetPatil](https://github.com/IndrajeetPatil),
  [\#414](https://github.com/cynkra/dm/issues/414),
  [\#1160](https://github.com/cynkra/dm/issues/1160)).

- Better message for learning error
  ([\#1081](https://github.com/cynkra/dm/issues/1081)).

- Greatly improved consistency, content, and language across all
  articles ([@IndrajeetPatil](https://github.com/IndrajeetPatil),
  [\#1056](https://github.com/cynkra/dm/issues/1056),
  [\#1132](https://github.com/cynkra/dm/issues/1132),
  [\#1157](https://github.com/cynkra/dm/issues/1157),
  [\#1166](https://github.com/cynkra/dm/issues/1166),
  [\#1079](https://github.com/cynkra/dm/issues/1079),
  [\#1082](https://github.com/cynkra/dm/issues/1082),
  [\#1098](https://github.com/cynkra/dm/issues/1098),
  [\#1100](https://github.com/cynkra/dm/issues/1100),
  [\#1101](https://github.com/cynkra/dm/issues/1101),
  [\#1103](https://github.com/cynkra/dm/issues/1103),
  [\#1112](https://github.com/cynkra/dm/issues/1112),
  [\#1120](https://github.com/cynkra/dm/issues/1120),
  [\#1158](https://github.com/cynkra/dm/issues/1158),
  [\#1175](https://github.com/cynkra/dm/issues/1175)).

- Tweaks of intro vignette and README
  ([\#1066](https://github.com/cynkra/dm/issues/1066),
  [\#1075](https://github.com/cynkra/dm/issues/1075),
  [@maelle](https://github.com/maelle)).

- Document
  [`glimpse()`](https://pillar.r-lib.org/reference/glimpse.html) S3
  method for `dm` ([@IndrajeetPatil](https://github.com/IndrajeetPatil),
  [\#1121](https://github.com/cynkra/dm/issues/1121)).

- Update credentials to fallback databases for
  [`dm_financial()`](https://dm.cynkra.com/dev/reference/dm_financial.md)
  hosted on pacha.dev ([\#916](https://github.com/cynkra/dm/issues/916),
  [@pachadotdev](https://github.com/pachadotdev)), also used now for
  vignettes ([\#1118](https://github.com/cynkra/dm/issues/1118)) and in
  [`dm_from_con()`](https://dm.cynkra.com/dev/reference/dm_from_con.md)
  example ([\#993](https://github.com/cynkra/dm/issues/993)).

- Update license year
  ([\#1029](https://github.com/cynkra/dm/issues/1029)).

### Internal

- Switch to duckdb as default database backend
  ([\#1179](https://github.com/cynkra/dm/issues/1179)).

- Test duckdb and MariaDB on GHA
  ([\#1091](https://github.com/cynkra/dm/issues/1091),
  [\#1136](https://github.com/cynkra/dm/issues/1136)).

## dm 0.2.8

CRAN release: 2022-04-08

### Features

- [`pack_join()`](https://dm.cynkra.com/dev/reference/pack_join.md)
  works correctly if `name` is the same as an existing column in either
  table. In some cases a column is overwritten, this is consistent with
  [`nest_join()`](https://dplyr.tidyverse.org/reference/nest_join.html)
  behavior ([\#864](https://github.com/cynkra/dm/issues/864),
  [\#865](https://github.com/cynkra/dm/issues/865)).
- Messages that suggest the installation of optional packages are shown
  only once per session
  ([\#852](https://github.com/cynkra/dm/issues/852)).
- [`dm_insert_zoomed()`](https://dm.cynkra.com/dev/reference/dm_zoom_to.md)
  uses the color from the zoomed table for the new table
  ([\#750](https://github.com/cynkra/dm/issues/750),
  [\#863](https://github.com/cynkra/dm/issues/863)).
- [`copy_dm_to()`](https://dm.cynkra.com/dev/reference/copy_dm_to.md)
  consumes less memory and is faster when writing to SQL Server
  ([\#855](https://github.com/cynkra/dm/issues/855)).

### Bug fixes

- Remove extra spaces in output when examining constraints with compound
  keys ([\#868](https://github.com/cynkra/dm/issues/868)).
- Fix column tracking for foreign keys
  ([\#856](https://github.com/cynkra/dm/issues/856),
  [\#857](https://github.com/cynkra/dm/issues/857)).
- [`copy_dm_to()`](https://dm.cynkra.com/dev/reference/copy_dm_to.md)
  shows progress bars again
  ([\#850](https://github.com/cynkra/dm/issues/850),
  [\#855](https://github.com/cynkra/dm/issues/855)).
- Progress bars use the console width
  ([\#853](https://github.com/cynkra/dm/issues/853)).
- Avoid calling
  [`dbAppendTable()`](https://dbi.r-dbi.org/reference/dbAppendTable.html)
  for zero-row tables
  ([\#847](https://github.com/cynkra/dm/issues/847)).

### Internal

- Require rlang 1.0.1
  ([\#840](https://github.com/cynkra/dm/issues/840)).

## dm 0.2.7

CRAN release: 2022-02-03

### Features

- New
  [`dm_wrap_tbl()`](https://dm.cynkra.com/dev/reference/dm_wrap_tbl.md),
  [`dm_unwrap_tbl()`](https://dm.cynkra.com/dev/reference/dm_unwrap_tbl.md),
  [`dm_nest_tbl()`](https://dm.cynkra.com/dev/reference/dm_nest_tbl.md),
  [`dm_unnest_tbl()`](https://dm.cynkra.com/dev/reference/dm_unnest_tbl.md),
  [`dm_pack_tbl()`](https://dm.cynkra.com/dev/reference/dm_pack_tbl.md)
  and
  [`dm_unpack_tbl()`](https://dm.cynkra.com/dev/reference/dm_unpack_tbl.md)
  ([\#595](https://github.com/cynkra/dm/issues/595),
  [\#733](https://github.com/cynkra/dm/issues/733),
  [\#737](https://github.com/cynkra/dm/issues/737)).
- New `dm_examine_cardinality()`
  ([\#264](https://github.com/cynkra/dm/issues/264),
  [\#735](https://github.com/cynkra/dm/issues/735)).
- New [`pack_join()`](https://dm.cynkra.com/dev/reference/pack_join.md)
  generic and method for data frames, the same to
  [`tidyr::pack()`](https://tidyr.tidyverse.org/reference/pack.html) as
  [`dplyr::nest_join()`](https://dplyr.tidyverse.org/reference/nest_join.html)
  is to
  [`tidyr::nest()`](https://tidyr.tidyverse.org/reference/nest.html)
  ([\#721](https://github.com/cynkra/dm/issues/721),
  [\#722](https://github.com/cynkra/dm/issues/722)).
- [`dm_pixarfilms()`](https://dm.cynkra.com/dev/reference/dm_pixarfilms.md)
  is exported and gains a `consistent = FALSE` argument; if `TRUE` the
  data is modified so that all referential constraints are satisfied
  ([\#703](https://github.com/cynkra/dm/issues/703),
  [\#707](https://github.com/cynkra/dm/issues/707),
  [\#708](https://github.com/cynkra/dm/issues/708),
  [@erictleung](https://github.com/erictleung)).

### Bug fixes

- `db_schema_...()` functions no longer pro-actively check for schema
  existence ([\#672](https://github.com/cynkra/dm/issues/672),
  [\#815](https://github.com/cynkra/dm/issues/815),
  [\#771](https://github.com/cynkra/dm/issues/771)).
- `db_schema_list.Microsoft SQL Server` no longer ignoring schemas for
  which the owner cannot be found
  ([\#815](https://github.com/cynkra/dm/issues/815),
  [\#771](https://github.com/cynkra/dm/issues/771)).
- [`copy_dm_to()`](https://dm.cynkra.com/dev/reference/copy_dm_to.md)
  works with DuckDB again, the SQL statements to define the tables and
  indexes are now created by us
  ([\#701](https://github.com/cynkra/dm/issues/701),
  [\#709](https://github.com/cynkra/dm/issues/709)).

### Internal

- Establish compatibility with rlang 1.0.0
  ([\#756](https://github.com/cynkra/dm/issues/756)).
- Simplify database checks on GitHub Actions
  ([\#712](https://github.com/cynkra/dm/issues/712)).

## dm 0.2.6

CRAN release: 2021-11-21

### Features

- New
  [`dm_pixarfilms()`](https://dm.cynkra.com/dev/reference/dm_pixarfilms.md)
  creates a dm object with data from the {pixarfilms} package
  ([\#600](https://github.com/cynkra/dm/issues/600),
  [@erictleung](https://github.com/erictleung)).
- [`check_cardinality_0_1()`](https://dm.cynkra.com/dev/reference/examine_cardinality.md),
  [`check_cardinality_0_n()`](https://dm.cynkra.com/dev/reference/examine_cardinality.md),
  [`check_cardinality_1_1()`](https://dm.cynkra.com/dev/reference/examine_cardinality.md),
  [`check_cardinality_1_n()`](https://dm.cynkra.com/dev/reference/examine_cardinality.md),
  and
  [`examine_cardinality()`](https://dm.cynkra.com/dev/reference/examine_cardinality.md)
  now support compound keys
  ([\#524](https://github.com/cynkra/dm/issues/524)).
- [`check_subset()`](https://dm.cynkra.com/dev/reference/check_subset.md)
  and
  [`check_set_equality()`](https://dm.cynkra.com/dev/reference/check_set_equality.md)
  support compound keys
  ([\#523](https://github.com/cynkra/dm/issues/523)).
- [`dm_paste()`](https://dm.cynkra.com/dev/reference/dm_paste.md) adds
  the `on_delete` argument to
  [`dm_add_fk()`](https://dm.cynkra.com/dev/reference/dm_add_fk.md)
  ([\#673](https://github.com/cynkra/dm/issues/673)).
- [`dm_disambiguate_cols()`](https://dm.cynkra.com/dev/reference/dm_disambiguate_cols.md)
  also disambiguates columns used in keys, to support correct
  disambiguation for compound keys
  ([\#662](https://github.com/cynkra/dm/issues/662)).
- [`dm_disambiguate_cols()`](https://dm.cynkra.com/dev/reference/dm_disambiguate_cols.md)
  now emits the source code equivalent of a renaming operation
  ([\#684](https://github.com/cynkra/dm/issues/684)).
- [`dm_examine_constraints()`](https://dm.cynkra.com/dev/reference/dm_examine_constraints.md)
  uses backticks to surround table names
  ([\#687](https://github.com/cynkra/dm/issues/687)).

### Bug fixes

- [`decompose_table()`](https://dm.cynkra.com/dev/reference/decompose_table.md)
  now avoids creating `NA` values in the key column
  ([\#580](https://github.com/cynkra/dm/issues/580)).
- [`dm_draw()`](https://dm.cynkra.com/dev/reference/dm_draw.md) works
  with empty tables ([\#585](https://github.com/cynkra/dm/issues/585)).

### Internal

- Fix compatibility with dplyr 1.0.8
  ([\#698](https://github.com/cynkra/dm/issues/698)).

## dm 0.2.5

CRAN release: 2021-10-15

### Features

- [`mutate()`](https://dplyr.tidyverse.org/reference/mutate.html),
  [`transmute()`](https://dplyr.tidyverse.org/reference/transmute.html),
  [`distinct()`](https://dplyr.tidyverse.org/reference/distinct.html)
  and
  [`summarize()`](https://dplyr.tidyverse.org/reference/summarise.html)
  now support
  [`dplyr::across()`](https://dplyr.tidyverse.org/reference/across.html)
  and extra arguments
  ([\#640](https://github.com/cynkra/dm/issues/640)).
- Key tracking for the first three verbs is less strict and based on
  name equality ([\#663](https://github.com/cynkra/dm/issues/663)).
- [`relocate()`](https://dplyr.tidyverse.org/reference/relocate.html)
  now works on zoomed `dm` objects
  ([\#666](https://github.com/cynkra/dm/issues/666)).
- [`dm_add_fk()`](https://dm.cynkra.com/dev/reference/dm_add_fk.md)
  gains `on_delete` argument which
  [`copy_dm_to()`](https://dm.cynkra.com/dev/reference/copy_dm_to.md)
  picks up and translates to an `ON DELETE CASCADE` or
  `ON DELETE NO ACTION` specification for the foreign key
  ([\#649](https://github.com/cynkra/dm/issues/649)).
- `dm_copy_to()` defines foreign keys during table creation, for all
  databases except DuckDB. Tables are created in topological order
  ([\#658](https://github.com/cynkra/dm/issues/658)). For cyclic
  relationship graphs, table creation is attempted in the original order
  and may fail ([\#664](https://github.com/cynkra/dm/issues/664)).
- [`waldo::compare()`](https://waldo.r-lib.org/reference/compare.html)
  shows better output for dm objects
  ([\#642](https://github.com/cynkra/dm/issues/642)).
- [`dm_paste()`](https://dm.cynkra.com/dev/reference/dm_paste.md) output
  uses trailing commas in the
  [`dm::dm()`](https://dm.cynkra.com/dev/reference/dm.md) and
  [`tibble::tibble()`](https://tibble.tidyverse.org/reference/tibble.html)
  calls, and sorts column attributes by name, for better modularity
  ([\#641](https://github.com/cynkra/dm/issues/641)).

### Breaking changes

- New
  [`db_schema_create()`](https://dm.cynkra.com/dev/reference/db_schema_create.md),
  [`db_schema_drop()`](https://dm.cynkra.com/dev/reference/db_schema_drop.md),
  [`db_schema_exists()`](https://dm.cynkra.com/dev/reference/db_schema_exists.md)
  and
  [`db_schema_list()`](https://dm.cynkra.com/dev/reference/db_schema_list.md)
  replace the corresponding `sql_schema_*()` functions, the latter are
  soft-deprecated ([\#670](https://github.com/cynkra/dm/issues/670)).
  The connection argument to `db_schema_*()` is called `con`, not `dest`
  ([\#668](https://github.com/cynkra/dm/issues/668)).

### Bug fixes

- [`copy_dm_to()`](https://dm.cynkra.com/dev/reference/copy_dm_to.md)
  and `sql_create_schema()` no longer actively check for schema
  existence ([\#644](https://github.com/cynkra/dm/issues/644),
  [\#660](https://github.com/cynkra/dm/issues/660)).
- Add newline after `OUTPUT` clause for SQL Server
  ([\#647](https://github.com/cynkra/dm/issues/647)).
- Fix `sql_rows_delete()` with `returning` argument for SQL Server
  ([\#645](https://github.com/cynkra/dm/issues/645)).

### Internal

- Remove method only needed for RSQLite \< 2.2.8, add warning if loaded
  RSQLite version is \<= 2.2.8
  ([\#632](https://github.com/cynkra/dm/issues/632)).
- Adapt MSSQL tests to testthat update
  ([\#648](https://github.com/cynkra/dm/issues/648)).

## dm 0.2.4

CRAN release: 2021-09-30

### Features

- [`rows_insert()`](https://dplyr.tidyverse.org/reference/rows.html),
  [`rows_update()`](https://dplyr.tidyverse.org/reference/rows.html) and
  [`rows_delete()`](https://dplyr.tidyverse.org/reference/rows.html)
  gain `returning` argument. In combination with `in_place = TRUE` this
  argument makes the newly inserted rows accessible via
  `get_returning_rows()` after the operation completes
  ([\#593](https://github.com/cynkra/dm/issues/593),
  [@mgirlich](https://github.com/mgirlich)).
- Implement
  [`rows_patch()`](https://dplyr.tidyverse.org/reference/rows.html) for
  DBI connections ([\#610](https://github.com/cynkra/dm/issues/610),
  [@mgirlich](https://github.com/mgirlich)).
- Use `NO ACTION` instead of `CASCADE` in foreign key constraints to
  permit self-references.
- [`dm_from_src()`](https://dm.cynkra.com/dev/reference/dm_from_src.md)
  supports
  [`pool::Pool`](http://rstudio.github.io/pool/reference/Pool-class.md)
  objects ([\#599](https://github.com/cynkra/dm/issues/599),
  [@moodymudskipper](https://github.com/moodymudskipper)).
- Better error message for
  [`dm_rows_update()`](https://dm.cynkra.com/dev/reference/rows-dm.md)
  and related functions for dm objects with tables without primary key
  ([\#592](https://github.com/cynkra/dm/issues/592)).
- [`glimpse()`](https://pillar.r-lib.org/reference/glimpse.html) is
  implemented for `dm` objects
  ([\#605](https://github.com/cynkra/dm/issues/605)).
- Support DuckDB in
  [`rows_insert()`](https://dplyr.tidyverse.org/reference/rows.html),
  [`rows_update()`](https://dplyr.tidyverse.org/reference/rows.html) and
  [`rows_delete()`](https://dplyr.tidyverse.org/reference/rows.html)
  ([\#617](https://github.com/cynkra/dm/issues/617),
  [@mgirlich](https://github.com/mgirlich)).

### Bug fixes

- Fix
  [`dm_zoom_to()`](https://dm.cynkra.com/dev/reference/dm_zoom_to.md)
  for `dm` objects with an empty table
  ([\#626](https://github.com/cynkra/dm/issues/626),
  [@moodymudskipper](https://github.com/moodymudskipper)).
- Avoid generating invalid `dm` objects in some corner cases
  ([\#596](https://github.com/cynkra/dm/issues/596)).

### Internal

- [`sql_schema_list()`](https://dm.cynkra.com/dev/reference/deprecated.md)
  supports
  [`pool::Pool`](http://rstudio.github.io/pool/reference/Pool-class.md)
  objects ([\#633](https://github.com/cynkra/dm/issues/633),
  [@brancengregory](https://github.com/brancengregory)).
- Establish compatibility with pillar 1.6.2, vctrs \> 0.3.8 and rlang \>
  0.4.11 ([\#613](https://github.com/cynkra/dm/issues/613)).
- Use `check_suggested()` everywhere
  ([\#572](https://github.com/cynkra/dm/issues/572),
  [@moodymudskipper](https://github.com/moodymudskipper)).
- Add CI run for validating all new `dm` objects
  ([\#597](https://github.com/cynkra/dm/issues/597)).

## dm 0.2.3

CRAN release: 2021-06-20

### Bug fixes

- Fix
  [`rows_truncate()`](https://dm.cynkra.com/dev/reference/deprecated.md)
  in interactive mode
  ([\#588](https://github.com/cynkra/dm/issues/588)).

### Features

- Implement
  [`rows_delete()`](https://dplyr.tidyverse.org/reference/rows.html) for
  databases ([\#589](https://github.com/cynkra/dm/issues/589)).

### Internal

- Skip examples that might require internet access on non-CI platforms.

## dm 0.2.2

CRAN release: 2021-06-13

### Features

- [`dm_examine_constraints()`](https://dm.cynkra.com/dev/reference/dm_examine_constraints.md),
  [`dm_rows_insert()`](https://dm.cynkra.com/dev/reference/rows-dm.md)
  and related,
  [`copy_dm_to()`](https://dm.cynkra.com/dev/reference/copy_dm_to.md)
  and
  [`collect.dm()`](https://dm.cynkra.com/dev/reference/materialize.md)
  show progress bars in interactive mode via the progress package. The
  new `progress = NA` argument controls the behavior
  ([\#262](https://github.com/cynkra/dm/issues/262),
  [@moodymudskipper](https://github.com/moodymudskipper)).
- [`copy_dm_to()`](https://dm.cynkra.com/dev/reference/copy_dm_to.md)
  gains a `copy_to` argument to support other ways of copying data to
  the database ([\#582](https://github.com/cynkra/dm/issues/582)).

### Internal

- Always run database tests on sqlite for df source.
- Establish compatibility with testthat \> 3.0.2
  ([\#566](https://github.com/cynkra/dm/issues/566),
  [@moodymudskipper](https://github.com/moodymudskipper)).

## dm 0.2.1

CRAN release: 2021-05-11

### Breaking changes

- [`dm_get_all_fks()`](https://dm.cynkra.com/dev/reference/dm_get_all_fks.md)
  returns a data frame with a `parent_key_cols` instead of a
  `parent_pk_cols` column (introduced in dm 0.2.0), to reflect the fact
  that a foreign key no longer necessarily points to a primary key
  ([\#562](https://github.com/cynkra/dm/issues/562)).
- `*_pk()` and `*_fk()` functions now verify that the dots are actually
  empty ([\#536](https://github.com/cynkra/dm/issues/536)).
- [`dm_get_pk()`](https://dm.cynkra.com/dev/reference/dm_get_pk.md) is
  deprecated in favor of
  [`dm_get_all_pks()`](https://dm.cynkra.com/dev/reference/dm_get_all_pks.md)
  ([\#561](https://github.com/cynkra/dm/issues/561)).
- [`dm_has_fk()`](https://dm.cynkra.com/dev/reference/dm_has_fk.md) and
  [`dm_get_fk()`](https://dm.cynkra.com/dev/reference/dm_has_fk.md) are
  deprecated in favor of
  [`dm_get_all_fks()`](https://dm.cynkra.com/dev/reference/dm_get_all_fks.md)
  ([\#561](https://github.com/cynkra/dm/issues/561)).

### Features

- [`dm_add_fk()`](https://dm.cynkra.com/dev/reference/dm_add_fk.md)
  gains `ref_columns` argument that supports creating foreign keys to
  non-primary keys ([\#402](https://github.com/cynkra/dm/issues/402)).
- [`dm_get_all_pks()`](https://dm.cynkra.com/dev/reference/dm_get_all_pks.md)
  gains `table` argument for filtering the returned primary keys
  ([\#560](https://github.com/cynkra/dm/issues/560)).
- [`dm_get_all_fks()`](https://dm.cynkra.com/dev/reference/dm_get_all_fks.md)
  gains `parent_table` argument for filtering the returned foreign keys
  ([\#560](https://github.com/cynkra/dm/issues/560)).
- [`dm_rm_fk()`](https://dm.cynkra.com/dev/reference/dm_rm_fk.md) gains
  an optional `ref_columns` argument. This function now supports removal
  of multiple foreign keys filtered by parent or child table or columns,
  with a message ([\#559](https://github.com/cynkra/dm/issues/559)).
- [`dm_rm_pk()`](https://dm.cynkra.com/dev/reference/dm_rm_pk.md) gains
  `columns` argument and allows filtering by columns and by tables or
  removing all primary keys. The `rm_referencing_fks` argument has been
  deprecated in favor of the new `fail_fk` argument
  ([\#558](https://github.com/cynkra/dm/issues/558)).
- [`dm_get_all_fks()`](https://dm.cynkra.com/dev/reference/dm_get_all_fks.md)
  has been optimized for speed and no longer sorts the keys
  ([\#560](https://github.com/cynkra/dm/issues/560)).
- dm operations are now slightly faster overall.

### Internal

- The internal data structure for a dm object has changed to accommodate
  foreign keys to other columns than the primary key. An upgrade message
  is shown when working with a dm object from an earlier version,
  e.g. if it was loaded from a cache or an `.rds` file
  ([\#402](https://github.com/cynkra/dm/issues/402)).
- Drop `"dm_v1"` class from dm objects again, this would have made every
  S3 dispatch more costly. Relying on an internal `"version"` attribute
  instead ([\#547](https://github.com/cynkra/dm/issues/547)).

## dm 0.2.0

CRAN release: 2021-05-03

### Breaking changes

- Deprecate
  [`dm_get_src()`](https://dm.cynkra.com/dev/reference/dplyr_src.md)
  [`tbl.dm()`](https://dm.cynkra.com/dev/reference/dplyr_src.md),
  [`src_tbls.dm()`](https://dm.cynkra.com/dev/reference/dplyr_src.md),
  [`copy_to.dm()`](https://dm.cynkra.com/dev/reference/dplyr_src.md).
  These functions have better alternatives and use the notion of a “data
  source” which is being phased out of dplyr
  ([\#527](https://github.com/cynkra/dm/issues/527)).
- `*_pk()` and `*_fk()` functions gain an ellipsis argument that comes
  before `check`, `force` and `rm_referencing_fks` arguments
  ([\#520](https://github.com/cynkra/dm/issues/520)).

### Features

- [`dm_add_pk()`](https://dm.cynkra.com/dev/reference/dm_add_pk.md) and
  [`dm_add_fk()`](https://dm.cynkra.com/dev/reference/dm_add_fk.md)
  support compound keys via the [`c()`](https://rdrr.io/r/base/c.html)
  notation, e.g. `dm_add_pk(dm, table, c(col1, col2))`.
  [`dm_nycflights13()`](https://dm.cynkra.com/dev/reference/dm_nycflights13.md)
  returns a data model with compound keys by default. Use
  `compound = FALSE` to return the data model from dm v0.1.13 or earlier
  ([\#3](https://github.com/cynkra/dm/issues/3)).
- [`dm_get_all_fks()`](https://dm.cynkra.com/dev/reference/dm_get_all_fks.md)
  includes `parent_pk_cols` column that describes the primary key
  columns of the parent table
  ([\#335](https://github.com/cynkra/dm/issues/335)).
- [`dm_from_src()`](https://dm.cynkra.com/dev/reference/dm_from_src.md)
  supports the `schema` argument also for MariaDB and MySQL databases
  ([\#516](https://github.com/cynkra/dm/issues/516)).
- dm objects now inherit from `"dm_v1"` in addition to `"dm"`, to allow
  backward-compatible changes of the internal format
  ([\#521](https://github.com/cynkra/dm/issues/521)).
- Use hack to create compound primary keys on the database
  ([\#522](https://github.com/cynkra/dm/issues/522)).
- [`dm_examine_constraints()`](https://dm.cynkra.com/dev/reference/dm_examine_constraints.md)
  and other check functions count the number of rows that violate
  constraints for primary and foreign keys
  ([\#335](https://github.com/cynkra/dm/issues/335)).
- `copy_dm_to(set_key_constraints = FALSE)` downgrades unique indexes to
  regular indexes ([\#335](https://github.com/cynkra/dm/issues/335)).
- [`rows_truncate()`](https://dm.cynkra.com/dev/reference/deprecated.md)
  implemented for data frames
  ([\#335](https://github.com/cynkra/dm/issues/335)).
- [`dm_enum_fk_candidates()`](https://dm.cynkra.com/dev/reference/dm_enum_fk_candidates.md)
  enumerates column in the order they apper in the table
  ([\#335](https://github.com/cynkra/dm/issues/335)).

## dm 0.1.13

CRAN release: 2021-04-25

### Features

- [`dm_draw()`](https://dm.cynkra.com/dev/reference/dm_draw.md) gains
  `column_types` argument, if `TRUE` the column type is shown for each
  displayed column ([\#444](https://github.com/cynkra/dm/issues/444),
  [@samssann](https://github.com/samssann)).
- [`copy_dm_to()`](https://dm.cynkra.com/dev/reference/copy_dm_to.md)
  gains `schema` argument
  ([\#432](https://github.com/cynkra/dm/issues/432)).
- [`dm_from_src()`](https://dm.cynkra.com/dev/reference/dm_from_src.md)
  gains `dbname` argument for MSSQL
  ([\#472](https://github.com/cynkra/dm/issues/472)).

### Bug fixes

- Fix [`rows_update()`](https://dplyr.tidyverse.org/reference/rows.html)
  when multiple columns are updated
  ([\#488](https://github.com/cynkra/dm/issues/488),
  [@samssann](https://github.com/samssann)).

### Performance

- [`enum_fk_candidates()`](https://dm.cynkra.com/dev/reference/dm_enum_fk_candidates.md)
  now only checks distinct values, this improves performance for large
  tables. As a consequence, only the number of distinct values is
  reported for mismatches, not the number of mismatching rows/entries
  ([\#494](https://github.com/cynkra/dm/issues/494)).

### Documentation

- Fix description of filtering behavior in
  [`?dm_zoom_to`](https://dm.cynkra.com/dev/reference/dm_zoom_to.md)
  ([\#403](https://github.com/cynkra/dm/issues/403)).

### Internal

- Move repository to <https://github.com/cynkra/dm>
  ([\#500](https://github.com/cynkra/dm/issues/500)).
- Enable more Postgres tests
  ([\#497](https://github.com/cynkra/dm/issues/497)).
- Test DuckDB on GitHub Actions
  ([\#498](https://github.com/cynkra/dm/issues/498)).

## dm 0.1.12

CRAN release: 2021-02-15

- [`dm_from_src()`](https://dm.cynkra.com/dev/reference/dm_from_src.md)
  gains `dbname` argument for MSSQL
  ([\#472](https://github.com/cynkra/dm/issues/472)).
- Implement
  [`count()`](https://dplyr.tidyverse.org/reference/count.html) and
  [`tally()`](https://dplyr.tidyverse.org/reference/count.html) for
  dplyr 1.0.3 compatibility
  ([\#475](https://github.com/cynkra/dm/issues/475)).
- Use databases.pacha.dev instead of db-edu.pacha.dev
  ([\#478](https://github.com/cynkra/dm/issues/478),
  [@pachamaltese](https://github.com/pachamaltese)).

## dm 0.1.10

CRAN release: 2021-01-07

- Columns with missing values are no longer primary keys
  ([\#469](https://github.com/cynkra/dm/issues/469)).
- Fix
  [`dm_from_src()`](https://dm.cynkra.com/dev/reference/dm_from_src.md)
  for MSSQL when `learn_keys = FALSE`
  ([\#427](https://github.com/cynkra/dm/issues/427)).
- Tests use `expect_snapshot()` everywhere
  ([\#456](https://github.com/cynkra/dm/issues/456)).
- Fix compatibility with testthat 3.0.1
  ([\#457](https://github.com/cynkra/dm/issues/457)).

## dm 0.1.9

CRAN release: 2020-11-18

- New
  [`vignette("howto-dm-copy", package = "dm")`](https://dm.cynkra.com/dev/articles/howto-dm-copy.md)
  and
  [`vignette("howto-dm-rows", package = "dm")`](https://dm.cynkra.com/dev/articles/howto-dm-rows.md)
  discuss updating data on the database. In part derived from
  [`vignette("howto-dm-db", package = "dm")`](https://dm.cynkra.com/dev/articles/howto-dm-db.md)
  ([\#411](https://github.com/cynkra/dm/issues/411),
  [@jawond](https://github.com/jawond)).
- New
  [`dm_mutate_tbl()`](https://dm.cynkra.com/dev/reference/dm_mutate_tbl.md)
  ([\#448](https://github.com/cynkra/dm/issues/448)).
- [`dm_financial()`](https://dm.cynkra.com/dev/reference/dm_financial.md)
  falls back to db-edu.pacha.dev if relational.fit.cvut.cz is
  unavailable ([\#446](https://github.com/cynkra/dm/issues/446),
  [@pachamaltese](https://github.com/pachamaltese)).
- Use testthat 3e ([\#455](https://github.com/cynkra/dm/issues/455)).

## dm 0.1.7

CRAN release: 2020-09-02

- Bump RMariaDB required version to 1.0.10 to work around timeout with
  `R CMD check`.
- [`dm_from_src()`](https://dm.cynkra.com/dev/reference/dm_from_src.md)
  accepts `schema` argument for MSSQL databases
  ([\#367](https://github.com/cynkra/dm/issues/367)).

## dm 0.1.6

CRAN release: 2020-07-29

### Breaking changes

- [`dm_get_src()`](https://dm.cynkra.com/dev/reference/dplyr_src.md)
  returns `NULL` for local data sources
  ([\#394](https://github.com/cynkra/dm/issues/394)).
- Local target in
  [`copy_dm_to()`](https://dm.cynkra.com/dev/reference/copy_dm_to.md)
  gives a deprecation message
  ([\#395](https://github.com/cynkra/dm/issues/395)).

### Features

- [`copy_dm_to()`](https://dm.cynkra.com/dev/reference/copy_dm_to.md)
  gives a better error message for bad `table_names`
  ([\#397](https://github.com/cynkra/dm/issues/397)).
- `dm` objects with local data sources no longer show the “Table source”
  part in the output.
- Error messages now refer to “tables”, not “elements”
  ([\#413](https://github.com/cynkra/dm/issues/413)).
- New [`dm_bind()`](https://dm.cynkra.com/dev/reference/deprecated.md)
  for binding two or more ‘dm’ objects together
  ([\#417](https://github.com/cynkra/dm/issues/417)).

### Bug fixes

- For databases, the underlying SQL table names are quoted early to
  avoid later SQL syntax errors
  ([\#419](https://github.com/cynkra/dm/issues/419)).
- [`dm_financial()`](https://dm.cynkra.com/dev/reference/dm_financial.md)
  no longer prints message about `learn_keys = FALSE`.
- [`dm_rows_update()`](https://dm.cynkra.com/dev/reference/rows-dm.md)
  and related functions now use the primary keys defined in `x` for
  establishing matching rows.

### Internal

- Use [`withCallingHandlers()`](https://rdrr.io/r/base/conditions.html)
  where appropriate ([\#422](https://github.com/cynkra/dm/issues/422)).
- Consistent definition of `.dm` and `.dm_zoomed` methods
  ([\#300](https://github.com/cynkra/dm/issues/300)).
- Examples involving
  [`dm_financial()`](https://dm.cynkra.com/dev/reference/dm_financial.md)
  are not run if connection can’t be established
  ([\#418](https://github.com/cynkra/dm/issues/418)).
- Fix database tests on CI
  ([\#416](https://github.com/cynkra/dm/issues/416)).

## dm 0.1.5

CRAN release: 2020-07-03

### Features

- [`dm_paste()`](https://dm.cynkra.com/dev/reference/dm_paste.md)
  generates self-contained code
  ([\#401](https://github.com/cynkra/dm/issues/401)).
- Errors regarding cycles in the relationship graph now show the
  shortest cycle ([\#405](https://github.com/cynkra/dm/issues/405)).
- Implement
  [`rows_truncate()`](https://dm.cynkra.com/dev/reference/deprecated.md)
  for databases.
- [`collect()`](https://dplyr.tidyverse.org/reference/compute.html)
  works on a zoomed dm, with a message.
- The data model is drawn in a more compact way if it comprises of
  multiple connected components.
- `dm_add_pk(check = TRUE)` gives a better error message.

### Bug fixes

- [`rows_insert()`](https://dplyr.tidyverse.org/reference/rows.html)
  works if column names consist of SQL keywords
  ([\#409](https://github.com/cynkra/dm/issues/409)).
- Cycles in other connected components don’t affect filtering in a
  cycle-free component.
- Avoid
  [`src_sqlite()`](https://dplyr.tidyverse.org/reference/defunct.html)
  in examples ([\#372](https://github.com/cynkra/dm/issues/372)).

### Internal

- Testing SQLite, Postgres and SQL Server on GitHub Actions
  ([\#408](https://github.com/cynkra/dm/issues/408),
  [@pat-s](https://github.com/pat-s)).
- Testing packages with all “Suggests” uninstalled.

## dm 0.1.4

CRAN release: 2020-06-07

### Features

- New
  [`dm_rows_insert()`](https://dm.cynkra.com/dev/reference/rows-dm.md),
  [`dm_rows_update()`](https://dm.cynkra.com/dev/reference/rows-dm.md),
  [`dm_rows_patch()`](https://dm.cynkra.com/dev/reference/rows-dm.md),
  [`dm_rows_upsert()`](https://dm.cynkra.com/dev/reference/rows-dm.md),
  [`dm_rows_delete()`](https://dm.cynkra.com/dev/reference/rows-dm.md)
  and
  [`dm_rows_truncate()`](https://dm.cynkra.com/dev/reference/deprecated.md),
  calling the corresponding `rows_*()` method for every table
  ([\#319](https://github.com/cynkra/dm/issues/319)).

- New
  [`rows_truncate()`](https://dm.cynkra.com/dev/reference/deprecated.md)
  ([\#319](https://github.com/cynkra/dm/issues/319)).

- Added
  [`rows_insert()`](https://dplyr.tidyverse.org/reference/rows.html) and
  [`rows_update()`](https://dplyr.tidyverse.org/reference/rows.html)
  methods for SQLite, Postgres, MariaDB and MSSQL
  ([\#319](https://github.com/cynkra/dm/issues/319)).

- Missing arguments now give a better error message
  ([\#388](https://github.com/cynkra/dm/issues/388)).

- Empty `dm` object prints as
  [`dm()`](https://dm.cynkra.com/dev/reference/dm.md)
  ([\#386](https://github.com/cynkra/dm/issues/386)).

- [`copy_dm_to()`](https://dm.cynkra.com/dev/reference/copy_dm_to.md)
  also accepts a function as the `table_names` argument. The
  `unique_table_names()` argument is deprecated
  ([\#80](https://github.com/cynkra/dm/issues/80)).

### Documentation

- Add TL;DR to README ([\#377](https://github.com/cynkra/dm/issues/377),
  [@jawond](https://github.com/jawond)).

- Add content from old README to `howto-dm-theory.Rmd`
  ([\#378](https://github.com/cynkra/dm/issues/378),
  [@jawond](https://github.com/jawond)).

### Internal

- Require dplyr \>= 1.0.0.

- Use GitHub Actions ([\#369](https://github.com/cynkra/dm/issues/369),
  [@pat-s](https://github.com/pat-s)).

## dm 0.1.3

CRAN release: 2020-05-25

- Avoid
  [`src_sqlite()`](https://dplyr.tidyverse.org/reference/defunct.html)
  in vignettes ([\#372](https://github.com/cynkra/dm/issues/372)).
- Rename vignettes ([\#349](https://github.com/cynkra/dm/issues/349)).
- Rename error class `"dm_error_tables_not_neighbours"` to
  `"dm_error_tables_not_neighbors"`.
- Shortened README and intro article
  ([\#192](https://github.com/cynkra/dm/issues/192),
  [@jawond](https://github.com/jawond)).
- Better testing for MSSQL
  ([\#339](https://github.com/cynkra/dm/issues/339)).
- Fix compatibility with dplyr 1.0.0.

## dm 0.1.2

CRAN release: 2020-05-04

### Features

- [`dm_from_src()`](https://dm.cynkra.com/dev/reference/dm_from_src.md)
  now works for databases other than Postgres and MSSQL
  ([\#288](https://github.com/cynkra/dm/issues/288)), gives a warning if
  tables cannot be accessed with `table_name = NULL`
  ([\#348](https://github.com/cynkra/dm/issues/348)), and gains
  `learn_keys` argument to control querying of primary and foreign keys
  from the database ([\#340](https://github.com/cynkra/dm/issues/340)).
- [`dm_examine_constraints()`](https://dm.cynkra.com/dev/reference/dm_examine_constraints.md)
  now prints a different message if a dm has no constraints defined.
- Disambiguation message now only lists column names for easier
  copy-pasting.
- New methods for `"dm_zoomed"`:
  [`head()`](https://rdrr.io/r/utils/head.html),
  [`tail()`](https://rdrr.io/r/utils/head.html),
  [`pull()`](https://dplyr.tidyverse.org/reference/pull.html),
  [`group_data()`](https://dplyr.tidyverse.org/reference/group_data.html),
  [`group_indices()`](https://dplyr.tidyverse.org/reference/group_data.html),
  [`group_vars()`](https://dplyr.tidyverse.org/reference/group_data.html),
  [`group_keys()`](https://dplyr.tidyverse.org/reference/group_data.html)
  and
  [`groups()`](https://dplyr.tidyverse.org/reference/group_data.html)
  ([\#236](https://github.com/cynkra/dm/issues/236),
  [\#203](https://github.com/cynkra/dm/issues/203)).
- [`dm_paste()`](https://dm.cynkra.com/dev/reference/dm_paste.md)
  supports writing colors and the table definition via the new `options`
  argument. The definition can be written to a file via the new `path`
  argument. The `select` argument is soft-deprecated
  ([\#218](https://github.com/cynkra/dm/issues/218),
  [\#302](https://github.com/cynkra/dm/issues/302)).
- [`dm_add_tbl()`](https://dm.cynkra.com/dev/reference/deprecated.md)
  uses [`rlang::list2()`](https://rlang.r-lib.org/reference/list2.html)
  internally, now accepts `:=` to specify table names.
- New [`dm_ptype()`](https://dm.cynkra.com/dev/reference/dm_ptype.md)
  ([\#301](https://github.com/cynkra/dm/issues/301)).
- New
  [`dm_financial()`](https://dm.cynkra.com/dev/reference/dm_financial.md)
  and
  [`dm_financial_sqlite()`](https://dm.cynkra.com/dev/reference/dm_financial.md).
- Printing dm objects from database sources with many tables is now
  faster ([\#308](https://github.com/cynkra/dm/issues/308),
  [@gadenbuie](https://github.com/gadenbuie)).
- [`check_key()`](https://dm.cynkra.com/dev/reference/check_key.md) now
  also works on a zoomed dm.
- Key columns are always selected in a join operation, with a message
  ([\#153](https://github.com/cynkra/dm/issues/153)).
- Support alpha colors for the table colors
  ([\#279](https://github.com/cynkra/dm/issues/279)).

### Bug fixes

- Fix visualization of column that acts as a foreign key more than once
  ([\#37](https://github.com/cynkra/dm/issues/37)).
- [`dm_add_pk()`](https://dm.cynkra.com/dev/reference/dm_add_pk.md),
  [`dm_rm_pk()`](https://dm.cynkra.com/dev/reference/dm_rm_pk.md),
  [`dm_add_fk()`](https://dm.cynkra.com/dev/reference/dm_add_fk.md) and
  [`dm_rm_fk()`](https://dm.cynkra.com/dev/reference/dm_rm_fk.md) are
  now stricter when keys exists or when attempting to remove keys that
  don’t exist. A more relaxed mode of operation may be added later
  ([\#214](https://github.com/cynkra/dm/issues/214)).
- [`examine_cardinality()`](https://dm.cynkra.com/dev/reference/examine_cardinality.md),
  [`dm_examine_constraints()`](https://dm.cynkra.com/dev/reference/dm_examine_constraints.md)
  and
  [`enum_pk_candidates()`](https://dm.cynkra.com/dev/reference/dm_enum_pk_candidates.md)
  now work for columns named `n`.
- `dm_set_key_constraints()` (and by extension
  `dm_copy_to(set_key_constraints = TRUE)`) now quote identifiers for
  the SQL that creates foreign keys on the database.
- [`collect()`](https://dplyr.tidyverse.org/reference/compute.html)
  gives a better error message when called on a `"dm_zoomed"`
  ([\#294](https://github.com/cynkra/dm/issues/294)).
- [`check_subset()`](https://dm.cynkra.com/dev/reference/check_subset.md)
  gives a clean error message if the tables are complex expressions.
- `dm_from_src(schema = "...")` works on Postgres if `search_path` is
  not set on the connection.
- [`compute.dm_zoomed()`](https://dm.cynkra.com/dev/reference/dplyr_table_manipulation.md)
  no longer throws an error.
- Remove unused DT import
  ([\#295](https://github.com/cynkra/dm/issues/295)).

### Compatibility

- Remove use of deprecated
  [`src_df()`](https://dplyr.tidyverse.org/reference/defunct.html)
  ([\#336](https://github.com/cynkra/dm/issues/336)).
- Fix compatibility with dplyr 1.0.0
  ([\#203](https://github.com/cynkra/dm/issues/203)).

### Documentation

- [`dm_draw()`](https://dm.cynkra.com/dev/reference/dm_draw.md) output
  is shown in examples
  ([\#251](https://github.com/cynkra/dm/issues/251)).
- New article “{dm} and databases”
  ([\#309](https://github.com/cynkra/dm/issues/309),
  [@jawond](https://github.com/jawond)).

### Internal

- Testing on local data frames (by default), optionally also SQLite,
  Postgres, RMariaDB, and SQL Server. Currently requires development
  versions and various pull requests
  ([\#334](https://github.com/cynkra/dm/issues/334),
  [\#327](https://github.com/cynkra/dm/issues/327),
  [\#312](https://github.com/cynkra/dm/issues/312),
  [\#76](https://github.com/cynkra/dm/issues/76)).
- `dm_nycflights13(subset = TRUE)` memoizes subset and also reduces the
  size of the `weather` table.
- Expand definitions of deprecated functions
  ([\#204](https://github.com/cynkra/dm/issues/204)).

## dm 0.1.1

CRAN release: 2020-03-12

- Implement `format.dm()`.
- Adapt to tidyselect 1.0.0
  ([\#257](https://github.com/cynkra/dm/issues/257)).
- Zooming and unzooming is now faster if no columns are removed.
- Table names must be unique.
- [`dm_examine_constraints()`](https://dm.cynkra.com/dev/reference/dm_examine_constraints.md)
  formats the problems nicely.
- New class for prettier printing of keys
  ([\#244](https://github.com/cynkra/dm/issues/244)).
- Add experimental schema support for
  [`dm_from_src()`](https://dm.cynkra.com/dev/reference/dm_from_src.md)
  for Postgres through the new `schema` and `table_type` arguments
  ([\#256](https://github.com/cynkra/dm/issues/256)).

## dm 0.1.0

- Package is now in the “maturing” lifecycle
  ([\#154](https://github.com/cynkra/dm/issues/154)).
- [`filter.dm_zoomed()`](https://dm.cynkra.com/dev/reference/dplyr_table_manipulation.md)
  no longer sets the filter.
- `examine_()` functions never throw an error
  ([\#238](https://github.com/cynkra/dm/issues/238)).
- API overhaul:
  [`dm_zoom_to()`](https://dm.cynkra.com/dev/reference/dm_zoom_to.md),
  [`dm_insert_zoomed()`](https://dm.cynkra.com/dev/reference/dm_zoom_to.md),
  [`dm_update_zoomed()`](https://dm.cynkra.com/dev/reference/dm_zoom_to.md)
  and
  [`dm_discard_zoomed()`](https://dm.cynkra.com/dev/reference/dm_zoom_to.md);
  `check_()` -\> `examine_()`; `dm_get_filter()` -\>
  [`dm_get_filters()`](https://dm.cynkra.com/dev/reference/deprecated.md);
  [`dm_from_src()`](https://dm.cynkra.com/dev/reference/dm_from_src.md) +
  `dm_learn_from_db()` -\>
  [`dm_from_src()`](https://dm.cynkra.com/dev/reference/dm_from_src.md)
  ([\#233](https://github.com/cynkra/dm/issues/233)).
- New `$.dm_zoomed()`, `[.dm_zoomed()`, `[[.dm_zoomed()`,
  `length.dm_zoomed()`, `names.dm_zoomed()`, `tbl_vars.dm_zoomed()`
  ([\#199](https://github.com/cynkra/dm/issues/199),
  [\#216](https://github.com/cynkra/dm/issues/216)).
- New [`as.list()`](https://rdrr.io/r/base/list.html) methods
  ([\#213](https://github.com/cynkra/dm/issues/213)).
- Help pages for dplyr methods
  ([\#209](https://github.com/cynkra/dm/issues/209)).
- New migration guide from dm \<= 0.0.5
  ([\#234](https://github.com/cynkra/dm/issues/234)).
- New {tidyselect} interface for setting colors
  ([\#162](https://github.com/cynkra/dm/issues/162)) and support for hex
  color codes as well as R standard colors.
- Prepare
  [`dm_examine_constraints()`](https://dm.cynkra.com/dev/reference/dm_examine_constraints.md)
  and other key-related functions for compound keys
  ([\#239](https://github.com/cynkra/dm/issues/239)).
- Avoid warnings in `R CMD check` with dev versions of dependencies.
- Improve error messages for missing tables
  ([\#220](https://github.com/cynkra/dm/issues/220)).

## dm 0.0.6

- Change `cdm_` prefix to `dm_`. The old names are still available
  ([\#117](https://github.com/cynkra/dm/issues/117)).
- New [`pull_tbl()`](https://dm.cynkra.com/dev/reference/pull_tbl.md)
  extracts a single table from a `dm`
  ([\#206](https://github.com/cynkra/dm/issues/206)).
- New
  [`dm_apply_filters_to_tbl()`](https://dm.cynkra.com/dev/reference/deprecated.md)
  that applies filters in related tables to a table, similar to
  [`dm_apply_filters()`](https://dm.cynkra.com/dev/reference/deprecated.md);
  [`tbl()`](https://dplyr.tidyverse.org/reference/tbl.html), `$` and
  `[[` no longer apply filter conditions defined in related tables
  ([\#161](https://github.com/cynkra/dm/issues/161)).
- New [`dm_paste()`](https://dm.cynkra.com/dev/reference/dm_paste.md)
  ([\#160](https://github.com/cynkra/dm/issues/160)).
- New
  [`check_cardinality()`](https://dm.cynkra.com/dev/reference/deprecated.md)
  returns the nature of the relationship between `parent_table$pk_col`
  and `child_table$fk_col`
  ([\#15](https://github.com/cynkra/dm/issues/15)).
- New zoom vignette ([\#171](https://github.com/cynkra/dm/issues/171)).
- [`check_key()`](https://dm.cynkra.com/dev/reference/check_key.md) no
  longer maps empty selection list to all columns.
- [`check_key()`](https://dm.cynkra.com/dev/reference/check_key.md)
  supports tidyselect
  ([\#188](https://github.com/cynkra/dm/issues/188)).
- [`dm_rm_tbl()`](https://dm.cynkra.com/dev/reference/deprecated.md)
  supports tidyselect
  ([\#127](https://github.com/cynkra/dm/issues/127)).
- [`decompose_table()`](https://dm.cynkra.com/dev/reference/decompose_table.md)
  uses tidyselect ([\#194](https://github.com/cynkra/dm/issues/194)).
- Implement
  [`copy_to()`](https://dplyr.tidyverse.org/reference/copy_to.html) for
  `dm` objects ([\#129](https://github.com/cynkra/dm/issues/129)).
- Relax test for cycles in relationship graph
  ([\#198](https://github.com/cynkra/dm/issues/198)).
- Return `ref_table` column in `dm_check_constraints()`
  ([\#178](https://github.com/cynkra/dm/issues/178)).
- [`str()`](https://rdrr.io/r/utils/str.html) shows simplified views
  ([\#123](https://github.com/cynkra/dm/issues/123)).
- Edits to README ([\#172](https://github.com/cynkra/dm/issues/172),
  [@bbecane](https://github.com/bbecane)).
- Extend
  [`validate_dm()`](https://dm.cynkra.com/dev/reference/deprecated.md)
  ([\#173](https://github.com/cynkra/dm/issues/173)).
- Fix zooming into table that uses an FK column as primary key
  ([\#193](https://github.com/cynkra/dm/issues/193)).
- Fix corner case in
  [`dm_rm_fk()`](https://dm.cynkra.com/dev/reference/dm_rm_fk.md)
  ([\#175](https://github.com/cynkra/dm/issues/175)).
- More efficient
  [`check_key()`](https://dm.cynkra.com/dev/reference/check_key.md) for
  databases ([\#208](https://github.com/cynkra/dm/issues/208)).
- Testing for R \>= 3.3 and for debug versions.
- Remove {stringr} dependency
  ([\#183](https://github.com/cynkra/dm/issues/183)).

## dm 0.0.5

### Features

- [`cdm_filter()`](https://dm.cynkra.com/dev/reference/deprecated.md)
  and
  [`filter.dm_zoomed()`](https://dm.cynkra.com/dev/reference/dplyr_table_manipulation.md)
  apply the filter instantly, the expression is recorded only for
  display purposes and for terminating the search for filtered tables in
  [`cdm_apply_filters()`](https://dm.cynkra.com/dev/reference/deprecated.md).
  This now allows using a variety of operations on filtered `dm` objects
  ([\#124](https://github.com/cynkra/dm/issues/124)).
- [`dimnames()`](https://rdrr.io/r/base/dimnames.html),
  [`colnames()`](https://rdrr.io/r/base/colnames.html),
  [`dim()`](https://rdrr.io/r/base/dim.html),
  [`distinct()`](https://dplyr.tidyverse.org/reference/distinct.html),
  [`arrange()`](https://dplyr.tidyverse.org/reference/arrange.html),
  [`slice()`](https://dplyr.tidyverse.org/reference/slice.html),
  [`separate()`](https://tidyr.tidyverse.org/reference/separate.html)
  and [`unite()`](https://tidyr.tidyverse.org/reference/unite.html)
  implemented for zoomed dm-s
  ([\#130](https://github.com/cynkra/dm/issues/130)).
- Joins on zoomed dm objects now supported
  ([\#121](https://github.com/cynkra/dm/issues/121)). Joins use the same
  column name disambiguation algorithm as
  [`cdm_flatten_to_tbl()`](https://dm.cynkra.com/dev/reference/deprecated.md)
  ([\#147](https://github.com/cynkra/dm/issues/147)).
- [`slice.dm_zoomed()`](https://dm.cynkra.com/dev/reference/dplyr_table_manipulation.md):
  user decides in arg `.keep_pk` if PK column is tracked or not
  ([\#152](https://github.com/cynkra/dm/issues/152)).
- Supported {dplyr} and {tidyr} verbs are reexported.
- [`enum_pk_candidates()`](https://dm.cynkra.com/dev/reference/dm_enum_pk_candidates.md)
  works with zoomed dm-s
  ([\#156](https://github.com/cynkra/dm/issues/156)).
- New
  [`enum_fk_candidates()`](https://dm.cynkra.com/dev/reference/dm_enum_fk_candidates.md)
  ([\#156](https://github.com/cynkra/dm/issues/156)).
- Add name repair argument for both
  [`cdm_insert_zoomed_tbl()`](https://dm.cynkra.com/dev/reference/deprecated.md)
  and
  [`cdm_add_tbl()`](https://dm.cynkra.com/dev/reference/deprecated.md),
  defaulting to renaming of old and new tables when adding tables with
  duplicate names ([\#132](https://github.com/cynkra/dm/issues/132)).
- Redesign constructors and validators:
  [`dm()`](https://dm.cynkra.com/dev/reference/dm.md) is akin to
  [`tibble()`](https://tibble.tidyverse.org/reference/tibble.html),
  [`dm_from_src()`](https://dm.cynkra.com/dev/reference/dm_from_src.md)
  works like [`dm()`](https://dm.cynkra.com/dev/reference/dm.md) did
  previously, [`new_dm()`](https://dm.cynkra.com/dev/reference/dm.md)
  only accepts a list of tables and no longer validates,
  [`validate_dm()`](https://dm.cynkra.com/dev/reference/deprecated.md)
  checks internal consistency
  ([\#69](https://github.com/cynkra/dm/issues/69)).
- [`compute.dm()`](https://dm.cynkra.com/dev/reference/materialize.md)
  applies filters and calls
  [`compute()`](https://dplyr.tidyverse.org/reference/compute.html) on
  all tables ([\#135](https://github.com/cynkra/dm/issues/135)).

### Documentation

- New demo.
- Add explanation for empty `dm`
  ([\#100](https://github.com/cynkra/dm/issues/100)).

### Bug fixes

- Avoid asterisk when printing local `dm_zoomed`
  ([\#131](https://github.com/cynkra/dm/issues/131)).
- [`cdm_select_tbl()`](https://dm.cynkra.com/dev/reference/deprecated.md)
  works again when multiple foreign keys are defined between two tables
  ([\#122](https://github.com/cynkra/dm/issues/122)).

## dm 0.0.4

- Many {dplyr} verbs now work on tables in a `dm`. Zooming to a table
  vie
  [`cdm_zoom_to_tbl()`](https://dm.cynkra.com/dev/reference/deprecated.md)
  creates a zoomed `dm` on which the {dplyr} verbs can be applied. The
  resulting table can be put back into the `dm` with
  [`cdm_update_zoomed_tbl()`](https://dm.cynkra.com/dev/reference/deprecated.md)
  (overwriting the original table) or
  [`cdm_insert_zoomed_tbl()`](https://dm.cynkra.com/dev/reference/deprecated.md)
  (creating a new table), respectively
  ([\#89](https://github.com/cynkra/dm/issues/89)).
- `cdm_select_to_tbl()` removes foreign key constraints if the
  corresponding columns are removed.
- Integrate code from {datamodelr} in this package
  ([@bergant](https://github.com/bergant),
  [\#111](https://github.com/cynkra/dm/issues/111)).
- Reorder tables in `"dm"` using
  [`cdm_select_tbl()`](https://dm.cynkra.com/dev/reference/deprecated.md)
  ([\#108](https://github.com/cynkra/dm/issues/108)).
- More accurate documentation of filtering operation
  ([\#98](https://github.com/cynkra/dm/issues/98)).
- Support empty `dm` objects via
  [`dm()`](https://dm.cynkra.com/dev/reference/dm.md) and
  [`new_dm()`](https://dm.cynkra.com/dev/reference/dm.md)
  ([\#96](https://github.com/cynkra/dm/issues/96)).
- [`cdm_flatten_to_tbl()`](https://dm.cynkra.com/dev/reference/deprecated.md)
  now flattens all immediate neighbors by default
  ([\#95](https://github.com/cynkra/dm/issues/95)).
- New
  [`cdm_add_tbl()`](https://dm.cynkra.com/dev/reference/deprecated.md)
  and
  [`cdm_rm_tbl()`](https://dm.cynkra.com/dev/reference/deprecated.md)
  ([\#90](https://github.com/cynkra/dm/issues/90)).
- New
  [`cdm_get_con()`](https://dm.cynkra.com/dev/reference/deprecated.md)
  ([\#84](https://github.com/cynkra/dm/issues/84)).
- A `dm` object is defined using a nested tibble, one row per table
  ([\#57](https://github.com/cynkra/dm/issues/57)).

## dm 0.0.3

- [`cdm_enum_pk_candidates()`](https://dm.cynkra.com/dev/reference/deprecated.md)
  and
  [`cdm_enum_fk_candidates()`](https://dm.cynkra.com/dev/reference/deprecated.md)
  both show candidates first
  ([\#85](https://github.com/cynkra/dm/issues/85)).
- [`cdm_flatten_to_tbl()`](https://dm.cynkra.com/dev/reference/deprecated.md)
  works only in the immediate neighborhood
  ([\#75](https://github.com/cynkra/dm/issues/75)).
- New
  [`cdm_squash_to_tbl()`](https://dm.cynkra.com/dev/reference/deprecated.md)
  implements recursive flattening for left, inner and full join
  ([\#75](https://github.com/cynkra/dm/issues/75)).
- Updated readme and introduction vignette
  ([\#72](https://github.com/cynkra/dm/issues/72),
  [@cutterkom](https://github.com/cutterkom)).
- New
  [`cdm_check_constraints()`](https://dm.cynkra.com/dev/reference/deprecated.md)
  to check referential integrity of a `dm`
  ([\#56](https://github.com/cynkra/dm/issues/56)).
- [`cdm_copy_to()`](https://dm.cynkra.com/dev/reference/deprecated.md)
  gains `table_names` argument
  ([\#79](https://github.com/cynkra/dm/issues/79)).
- [`check_key()`](https://dm.cynkra.com/dev/reference/check_key.md) now
  deals correctly with named column lists
  ([\#83](https://github.com/cynkra/dm/issues/83)).
- Improve error message when calling
  [`cdm_add_pk()`](https://dm.cynkra.com/dev/reference/deprecated.md)
  with a missing column.

## dm 0.0.2.9003

- Fix `R CMD check`.

## dm 0.0.2.9002

- Use caching to improve loading times.
- Run some tests only for one source
  ([\#76](https://github.com/cynkra/dm/issues/76)).
- [`cdm_enum_fk_candidates()`](https://dm.cynkra.com/dev/reference/deprecated.md)
  checks for class compatibility implicitly via
  [`left_join()`](https://dplyr.tidyverse.org/reference/mutate-joins.html).
- [`cdm_enum_fk_candidates()`](https://dm.cynkra.com/dev/reference/deprecated.md)
  contains a more detailed entry in column why if no error & no
  candidate (percentage of mismatched vals etc.).
- Improve error messages for
  [`cdm_join_to_tbl()`](https://dm.cynkra.com/dev/reference/deprecated.md)
  and
  [`cdm_flatten_to_tbl()`](https://dm.cynkra.com/dev/reference/deprecated.md)
  in the presence of cycles or disconnected tables
  ([\#74](https://github.com/cynkra/dm/issues/74)).

## dm 0.0.2.9001

- Remove the `src` component from dm
  ([\#38](https://github.com/cynkra/dm/issues/38)).
- Internal: Add function checking if all tables have same src.
- Internal: Add 2 classed errors.
- [`cdm_get_src()`](https://dm.cynkra.com/dev/reference/deprecated.md)
  for local dm always returns a src based on `.GlobalEnv`.
- `cdm_flatten()` gains `...` argument to specify which tables to
  include. Currently, all tables must form a connected subtree rooted at
  `start`. Disambiguation of column names now happens after selecting
  relevant tables. The resulting SQL query is more efficient for inner
  and outer joins if filtering is applied. Flattening with a
  `right_join` with more than two tables is not well-defined and gives
  an error ([\#62](https://github.com/cynkra/dm/issues/62)).
- Add a vignette for joining functions
  ([\#60](https://github.com/cynkra/dm/issues/60),
  [@cutterkom](https://github.com/cutterkom)).
- Shorten message in
  [`cdm_disambiguate_cols()`](https://dm.cynkra.com/dev/reference/deprecated.md).

## dm 0.0.2.9000

- [`cdm_flatten_to_tbl()`](https://dm.cynkra.com/dev/reference/deprecated.md)
  disambiguates only the necessary columns.
- When flattening, the column name of the LHS (child) table is used
  ([\#52](https://github.com/cynkra/dm/issues/52)).
- Fix formatting in
  [`enum_pk_candidates()`](https://dm.cynkra.com/dev/reference/dm_enum_pk_candidates.md)
  for character data.
- [`cdm_add_pk()`](https://dm.cynkra.com/dev/reference/deprecated.md)
  and
  [`cdm_add_fk()`](https://dm.cynkra.com/dev/reference/deprecated.md) no
  longer check data integrity by default.
- Explicitly checking that the `join` argument is a function, to avoid
  surprises when the caller passes data.
- [`cdm_copy_to()`](https://dm.cynkra.com/dev/reference/deprecated.md)
  works correctly with filtered `dm` objects.
- [`cdm_apply_filters()`](https://dm.cynkra.com/dev/reference/deprecated.md)
  actually resets the filter conditions.
- A more detailed README file and a vignette for filtering
  ([\#29](https://github.com/cynkra/dm/issues/29),
  [@cutterkom](https://github.com/cutterkom)).
- [`cdm_draw()`](https://dm.cynkra.com/dev/reference/deprecated.md) no
  longer supports the `table_names` argument, use
  [`cdm_select_tbl()`](https://dm.cynkra.com/dev/reference/deprecated.md).
- Copying a `dm` to a database now creates indexes for all primary and
  foreign keys.

## dm 0.0.2

### Breaking changes

- Requires tidyr \>= 1.0.0.
- [`cdm_nrow()`](https://dm.cynkra.com/dev/reference/deprecated.md)
  returns named list ([\#49](https://github.com/cynkra/dm/issues/49)).
- Remove `cdm_semi_join()`.
- Remove `cdm_find_conn_tbls()` and the `all_connected` argument to
  [`cdm_select()`](https://dm.cynkra.com/dev/reference/deprecated.md)
  ([\#35](https://github.com/cynkra/dm/issues/35)).
- Unexport `cdm_set_key_constraints()`.
- Rename
  [`cdm_select()`](https://dm.cynkra.com/dev/reference/deprecated.md) to
  [`cdm_select_tbl()`](https://dm.cynkra.com/dev/reference/deprecated.md),
  now uses {tidyselect}.
- [`cdm_nycflights13()`](https://dm.cynkra.com/dev/reference/deprecated.md)
  now has `cycle = FALSE` as default.
- Rename `cdm_check_for_*()` to `cdm_enum_*()`.

### Performance

- [`cdm_filter()`](https://dm.cynkra.com/dev/reference/deprecated.md)
  only records the filtering operation, the filter is applied only when
  querying a table via
  [`tbl()`](https://dplyr.tidyverse.org/reference/tbl.html) or when
  calling
  [`compute()`](https://dplyr.tidyverse.org/reference/compute.html) or
  the new
  [`cdm_apply_filters()`](https://dm.cynkra.com/dev/reference/deprecated.md)
  ([\#32](https://github.com/cynkra/dm/issues/32)).

### New functions

- New
  [`cdm_flatten_to_tbl()`](https://dm.cynkra.com/dev/reference/deprecated.md)
  flattens a `dm` to a wide table with starting from a specified table
  ([\#13](https://github.com/cynkra/dm/issues/13)). Rename
  `cdm_join_tbl()` to
  [`cdm_join_to_tbl()`](https://dm.cynkra.com/dev/reference/deprecated.md).
- New
  [`cdm_disambiguate_cols()`](https://dm.cynkra.com/dev/reference/deprecated.md)
  ([\#40](https://github.com/cynkra/dm/issues/40)).
- New
  [`cdm_rename()`](https://dm.cynkra.com/dev/reference/deprecated.md)
  ([\#41](https://github.com/cynkra/dm/issues/41)) and
  [`cdm_select()`](https://dm.cynkra.com/dev/reference/deprecated.md)
  ([\#50](https://github.com/cynkra/dm/issues/50)) for renaming and
  selecting columns of `dm` tables.
- New `length.dm()` and `length<-.dm()`
  ([\#53](https://github.com/cynkra/dm/issues/53)).
- `$`, `[[`, `[`, [`names()`](https://rdrr.io/r/base/names.html),
  [`str()`](https://rdrr.io/r/utils/str.html) and
  [`length()`](https://rdrr.io/r/base/length.html) now implemented for
  dm objects (read-only).
- New
  [`enum_pk_candidates()`](https://dm.cynkra.com/dev/reference/dm_enum_pk_candidates.md).

### Minor changes

- `browse_docs()` opens the pkgdown website
  ([\#36](https://github.com/cynkra/dm/issues/36)).
- [`as_dm()`](https://dm.cynkra.com/dev/reference/dm.md) now also
  accepts a list of remote tables
  ([\#30](https://github.com/cynkra/dm/issues/30)).
- Use {tidyselect} syntax for
  [`cdm_rename_tbl()`](https://dm.cynkra.com/dev/reference/deprecated.md)
  and
  [`cdm_select_tbl()`](https://dm.cynkra.com/dev/reference/deprecated.md)
  ([\#14](https://github.com/cynkra/dm/issues/14)).
- The tibbles returned by
  [`cdm_enum_fk_candidates()`](https://dm.cynkra.com/dev/reference/deprecated.md)
  and
  [`cdm_enum_pk_candidates()`](https://dm.cynkra.com/dev/reference/deprecated.md)
  contain a `why` column that explains the reasons for rejection in a
  human-readable form ([\#12](https://github.com/cynkra/dm/issues/12)).
- Improve compatibility with RPostgres.
- `create_graph_from_dm()` no longer fails in the presence of cycles
  ([\#10](https://github.com/cynkra/dm/issues/10)).
- Only suggest {RSQLite}.
- [`cdm_filter()`](https://dm.cynkra.com/dev/reference/deprecated.md) no
  longer requires a primary key.
- [`decompose_table()`](https://dm.cynkra.com/dev/reference/decompose_table.md)
  adds the new column in the table to the end.
- [`tbl()`](https://dplyr.tidyverse.org/reference/tbl.html) now fails if
  the table is not part of the data model.

### Documentation

- Add setup article ([\#7](https://github.com/cynkra/dm/issues/7)).

### Internal

- Using simpler internal data structure to store primary and foreign key
  relations ([\#26](https://github.com/cynkra/dm/issues/26)).
- New `nse_function()` replaces `h()` for marking functions as NSE to
  avoid R CMD check warnings.
- Simplified internal data structure so that creation of new operations
  that update a dm becomes easier.
- When copying a dm to a database, `NOT NULL` constraints are set at
  creation of the table. This removes the necessity to store column
  types.
- Using {RPostgres} instead of {RPostgreSQL} for testing.

## dm 0.0.1

Initial GitHub release.

### Creating `dm` objects and basic functions:

- [`dm()`](https://dm.cynkra.com/dev/reference/dm.md)
- [`new_dm()`](https://dm.cynkra.com/dev/reference/dm.md)
- [`validate_dm()`](https://dm.cynkra.com/dev/reference/deprecated.md)
- [`cdm_get_src()`](https://dm.cynkra.com/dev/reference/deprecated.md)
- [`cdm_get_tables()`](https://dm.cynkra.com/dev/reference/deprecated.md)
- `cdm_get_data_model()`
- [`is_dm()`](https://dm.cynkra.com/dev/reference/dm.md)
- [`as_dm()`](https://dm.cynkra.com/dev/reference/dm.md)

### Primary keys

- [`cdm_add_pk()`](https://dm.cynkra.com/dev/reference/deprecated.md)
- [`cdm_has_pk()`](https://dm.cynkra.com/dev/reference/deprecated.md)
- [`cdm_get_pk()`](https://dm.cynkra.com/dev/reference/deprecated.md)
- [`cdm_get_all_pks()`](https://dm.cynkra.com/dev/reference/deprecated.md)
- [`cdm_rm_pk()`](https://dm.cynkra.com/dev/reference/deprecated.md)
- `cdm_check_for_pk_candidates()`

### Foreign keys

- [`cdm_add_fk()`](https://dm.cynkra.com/dev/reference/deprecated.md)
- [`cdm_has_fk()`](https://dm.cynkra.com/dev/reference/deprecated.md)
- [`cdm_get_fk()`](https://dm.cynkra.com/dev/reference/deprecated.md)
- [`cdm_get_all_fks()`](https://dm.cynkra.com/dev/reference/deprecated.md)
- [`cdm_rm_fk()`](https://dm.cynkra.com/dev/reference/deprecated.md)
- `cdm_check_for_fk_candidates()`

### Visualization

- [`cdm_draw()`](https://dm.cynkra.com/dev/reference/deprecated.md)
- [`cdm_set_colors()`](https://dm.cynkra.com/dev/reference/deprecated.md)
- [`cdm_get_colors()`](https://dm.cynkra.com/dev/reference/deprecated.md)
- [`cdm_get_available_colors()`](https://dm.cynkra.com/dev/reference/deprecated.md)

### Flattening

- `cdm_join_tbl()`

### Filtering

- [`cdm_filter()`](https://dm.cynkra.com/dev/reference/deprecated.md)
- `cdm_semi_join()`
- [`cdm_nrow()`](https://dm.cynkra.com/dev/reference/deprecated.md)

### Interaction with DBs

- [`cdm_copy_to()`](https://dm.cynkra.com/dev/reference/deprecated.md)
- `cdm_set_key_constraints()`
- [`cdm_learn_from_db()`](https://dm.cynkra.com/dev/reference/deprecated.md)

### Utilizing foreign key relations

- [`cdm_is_referenced()`](https://dm.cynkra.com/dev/reference/deprecated.md)
- [`cdm_get_referencing_tables()`](https://dm.cynkra.com/dev/reference/deprecated.md)
- [`cdm_select()`](https://dm.cynkra.com/dev/reference/deprecated.md)
- `cdm_find_conn_tbls()`

### Table surgery

- [`decompose_table()`](https://dm.cynkra.com/dev/reference/decompose_table.md)
- [`reunite_parent_child()`](https://dm.cynkra.com/dev/reference/reunite_parent_child.md)
- [`reunite_parent_child_from_list()`](https://dm.cynkra.com/dev/reference/reunite_parent_child.md)

### Check keys and cardinalities

- [`check_key()`](https://dm.cynkra.com/dev/reference/check_key.md)
- [`check_if_subset()`](https://dm.cynkra.com/dev/reference/deprecated.md)
- [`check_set_equality()`](https://dm.cynkra.com/dev/reference/check_set_equality.md)
- [`check_cardinality_0_n()`](https://dm.cynkra.com/dev/reference/examine_cardinality.md)
- [`check_cardinality_1_n()`](https://dm.cynkra.com/dev/reference/examine_cardinality.md)
- [`check_cardinality_1_1()`](https://dm.cynkra.com/dev/reference/examine_cardinality.md)
- [`check_cardinality_0_1()`](https://dm.cynkra.com/dev/reference/examine_cardinality.md)

### Miscellaneous

- [`cdm_nycflights13()`](https://dm.cynkra.com/dev/reference/deprecated.md)
- `cdm_rename_table()`
- `cdm_rename_tables()`
