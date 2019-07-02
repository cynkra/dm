
<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
[![Travis build
status](https://travis-ci.org/krlmlr/dm.svg?branch=master)](https://travis-ci.org/krlmlr/dm)
[![CRAN
status](https://www.r-pkg.org/badges/version/dm)](https://cran.r-project.org/package=dm)
<!-- badges: end -->

# dm

The goal of `dm` is to provide tools for frequently required tasks when
working with a set of related tables. This package works with all data
sources that provide a {dplyr} interface: local data frames, relational
databases, and more.

``` r
library(tidyverse)
library(dm)
```

The new class `dm` contains all the important information about a set of
related tables:

  - a `src` object: location of tables (database, in-memory, …)
  - a `data_model` object: metadata about data model (keys, table &
    columns names, …)
  - the data: the tables itself

This package augments {dplyr}/{dbplyr} workflows:

  - multiple related tables are kept in a single compound object,
  - joins across multiple tables are available by stating the tables
    involved, no need to memoize column names or relationships

In addition, a battery of utilities is provided that helps with creating
a tidy data model.

This package follows the tidyverse principles:

  - `dm` objects are immutable (your data will never be overwritten in
    place)
  - many functions used on `dm` objects are pipeable (i.e., return new
    `dm` objects)
  - tidy evaluation is used (unquoted function parameters are supported)

## Example

A readymade `dm` object with preset keys is included in the
package:

``` r
cdm_nycflights13()
```

<PRE class="fansi fansi-output"><CODE>#&gt; <span style='color: #00BB00;'>──</span><span> </span><span style='color: #00BB00;'>Table source</span><span> </span><span style='color: #00BB00;'>───────────────────────────────────────────────────────────</span><span>
#&gt; src:  &lt;package: nycflights13&gt;
#&gt; </span><span style='color: #555555;'>──</span><span> </span><span style='color: #555555;'>Data model</span><span> </span><span style='color: #555555;'>─────────────────────────────────────────────────────────────</span><span>
#&gt; Data model object:
#&gt;   5 tables:  airlines, airports, flights, planes ... 
#&gt;   53 columns
#&gt;   3 primary keys
#&gt;   4 references
#&gt; </span><span style='color: #BBBB00;'>──</span><span> </span><span style='color: #BBBB00;'>Rows</span><span> </span><span style='color: #BBBB00;'>───────────────────────────────────────────────────────────────────</span><span>
#&gt; Total: 367687
#&gt; airlines: 16, airports: 1458, flights: 336776, planes: 3322, weather: 26115
</span></CODE></PRE>

The `cdm_draw()` function creates a visualization of the entity
relationship model:

``` r
cdm_nycflights13() %>% 
  cdm_draw()
```

<img src="man/figures/README-draw-1.png" width="100%" />

## Filtering and joining

Similarly to `dplyr::filter()`, a filtering function `cdm_filter()` is
available for `dm` objects. You need to provide the `dm` object, the
table whose rows you want to filter, and the filter expression. A `dm`
object is returned whose tables only contain rows that are related to
the reduced rows in the filtered table. This currently only works for
cycle-free relationships between the tables.

``` r
cdm_nycflights13(cycle = FALSE) %>%
  cdm_get_tables() %>%
  map_int(nrow)
#> airlines airports  flights   planes  weather 
#>       16     1458   336776     3322    26115

cdm_nycflights13(cycle = FALSE) %>% 
  cdm_filter(planes, year == 2000, manufacturer == "BOEING") %>%
  cdm_get_tables() %>%
  map_int(nrow)
#> airlines airports  flights   planes  weather 
#>        4        3     7301      134    26115
```

For joining two tables using their relationship defined in the `dm`, you
can use `cdm_join_tbl()`:

``` r
cdm_nycflights13(cycle = FALSE) %>%
  cdm_join_tbl(airports, flights, join = semi_join)
```

<PRE class="fansi fansi-output"><CODE>#&gt; <span style='color: #555555;'># A tibble: 3 x 8</span><span>
#&gt;   </span><span style='font-weight: bold;'>faa</span><span>   </span><span style='font-weight: bold;'>name</span><span>                  </span><span style='font-weight: bold;'>lat</span><span>   </span><span style='font-weight: bold;'>lon</span><span>   </span><span style='font-weight: bold;'>alt</span><span>    </span><span style='font-weight: bold;'>tz</span><span> </span><span style='font-weight: bold;'>dst</span><span>   </span><span style='font-weight: bold;'>tzone</span><span>           
#&gt;   </span><span style='color: #555555;font-style: italic;'>&lt;chr&gt;</span><span> </span><span style='color: #555555;font-style: italic;'>&lt;chr&gt;</span><span>               </span><span style='color: #555555;font-style: italic;'>&lt;dbl&gt;</span><span> </span><span style='color: #555555;font-style: italic;'>&lt;dbl&gt;</span><span> </span><span style='color: #555555;font-style: italic;'>&lt;int&gt;</span><span> </span><span style='color: #555555;font-style: italic;'>&lt;dbl&gt;</span><span> </span><span style='color: #555555;font-style: italic;'>&lt;chr&gt;</span><span> </span><span style='color: #555555;font-style: italic;'>&lt;chr&gt;</span><span>           
#&gt; </span><span style='color: #555555;'>1</span><span> EWR   Newark Liberty Intl  40.7 -</span><span style='color: #BB0000;'>74.2</span><span>    18    -</span><span style='color: #BB0000;'>5</span><span> A     America/New_York
#&gt; </span><span style='color: #555555;'>2</span><span> JFK   John F Kennedy Intl  40.6 -</span><span style='color: #BB0000;'>73.8</span><span>    13    -</span><span style='color: #BB0000;'>5</span><span> A     America/New_York
#&gt; </span><span style='color: #555555;'>3</span><span> LGA   La Guardia           40.8 -</span><span style='color: #BB0000;'>73.9</span><span>    22    -</span><span style='color: #BB0000;'>5</span><span> A     America/New_York
</span></CODE></PRE>

In our `dm`, the `origin` column of the `flights` table points to the
`airports` table. Since all `nycflights13`-flights depart from New York,
only these airports are included in the semi-join.

## From and to databases

In order to transfer an existing `dm` object to a DB, you can call
`cdm_copy_to()` with the target DB and the `dm` object:

``` r
src_sqlite <- src_sqlite(":memory:", create = TRUE)
src_sqlite
#> src:  sqlite 3.25.3 [:memory:]
#> tbls:
nycflights13_remote <- cdm_copy_to(src_sqlite, cdm_nycflights13())
nycflights13_remote
```

<PRE class="fansi fansi-output"><CODE>#&gt; <span style='color: #00BB00;'>──</span><span> </span><span style='color: #00BB00;'>Table source</span><span> </span><span style='color: #00BB00;'>───────────────────────────────────────────────────────────</span><span>
#&gt; src:  sqlite 3.25.3 [:memory:]
#&gt; </span><span style='color: #555555;'>──</span><span> </span><span style='color: #555555;'>Data model</span><span> </span><span style='color: #555555;'>─────────────────────────────────────────────────────────────</span><span>
#&gt; Data model object:
#&gt;   5 tables:  airlines, airports, flights, planes ... 
#&gt;   53 columns
#&gt;   3 primary keys
#&gt;   4 references
#&gt; </span><span style='color: #BBBB00;'>──</span><span> </span><span style='color: #BBBB00;'>Rows</span><span> </span><span style='color: #BBBB00;'>───────────────────────────────────────────────────────────────────</span><span>
#&gt; Total: 367687
#&gt; airlines: 16, airports: 1458, flights: 336776, planes: 3322, weather: 26115
</span></CODE></PRE>

The key constraints from the original object are also copied to the
newly created object. With the default setting `set_key_constraints =
TRUE` for `cdm_copy_to()`, key constraints are also established on the
target DB. Currently this feature is only supported for MSSQL and
Postgres database management systems (DBMS).

It is also possible to automatically create a `dm` object from the
permanent tables of a DB. Again, for now just MSSQL and Postgres are
supported for this feature, so the next chunk is not evaluated. The
support for other DBMS will be implemented in a future update.

``` r
src_postgres <- src_postgres()
nycflights13_from_remote <- cdm_learn_from_db(src_postgres)
```

## More information

If you would like to learn more about the possibilities of {dm}, please
see the [function
reference](https://krlmlr.github.io/dm/reference/index.html) or the
articles:

  - [Getting started](https://krlmlr.github.io/dm/articles/dm.html)
  - [Class ‘dm’ and basic
    operations](https://krlmlr.github.io/dm/articles/dm-class-and-basic-operations.html)
  - [Visualizing ‘dm’
    objects](https://krlmlr.github.io/dm/articles/dm-visualization.html)
  - [Low-level
    operations](https://krlmlr.github.io/dm/articles/dm-low-level.html)
    <!-- FIXME: vignettes missing; once there, needs to be linked -->

## Installation

Once on CRAN, the package can be installed with

``` r
install.packages("dm")
```

Install the latest development version with

``` r
# install.packages("devtools")
devtools::install_github("krlmlr/dm")
```

-----

License: MIT © cynkra GmbH.

Funded by:

[![energie360°](man/figures/energie-72.png)](https://www.energie360.ch)
<span style="padding-right:50px"> </span>
[![cynkra](man/figures/cynkra-72.png)](https://www.cynkra.com/)

-----

Please note that the ‘dm’ project is released with a [Contributor Code
of Conduct](CODE_OF_CONDUCT.md). By contributing to this project, you
agree to abide by its terms.
