This vignette deals with situations where you want to transform tables
of your `dm` and then update an existing table or add a new table to the
`dm`. There are two straightforward approaches:

1.  individually extract the tables relevant to the calculation, perform
    the necessary transformations, add the result to the `dm` (or
    replace an existing table) and establish the key relations.
2.  do all this within the `dm` object by zooming to a table and
    manipulating it while maintaining the key relations whenever
    possible.

The first approach is rather self-explanatory, so let us have a closer
look at the second way.

Enabling {dplyr}-workflow within a `dm`
---------------------------------------

Some general information about “zooming” to a table of a `dm`: - all
information stored in the original `dm` is kept, including the
originally zoomed table - an object of class `zoomed_dm` is produced,
presenting a view of the table for transformations - you do not need to
specify the table when calling `select()`, `mutate()` and other table
manipulation functions

{dm} provides methods for many of the {dplyr}-verbs for a `zoomed_dm`
which behave the way you are used to, affecting only the zoomed table
and leaving the rest of the `dm` untouched. When you are finished with
transforming the table, there are three options to proceed:

1.  use `dm_update_zoomed()` if you want to replace the originally
    zoomed table with the new table
2.  use `dm_insert_zoomed()` if you are creating a new table for your
    `dm`
3.  use `dm_discard_zoomed()` if you do not need the result and want to
    discard it

When employing one of the first two options, the resulting table in the
`dm` will have all the primary and foreign keys available that could be
tracked from the originally zoomed table.

Examples
--------

So much for the theory, but how does it look and feel? To explore this,
we once more make use of our trusted {nycflights13} data.

### Use case 1: Add a new column to an existing table

Imagine you want to have a column in `flights`, specifying if a flight
left before noon or after. Just like with {dplyr}, we can tackle this
with `mutate()`. Let us do this step by step:

``` r
library(dm)
library(dplyr)
#> 
#> Attaching package: 'dplyr'
#> The following object is masked from 'package:testthat':
#> 
#>     matches
#> The following objects are masked from 'package:stats':
#> 
#>     filter, lag
#> The following objects are masked from 'package:base':
#> 
#>     intersect, setdiff, setequal, union
flights_dm <- dm_nycflights13()
flights_dm
```

<PRE class="fansi fansi-output"><CODE>#&gt; <span style='color: #FFAFFF;'>──</span><span> </span><span style='color: #FFAFFF;'>Metadata</span><span> </span><span style='color: #FFAFFF;'>───────────────────────────────────────────────────────────────</span><span>
#&gt; Tables: `airlines`, `airports`, `flights`, `planes`, `weather`
#&gt; Columns: 53
#&gt; Primary keys: 3
#&gt; Foreign keys: 3
</span></CODE></PRE>

``` r
flights_zoomed <- 
  flights_dm %>% 
  dm_zoom_to(flights)
# The print output for a `zoomed_dm` looks very much like that from a normal `tibble`.
flights_zoomed
```

