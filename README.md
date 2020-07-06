
<!-- README.md is generated from README.Rmd. Please edit that file -->

# [dm](https://krlmlr.github.io/dm)

<!-- badges: start -->

[![Lifecycle:
maturing](https://img.shields.io/badge/lifecycle-maturing-blue.svg)](https://www.tidyverse.org/lifecycle/#maturing)
[![R build
status](https://github.com/krlmlr/dm/workflows/tic/badge.svg)](https://github.com/krlmlr/dm/actions)
[![Codecov test
coverage](https://codecov.io/gh/krlmlr/dm/branch/master/graph/badge.svg)](https://codecov.io/gh/krlmlr/dm?branch=master)
[![CRAN
status](https://www.r-pkg.org/badges/version/dm)](https://CRAN.R-project.org/package=dm)
[![Launch
rstudio.cloud](https://img.shields.io/badge/rstudio-cloud-blue.svg)](https://rstudio.cloud/project/523482)
<!-- badges: end -->

## TL;DR

Are you using multiple data frames or database tables in R? Organize
them with dm.

  - Use it today (if only like a list of tables).
  - Build data models tomorrow.
  - Deploy the data models to your organization’s RDBMS the day after.

## Overview

dm bridges the gap in the data pipeline between individual data frames
and relational databases. It’s a [grammar of joined
tables](https://twitter.com/drob/status/1224851726068527106) that
provides a consistent set of verbs for consuming, creating, and
deploying relational data models. For individual researchers, it
broadens the scope of datasets they can work with and how they work with
them. For organizations, it enables teams to quickly and efficiently
create and share large, complex datasets.

dm objects encapsulate relational data models constructed from local
data frames or lazy tables connected to an RDBMS. dm objects support the
full suite of dplyr data manipulation verbs along with additional
methods for constructing and verifying relational data models, including
key selection, key creation, and rigorous constraint checking. Once a
data model is complete, dm provides methods for deploying it to an
RDBMS. This allows it to scale from datasets that fit in memory to
databases with billions of rows.

## Features

dm makes it easy to bring an existing relational data model into your R
session. As the dm object behaves like a named list of tables it
requires little change to incorporate it within existing workflows. The
dm interface and behavior is modeled after dplyr, so you may already be
familiar with many of its verbs. dm also offers:

  - visualization to help you understand relationships between entities
    represented by the tables
  - simpler joins that “know” how tables are related, including a
    “flatten” operation that automatically follows keys and performs
    column name disambiguation
  - consistency and constraint checks to help you understand (and fix)
    the limitations of your data

That’s just the tip of the iceberg. See [Getting
started](https://krlmlr.github.io/dm/articles/dm.html) to hit the ground
running and explore all the features.

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

Create a dm object (see [Getting
started](https://krlmlr.github.io/dm/articles/dm.html) for details).

``` r
library(dm)
dm <- dm_nycflights13()
dm
```

<PRE class="fansi fansi-output"><CODE>#&gt; <span style='color: #00BB00;'>──</span><span> </span><span style='color: #00BB00;'>Table source</span><span> </span><span style='color: #00BB00;'>───────────────────────────────────────────────────────────</span><span>
#&gt; src:  &lt;environment: R_GlobalEnv&gt;
#&gt; </span><span style='color: #555555;'>──</span><span> </span><span style='color: #555555;'>Metadata</span><span> </span><span style='color: #555555;'>───────────────────────────────────────────────────────────────</span><span>
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
#&gt;   </span><span style='color: #555555;font-style: italic;'>&lt;chr&gt;</span><span>  </span><span style='color: #555555;font-style: italic;'>&lt;int&gt;</span><span>
#&gt; </span><span style='color: #555555;'>1</span><span> EWR     </span><span style='text-decoration: underline;'>4</span><span>043
#&gt; </span><span style='color: #555555;'>2</span><span> JFK     </span><span style='text-decoration: underline;'>3</span><span>661
#&gt; </span><span style='color: #555555;'>3</span><span> LGA     </span><span style='text-decoration: underline;'>3</span><span>523
</span></CODE></PRE>

Visualize relationships at any time:

``` r
dm %>%
  dm_draw()
```

<img src="man/figures/README-draw.svg" />

Simple joins:

``` r
dm %>%
  dm_flatten_to_tbl(flights)
#> Renamed columns:
#> * year -> flights.year, planes.year
#> * name -> airlines.name, airports.name
```

<PRE class="fansi fansi-output"><CODE>#&gt; <span style='color: #555555;'># A tibble: 11,227 x 35</span><span>
#&gt;    </span><span style='font-weight: bold;'>flights.year</span><span> </span><span style='font-weight: bold;'>month</span><span>   </span><span style='font-weight: bold;'>day</span><span> </span><span style='font-weight: bold;'>dep_time</span><span> </span><span style='font-weight: bold;'>sched_dep_time</span><span> </span><span style='font-weight: bold;'>dep_delay</span><span> </span><span style='font-weight: bold;'>arr_time</span><span>
#&gt;           </span><span style='color: #555555;font-style: italic;'>&lt;int&gt;</span><span> </span><span style='color: #555555;font-style: italic;'>&lt;int&gt;</span><span> </span><span style='color: #555555;font-style: italic;'>&lt;int&gt;</span><span>    </span><span style='color: #555555;font-style: italic;'>&lt;int&gt;</span><span>          </span><span style='color: #555555;font-style: italic;'>&lt;int&gt;</span><span>     </span><span style='color: #555555;font-style: italic;'>&lt;dbl&gt;</span><span>    </span><span style='color: #555555;font-style: italic;'>&lt;int&gt;</span><span>
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
```

<PRE class="fansi fansi-message"><CODE>#&gt; <span style='color: #BBBB00;'>!</span><span> Unsatisfied constraints:
</span></CODE></PRE>

<PRE class="fansi fansi-output"><CODE>#&gt; <span style='color: #BB0000;'>●</span><span> Table `flights`: foreign key tailnum into table `planes`: 1640 entries (14.6%) of `flights$tailnum` not in `planes$tailnum`: N722MQ (27), N725MQ (20), N520MQ (19), N723MQ (19), N508MQ (16), …
</span></CODE></PRE>

Learn more in the [Getting
started](https://krlmlr.github.io/dm/articles/dm.html) article.

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
