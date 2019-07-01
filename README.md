
# dm

The goal of `dm` is to provide tools for frequently required tasks when
working with a set of related tables, independent of where the tables
are living.

## Installation

You can receive the package as a file `dm.tar.gz` from Kirill Müller,
Email: <kirill@cynkra.com> .
<!-- FIXME: almost outdated, needs to be github-link  -->

One way to install it to your R-Library is by opening R-Studio and
selecting “Install Packages…” from the `Tools` menu. In the appearing
window, choose the option “Install from: Package Archive File (.tgz;
.tar.gz)” and browse to `dm.tar.gz`.

## Class `dm`

The new class `dm` is essentially a list containing all the important
information about a set of related tables, its components being:

  - `src` object: location of tables (database (DB), locally, …)
  - a so-called `data_model` object: meta-info about data model (keys,
    table & columns names, …)
  - the data: the tables itself

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

<img src="man/figures/README-unnamed-chunk-2-1.png" width="100%" />

The different colors of the tables were assigned in
`cdm_nycflights13()`. For how to add colors to subsets of the tables and
further customization please see vignette “Visualizing ‘dm’ objects”
<!-- FIXME: vignette missing; once there, needs to be linked -->

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
  - Visualizing ‘dm’ objects (missing as of yet)
  - Filtering (missing as of yet)
  - {dm} and databases (missing as of yet)
  - Further operations (missing as of yet)
  - Shiny with {dynafilter} (missing as of yet)
    <!-- FIXME: vignettes missing; once there, needs to be linked -->

## Package overview

To get an overview of `dm`, you can call the package’s function
`browse_docs()`, which will open a .html-file in your standard web
browser. You can also manually open the file, it is `index.html` in the
folder `pkgdown`.