<PRE class="fansi fansi-output"><CODE>#&gt; <span style='color: #949494;'># Zoomed table: flights</span><span>
#&gt; </span><span style='color: #949494;'># A tibble:     11,227 x 19</span><span>
#&gt;     year month   day dep_time sched_dep_time dep_delay arr_time
#&gt;    </span><span style='color: #949494;font-style: italic;'>&lt;int&gt;</span><span> </span><span style='color: #949494;font-style: italic;'>&lt;int&gt;</span><span> </span><span style='color: #949494;font-style: italic;'>&lt;int&gt;</span><span>    </span><span style='color: #949494;font-style: italic;'>&lt;int&gt;</span><span>          </span><span style='color: #949494;font-style: italic;'>&lt;int&gt;</span><span>     </span><span style='color: #949494;font-style: italic;'>&lt;dbl&gt;</span><span>    </span><span style='color: #949494;font-style: italic;'>&lt;int&gt;</span><span>
#&gt; </span><span style='color: #BCBCBC;'> 1</span><span>  </span><span style='text-decoration: underline;'>2</span><span>013     1    10        3           </span><span style='text-decoration: underline;'>2</span><span>359         4      426
#&gt; </span><span style='color: #BCBCBC;'> 2</span><span>  </span><span style='text-decoration: underline;'>2</span><span>013     1    10       16           </span><span style='text-decoration: underline;'>2</span><span>359        17      447
#&gt; </span><span style='color: #BCBCBC;'> 3</span><span>  </span><span style='text-decoration: underline;'>2</span><span>013     1    10      450            500       -</span><span style='color: #BB0000;'>10</span><span>      634
#&gt; </span><span style='color: #BCBCBC;'> 4</span><span>  </span><span style='text-decoration: underline;'>2</span><span>013     1    10      520            525        -</span><span style='color: #BB0000;'>5</span><span>      813
#&gt; </span><span style='color: #BCBCBC;'> 5</span><span>  </span><span style='text-decoration: underline;'>2</span><span>013     1    10      530            530         0      824
#&gt; </span><span style='color: #BCBCBC;'> 6</span><span>  </span><span style='text-decoration: underline;'>2</span><span>013     1    10      531            540        -</span><span style='color: #BB0000;'>9</span><span>      832
#&gt; </span><span style='color: #BCBCBC;'> 7</span><span>  </span><span style='text-decoration: underline;'>2</span><span>013     1    10      535            540        -</span><span style='color: #BB0000;'>5</span><span>     </span><span style='text-decoration: underline;'>1</span><span>015
#&gt; </span><span style='color: #BCBCBC;'> 8</span><span>  </span><span style='text-decoration: underline;'>2</span><span>013     1    10      546            600       -</span><span style='color: #BB0000;'>14</span><span>      645
#&gt; </span><span style='color: #BCBCBC;'> 9</span><span>  </span><span style='text-decoration: underline;'>2</span><span>013     1    10      549            600       -</span><span style='color: #BB0000;'>11</span><span>      652
#&gt; </span><span style='color: #BCBCBC;'>10</span><span>  </span><span style='text-decoration: underline;'>2</span><span>013     1    10      550            600       -</span><span style='color: #BB0000;'>10</span><span>      649
#&gt; </span><span style='color: #949494;'># … with 11,217 more rows, and 12 more variables: sched_arr_time </span><span style='color: #949494;font-style: italic;'>&lt;int&gt;</span><span style='color: #949494;'>,</span><span>
#&gt; </span><span style='color: #949494;'>#   arr_delay </span><span style='color: #949494;font-style: italic;'>&lt;dbl&gt;</span><span style='color: #949494;'>, carrier </span><span style='color: #949494;font-style: italic;'>&lt;chr&gt;</span><span style='color: #949494;'>, flight </span><span style='color: #949494;font-style: italic;'>&lt;int&gt;</span><span style='color: #949494;'>, tailnum </span><span style='color: #949494;font-style: italic;'>&lt;chr&gt;</span><span style='color: #949494;'>,</span><span>
#&gt; </span><span style='color: #949494;'>#   origin </span><span style='color: #949494;font-style: italic;'>&lt;chr&gt;</span><span style='color: #949494;'>, dest </span><span style='color: #949494;font-style: italic;'>&lt;chr&gt;</span><span style='color: #949494;'>, air_time </span><span style='color: #949494;font-style: italic;'>&lt;dbl&gt;</span><span style='color: #949494;'>, distance </span><span style='color: #949494;font-style: italic;'>&lt;dbl&gt;</span><span style='color: #949494;'>, hour </span><span style='color: #949494;font-style: italic;'>&lt;dbl&gt;</span><span style='color: #949494;'>,</span><span>
#&gt; </span><span style='color: #949494;'>#   minute </span><span style='color: #949494;font-style: italic;'>&lt;dbl&gt;</span><span style='color: #949494;'>, time_hour </span><span style='color: #949494;font-style: italic;'>&lt;dttm&gt;</span><span>
</span></CODE></PRE>

``` r

flights_zoomed_mutate <- 
  flights_zoomed %>% 
  mutate(am_pm_dep = if_else(dep_time < 1200, "am", "pm")) %>% 
  # in order to see our changes in the output we use `select()` for reordering the columns
  select(year:dep_time, am_pm_dep, everything())
flights_zoomed_mutate
```

