The goal of the {dm} package and the `dm` class that comes with it, is
to make your life easier when you are dealing with data from several
different tables.

Let’s take a look at the `dm` class.

Class `dm`
----------

The `dm` class consists of a collection of tables and metadata about the
tables, such as

-   the names of the tables
-   the names of the columns of the tables
-   the primary and foreign keys of the tables to link the tables
    together
-   the data (either as data frames or as references to database tables)

All tables in a `dm` must be obtained from the same data source; csv
files and spreadsheets would need to be imported to data frames in R.

Examples of `dm` objects
------------------------

There are currently three options available for creating a `dm` object.
The relevant functions for creating `dm` objects are:

1.  `dm()`
2.  `as_dm()`
3.  `new_dm()`
4.  `dm_from_src()`

To illustrate these options, we will now create the same `dm` in several
different ways. We can use the tables from the well-known {nycflights13}
package.

### Pass the tables directly

Create a `dm` object directly by providing data frames to `dm()`:

``` r
library(nycflights13)
library(dm)
dm(airlines, airports, flights, planes, weather)
```

<PRE class="fansi fansi-output"><CODE>#&gt; <span style='color: #FFAFFF;'>──</span><span> </span><span style='color: #FFAFFF;'>Metadata</span><span> </span><span style='color: #FFAFFF;'>───────────────────────────────────────────────────────────────</span><span>
#&gt; Tables: `airlines`, `airports`, `flights`, `planes`, `weather`
#&gt; Columns: 53
#&gt; Primary keys: 0
#&gt; Foreign keys: 0
</span></CODE></PRE>

### Start with an empty `dm`

Start with an empty `dm` object that has been created with `dm()` or
`new_dm()`, and add tables to that object:

``` r
library(nycflights13)
library(dm)
empty_dm <- dm()
empty_dm
#> dm()
dm_add_tbl(empty_dm, airlines, airports, flights, planes, weather) 
```

<PRE class="fansi fansi-output"><CODE>#&gt; <span style='color: #FFAFFF;'>──</span><span> </span><span style='color: #FFAFFF;'>Metadata</span><span> </span><span style='color: #FFAFFF;'>───────────────────────────────────────────────────────────────</span><span>
#&gt; Tables: `airlines`, `airports`, `flights`, `planes`, `weather`
#&gt; Columns: 53
#&gt; Primary keys: 0
#&gt; Foreign keys: 0
</span></CODE></PRE>

### Coerce a list of tables

Turn a named list of tables into a `dm` with `as_dm()`:

``` r
as_dm(list(airlines = airlines, 
           airports = airports, 
           flights = flights, 
           planes = planes, 
           weather = weather))
```

<PRE class="fansi fansi-output"><CODE>#&gt; <span style='color: #FFAFFF;'>──</span><span> </span><span style='color: #FFAFFF;'>Metadata</span><span> </span><span style='color: #FFAFFF;'>───────────────────────────────────────────────────────────────</span><span>
#&gt; Tables: `airlines`, `airports`, `flights`, `planes`, `weather`
#&gt; Columns: 53
#&gt; Primary keys: 0
#&gt; Foreign keys: 0
</span></CODE></PRE>

### Turn tables from a `src` into a `dm`

Squeeze all (or a subset of) tables belonging to a `src` object into a
`dm` using `dm_from_src()`:

``` r
sqlite_src <- dbplyr::nycflights13_sqlite()

flights_dm <- dm_from_src(sqlite_src)
flights_dm
```

<PRE class="fansi fansi-output"><CODE>#&gt; <span style='color: #00BB00;'>──</span><span> </span><span style='color: #00BB00;'>Table source</span><span> </span><span style='color: #00BB00;'>───────────────────────────────────────────────────────────</span><span>
#&gt; src:  sqlite 3.30.1 [/tmp/Rtmp41BWR6/nycflights13.sqlite]
#&gt; </span><span style='color: #FFAFFF;'>──</span><span> </span><span style='color: #FFAFFF;'>Metadata</span><span> </span><span style='color: #FFAFFF;'>───────────────────────────────────────────────────────────────</span><span>
#&gt; Tables: `airlines`, `airports`, `flights`, `planes`, `sqlite_stat1`, … (7 total)
#&gt; Columns: 62
#&gt; Primary keys: 0
#&gt; Foreign keys: 0
</span></CODE></PRE>

