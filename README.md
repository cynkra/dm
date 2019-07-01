
# dm

The goal of `dm` is to provide tools for frequently required tasks when
working with a set of related tables. This package works with all data
sources that provide a {dplyr} interface: local data frames, relational
databases, and many more.

``` r
library(tidyverse)
library(dm)
```

The new class `dm` is essentially a list containing all the important
information about a set of related tables, its components being:

  - `src` object: location of tables (database (DB), locally, …)
  - a so-called `data_model` object: meta-info about data model (keys,
    table & columns names, …)
  - the data: the tables itself

This package augments {dplyr}/{dbplyr} workflows:

  - multiple related tables are kept in a single compound object,
  - joins across multiple tables are available by stating the tables
    involved, no need to memoize column names or relationships

In addition, a battery of utilities is provided that helps with creating
a tidy data model.

This package follows several of the “tidyverse” rules:

  - `dm` objects are immutable (your data will never be overwritten in
    place)
  - many functions used on `dm` objects are pipeable (i.e., return new
    `dm` objects)
  - tidy evaluation is used (unquoted function parameters are supported)

A readymade `dm` object with preset keys is included in the package:

``` r
flights_dm_with_keys <- cdm_nycflights13()
flights_dm_with_keys
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

For more information about the `dm` class and how to establish and
display key constraints we would like to refer you to vignette “class
‘dm’ and basic operations”.
<!-- FIXME: vignette missing; once there, needs to be linked -->

## Visualization

A basic graphic representation of the entity relationship model can be
generated with:

``` r
flights_dm_with_keys %>% 
  cdm_draw()
```

<img src="man/figures/README-unnamed-chunk-3-1.png" width="100%" />

The different colors of the tables were assigned in
`cdm_nycflights13()`. For how to add colors to subsets of the tables and
further customization please see vignette “Visualizing ‘dm’ objects”
<!-- FIXME: vignette missing; once there, needs to be linked -->

## Filtering `dm` object and joining its tables

Similar to `dplyr::filter()`, a filtering function `cdm_filter()` is
available for `dm` objects. You need to provide the `dm` object, the
table whose rows you want to filter and the filter expression. A `dm`
object is returned whose tables only contain rows that are related to
the reduced rows in the filtered table. This currently only works for
cycle-free relationships between the tables, since otherwise no
well-defined solution can be calculated. Thus, we need a slightly
different `dm` object from before to show the functionality of
`cdm_filter()`:

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

If you want to join 2 tables of a `dm`, making use of their foreign key
relation, you can use `cdm_join_tbl()`:

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

In our `dm`, column `origin` of table `flights` points to table
`airports`. Since all `nycflights13`-flights take off from New York,
only the NY airports are left after the semi-join.

## From and to DBs

In order to transfer an existing `dm` object to a DB, you just need to
provide the `src` object with the connection to the target DB and the
`dm` object:

``` r
src_sqlite <- src_sqlite(":memory:", create = TRUE)
src_sqlite
#> src:  sqlite 3.25.3 [:memory:]
#> tbls:
flights_dm_with_keys_remote <- cdm_copy_to(src_sqlite, flights_dm_with_keys)
flights_dm_with_keys_remote
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

With the default setting `set_key_constraints = TRUE` for
`cdm_copy_to()`, key constraints are established on the target DB, based
on the constraints in the `data_model` part of the `dm`. Currently this
feature is only supported for MSSQL and Postgres database management
systems (DBMS).

It is also possible to automatically create a `dm` object from the
permanent tables of a DB. Again, for now just MSSQL and Postgres are
supported for this feature, so the next chunk is not evaluated. The
support for other DBMS will be implemented in a future update.

``` r
flights_dm_from_remote <- cdm_learn_from_db(src_sqlite)
```

## More information

If you would like to learn more about the possibilities of {dm}, please
see the function documentation or the vignettes:

  - Getting started
  - Class ‘dm’ and basic operations
  - Visualizing ‘dm’ objects
  - Filtering
  - {dm} and databases
  - shiny with {dynafilter}
  - Tips and tricks
    <!-- FIXME: vignettes missing; once there, needs to be linked -->

## Package overview

To get an overview of `dm`, you can call the package’s function
`browse_docs()`, which will open a .html-file in your standard web
browser. You can also manually open the file, it is `index.html` in the
folder `pkgdown`.

## Installation

You can receive the package as a file `dm.tar.gz` from Kirill Müller,
Email: <kirill@cynkra.com> .
<!-- FIXME: almost outdated, needs to be github-link  -->

One way to install it to your R-Library is by opening R-Studio and
selecting “Install Packages…” from the `Tools` menu. In the appearing
window, choose the option “Install from: Package Archive File (.tgz;
.tar.gz)” and browse to `dm.tar.gz`.

-----

FIXME: funder, copyright holder, code of conduct