<PRE class="fansi fansi-output"><CODE>#&gt; <span style='color: #949494;'># Zoomed table: flights</span><span>
#&gt; </span><span style='color: #949494;'># A tibble:     11,227 x 20</span><span>
#&gt;     year month   day dep_time am_pm_dep sched_dep_time dep_delay arr_time
#&gt;    </span><span style='color: #949494;font-style: italic;'>&lt;int&gt;</span><span> </span><span style='color: #949494;font-style: italic;'>&lt;int&gt;</span><span> </span><span style='color: #949494;font-style: italic;'>&lt;int&gt;</span><span>    </span><span style='color: #949494;font-style: italic;'>&lt;int&gt;</span><span> </span><span style='color: #949494;font-style: italic;'>&lt;chr&gt;</span><span>              </span><span style='color: #949494;font-style: italic;'>&lt;int&gt;</span><span>     </span><span style='color: #949494;font-style: italic;'>&lt;dbl&gt;</span><span>    </span><span style='color: #949494;font-style: italic;'>&lt;int&gt;</span><span>
#&gt; </span><span style='color: #BCBCBC;'> 1</span><span>  </span><span style='text-decoration: underline;'>2</span><span>013     1    10        3 am                  </span><span style='text-decoration: underline;'>2</span><span>359         4      426
#&gt; </span><span style='color: #BCBCBC;'> 2</span><span>  </span><span style='text-decoration: underline;'>2</span><span>013     1    10       16 am                  </span><span style='text-decoration: underline;'>2</span><span>359        17      447
#&gt; </span><span style='color: #BCBCBC;'> 3</span><span>  </span><span style='text-decoration: underline;'>2</span><span>013     1    10      450 am                   500       -</span><span style='color: #BB0000;'>10</span><span>      634
#&gt; </span><span style='color: #BCBCBC;'> 4</span><span>  </span><span style='text-decoration: underline;'>2</span><span>013     1    10      520 am                   525        -</span><span style='color: #BB0000;'>5</span><span>      813
#&gt; </span><span style='color: #BCBCBC;'> 5</span><span>  </span><span style='text-decoration: underline;'>2</span><span>013     1    10      530 am                   530         0      824
#&gt; </span><span style='color: #BCBCBC;'> 6</span><span>  </span><span style='text-decoration: underline;'>2</span><span>013     1    10      531 am                   540        -</span><span style='color: #BB0000;'>9</span><span>      832
#&gt; </span><span style='color: #BCBCBC;'> 7</span><span>  </span><span style='text-decoration: underline;'>2</span><span>013     1    10      535 am                   540        -</span><span style='color: #BB0000;'>5</span><span>     </span><span style='text-decoration: underline;'>1</span><span>015
#&gt; </span><span style='color: #BCBCBC;'> 8</span><span>  </span><span style='text-decoration: underline;'>2</span><span>013     1    10      546 am                   600       -</span><span style='color: #BB0000;'>14</span><span>      645
#&gt; </span><span style='color: #BCBCBC;'> 9</span><span>  </span><span style='text-decoration: underline;'>2</span><span>013     1    10      549 am                   600       -</span><span style='color: #BB0000;'>11</span><span>      652
#&gt; </span><span style='color: #BCBCBC;'>10</span><span>  </span><span style='text-decoration: underline;'>2</span><span>013     1    10      550 am                   600       -</span><span style='color: #BB0000;'>10</span><span>      649
#&gt; </span><span style='color: #949494;'># … with 11,217 more rows, and 12 more variables: sched_arr_time </span><span style='color: #949494;font-style: italic;'>&lt;int&gt;</span><span style='color: #949494;'>,</span><span>
#&gt; </span><span style='color: #949494;'>#   arr_delay </span><span style='color: #949494;font-style: italic;'>&lt;dbl&gt;</span><span style='color: #949494;'>, carrier </span><span style='color: #949494;font-style: italic;'>&lt;chr&gt;</span><span style='color: #949494;'>, flight </span><span style='color: #949494;font-style: italic;'>&lt;int&gt;</span><span style='color: #949494;'>, tailnum </span><span style='color: #949494;font-style: italic;'>&lt;chr&gt;</span><span style='color: #949494;'>,</span><span>
#&gt; </span><span style='color: #949494;'>#   origin </span><span style='color: #949494;font-style: italic;'>&lt;chr&gt;</span><span style='color: #949494;'>, dest </span><span style='color: #949494;font-style: italic;'>&lt;chr&gt;</span><span style='color: #949494;'>, air_time </span><span style='color: #949494;font-style: italic;'>&lt;dbl&gt;</span><span style='color: #949494;'>, distance </span><span style='color: #949494;font-style: italic;'>&lt;dbl&gt;</span><span style='color: #949494;'>, hour </span><span style='color: #949494;font-style: italic;'>&lt;dbl&gt;</span><span style='color: #949494;'>,</span><span>
#&gt; </span><span style='color: #949494;'>#   minute </span><span style='color: #949494;font-style: italic;'>&lt;dbl&gt;</span><span style='color: #949494;'>, time_hour </span><span style='color: #949494;font-style: italic;'>&lt;dttm&gt;</span><span>
</span></CODE></PRE>

``` r

# To update the original `dm` with a new `flights` table we use `dm_update_zoomed()`:
updated_flights_dm <- 
  flights_zoomed_mutate %>% 
  dm_update_zoomed()
# The only difference in the `dm` print output is the increased number of columns
updated_flights_dm
```

<PRE class="fansi fansi-output"><CODE>#&gt; <span style='color: #FFAFFF;'>──</span><span> </span><span style='color: #FFAFFF;'>Metadata</span><span> </span><span style='color: #FFAFFF;'>───────────────────────────────────────────────────────────────</span><span>
#&gt; Tables: `airlines`, `airports`, `flights`, `planes`, `weather`
#&gt; Columns: 54
#&gt; Primary keys: 3
#&gt; Foreign keys: 3
</span></CODE></PRE>