The function `dm_from_src(src, table_names = NULL)` includes all
available tables on a source in the `dm` object. This means that you can
use this, for example, on a postgres database that you access via
`src_postgres()` (with the appropriate arguments `dbname`, `host`,
`port`, …), to produce a `dm` object with all the tables on the
database.

### Low-level construction

Another way of creating a `dm` object is calling `new_dm()` on a list of
`tbl` objects:

``` r
base_dm <- new_dm(list(trees = trees, mtcars = mtcars))
base_dm
```

<PRE class="fansi fansi-output"><CODE>#&gt; <span style='color: #FFAFFF;'>──</span><span> </span><span style='color: #FFAFFF;'>Metadata</span><span> </span><span style='color: #FFAFFF;'>───────────────────────────────────────────────────────────────</span><span>
#&gt; Tables: `trees`, `mtcars`
#&gt; Columns: 14
#&gt; Primary keys: 0
#&gt; Foreign keys: 0
</span></CODE></PRE>

This constructor is optimized for speed and does not perform integrity
checks. Use with caution, validate using `validate_dm()` if necessary.

``` r
validate_dm(base_dm)
```

Access tables
-------------

We can get the list of tables with `dm_get_tables()` and the `src`
object with `dm_get_src()`.

In order to pull a specific table from a `dm`, use:

``` r
tbl(flights_dm, "airports")
```

<PRE class="fansi fansi-output"><CODE>#&gt; <span style='color: #949494;'># Source:   table&lt;`airports`&gt; [?? x 8]</span><span>
#&gt; </span><span style='color: #949494;'># Database: sqlite 3.30.1 [/tmp/Rtmp41BWR6/nycflights13.sqlite]</span><span>
#&gt;    faa   name                    lat    lon   alt    tz dst   tzone        
#&gt;    </span><span style='color: #949494;font-style: italic;'>&lt;chr&gt;</span><span> </span><span style='color: #949494;font-style: italic;'>&lt;chr&gt;</span><span>                 </span><span style='color: #949494;font-style: italic;'>&lt;dbl&gt;</span><span>  </span><span style='color: #949494;font-style: italic;'>&lt;dbl&gt;</span><span> </span><span style='color: #949494;font-style: italic;'>&lt;dbl&gt;</span><span> </span><span style='color: #949494;font-style: italic;'>&lt;dbl&gt;</span><span> </span><span style='color: #949494;font-style: italic;'>&lt;chr&gt;</span><span> </span><span style='color: #949494;font-style: italic;'>&lt;chr&gt;</span><span>        
#&gt; </span><span style='color: #BCBCBC;'> 1</span><span> 04G   Lansdowne Airport      41.1  -</span><span style='color: #BB0000;'>80.6</span><span>  </span><span style='text-decoration: underline;'>1</span><span>044    -</span><span style='color: #BB0000;'>5</span><span> A     America/New_…
#&gt; </span><span style='color: #BCBCBC;'> 2</span><span> 06A   Moton Field Municipa…  32.5  -</span><span style='color: #BB0000;'>85.7</span><span>   264    -</span><span style='color: #BB0000;'>6</span><span> A     America/Chic…
#&gt; </span><span style='color: #BCBCBC;'> 3</span><span> 06C   Schaumburg Regional    42.0  -</span><span style='color: #BB0000;'>88.1</span><span>   801    -</span><span style='color: #BB0000;'>6</span><span> A     America/Chic…
#&gt; </span><span style='color: #BCBCBC;'> 4</span><span> 06N   Randall Airport        41.4  -</span><span style='color: #BB0000;'>74.4</span><span>   523    -</span><span style='color: #BB0000;'>5</span><span> A     America/New_…
#&gt; </span><span style='color: #BCBCBC;'> 5</span><span> 09J   Jekyll Island Airport  31.1  -</span><span style='color: #BB0000;'>81.4</span><span>    11    -</span><span style='color: #BB0000;'>5</span><span> A     America/New_…
#&gt; </span><span style='color: #BCBCBC;'> 6</span><span> 0A9   Elizabethton Municip…  36.4  -</span><span style='color: #BB0000;'>82.2</span><span>  </span><span style='text-decoration: underline;'>1</span><span>593    -</span><span style='color: #BB0000;'>5</span><span> A     America/New_…
#&gt; </span><span style='color: #BCBCBC;'> 7</span><span> 0G6   Williams County Airp…  41.5  -</span><span style='color: #BB0000;'>84.5</span><span>   730    -</span><span style='color: #BB0000;'>5</span><span> A     America/New_…
#&gt; </span><span style='color: #BCBCBC;'> 8</span><span> 0G7   Finger Lakes Regiona…  42.9  -</span><span style='color: #BB0000;'>76.8</span><span>   492    -</span><span style='color: #BB0000;'>5</span><span> A     America/New_…
#&gt; </span><span style='color: #BCBCBC;'> 9</span><span> 0P2   Shoestring Aviation …  39.8  -</span><span style='color: #BB0000;'>76.6</span><span>  </span><span style='text-decoration: underline;'>1</span><span>000    -</span><span style='color: #BB0000;'>5</span><span> U     America/New_…
#&gt; </span><span style='color: #BCBCBC;'>10</span><span> 0S9   Jefferson County Intl  48.1 -</span><span style='color: #BB0000;'>123.</span><span>    108    -</span><span style='color: #BB0000;'>8</span><span> A     America/Los_…
#&gt; </span><span style='color: #949494;'># … with more rows</span><span>
</span></CODE></PRE>

