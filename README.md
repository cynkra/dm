
<!-- badges: start -->

[![Lifecycle:
maturing](https://img.shields.io/badge/lifecycle-maturing-blue.svg)](https://www.tidyverse.org/lifecycle/#maturing)
[![Travis build
status](https://travis-ci.org/krlmlr/dm.svg?branch=master)](https://travis-ci.org/krlmlr/dm)
[![Codecov test
coverage](https://codecov.io/gh/krlmlr/dm/branch/master/graph/badge.svg)](https://codecov.io/gh/krlmlr/dm?branch=master)
[![CRAN
status](https://www.r-pkg.org/badges/version/dm)](https://CRAN.R-project.org/package=dm)
[![Launch
rstudio.cloud](https://img.shields.io/badge/rstudio-cloud-blue.svg)](https://rstudio.cloud/project/523482)
<!-- badges: end -->

# dm

## Overview

FIXME: dm is a [grammar of joined
tables](https://twitter.com/drob/status/1224851726068527106)?

dm is an R package for building and manipulating relational databases to
aid the querying of data models stored in local dataframes, and the
construction of flat data models from relational databases.

FIXME: Intro paragraph around three use cases for relational data models
(=if you’re working with more than one table/data frame in R)

1.  use data (example below)

2.  deploy data

3.  organize data

END FIXME

The intent behind dm is to bridge the gap in the data pipeline between
individual dataframes and relational databases by providing methods to
move data between different sources, and methods for performing data
manipulation (eg, aggregation, summarisation, filtering, etc) and table
manipulation (eg, joins, creation, deletion, etc) that are agnostic to
the data source.

FIXME: Immediate benefits of adopting dm, see “usage” for code

  - very easy to bring an existing relational data model into your R
    session. We’re using a built-in objects, it’s easy with databases
    too. Interface and behavior modeled after dplyr. Little change to
    workflow – behaves like a named list of tables

  - benefit 1: visualization, understand relationships between entities
    represented by the tables

  - benefit 2: simpler joins, “flatten” operation with column name
    disambiguation and automatic keys as an example

  - benefit 3: consistency checks, understand (and fix\!) limitations of
    your data

That’s just the tip of the iceberg. See “Getting started” to hit the
ground running and explore all the features.

END FIXME

Calling methods on a dm object for importing data sources, defining
relationships between them, and specifying the sequence of operations to
produce the required data, results in clearly specified and repeatable
workflows. dm’s use of lazy evaluation minimises transfer and
duplication of large datasets as you build your workflow, while
providing snapshots of intermediate results for confirming your workflow
is producing the expected results.

dm builds upon the [DBI](https://github.com/r-dbi/DBI) package for
interfacing with over 30 DBMS’s, [dplyr](https://dplyr.tidyverse.org/)
for its database interaction methods and its grammar of data
manipulation, and [tidyr](https://tidyr.tidyverse.org/) for its column
operations.

If you are new to dm, the best place to begin is the [Getting Started
article](https://krlmlr.github.io/dm/articles/dm.html).

## Installation

The latest stable version of the {dm} package can be obtained from
[CRAN](https://CRAN.R-project.org/package=dm) with the command

``` r
install.packages("dm")
```

The latest development version of {dm} can be installed from GitHub.

``` r
# install.packages("devtools")
devtools::install_github("krlmlr/dm")
```

## Usage

Load data as a dm object, see “Getting started” for details:

``` r
library(dm)
dm <- dm_nycflights13()
dm
```

<PRE class="fansi fansi-output"><CODE>#&gt; <span style='color: #00BB00;'>──</span><span> </span><span style='color: #00BB00;'>Table source</span><span> </span><span style='color: #00BB00;'>───────────────────────────────────────────────────────────</span><span>
</span></CODE></PRE>

    #> Warning: `src_local()` is deprecated as of dplyr 1.0.0.
    #> [90mThis warning is displayed once every 8 hours.[39m
    #> [90mCall `lifecycle::last_warnings()` to see where this warning was generated.[39m

<PRE class="fansi fansi-output"><CODE>#&gt; src:  &lt;environment: R_GlobalEnv&gt;
#&gt; <span style='color: #555555;'>──</span><span> </span><span style='color: #555555;'>Metadata</span><span> </span><span style='color: #555555;'>───────────────────────────────────────────────────────────────</span><span>
#&gt; Tables: `airlines`, `airports`, `flights`, `planes`, `weather`
#&gt; Columns: 53
#&gt; Primary keys: 3
#&gt; Foreign keys: 3
</span></CODE></PRE>

dm is a named list of tables:

``` r
names(dm)
#> [1] "airlines" "airports" "flights"  "planes"   "weather"
nrow(dm$airports)
#> [1] 1458
dm$flights %>% 
  count(origin)
```

<PRE class="fansi fansi-output"><CODE>#&gt; <span style='color: #555555;'># A tibble: 3 x 2</span><span>
#&gt;   </span><span style='font-weight: bold;'>origin</span><span>     </span><span style='font-weight: bold;'>n</span><span>
#&gt; </span><span style='color: #555555;'>*</span><span> </span><span style='color: #555555;font-style: italic;'>&lt;chr&gt;</span><span>  </span><span style='color: #555555;font-style: italic;'>&lt;int&gt;</span><span>
#&gt; </span><span style='color: #555555;'>1</span><span> EWR     </span><span style='text-decoration: underline;'>4</span><span>043
#&gt; </span><span style='color: #555555;'>2</span><span> JFK     </span><span style='text-decoration: underline;'>3</span><span>661
#&gt; </span><span style='color: #555555;'>3</span><span> LGA     </span><span style='text-decoration: underline;'>3</span><span>523
</span></CODE></PRE>

Visualize relationships at any time:

``` r
dm %>%
  dm_draw()
```

<img src="man/figures/README-draw-1.png" width="100%" />

Simple joins:

``` r
dm %>% 
  dm_flatten_to_tbl(flights)
#> Renamed columns:
#> * year -> flights$flights.year, planes$planes.year
#> * name -> airlines$airlines.name, airports$airports.name
```

<PRE class="fansi fansi-output"><CODE>#&gt; <span style='color: #555555;'># A tibble: 11,227 x 35</span><span>
#&gt;    </span><span style='font-weight: bold;'>flights.year</span><span> </span><span style='font-weight: bold;'>month</span><span>   </span><span style='font-weight: bold;'>day</span><span> </span><span style='font-weight: bold;'>dep_time</span><span> </span><span style='font-weight: bold;'>sched_dep_time</span><span> </span><span style='font-weight: bold;'>dep_delay</span><span> </span><span style='font-weight: bold;'>arr_time</span><span>
#&gt;  </span><span style='color: #555555;'>*</span><span>        </span><span style='color: #555555;font-style: italic;'>&lt;int&gt;</span><span> </span><span style='color: #555555;font-style: italic;'>&lt;int&gt;</span><span> </span><span style='color: #555555;font-style: italic;'>&lt;int&gt;</span><span>    </span><span style='color: #555555;font-style: italic;'>&lt;int&gt;</span><span>          </span><span style='color: #555555;font-style: italic;'>&lt;int&gt;</span><span>     </span><span style='color: #555555;font-style: italic;'>&lt;dbl&gt;</span><span>    </span><span style='color: #555555;font-style: italic;'>&lt;int&gt;</span><span>
#&gt; </span><span style='color: #555555;'> 1</span><span>         </span><span style='text-decoration: underline;'>2</span><span>013     1    10        3           </span><span style='text-decoration: underline;'>2</span><span>359         4      426
#&gt; </span><span style='color: #555555;'> 2</span><span>         </span><span style='text-decoration: underline;'>2</span><span>013     1    10       16           </span><span style='text-decoration: underline;'>2</span><span>359        17      447
#&gt; </span><span style='color: #555555;'> 3</span><span>         </span><span style='text-decoration: underline;'>2</span><span>013     1    10      450            500       -</span><span style='color: #BB0000;'>10</span><span>      634
#&gt; </span><span style='color: #555555;'> 4</span><span>         </span><span style='text-decoration: underline;'>2</span><span>013     1    10      520            525        -</span><span style='color: #BB0000;'>5</span><span>      813
#&gt; </span><span style='color: #555555;'> 5</span><span>         </span><span style='text-decoration: underline;'>2</span><span>013     1    10      530            530         0      824
#&gt; </span><span style='color: #555555;'> 6</span><span>         </span><span style='text-decoration: underline;'>2</span><span>013     1    10      531            540        -</span><span style='color: #BB0000;'>9</span><span>      832
#&gt; </span><span style='color: #555555;'> 7</span><span>         </span><span style='text-decoration: underline;'>2</span><span>013     1    10      535            540        -</span><span style='color: #BB0000;'>5</span><span>     </span><span style='text-decoration: underline;'>1</span><span>015
#&gt; </span><span style='color: #555555;'> 8</span><span>         </span><span style='text-decoration: underline;'>2</span><span>013     1    10      546            600       -</span><span style='color: #BB0000;'>14</span><span>      645
#&gt; </span><span style='color: #555555;'> 9</span><span>         </span><span style='text-decoration: underline;'>2</span><span>013     1    10      549            600       -</span><span style='color: #BB0000;'>11</span><span>      652
#&gt; </span><span style='color: #555555;'>10</span><span>         </span><span style='text-decoration: underline;'>2</span><span>013     1    10      550            600       -</span><span style='color: #BB0000;'>10</span><span>      649
#&gt; </span><span style='color: #555555;'># … with 11,217 more rows, and 28 more variables: </span><span style='color: #555555;font-weight: bold;'>sched_arr_time</span><span style='color: #555555;'> </span><span style='color: #555555;font-style: italic;'>&lt;int&gt;</span><span style='color: #555555;'>,</span><span>
#&gt; </span><span style='color: #555555;'>#   </span><span style='color: #555555;font-weight: bold;'>arr_delay</span><span style='color: #555555;'> </span><span style='color: #555555;font-style: italic;'>&lt;dbl&gt;</span><span style='color: #555555;'>, </span><span style='color: #555555;font-weight: bold;'>carrier</span><span style='color: #555555;'> </span><span style='color: #555555;font-style: italic;'>&lt;chr&gt;</span><span style='color: #555555;'>, </span><span style='color: #555555;font-weight: bold;'>flight</span><span style='color: #555555;'> </span><span style='color: #555555;font-style: italic;'>&lt;int&gt;</span><span style='color: #555555;'>, </span><span style='color: #555555;font-weight: bold;'>tailnum</span><span style='color: #555555;'> </span><span style='color: #555555;font-style: italic;'>&lt;chr&gt;</span><span style='color: #555555;'>,</span><span>
#&gt; </span><span style='color: #555555;'>#   </span><span style='color: #555555;font-weight: bold;'>origin</span><span style='color: #555555;'> </span><span style='color: #555555;font-style: italic;'>&lt;chr&gt;</span><span style='color: #555555;'>, </span><span style='color: #555555;font-weight: bold;'>dest</span><span style='color: #555555;'> </span><span style='color: #555555;font-style: italic;'>&lt;chr&gt;</span><span style='color: #555555;'>, </span><span style='color: #555555;font-weight: bold;'>air_time</span><span style='color: #555555;'> </span><span style='color: #555555;font-style: italic;'>&lt;dbl&gt;</span><span style='color: #555555;'>, </span><span style='color: #555555;font-weight: bold;'>distance</span><span style='color: #555555;'> </span><span style='color: #555555;font-style: italic;'>&lt;dbl&gt;</span><span style='color: #555555;'>, </span><span style='color: #555555;font-weight: bold;'>hour</span><span style='color: #555555;'> </span><span style='color: #555555;font-style: italic;'>&lt;dbl&gt;</span><span style='color: #555555;'>,</span><span>
#&gt; </span><span style='color: #555555;'>#   </span><span style='color: #555555;font-weight: bold;'>minute</span><span style='color: #555555;'> </span><span style='color: #555555;font-style: italic;'>&lt;dbl&gt;</span><span style='color: #555555;'>, </span><span style='color: #555555;font-weight: bold;'>time_hour</span><span style='color: #555555;'> </span><span style='color: #555555;font-style: italic;'>&lt;dttm&gt;</span><span style='color: #555555;'>, </span><span style='color: #555555;font-weight: bold;'>airlines.name</span><span style='color: #555555;'> </span><span style='color: #555555;font-style: italic;'>&lt;chr&gt;</span><span style='color: #555555;'>,</span><span>
#&gt; </span><span style='color: #555555;'>#   </span><span style='color: #555555;font-weight: bold;'>airports.name</span><span style='color: #555555;'> </span><span style='color: #555555;font-style: italic;'>&lt;chr&gt;</span><span style='color: #555555;'>, </span><span style='color: #555555;font-weight: bold;'>lat</span><span style='color: #555555;'> </span><span style='color: #555555;font-style: italic;'>&lt;dbl&gt;</span><span style='color: #555555;'>, </span><span style='color: #555555;font-weight: bold;'>lon</span><span style='color: #555555;'> </span><span style='color: #555555;font-style: italic;'>&lt;dbl&gt;</span><span style='color: #555555;'>, </span><span style='color: #555555;font-weight: bold;'>alt</span><span style='color: #555555;'> </span><span style='color: #555555;font-style: italic;'>&lt;dbl&gt;</span><span style='color: #555555;'>, </span><span style='color: #555555;font-weight: bold;'>tz</span><span style='color: #555555;'> </span><span style='color: #555555;font-style: italic;'>&lt;dbl&gt;</span><span style='color: #555555;'>,</span><span>
#&gt; </span><span style='color: #555555;'>#   </span><span style='color: #555555;font-weight: bold;'>dst</span><span style='color: #555555;'> </span><span style='color: #555555;font-style: italic;'>&lt;chr&gt;</span><span style='color: #555555;'>, </span><span style='color: #555555;font-weight: bold;'>tzone</span><span style='color: #555555;'> </span><span style='color: #555555;font-style: italic;'>&lt;chr&gt;</span><span style='color: #555555;'>, </span><span style='color: #555555;font-weight: bold;'>planes.year</span><span style='color: #555555;'> </span><span style='color: #555555;font-style: italic;'>&lt;int&gt;</span><span style='color: #555555;'>, </span><span style='color: #555555;font-weight: bold;'>type</span><span style='color: #555555;'> </span><span style='color: #555555;font-style: italic;'>&lt;chr&gt;</span><span style='color: #555555;'>,</span><span>
#&gt; </span><span style='color: #555555;'>#   </span><span style='color: #555555;font-weight: bold;'>manufacturer</span><span style='color: #555555;'> </span><span style='color: #555555;font-style: italic;'>&lt;chr&gt;</span><span style='color: #555555;'>, </span><span style='color: #555555;font-weight: bold;'>model</span><span style='color: #555555;'> </span><span style='color: #555555;font-style: italic;'>&lt;chr&gt;</span><span style='color: #555555;'>, </span><span style='color: #555555;font-weight: bold;'>engines</span><span style='color: #555555;'> </span><span style='color: #555555;font-style: italic;'>&lt;int&gt;</span><span style='color: #555555;'>, </span><span style='color: #555555;font-weight: bold;'>seats</span><span style='color: #555555;'> </span><span style='color: #555555;font-style: italic;'>&lt;int&gt;</span><span style='color: #555555;'>,</span><span>
#&gt; </span><span style='color: #555555;'>#   </span><span style='color: #555555;font-weight: bold;'>speed</span><span style='color: #555555;'> </span><span style='color: #555555;font-style: italic;'>&lt;int&gt;</span><span style='color: #555555;'>, </span><span style='color: #555555;font-weight: bold;'>engine</span><span style='color: #555555;'> </span><span style='color: #555555;font-style: italic;'>&lt;chr&gt;</span><span>
</span></CODE></PRE>

Check consistency:

``` r
dm %>% 
  dm_examine_constraints()
#> [33m![39m Unsatisfied constraints:
```

<PRE class="fansi fansi-output"><CODE>#&gt; <span style='color: #BB0000;'>●</span><span> Table `flights`: foreign key tailnum into table `planes`: 1640 entries (14.6%) of `flights$tailnum` not in `planes$tailnum`: N722MQ (27), N725MQ (20), N520MQ (19), N723MQ (19), N508MQ (16), …
</span></CODE></PRE>

That’s just the tip of the iceberg. See “Getting started” to hit the
ground running and explore all the features.

END FIXME

FIXME: Standing on the shoulders of giants? Perhaps a short version?

## Getting help

If you encounter a clear bug, please file an issue with a minimal
reproducible example on [GitHub](https://github.com/krlmlr/dm/issues).
For questions and other discussion, please use
[community.rstudio.com](https://community.rstudio.com/).

-----

License: MIT © cynkra GmbH.

Funded by:

[![energie360°](man/figures/energie-72.png)](https://www.energie360.ch)
<span style="padding-right:50px"> </span>
[![cynkra](man/figures/cynkra-72.png)](https://www.cynkra.com/)

-----

Please note that the ‘dm’ project is released with a [Contributor Code
of Conduct](https://krlmlr.github.io/dm/CODE_OF_CONDUCT.html). By
contributing to this project, you agree to abide by its terms.