``` r
# The schematic view of the data model remains unchanged
dm_draw(updated_flights_dm)
```

![](/home/kirill/git/cynkra/cynkra/public/dm/vignettes/out/tech-dm-zoom_files/figure-markdown_github/zoom-1.png)

### Use case 2: Creation of a surrogate key

The same course of action could, for example, be employed to create a
surrogate key for a table. We can do this for the `weather` table.

``` r
library(tidyr)
#> 
#> Attaching package: 'tidyr'
#> The following object is masked from 'package:dm':
#> 
#>     extract
#> The following object is masked from 'package:testthat':
#> 
#>     matches
weather_zoomed <- 
  flights_dm %>% 
  dm_zoom_to(weather)
weather_zoomed
```

<PRE class="fansi fansi-output"><CODE>#&gt; <span style='color: #949494;'># Zoomed table: weather</span><span>
#&gt; </span><span style='color: #949494;'># A tibble:     861 x 15</span><span>
#&gt;    origin  year month   day  hour  temp  dewp humid wind_dir wind_speed
#&gt;    </span><span style='color: #949494;font-style: italic;'>&lt;chr&gt;</span><span>  </span><span style='color: #949494;font-style: italic;'>&lt;int&gt;</span><span> </span><span style='color: #949494;font-style: italic;'>&lt;int&gt;</span><span> </span><span style='color: #949494;font-style: italic;'>&lt;int&gt;</span><span> </span><span style='color: #949494;font-style: italic;'>&lt;int&gt;</span><span> </span><span style='color: #949494;font-style: italic;'>&lt;dbl&gt;</span><span> </span><span style='color: #949494;font-style: italic;'>&lt;dbl&gt;</span><span> </span><span style='color: #949494;font-style: italic;'>&lt;dbl&gt;</span><span>    </span><span style='color: #949494;font-style: italic;'>&lt;dbl&gt;</span><span>      </span><span style='color: #949494;font-style: italic;'>&lt;dbl&gt;</span><span>
#&gt; </span><span style='color: #BCBCBC;'> 1</span><span> EWR     </span><span style='text-decoration: underline;'>2</span><span>013     1    10     0  41    32    70.1      230       8.06
#&gt; </span><span style='color: #BCBCBC;'> 2</span><span> EWR     </span><span style='text-decoration: underline;'>2</span><span>013     1    10     1  39.0  30.0  69.9      210       9.21
#&gt; </span><span style='color: #BCBCBC;'> 3</span><span> EWR     </span><span style='text-decoration: underline;'>2</span><span>013     1    10     2  39.0  28.9  66.8      230       6.90
#&gt; </span><span style='color: #BCBCBC;'> 4</span><span> EWR     </span><span style='text-decoration: underline;'>2</span><span>013     1    10     3  39.9  27.0  59.5      270       5.75
#&gt; </span><span style='color: #BCBCBC;'> 5</span><span> EWR     </span><span style='text-decoration: underline;'>2</span><span>013     1    10     4  41    26.1  55.0      320       6.90
#&gt; </span><span style='color: #BCBCBC;'> 6</span><span> EWR     </span><span style='text-decoration: underline;'>2</span><span>013     1    10     5  41    26.1  55.0      300      12.7 
#&gt; </span><span style='color: #BCBCBC;'> 7</span><span> EWR     </span><span style='text-decoration: underline;'>2</span><span>013     1    10     6  39.9  25.0  54.8      280       6.90
#&gt; </span><span style='color: #BCBCBC;'> 8</span><span> EWR     </span><span style='text-decoration: underline;'>2</span><span>013     1    10     7  41    25.0  52.6      330       6.90
#&gt; </span><span style='color: #BCBCBC;'> 9</span><span> EWR     </span><span style='text-decoration: underline;'>2</span><span>013     1    10     8  43.0  25.0  48.7      330       8.06
#&gt; </span><span style='color: #BCBCBC;'>10</span><span> EWR     </span><span style='text-decoration: underline;'>2</span><span>013     1    10     9  45.0  23    41.6      320      17.3 
#&gt; </span><span style='color: #949494;'># … with 851 more rows, and 5 more variables: wind_gust </span><span style='color: #949494;font-style: italic;'>&lt;dbl&gt;</span><span style='color: #949494;'>,</span><span>
#&gt; </span><span style='color: #949494;'>#   precip </span><span style='color: #949494;font-style: italic;'>&lt;dbl&gt;</span><span style='color: #949494;'>, pressure </span><span style='color: #949494;font-style: italic;'>&lt;dbl&gt;</span><span style='color: #949494;'>, visib </span><span style='color: #949494;font-style: italic;'>&lt;dbl&gt;</span><span style='color: #949494;'>, time_hour </span><span style='color: #949494;font-style: italic;'>&lt;dttm&gt;</span><span>
</span></CODE></PRE>