But how can we use {dm}-functions to manage the primary keys of the
tables in a `dm` object?

Primary keys of `dm` objects
----------------------------

Some useful functions for managing primary key settings are:

1.  `dm_add_pk()`
2.  `dm_has_pk()`
3.  `dm_get_pk()`
4.  `dm_rm_pk()`
5.  `dm_enum_pk_candidates()`
6.  `dm_get_all_pks()`

Currently `dm` objects only support one-column primary keys. If your
tables have unique compound keys, adding a surrogate key column might be
helpful. If you created a `dm` object according to the examples in
[“Examples of `dm` objects”](#ex_dm), your object does not yet have any
primary keys set. So let’s add one.

`dm_add_pk()` has an option to check if the column of the table given by
the user is a unique key; for performance reasons, the check will not be
executed unless requested. We use the `nycflights13` tables,
i.e. `flights_dm` from above.

``` r
dm_has_pk(flights_dm, airports)
#> [1] FALSE
flights_dm_with_key <- dm_add_pk(flights_dm, airports, faa)
flights_dm_with_key
```

<PRE class="fansi fansi-output"><CODE>#&gt; <span style='color: #00BB00;'>──</span><span> </span><span style='color: #00BB00;'>Table source</span><span> </span><span style='color: #00BB00;'>───────────────────────────────────────────────────────────</span><span>
#&gt; src:  sqlite 3.30.1 [/tmp/Rtmp41BWR6/nycflights13.sqlite]
#&gt; </span><span style='color: #FFAFFF;'>──</span><span> </span><span style='color: #FFAFFF;'>Metadata</span><span> </span><span style='color: #FFAFFF;'>───────────────────────────────────────────────────────────────</span><span>
#&gt; Tables: `airlines`, `airports`, `flights`, `planes`, `sqlite_stat1`, … (7 total)
#&gt; Columns: 62
#&gt; Primary keys: 1
#&gt; Foreign keys: 0
</span></CODE></PRE>

The `dm` now has a primary key. Let’s check:

``` r
dm_has_pk(flights_dm_with_key, airports)
#> [1] TRUE
```

Get the name of the column that is marked as primary key of the table:

``` r
dm_get_pk(flights_dm_with_key, airports)
#> <list_of<character>[1]>
#> [[1]]
#> [1] "faa"
```

Remove a primary key:

``` r
dm_rm_pk(flights_dm_with_key, airports) %>% 
  dm_has_pk(airports)
#> [1] FALSE
```

If you still need to get to know your data better, and it is already
available in the form of a `dm` object, you can use the
`dm_enum_pk_candidates()` function in order to get information about
which columns of the table are unique keys:

``` r
dm_enum_pk_candidates(flights_dm_with_key, airports)
```

<PRE class="fansi fansi-output"><CODE>#&gt; <span style='color: #949494;'># A tibble: 8 x 3</span><span>
#&gt;   columns candidate why                                                    
#&gt;   </span><span style='color: #949494;font-style: italic;'>&lt;keys&gt;</span><span>  </span><span style='color: #949494;font-style: italic;'>&lt;lgl&gt;</span><span>     </span><span style='color: #949494;font-style: italic;'>&lt;chr&gt;</span><span>                                                  
#&gt; </span><span style='color: #BCBCBC;'>1</span><span> faa     TRUE      </span><span style='color: #949494;'>""</span><span>                                                     
#&gt; </span><span style='color: #BCBCBC;'>2</span><span> lon     TRUE      </span><span style='color: #949494;'>""</span><span>                                                     
#&gt; </span><span style='color: #BCBCBC;'>3</span><span> alt     FALSE     </span><span style='color: #949494;'>"</span><span>has duplicate values: 0, 1, 3, 4, 5, …</span><span style='color: #949494;'>"</span><span>               
#&gt; </span><span style='color: #BCBCBC;'>4</span><span> dst     FALSE     </span><span style='color: #949494;'>"</span><span>has duplicate values: A, N, U</span><span style='color: #949494;'>"</span><span>                        
#&gt; </span><span style='color: #BCBCBC;'>5</span><span> lat     FALSE     </span><span style='color: #949494;'>"</span><span>has duplicate values: 38.88944, 40.63975</span><span style='color: #949494;'>"</span><span>             
#&gt; </span><span style='color: #BCBCBC;'>6</span><span> name    FALSE     </span><span style='color: #949494;'>"</span><span>has duplicate values: All Airports, Capital City Airp…
#&gt; </span><span style='color: #BCBCBC;'>7</span><span> tz      FALSE     </span><span style='color: #949494;'>"</span><span>has duplicate values: -10, -9, -8, -7, -6, …</span><span style='color: #949494;'>"</span><span>         
#&gt; </span><span style='color: #BCBCBC;'>8</span><span> tzone   FALSE     </span><span style='color: #949494;'>"</span><span>has duplicate values: NA, America/Anchorage, America/…
</span></CODE></PRE>

The `flights` table does not have any one-column primary key candidates:

``` r
dm_enum_pk_candidates(flights_dm_with_key, flights) %>% dplyr::count(candidate)
```

<PRE class="fansi fansi-output"><CODE>#&gt; <span style='color: #949494;'># A tibble: 1 x 2</span><span>
#&gt;   candidate     n
#&gt;   </span><span style='color: #949494;font-style: italic;'>&lt;lgl&gt;</span><span>     </span><span style='color: #949494;font-style: italic;'>&lt;int&gt;</span><span>
#&gt; </span><span style='color: #BCBCBC;'>1</span><span> FALSE        19
</span></CODE></PRE>

To get an overview over all tables with primary keys, use
`dm_get_all_pks()`:

``` r
dm_get_all_pks(dm_nycflights13(cycle = TRUE))
```

<PRE class="fansi fansi-output"><CODE>#&gt; <span style='color: #949494;'># A tibble: 3 x 2</span><span>
#&gt;   table    pk_col 
#&gt;   </span><span style='color: #949494;font-style: italic;'>&lt;chr&gt;</span><span>    </span><span style='color: #949494;font-style: italic;'>&lt;keys&gt;</span><span> 
#&gt; </span><span style='color: #BCBCBC;'>1</span><span> airlines carrier
#&gt; </span><span style='color: #BCBCBC;'>2</span><span> airports faa    
#&gt; </span><span style='color: #BCBCBC;'>3</span><span> planes   tailnum
</span></CODE></PRE>

Here we used the prepared `dm` object `dm_nycflights13(cycle = TRUE)` as
an example. This object already has all keys pre-set.

Foreign keys
------------

Useful functions for managing foreign key relations include:

1.  `dm_add_fk()`
2.  `dm_has_fk()`
3.  `dm_get_fk()`
4.  `dm_rm_fk()`
5.  `dm_enum_fk_candidates()`
6.  `dm_get_all_fks()`

Now it gets (even more) interesting: we want to define relations between
different tables. With the `dm_add_fk()` function you can define which
column of which table points to another table’s column.

This is done by choosing a foreign key from one table that will point to
a primary key of another table. The primary key of the referred table
must be set with `dm_add_pk()`. `dm_add_fk()` will find the primary key
column of the referenced table by itself and make the indicated column
of the child table point to it.

``` r
flights_dm_with_key %>% dm_add_fk(flights, origin, airports)
```

<PRE class="fansi fansi-output"><CODE>#&gt; <span style='color: #00BB00;'>──</span><span> </span><span style='color: #00BB00;'>Table source</span><span> </span><span style='color: #00BB00;'>───────────────────────────────────────────────────────────</span><span>
#&gt; src:  sqlite 3.30.1 [/tmp/Rtmp41BWR6/nycflights13.sqlite]
#&gt; </span><span style='color: #FFAFFF;'>──</span><span> </span><span style='color: #FFAFFF;'>Metadata</span><span> </span><span style='color: #FFAFFF;'>───────────────────────────────────────────────────────────────</span><span>
#&gt; Tables: `airlines`, `airports`, `flights`, `planes`, `sqlite_stat1`, … (7 total)
#&gt; Columns: 62
#&gt; Primary keys: 1
#&gt; Foreign keys: 1
</span></CODE></PRE>

This will throw an error:

``` r
flights_dm %>% dm_add_fk(flights, origin, airports)
#> Error: ref_table `airports` needs a primary key first. Use `dm_enum_pk_candidates()` to find appropriate columns and `dm_add_pk()` to define a primary key.
```

Let’s create a `dm` object with a foreign key relation to work with
later on:

``` r
flights_dm_with_fk <- dm_add_fk(flights_dm_with_key, flights, origin, airports)
```

What if we tried to add another foreign key relation from `flights` to
`airports` to the object? Column `dest` might work, since it also
contains airport codes:

``` r
flights_dm_with_fk %>% dm_add_fk(flights, dest, airports, check = TRUE)
#> Error: Column `dest` of table `flights` contains values (see above) that are not present in column `faa` of table `airports`.
```

As you can see, behind the scenes, checks are executed automatically
(unless `check = FALSE`) by the functions of `dm` to prevent steps that
would result in inconsistent representations.

Use `dm_has_fk()` for checking if a foreign key exists that is pointing
from one table to another:

``` r
flights_dm_with_fk %>% dm_has_fk(flights, planes)
#> [1] FALSE
flights_dm_with_fk %>% dm_has_fk(flights, airports)
#> [1] TRUE
```

If you want to access the name of the column which acts as a foreign key
of one table to another table’s column, use `dm_get_fk()`:

``` r
flights_dm_with_fk %>% dm_get_fk(flights, planes)
#> <list_of<character>[0]>
flights_dm_with_fk %>% dm_get_fk(flights, airports)
#> <list_of<character>[1]>
#> [[1]]
#> [1] "origin"
```

Remove foreign key relations with `dm_rm_fk()` (parameter
`column = NULL` means that all relations will be removed):

``` r
flights_dm_with_fk %>% 
  dm_rm_fk(table = flights, column = dest, ref_table = airports) %>% 
  dm_get_fk(flights, airports)
#> Error: (`dest`) is not a foreign key of table `flights` into table `airports`.
flights_dm_with_fk %>% 
  dm_rm_fk(flights, origin, airports) %>% 
  dm_get_fk(flights, airports)
#> <list_of<character>[0]>
flights_dm_with_fk %>% 
  dm_rm_fk(flights, NULL, airports) %>% 
  dm_get_fk(flights, airports)
#> <list_of<character>[0]>
```

Since the primary keys are defined in the `dm` object, you do not need
to provide the referenced column name of `ref_table`. This is always the
primary key column of the table.

Another function for getting to know your data better
(cf. `dm_enum_pk_candidates()` in [“Primary keys of `dm` objects”](#pk))
is `dm_enum_fk_candidates()`. Use it to get an overview over foreign key
candidates that point from one table to another:

``` r
dm_enum_fk_candidates(flights_dm_with_key, weather, airports)
```

<PRE class="fansi fansi-output"><CODE>#&gt; <span style='color: #949494;'># A tibble: 15 x 3</span><span>
#&gt;    columns    candidate why                                                
#&gt;    </span><span style='color: #949494;font-style: italic;'>&lt;keys&gt;</span><span>     </span><span style='color: #949494;font-style: italic;'>&lt;lgl&gt;</span><span>     </span><span style='color: #949494;font-style: italic;'>&lt;chr&gt;</span><span>                                              
#&gt; </span><span style='color: #BCBCBC;'> 1</span><span> origin     TRUE      </span><span style='color: #949494;'>""</span><span>                                                 
#&gt; </span><span style='color: #BCBCBC;'> 2</span><span> wind_gust  FALSE     </span><span style='color: #949494;'>"</span><span>5337 entries (20.4%) of `weather$wind_gust` not i…
#&gt; </span><span style='color: #BCBCBC;'> 3</span><span> pressure   FALSE     </span><span style='color: #949494;'>"</span><span>23386 entries (89.6%) of `weather$pressure` not i…
#&gt; </span><span style='color: #BCBCBC;'> 4</span><span> wind_dir   FALSE     </span><span style='color: #949494;'>"</span><span>25655 entries (98.2%) of `weather$wind_dir` not i…
#&gt; </span><span style='color: #BCBCBC;'> 5</span><span> wind_speed FALSE     </span><span style='color: #949494;'>"</span><span>26111 entries (100%) of `weather$wind_speed` not …
#&gt; </span><span style='color: #BCBCBC;'> 6</span><span> dewp       FALSE     </span><span style='color: #949494;'>"</span><span>26114 entries (100%) of `weather$dewp` not in `ai…
#&gt; </span><span style='color: #BCBCBC;'> 7</span><span> humid      FALSE     </span><span style='color: #949494;'>"</span><span>26114 entries (100%) of `weather$humid` not in `a…
#&gt; </span><span style='color: #BCBCBC;'> 8</span><span> temp       FALSE     </span><span style='color: #949494;'>"</span><span>26114 entries (100%) of `weather$temp` not in `ai…
#&gt; </span><span style='color: #BCBCBC;'> 9</span><span> day        FALSE     </span><span style='color: #949494;'>"</span><span>26115 entries (100%) of `weather$day` not in `air…
#&gt; </span><span style='color: #BCBCBC;'>10</span><span> hour       FALSE     </span><span style='color: #949494;'>"</span><span>26115 entries (100%) of `weather$hour` not in `ai…
#&gt; </span><span style='color: #BCBCBC;'>11</span><span> month      FALSE     </span><span style='color: #949494;'>"</span><span>26115 entries (100%) of `weather$month` not in `a…
#&gt; </span><span style='color: #BCBCBC;'>12</span><span> precip     FALSE     </span><span style='color: #949494;'>"</span><span>26115 entries (100%) of `weather$precip` not in `…
#&gt; </span><span style='color: #BCBCBC;'>13</span><span> time_hour  FALSE     </span><span style='color: #949494;'>"</span><span>26115 entries (100%) of `weather$time_hour` not i…
#&gt; </span><span style='color: #BCBCBC;'>14</span><span> visib      FALSE     </span><span style='color: #949494;'>"</span><span>26115 entries (100%) of `weather$visib` not in `a…
#&gt; </span><span style='color: #BCBCBC;'>15</span><span> year       FALSE     </span><span style='color: #949494;'>"</span><span>26115 entries (100%) of `weather$year` not in `ai…
</span></CODE></PRE>

Get an overview of all foreign key relations with`dm_get_all_fks()`:

``` r
dm_get_all_fks(dm_nycflights13(cycle = TRUE))
```

<PRE class="fansi fansi-output"><CODE>#&gt; <span style='color: #949494;'># A tibble: 4 x 3</span><span>
#&gt;   child_table child_fk_cols parent_table
#&gt;   </span><span style='color: #949494;font-style: italic;'>&lt;chr&gt;</span><span>       </span><span style='color: #949494;font-style: italic;'>&lt;keys&gt;</span><span>        </span><span style='color: #949494;font-style: italic;'>&lt;chr&gt;</span><span>       
#&gt; </span><span style='color: #BCBCBC;'>1</span><span> flights     carrier       airlines    
#&gt; </span><span style='color: #BCBCBC;'>2</span><span> flights     dest          airports    
#&gt; </span><span style='color: #BCBCBC;'>3</span><span> flights     origin        airports    
#&gt; </span><span style='color: #BCBCBC;'>4</span><span> flights     tailnum       planes
</span></CODE></PRE>