``` r
# Maybe there is some hidden candidate for a primary key that we overlooked
enum_pk_candidates(weather_zoomed)
```

<PRE class="fansi fansi-output"><CODE>#&gt; <span style='color: #949494;'># A tibble: 15 x 3</span><span>
#&gt;    columns    candidate why                                                
#&gt;    </span><span style='color: #949494;font-style: italic;'>&lt;keys&gt;</span><span>     </span><span style='color: #949494;font-style: italic;'>&lt;lgl&gt;</span><span>     </span><span style='color: #949494;font-style: italic;'>&lt;chr&gt;</span><span>                                              
#&gt; </span><span style='color: #BCBCBC;'> 1</span><span> day        FALSE     has duplicate values: 10                           
#&gt; </span><span style='color: #BCBCBC;'> 2</span><span> dewp       FALSE     has duplicate values: 5.00, 6.08, 6.98, 8.06, 8.96…
#&gt; </span><span style='color: #BCBCBC;'> 3</span><span> hour       FALSE     has duplicate values: 0, 1, 2, 3, 4, …             
#&gt; </span><span style='color: #BCBCBC;'> 4</span><span> humid      FALSE     has duplicate values: 32.53, 32.86, 34.41, 36.31, …
#&gt; </span><span style='color: #BCBCBC;'> 5</span><span> month      FALSE     has duplicate values: 1, 2, 3, 4, 5, …             
#&gt; </span><span style='color: #BCBCBC;'> 6</span><span> origin     FALSE     has duplicate values: EWR, JFK, LGA                
#&gt; </span><span style='color: #BCBCBC;'> 7</span><span> precip     FALSE     has duplicate values: 0.00, 0.01, 0.02, 0.03, 0.04…
#&gt; </span><span style='color: #BCBCBC;'> 8</span><span> pressure   FALSE     has duplicate values: 1009.4, 1009.7, 1009.8, 1009…
#&gt; </span><span style='color: #BCBCBC;'> 9</span><span> temp       FALSE     has duplicate values: 15.98, 17.06, 17.96, 19.04, …
#&gt; </span><span style='color: #BCBCBC;'>10</span><span> time_hour  FALSE     has duplicate values: 2013-01-10 00:00:00, 2013-01…
#&gt; </span><span style='color: #BCBCBC;'>11</span><span> visib      FALSE     has duplicate values: 0.25, 0.50, 2.00, 2.50, 3.00…
#&gt; </span><span style='color: #BCBCBC;'>12</span><span> wind_dir   FALSE     has duplicate values: 0, 10, 20, 30, 40, …         
#&gt; </span><span style='color: #BCBCBC;'>13</span><span> wind_gust  FALSE     has duplicate values: 16.11092, 17.26170, 18.41248…
#&gt; </span><span style='color: #BCBCBC;'>14</span><span> wind_speed FALSE     has duplicate values: 0.00000, 3.45234, 4.60312, 5…
#&gt; </span><span style='color: #BCBCBC;'>15</span><span> year       FALSE     has duplicate values: 2013
</span></CODE></PRE>

``` r
# Seems we have to construct a column with unique values
# This can be done by combining column `origin` with `time_hour`, if the latter 
# is converted to a single time zone first; all within the `dm`:
weather_zoomed_mutate <- 
  weather_zoomed %>% 
  # first convert all times to the same time zone:
  mutate(time_hour_fmt = format(time_hour, tz = "UTC")) %>% 
  # paste together as character the airport code and the time
  unite("origin_slot_id", origin, time_hour_fmt) %>% 
  select(origin_slot_id, everything())
# check if we the result is as expected:
enum_pk_candidates(weather_zoomed_mutate) %>% filter(candidate)
```

<PRE class="fansi fansi-output"><CODE>#&gt; <span style='color: #949494;'># A tibble: 1 x 3</span><span>
#&gt;   columns        candidate why  
#&gt;   </span><span style='color: #949494;font-style: italic;'>&lt;keys&gt;</span><span>         </span><span style='color: #949494;font-style: italic;'>&lt;lgl&gt;</span><span>     </span><span style='color: #949494;font-style: italic;'>&lt;chr&gt;</span><span>
#&gt; </span><span style='color: #BCBCBC;'>1</span><span> origin_slot_id TRUE      </span><span style='color: #949494;'>""</span><span>
</span></CODE></PRE>

``` r
flights_upd_weather_dm <- 
  weather_zoomed_mutate %>% 
  dm_update_zoomed() %>% 
  dm_add_pk(weather, origin_slot_id)
flights_upd_weather_dm
```

<PRE class="fansi fansi-output"><CODE>#&gt; <span style='color: #FFAFFF;'>──</span><span> </span><span style='color: #FFAFFF;'>Metadata</span><span> </span><span style='color: #FFAFFF;'>───────────────────────────────────────────────────────────────</span><span>
#&gt; Tables: `airlines`, `airports`, `flights`, `planes`, `weather`
#&gt; Columns: 53
#&gt; Primary keys: 4
#&gt; Foreign keys: 3
</span></CODE></PRE>

``` r
# creating the coveted FK relation between `flights` and `weather`
extended_flights_dm <- 
  flights_upd_weather_dm %>% 
  dm_zoom_to(flights) %>% 
  mutate(time_hour_fmt = format(time_hour, tz = "UTC")) %>% 
  # need to keep `origin` as FK to airports, so `remove = FALSE`
  unite("origin_slot_id", origin, time_hour_fmt, remove = FALSE) %>% 
  dm_update_zoomed() %>% 
  dm_add_fk(flights, origin_slot_id, weather)
extended_flights_dm %>% dm_draw()
```

![](/home/kirill/git/cynkra/cynkra/public/dm/vignettes/out/tech-dm-zoom_files/figure-markdown_github/unnamed-chunk-1-1.png)

### Use case 3: Disentangle `dm`

If you look at the `dm` created by `dm_nycflights13(cycle = TRUE)`, you
see that two columns of `flights` relate to one and the same table,
`airports`. One column stands for the departure airport and the other
for the arrival airport.

``` r
dm_draw(dm_nycflights13(cycle = TRUE))
```

![](/home/kirill/git/cynkra/cynkra/public/dm/vignettes/out/tech-dm-zoom_files/figure-markdown_github/unnamed-chunk-2-1.png)
In such cases it can be beneficial, to “disentangle” the `dm` by
duplicating the referred table. One way to do this in the {dm}-framework
is as follows:

``` r
disentangled_flights_dm <- 
  dm_nycflights13(cycle = TRUE) %>% 
  # zooming and immediately inserting essentially creates a copy of the original table
  dm_zoom_to(airports) %>% 
  # reinserting the `airports` table under the name `destination`
  dm_insert_zoomed("destination") %>% 
  # renaming the originally zoomed table
  dm_rename_tbl(origin = airports) %>% 
  # Key relations are also duplicated, so the wrong ones need to be removed
  dm_rm_fk(flights, dest, origin) %>% 
  dm_rm_fk(flights, origin, destination)
dm_draw(disentangled_flights_dm)
```

![](/home/kirill/git/cynkra/cynkra/public/dm/vignettes/out/tech-dm-zoom_files/figure-markdown_github/unnamed-chunk-3-1.png)

In a future update we will provide a more convenient way to
“disentangle” `dm` objects, so that the individual steps will be done
automatically.

### Use case 4: Add summary table to `dm`

Here is an example for adding a summary of a table as a new table to a
`dm` (FK-relations are taken care of automatically):

``` r
dm_with_summary <- 
  flights_dm %>% 
  dm_zoom_to(flights) %>% 
  count(origin, carrier) %>% 
  dm_insert_zoomed("dep_carrier_count")
dm_draw(dm_with_summary)
```

![](/home/kirill/git/cynkra/cynkra/public/dm/vignettes/out/tech-dm-zoom_files/figure-markdown_github/unnamed-chunk-4-1.png)

### Use case 5: Joining tables

If you would like to join some or all of the columns of one table to
another, you can make use of one of the `join`-methods for a
`zoomed_dm`. In addition to the usual arguments for the {dplyr}-joins,
by supplying the `select` argument you can specify which columns of the
RHS-table you want to be included in the join. For the syntax please see
the example below. The LHS-table of a join is always the zoomed table.

``` r
joined_flights_dm <- 
  flights_dm %>% 
  dm_zoom_to(flights) %>% 
  # let's first reduce the number of columns of flights
  select(-dep_delay:-arr_delay, -air_time:-time_hour) %>% 
  # in the {dm}-method for the joins you can specify which columns you want to add to the zoomed table
  left_join(planes, select = c(tailnum, plane_type = type)) %>% 
  dm_insert_zoomed("flights_plane_type")
# this is how the table looks now
joined_flights_dm$flights_plane_type
```

<PRE class="fansi fansi-output"><CODE>#&gt; <span style='color: #949494;'># A tibble: 11,227 x 11</span><span>
#&gt;     year month   day dep_time sched_dep_time carrier flight tailnum origin
#&gt;    </span><span style='color: #949494;font-style: italic;'>&lt;int&gt;</span><span> </span><span style='color: #949494;font-style: italic;'>&lt;int&gt;</span><span> </span><span style='color: #949494;font-style: italic;'>&lt;int&gt;</span><span>    </span><span style='color: #949494;font-style: italic;'>&lt;int&gt;</span><span>          </span><span style='color: #949494;font-style: italic;'>&lt;int&gt;</span><span> </span><span style='color: #949494;font-style: italic;'>&lt;chr&gt;</span><span>    </span><span style='color: #949494;font-style: italic;'>&lt;int&gt;</span><span> </span><span style='color: #949494;font-style: italic;'>&lt;chr&gt;</span><span>   </span><span style='color: #949494;font-style: italic;'>&lt;chr&gt;</span><span> 
#&gt; </span><span style='color: #BCBCBC;'> 1</span><span>  </span><span style='text-decoration: underline;'>2</span><span>013     1    10        3           </span><span style='text-decoration: underline;'>2</span><span>359 B6         727 N571JB  JFK   
#&gt; </span><span style='color: #BCBCBC;'> 2</span><span>  </span><span style='text-decoration: underline;'>2</span><span>013     1    10       16           </span><span style='text-decoration: underline;'>2</span><span>359 B6         739 N564JB  JFK   
#&gt; </span><span style='color: #BCBCBC;'> 3</span><span>  </span><span style='text-decoration: underline;'>2</span><span>013     1    10      450            500 US        </span><span style='text-decoration: underline;'>1</span><span>117 N171US  EWR   
#&gt; </span><span style='color: #BCBCBC;'> 4</span><span>  </span><span style='text-decoration: underline;'>2</span><span>013     1    10      520            525 UA        </span><span style='text-decoration: underline;'>1</span><span>018 N35204  EWR   
#&gt; </span><span style='color: #BCBCBC;'> 5</span><span>  </span><span style='text-decoration: underline;'>2</span><span>013     1    10      530            530 UA         404 N815UA  LGA   
#&gt; </span><span style='color: #BCBCBC;'> 6</span><span>  </span><span style='text-decoration: underline;'>2</span><span>013     1    10      531            540 AA        </span><span style='text-decoration: underline;'>1</span><span>141 N5EAAA  JFK   
#&gt; </span><span style='color: #BCBCBC;'> 7</span><span>  </span><span style='text-decoration: underline;'>2</span><span>013     1    10      535            540 B6         725 N784JB  JFK   
#&gt; </span><span style='color: #BCBCBC;'> 8</span><span>  </span><span style='text-decoration: underline;'>2</span><span>013     1    10      546            600 B6         380 N337JB  EWR   
#&gt; </span><span style='color: #BCBCBC;'> 9</span><span>  </span><span style='text-decoration: underline;'>2</span><span>013     1    10      549            600 EV        </span><span style='text-decoration: underline;'>6</span><span>055 N19554  LGA   
#&gt; </span><span style='color: #BCBCBC;'>10</span><span>  </span><span style='text-decoration: underline;'>2</span><span>013     1    10      550            600 US        </span><span style='text-decoration: underline;'>2</span><span>114 N740UW  LGA   
#&gt; </span><span style='color: #949494;'># … with 11,217 more rows, and 2 more variables: dest </span><span style='color: #949494;font-style: italic;'>&lt;chr&gt;</span><span style='color: #949494;'>,</span><span>
#&gt; </span><span style='color: #949494;'>#   plane_type </span><span style='color: #949494;font-style: italic;'>&lt;chr&gt;</span><span>
</span></CODE></PRE>

``` r
# also here, the FK-relations are transferred to the new table
dm_draw(joined_flights_dm)
```

![](/home/kirill/git/cynkra/cynkra/public/dm/vignettes/out/tech-dm-zoom_files/figure-markdown_github/unnamed-chunk-5-1.png)

### Tip: Accessing the zoomed table

At each point you can retrieve the zoomed table by calling `pull_tbl()`
on a `zoomed_dm`. To use our last example once more:

``` r
flights_dm %>% 
  dm_zoom_to(flights) %>% 
  select(-dep_delay:-arr_delay, -air_time:-time_hour) %>% 
  left_join(planes, select = c(tailnum, plane_type = type)) %>% 
  pull_tbl()
```

<PRE class="fansi fansi-output"><CODE>#&gt; <span style='color: #949494;'># A tibble: 11,227 x 11</span><span>
#&gt;     year month   day dep_time sched_dep_time carrier flight tailnum origin
#&gt;    </span><span style='color: #949494;font-style: italic;'>&lt;int&gt;</span><span> </span><span style='color: #949494;font-style: italic;'>&lt;int&gt;</span><span> </span><span style='color: #949494;font-style: italic;'>&lt;int&gt;</span><span>    </span><span style='color: #949494;font-style: italic;'>&lt;int&gt;</span><span>          </span><span style='color: #949494;font-style: italic;'>&lt;int&gt;</span><span> </span><span style='color: #949494;font-style: italic;'>&lt;chr&gt;</span><span>    </span><span style='color: #949494;font-style: italic;'>&lt;int&gt;</span><span> </span><span style='color: #949494;font-style: italic;'>&lt;chr&gt;</span><span>   </span><span style='color: #949494;font-style: italic;'>&lt;chr&gt;</span><span> 
#&gt; </span><span style='color: #BCBCBC;'> 1</span><span>  </span><span style='text-decoration: underline;'>2</span><span>013     1    10        3           </span><span style='text-decoration: underline;'>2</span><span>359 B6         727 N571JB  JFK   
#&gt; </span><span style='color: #BCBCBC;'> 2</span><span>  </span><span style='text-decoration: underline;'>2</span><span>013     1    10       16           </span><span style='text-decoration: underline;'>2</span><span>359 B6         739 N564JB  JFK   
#&gt; </span><span style='color: #BCBCBC;'> 3</span><span>  </span><span style='text-decoration: underline;'>2</span><span>013     1    10      450            500 US        </span><span style='text-decoration: underline;'>1</span><span>117 N171US  EWR   
#&gt; </span><span style='color: #BCBCBC;'> 4</span><span>  </span><span style='text-decoration: underline;'>2</span><span>013     1    10      520            525 UA        </span><span style='text-decoration: underline;'>1</span><span>018 N35204  EWR   
#&gt; </span><span style='color: #BCBCBC;'> 5</span><span>  </span><span style='text-decoration: underline;'>2</span><span>013     1    10      530            530 UA         404 N815UA  LGA   
#&gt; </span><span style='color: #BCBCBC;'> 6</span><span>  </span><span style='text-decoration: underline;'>2</span><span>013     1    10      531            540 AA        </span><span style='text-decoration: underline;'>1</span><span>141 N5EAAA  JFK   
#&gt; </span><span style='color: #BCBCBC;'> 7</span><span>  </span><span style='text-decoration: underline;'>2</span><span>013     1    10      535            540 B6         725 N784JB  JFK   
#&gt; </span><span style='color: #BCBCBC;'> 8</span><span>  </span><span style='text-decoration: underline;'>2</span><span>013     1    10      546            600 B6         380 N337JB  EWR   
#&gt; </span><span style='color: #BCBCBC;'> 9</span><span>  </span><span style='text-decoration: underline;'>2</span><span>013     1    10      549            600 EV        </span><span style='text-decoration: underline;'>6</span><span>055 N19554  LGA   
#&gt; </span><span style='color: #BCBCBC;'>10</span><span>  </span><span style='text-decoration: underline;'>2</span><span>013     1    10      550            600 US        </span><span style='text-decoration: underline;'>2</span><span>114 N740UW  LGA   
#&gt; </span><span style='color: #949494;'># … with 11,217 more rows, and 2 more variables: dest </span><span style='color: #949494;font-style: italic;'>&lt;chr&gt;</span><span style='color: #949494;'>,</span><span>
#&gt; </span><span style='color: #949494;'>#   plane_type </span><span style='color: #949494;font-style: italic;'>&lt;chr&gt;</span><span>
</span></CODE></PRE>

### Possible pitfalls and caveats

1.  Currently not all of the {dplyr}-verbs have their own method for a
    `zoomed_dm`, so be aware that in some cases it will still be
    necessary to resort to extracting one or more tables from a `dm` and
    reinserting a transformed version of theirs into the `dm`
    eventually. The supported functions are: `group_by()`, `ungroup()`,
    `summarise()`, `mutate()`, `transmute()`, `filter()`, `select()`,
    `rename()`, `distinct()`, `arrange()`, `slice()`, `left_join()`,
    `inner_join()`, `full_join()`, `right_join()`, `semi_join()` and
    `anti_join()`.

2.  The same is true for {tidyr}-functions. Methods are provided for:
    `unite()` and `separate()`.

3.  There might be situations when you would like the key relations to
    remain intact, but they are dropped nevertheless. This is because a
    rigid logic is implemented, that does drop a key when its associated
    column is acted upon with e.g. a `mutate()` call. In these cases the
    key relations will need to be established once more after finishing
    with the manipulations.
