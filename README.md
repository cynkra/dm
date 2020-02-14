
<!-- badges: start -->

[![Lifecycle:
maturing](https://img.shields.io/badge/lifecycle-maturing-blue.svg)](https://www.tidyverse.org/lifecycle/#maturing)
[![Travis build
status](https://travis-ci.com/krlmlr/dm.svg?branch=master)](https://travis-ci.com/krlmlr/dm)
[![Codecov test
coverage](https://codecov.io/gh/krlmlr/dm/branch/master/graph/badge.svg)](https://codecov.io/gh/krlmlr/dm?branch=master)
[![CRAN
status](https://www.r-pkg.org/badges/version/dm)](https://CRAN.R-project.org/package=dm)
[![Launch
rstudio.cloud](https://img.shields.io/badge/rstudio-cloud-blue.svg)](https://rstudio.cloud/project/523482)
<!-- badges: end -->

# dm

{dm} is an R package that provides tools for working with multiple
related tables, stored as data frames or in a relational database.

**Contents**

  - [Background](#background) explains the philosophy behind the package
    and the problem that it tries to solve
  - [Example](#example) illustrates the general concept with a simple
    example
  - [Features](#features) gives an overview of the scope of the package
  - [Installation](#installation) describes how to install the package
  - [More information](#more-information) lists more detailed
    documentation sources
  - [Standing on the shoulders of
    giants](#standing-on-the-shoulders-of-giants) credits related work

## Background

Relational databases and flat tables, like data frames or spreadsheets,
present data in fundamentally different ways.

In data frames and spreadsheets, all data is presented together in one
large table with many rows and columns. This means that the data is
accessible in one location but has the disadvantage that the same values
may be repeated multiple times, resulting in bloated tables with
redundant data. In the worst case scenario, a data frame may have many
rows and columns but only a single value different in each row.

Relational databases, on the other hand, do not keep all data together
but split it into multiple smaller tables. That separation into
sub-tables has several advantages:

  - all information is stored only once, avoiding repetition and
    conserving memory
  - all information is updated only once and in one place, improving
    consistency and avoiding errors that may result from updating the
    same value in multiple locations
  - all information is organized by topic and segmented into smaller
    tables that are easier to handle

Separation of data, thus, helps with data quality, and explains the
continuing popularity of relational databases in production-level data
management.

The downside of this approach is that it is harder to merge together
information from different data sources and to identify which entities
refer to the same object, a common task when modelling or plotting data.
To be mapped uniquely, the entities would need to be designated as
*keys*, and the separate tables collated together through a process
called *joining*.

In R, there already exist packages that support handling inter-linked
tables but the code is complex and requires multiple command sequences.
The goal of the {dm} package is to simplify the data management
processes in R while keeping the advantages of relational data models
and the core concept of splitting one table into multiple tables. In
this way, you can have the best of both worlds: manage your data as a
collection of linked tables, then flatten multiple tables into one for
an analysis with {dplyr} or other packages, on an as-needed basis.

Although {dm} is built upon relational data models, it is not a database
itself. It can work transparently with both relational database systems
and in-memory data, and copy data [from and to
databases](https://krlmlr.github.io/dm/articles/dm.html#copy).

## Example

As an example, consider the
[`nycflights13`](https://github.com/hadley/nycflights13) dataset about
the flights that departed New York City airports in 2013. The dataset
contains five tables: the main `flights` table with links to the
`airlines`, `planes` and `airports` tables, and the `weather` table
without explicit links.

Assume that your task is to merge all tables, except the `weather`
table.

<img src="man/figures/README-draw-1.png" width="100%" />

In the classical [{dplyr}](https://dplyr.tidyverse.org) notation, you
would need three `left_join()` calls to merge the `flights` table
gradually to the `airlines`, `planes` and `airports` tables to create
one wide data frame:

``` r
library(tidyverse)
library(nycflights13)

flights %>%
  left_join(airlines, by = "carrier") %>%
  left_join(planes, by = "tailnum") %>%
  left_join(airports, by = c("origin" = "faa"))
```

<PRE class="fansi fansi-output"><CODE>#&gt; <span style='color: #555555;'># A tibble: 336,776 x 35</span><span>
#&gt;    </span><span style='font-weight: bold;'>year.x</span><span> </span><span style='font-weight: bold;'>month</span><span>   </span><span style='font-weight: bold;'>day</span><span> </span><span style='font-weight: bold;'>dep_time</span><span> </span><span style='font-weight: bold;'>sched_dep_time</span><span> </span><span style='font-weight: bold;'>dep_delay</span><span> </span><span style='font-weight: bold;'>arr_time</span><span>
#&gt;     </span><span style='color: #555555;font-style: italic;'>&lt;int&gt;</span><span> </span><span style='color: #555555;font-style: italic;'>&lt;int&gt;</span><span> </span><span style='color: #555555;font-style: italic;'>&lt;int&gt;</span><span>    </span><span style='color: #555555;font-style: italic;'>&lt;int&gt;</span><span>          </span><span style='color: #555555;font-style: italic;'>&lt;int&gt;</span><span>     </span><span style='color: #555555;font-style: italic;'>&lt;dbl&gt;</span><span>    </span><span style='color: #555555;font-style: italic;'>&lt;int&gt;</span><span>
#&gt; </span><span style='color: #555555;'> 1</span><span>   </span><span style='text-decoration: underline;'>2</span><span>013     1     1      517            515         2      830
#&gt; </span><span style='color: #555555;'> 2</span><span>   </span><span style='text-decoration: underline;'>2</span><span>013     1     1      533            529         4      850
#&gt; </span><span style='color: #555555;'> 3</span><span>   </span><span style='text-decoration: underline;'>2</span><span>013     1     1      542            540         2      923
#&gt; </span><span style='color: #555555;'> 4</span><span>   </span><span style='text-decoration: underline;'>2</span><span>013     1     1      544            545        -</span><span style='color: #BB0000;'>1</span><span>     </span><span style='text-decoration: underline;'>1</span><span>004
#&gt; </span><span style='color: #555555;'> 5</span><span>   </span><span style='text-decoration: underline;'>2</span><span>013     1     1      554            600        -</span><span style='color: #BB0000;'>6</span><span>      812
#&gt; </span><span style='color: #555555;'> 6</span><span>   </span><span style='text-decoration: underline;'>2</span><span>013     1     1      554            558        -</span><span style='color: #BB0000;'>4</span><span>      740
#&gt; </span><span style='color: #555555;'> 7</span><span>   </span><span style='text-decoration: underline;'>2</span><span>013     1     1      555            600        -</span><span style='color: #BB0000;'>5</span><span>      913
#&gt; </span><span style='color: #555555;'> 8</span><span>   </span><span style='text-decoration: underline;'>2</span><span>013     1     1      557            600        -</span><span style='color: #BB0000;'>3</span><span>      709
#&gt; </span><span style='color: #555555;'> 9</span><span>   </span><span style='text-decoration: underline;'>2</span><span>013     1     1      557            600        -</span><span style='color: #BB0000;'>3</span><span>      838
#&gt; </span><span style='color: #555555;'>10</span><span>   </span><span style='text-decoration: underline;'>2</span><span>013     1     1      558            600        -</span><span style='color: #BB0000;'>2</span><span>      753
#&gt; </span><span style='color: #555555;'># … with 336,766 more rows, and 28 more variables: </span><span style='color: #555555;font-weight: bold;'>sched_arr_time</span><span style='color: #555555;'> </span><span style='color: #555555;font-style: italic;'>&lt;int&gt;</span><span style='color: #555555;'>,
#&gt; #   </span><span style='color: #555555;font-weight: bold;'>arr_delay</span><span style='color: #555555;'> </span><span style='color: #555555;font-style: italic;'>&lt;dbl&gt;</span><span style='color: #555555;'>, </span><span style='color: #555555;font-weight: bold;'>carrier</span><span style='color: #555555;'> </span><span style='color: #555555;font-style: italic;'>&lt;chr&gt;</span><span style='color: #555555;'>, </span><span style='color: #555555;font-weight: bold;'>flight</span><span style='color: #555555;'> </span><span style='color: #555555;font-style: italic;'>&lt;int&gt;</span><span style='color: #555555;'>, </span><span style='color: #555555;font-weight: bold;'>tailnum</span><span style='color: #555555;'> </span><span style='color: #555555;font-style: italic;'>&lt;chr&gt;</span><span style='color: #555555;'>,
#&gt; #   </span><span style='color: #555555;font-weight: bold;'>origin</span><span style='color: #555555;'> </span><span style='color: #555555;font-style: italic;'>&lt;chr&gt;</span><span style='color: #555555;'>, </span><span style='color: #555555;font-weight: bold;'>dest</span><span style='color: #555555;'> </span><span style='color: #555555;font-style: italic;'>&lt;chr&gt;</span><span style='color: #555555;'>, </span><span style='color: #555555;font-weight: bold;'>air_time</span><span style='color: #555555;'> </span><span style='color: #555555;font-style: italic;'>&lt;dbl&gt;</span><span style='color: #555555;'>, </span><span style='color: #555555;font-weight: bold;'>distance</span><span style='color: #555555;'> </span><span style='color: #555555;font-style: italic;'>&lt;dbl&gt;</span><span style='color: #555555;'>, </span><span style='color: #555555;font-weight: bold;'>hour</span><span style='color: #555555;'> </span><span style='color: #555555;font-style: italic;'>&lt;dbl&gt;</span><span style='color: #555555;'>,
#&gt; #   </span><span style='color: #555555;font-weight: bold;'>minute</span><span style='color: #555555;'> </span><span style='color: #555555;font-style: italic;'>&lt;dbl&gt;</span><span style='color: #555555;'>, </span><span style='color: #555555;font-weight: bold;'>time_hour</span><span style='color: #555555;'> </span><span style='color: #555555;font-style: italic;'>&lt;dttm&gt;</span><span style='color: #555555;'>, </span><span style='color: #555555;font-weight: bold;'>name.x</span><span style='color: #555555;'> </span><span style='color: #555555;font-style: italic;'>&lt;chr&gt;</span><span style='color: #555555;'>, </span><span style='color: #555555;font-weight: bold;'>year.y</span><span style='color: #555555;'> </span><span style='color: #555555;font-style: italic;'>&lt;int&gt;</span><span style='color: #555555;'>,
#&gt; #   </span><span style='color: #555555;font-weight: bold;'>type</span><span style='color: #555555;'> </span><span style='color: #555555;font-style: italic;'>&lt;chr&gt;</span><span style='color: #555555;'>, </span><span style='color: #555555;font-weight: bold;'>manufacturer</span><span style='color: #555555;'> </span><span style='color: #555555;font-style: italic;'>&lt;chr&gt;</span><span style='color: #555555;'>, </span><span style='color: #555555;font-weight: bold;'>model</span><span style='color: #555555;'> </span><span style='color: #555555;font-style: italic;'>&lt;chr&gt;</span><span style='color: #555555;'>, </span><span style='color: #555555;font-weight: bold;'>engines</span><span style='color: #555555;'> </span><span style='color: #555555;font-style: italic;'>&lt;int&gt;</span><span style='color: #555555;'>,
#&gt; #   </span><span style='color: #555555;font-weight: bold;'>seats</span><span style='color: #555555;'> </span><span style='color: #555555;font-style: italic;'>&lt;int&gt;</span><span style='color: #555555;'>, </span><span style='color: #555555;font-weight: bold;'>speed</span><span style='color: #555555;'> </span><span style='color: #555555;font-style: italic;'>&lt;int&gt;</span><span style='color: #555555;'>, </span><span style='color: #555555;font-weight: bold;'>engine</span><span style='color: #555555;'> </span><span style='color: #555555;font-style: italic;'>&lt;chr&gt;</span><span style='color: #555555;'>, </span><span style='color: #555555;font-weight: bold;'>name.y</span><span style='color: #555555;'> </span><span style='color: #555555;font-style: italic;'>&lt;chr&gt;</span><span style='color: #555555;'>, </span><span style='color: #555555;font-weight: bold;'>lat</span><span style='color: #555555;'> </span><span style='color: #555555;font-style: italic;'>&lt;dbl&gt;</span><span style='color: #555555;'>,
#&gt; #   </span><span style='color: #555555;font-weight: bold;'>lon</span><span style='color: #555555;'> </span><span style='color: #555555;font-style: italic;'>&lt;dbl&gt;</span><span style='color: #555555;'>, </span><span style='color: #555555;font-weight: bold;'>alt</span><span style='color: #555555;'> </span><span style='color: #555555;font-style: italic;'>&lt;dbl&gt;</span><span style='color: #555555;'>, </span><span style='color: #555555;font-weight: bold;'>tz</span><span style='color: #555555;'> </span><span style='color: #555555;font-style: italic;'>&lt;dbl&gt;</span><span style='color: #555555;'>, </span><span style='color: #555555;font-weight: bold;'>dst</span><span style='color: #555555;'> </span><span style='color: #555555;font-style: italic;'>&lt;chr&gt;</span><span style='color: #555555;'>, </span><span style='color: #555555;font-weight: bold;'>tzone</span><span style='color: #555555;'> </span><span style='color: #555555;font-style: italic;'>&lt;chr&gt;</span><span>
</span></CODE></PRE>

With the {dm} package, you would create [a `dm`
object](https://krlmlr.github.io/dm/articles/dm-class-and-basic-operations.html).
After that you would be able to use the links between the tables as
often as you wish, without explicitly referring to the relations ever
again.

For the example data set, you can use `dm_nycflights13()` to create the
`dm` object, and a single command for merging the tables. The task of
joining the four `flights`, `airlines`, `planes` and `airports` tables
then boils down to:

``` r
library(dm)

dm_nycflights13() %>%
  dm_flatten_to_tbl(start = flights)
#> Renamed columns:
#> * year -> flights$flights.year, planes$planes.year
#> * name -> airlines$airlines.name, airports$airports.name
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
#&gt; </span><span style='color: #555555;'># … with 11,217 more rows, and 28 more variables: </span><span style='color: #555555;font-weight: bold;'>sched_arr_time</span><span style='color: #555555;'> </span><span style='color: #555555;font-style: italic;'>&lt;int&gt;</span><span style='color: #555555;'>,
#&gt; #   </span><span style='color: #555555;font-weight: bold;'>arr_delay</span><span style='color: #555555;'> </span><span style='color: #555555;font-style: italic;'>&lt;dbl&gt;</span><span style='color: #555555;'>, </span><span style='color: #555555;font-weight: bold;'>carrier</span><span style='color: #555555;'> </span><span style='color: #555555;font-style: italic;'>&lt;chr&gt;</span><span style='color: #555555;'>, </span><span style='color: #555555;font-weight: bold;'>flight</span><span style='color: #555555;'> </span><span style='color: #555555;font-style: italic;'>&lt;int&gt;</span><span style='color: #555555;'>, </span><span style='color: #555555;font-weight: bold;'>tailnum</span><span style='color: #555555;'> </span><span style='color: #555555;font-style: italic;'>&lt;chr&gt;</span><span style='color: #555555;'>,
#&gt; #   </span><span style='color: #555555;font-weight: bold;'>origin</span><span style='color: #555555;'> </span><span style='color: #555555;font-style: italic;'>&lt;chr&gt;</span><span style='color: #555555;'>, </span><span style='color: #555555;font-weight: bold;'>dest</span><span style='color: #555555;'> </span><span style='color: #555555;font-style: italic;'>&lt;chr&gt;</span><span style='color: #555555;'>, </span><span style='color: #555555;font-weight: bold;'>air_time</span><span style='color: #555555;'> </span><span style='color: #555555;font-style: italic;'>&lt;dbl&gt;</span><span style='color: #555555;'>, </span><span style='color: #555555;font-weight: bold;'>distance</span><span style='color: #555555;'> </span><span style='color: #555555;font-style: italic;'>&lt;dbl&gt;</span><span style='color: #555555;'>, </span><span style='color: #555555;font-weight: bold;'>hour</span><span style='color: #555555;'> </span><span style='color: #555555;font-style: italic;'>&lt;dbl&gt;</span><span style='color: #555555;'>,
#&gt; #   </span><span style='color: #555555;font-weight: bold;'>minute</span><span style='color: #555555;'> </span><span style='color: #555555;font-style: italic;'>&lt;dbl&gt;</span><span style='color: #555555;'>, </span><span style='color: #555555;font-weight: bold;'>time_hour</span><span style='color: #555555;'> </span><span style='color: #555555;font-style: italic;'>&lt;dttm&gt;</span><span style='color: #555555;'>, </span><span style='color: #555555;font-weight: bold;'>airlines.name</span><span style='color: #555555;'> </span><span style='color: #555555;font-style: italic;'>&lt;chr&gt;</span><span style='color: #555555;'>,
#&gt; #   </span><span style='color: #555555;font-weight: bold;'>airports.name</span><span style='color: #555555;'> </span><span style='color: #555555;font-style: italic;'>&lt;chr&gt;</span><span style='color: #555555;'>, </span><span style='color: #555555;font-weight: bold;'>lat</span><span style='color: #555555;'> </span><span style='color: #555555;font-style: italic;'>&lt;dbl&gt;</span><span style='color: #555555;'>, </span><span style='color: #555555;font-weight: bold;'>lon</span><span style='color: #555555;'> </span><span style='color: #555555;font-style: italic;'>&lt;dbl&gt;</span><span style='color: #555555;'>, </span><span style='color: #555555;font-weight: bold;'>alt</span><span style='color: #555555;'> </span><span style='color: #555555;font-style: italic;'>&lt;dbl&gt;</span><span style='color: #555555;'>, </span><span style='color: #555555;font-weight: bold;'>tz</span><span style='color: #555555;'> </span><span style='color: #555555;font-style: italic;'>&lt;dbl&gt;</span><span style='color: #555555;'>,
#&gt; #   </span><span style='color: #555555;font-weight: bold;'>dst</span><span style='color: #555555;'> </span><span style='color: #555555;font-style: italic;'>&lt;chr&gt;</span><span style='color: #555555;'>, </span><span style='color: #555555;font-weight: bold;'>tzone</span><span style='color: #555555;'> </span><span style='color: #555555;font-style: italic;'>&lt;chr&gt;</span><span style='color: #555555;'>, </span><span style='color: #555555;font-weight: bold;'>planes.year</span><span style='color: #555555;'> </span><span style='color: #555555;font-style: italic;'>&lt;int&gt;</span><span style='color: #555555;'>, </span><span style='color: #555555;font-weight: bold;'>type</span><span style='color: #555555;'> </span><span style='color: #555555;font-style: italic;'>&lt;chr&gt;</span><span style='color: #555555;'>,
#&gt; #   </span><span style='color: #555555;font-weight: bold;'>manufacturer</span><span style='color: #555555;'> </span><span style='color: #555555;font-style: italic;'>&lt;chr&gt;</span><span style='color: #555555;'>, </span><span style='color: #555555;font-weight: bold;'>model</span><span style='color: #555555;'> </span><span style='color: #555555;font-style: italic;'>&lt;chr&gt;</span><span style='color: #555555;'>, </span><span style='color: #555555;font-weight: bold;'>engines</span><span style='color: #555555;'> </span><span style='color: #555555;font-style: italic;'>&lt;int&gt;</span><span style='color: #555555;'>, </span><span style='color: #555555;font-weight: bold;'>seats</span><span style='color: #555555;'> </span><span style='color: #555555;font-style: italic;'>&lt;int&gt;</span><span style='color: #555555;'>,
#&gt; #   </span><span style='color: #555555;font-weight: bold;'>speed</span><span style='color: #555555;'> </span><span style='color: #555555;font-style: italic;'>&lt;int&gt;</span><span style='color: #555555;'>, </span><span style='color: #555555;font-weight: bold;'>engine</span><span style='color: #555555;'> </span><span style='color: #555555;font-style: italic;'>&lt;chr&gt;</span><span>
</span></CODE></PRE>

The example data model for {nycflights13} is integrated in {dm} and
defines primary and foreign keys to identify the common points between
the tables. For data other than the example data, the `dm` object would
need to be created by using the `dm()` constructor and by adding keys
using `dm_add_pk()` and `dm_add_fk()`.

## Features

The {dm} package helps with the challenges that arise with working with
relational data models.

### Compound object

The `dm` class manages several related tables. It stores both the
**data** and the **metadata** in a compound object.

  - data: a table source storing all tables
  - metadata: table names, column names, primary and foreign keys

This concept helps separating the join logic from the code: declare your
relationships once, as part of your data, then use them in your code
without repeating yourself.

Various operations on `dm` objects are implemented. They either affect
the data (e.g., a filter), or the metadata (e.g., definition of keys),
or both (e.g., creation of a new table).

### Storage agnostic

The {dm} package augments
[{dplyr}](https://dplyr.tidyverse.org/)/[{dbplyr}](https://dbplyr.tidyverse.org/)
workflows. Generally, if you can use {dplyr} on your data, it’s likely
that you can use {dm} too. This includes local data frames, relational
database systems, and many more.

### Data preparation

A battery of utilities helps with creating a tidy relational data model.

  - Splitting and rejoining tables
  - Determining key candidates
  - Checking keys and cardinalities

### Filtering and joining

Similarly to `dplyr::filter()`, a filtering function `dm_filter()` is
available for `dm` objects. You need to provide the `dm` object, the
table whose rows you want to filter, and the filter expression. The
actual effect of the filtering will only be realized once you use
`dm_apply_filters`. Before that, the filter conditions are merely stored
within the `dm`. After using `dm_apply_filters()` a `dm` object is
returned whose tables only contain rows that are related to the reduced
rows in the filtered table. This currently only works for cycle-free
relationships between the tables.

``` r
dm_nycflights13(cycle = FALSE) %>%
  dm_get_tables() %>%
  map_int(nrow)
#> airlines airports  flights   planes  weather 
#>       16     1458    11227     3322    26115

dm_nycflights13(cycle = FALSE) %>%
  dm_filter(planes, year == 2000, manufacturer == "BOEING") %>%
  dm_apply_filters() %>%
  dm_get_tables() %>%
  map_int(nrow)
#> airlines airports  flights   planes  weather 
#>        4        3      220      134    26115
```

For joining two tables using their relationship defined in the `dm`, you
can use `dm_join_to_tbl()`:

``` r
dm_nycflights13(cycle = FALSE) %>%
  dm_join_to_tbl(airports, flights, join = semi_join)
```

<PRE class="fansi fansi-output"><CODE>#&gt; <span style='color: #555555;'># A tibble: 11,227 x 19</span><span>
#&gt;     </span><span style='font-weight: bold;'>year</span><span> </span><span style='font-weight: bold;'>month</span><span>   </span><span style='font-weight: bold;'>day</span><span> </span><span style='font-weight: bold;'>dep_time</span><span> </span><span style='font-weight: bold;'>sched_dep_time</span><span> </span><span style='font-weight: bold;'>dep_delay</span><span> </span><span style='font-weight: bold;'>arr_time</span><span>
#&gt;    </span><span style='color: #555555;font-style: italic;'>&lt;int&gt;</span><span> </span><span style='color: #555555;font-style: italic;'>&lt;int&gt;</span><span> </span><span style='color: #555555;font-style: italic;'>&lt;int&gt;</span><span>    </span><span style='color: #555555;font-style: italic;'>&lt;int&gt;</span><span>          </span><span style='color: #555555;font-style: italic;'>&lt;int&gt;</span><span>     </span><span style='color: #555555;font-style: italic;'>&lt;dbl&gt;</span><span>    </span><span style='color: #555555;font-style: italic;'>&lt;int&gt;</span><span>
#&gt; </span><span style='color: #555555;'> 1</span><span>  </span><span style='text-decoration: underline;'>2</span><span>013     1    10        3           </span><span style='text-decoration: underline;'>2</span><span>359         4      426
#&gt; </span><span style='color: #555555;'> 2</span><span>  </span><span style='text-decoration: underline;'>2</span><span>013     1    10       16           </span><span style='text-decoration: underline;'>2</span><span>359        17      447
#&gt; </span><span style='color: #555555;'> 3</span><span>  </span><span style='text-decoration: underline;'>2</span><span>013     1    10      450            500       -</span><span style='color: #BB0000;'>10</span><span>      634
#&gt; </span><span style='color: #555555;'> 4</span><span>  </span><span style='text-decoration: underline;'>2</span><span>013     1    10      520            525        -</span><span style='color: #BB0000;'>5</span><span>      813
#&gt; </span><span style='color: #555555;'> 5</span><span>  </span><span style='text-decoration: underline;'>2</span><span>013     1    10      530            530         0      824
#&gt; </span><span style='color: #555555;'> 6</span><span>  </span><span style='text-decoration: underline;'>2</span><span>013     1    10      531            540        -</span><span style='color: #BB0000;'>9</span><span>      832
#&gt; </span><span style='color: #555555;'> 7</span><span>  </span><span style='text-decoration: underline;'>2</span><span>013     1    10      535            540        -</span><span style='color: #BB0000;'>5</span><span>     </span><span style='text-decoration: underline;'>1</span><span>015
#&gt; </span><span style='color: #555555;'> 8</span><span>  </span><span style='text-decoration: underline;'>2</span><span>013     1    10      546            600       -</span><span style='color: #BB0000;'>14</span><span>      645
#&gt; </span><span style='color: #555555;'> 9</span><span>  </span><span style='text-decoration: underline;'>2</span><span>013     1    10      549            600       -</span><span style='color: #BB0000;'>11</span><span>      652
#&gt; </span><span style='color: #555555;'>10</span><span>  </span><span style='text-decoration: underline;'>2</span><span>013     1    10      550            600       -</span><span style='color: #BB0000;'>10</span><span>      649
#&gt; </span><span style='color: #555555;'># … with 11,217 more rows, and 12 more variables: </span><span style='color: #555555;font-weight: bold;'>sched_arr_time</span><span style='color: #555555;'> </span><span style='color: #555555;font-style: italic;'>&lt;int&gt;</span><span style='color: #555555;'>,
#&gt; #   </span><span style='color: #555555;font-weight: bold;'>arr_delay</span><span style='color: #555555;'> </span><span style='color: #555555;font-style: italic;'>&lt;dbl&gt;</span><span style='color: #555555;'>, </span><span style='color: #555555;font-weight: bold;'>carrier</span><span style='color: #555555;'> </span><span style='color: #555555;font-style: italic;'>&lt;chr&gt;</span><span style='color: #555555;'>, </span><span style='color: #555555;font-weight: bold;'>flight</span><span style='color: #555555;'> </span><span style='color: #555555;font-style: italic;'>&lt;int&gt;</span><span style='color: #555555;'>, </span><span style='color: #555555;font-weight: bold;'>tailnum</span><span style='color: #555555;'> </span><span style='color: #555555;font-style: italic;'>&lt;chr&gt;</span><span style='color: #555555;'>,
#&gt; #   </span><span style='color: #555555;font-weight: bold;'>origin</span><span style='color: #555555;'> </span><span style='color: #555555;font-style: italic;'>&lt;chr&gt;</span><span style='color: #555555;'>, </span><span style='color: #555555;font-weight: bold;'>dest</span><span style='color: #555555;'> </span><span style='color: #555555;font-style: italic;'>&lt;chr&gt;</span><span style='color: #555555;'>, </span><span style='color: #555555;font-weight: bold;'>air_time</span><span style='color: #555555;'> </span><span style='color: #555555;font-style: italic;'>&lt;dbl&gt;</span><span style='color: #555555;'>, </span><span style='color: #555555;font-weight: bold;'>distance</span><span style='color: #555555;'> </span><span style='color: #555555;font-style: italic;'>&lt;dbl&gt;</span><span style='color: #555555;'>, </span><span style='color: #555555;font-weight: bold;'>hour</span><span style='color: #555555;'> </span><span style='color: #555555;font-style: italic;'>&lt;dbl&gt;</span><span style='color: #555555;'>,
#&gt; #   </span><span style='color: #555555;font-weight: bold;'>minute</span><span style='color: #555555;'> </span><span style='color: #555555;font-style: italic;'>&lt;dbl&gt;</span><span style='color: #555555;'>, </span><span style='color: #555555;font-weight: bold;'>time_hour</span><span style='color: #555555;'> </span><span style='color: #555555;font-style: italic;'>&lt;dttm&gt;</span><span>
</span></CODE></PRE>

In our `dm`, the `origin` column of the `flights` table points to the
`airports` table. Since all `nycflights13`-flights depart from New York,
only these airports are included in the semi-join.

### From and to databases

In order to transfer an existing `dm` object to a DB, you can call
`dm_copy_to()` with the target DB and the `dm` object:

``` r
src_sqlite <- src_sqlite(":memory:", create = TRUE)
src_sqlite
#> src:  sqlite 3.30.1 [:memory:]
#> tbls:
nycflights13_remote <- copy_dm_to(src_sqlite, dm_nycflights13(cycle = TRUE))
nycflights13_remote
```

<PRE class="fansi fansi-output"><CODE>#&gt; <span style='color: #00BB00;'>──</span><span> </span><span style='color: #00BB00;'>Table source</span><span> </span><span style='color: #00BB00;'>───────────────────────────────────────────────────────────</span><span>
#&gt; src:  sqlite 3.30.1 [:memory:]
#&gt; </span><span style='color: #555555;'>──</span><span> </span><span style='color: #555555;'>Metadata</span><span> </span><span style='color: #555555;'>───────────────────────────────────────────────────────────────</span><span>
#&gt; Tables: `airlines`, `airports`, `flights`, `planes`, `weather`
#&gt; Columns: 53
#&gt; Primary keys: 3
#&gt; Foreign keys: 4
</span></CODE></PRE>

The key constraints from the original object are also copied to the
newly created object. With the default setting `set_key_constraints =
TRUE` for `dm_copy_to()`, key constraints are also established on the
target DB. Currently this feature is only supported for MSSQL and
Postgres database management systems (DBMS).

It is also possible to automatically create a `dm` object from the
permanent tables of a DB. Again, for now just MSSQL and Postgres are
supported for this feature, so the next chunk is not evaluated. The
support for other DBMS will be implemented in a future update.

``` r
src_postgres <- src_postgres()
nycflights13_from_remote <- dm_learn_from_db(src_postgres)
```

## Installation

The latest (development) version of {dm} can be installed from GitHub.

``` r
# install.packages("devtools")
devtools::install_github("krlmlr/dm")
```

The {dm} package will also be made available on
[CRAN](https://CRAN.R-project.org/package=dm), from where it can be
installed with the command

``` r
install.packages("dm")
```

## More information

For an introduction into relational data models and to jump-start
working with {dm}, please see the article [“Introduction to Relational
Data
Models”](https://krlmlr.github.io/dm/articles/dm-introduction-relational-data-models.html).

If you would like to learn more about {dm}, the [Intro
article](https://krlmlr.github.io/dm/articles/dm.html) is a good place
to start.

Further resources:

  - [Function
    reference](https://krlmlr.github.io/dm/reference/index.html)
  - [Introduction to Relational Data
    Models](https://krlmlr.github.io/dm/articles/dm-introduction-relational-data-models.html)
    article
  - [Joining](https://krlmlr.github.io/dm/articles/dm-joining.html)
    article
  - [Filtering](https://krlmlr.github.io/dm/articles/dm-filtering.html)
    article
  - [Class ‘dm’ and basic
    operations](https://krlmlr.github.io/dm/articles/dm-class-and-basic-operations.html)
    article
  - [Visualizing ‘dm’
    objects](https://krlmlr.github.io/dm/articles/dm-visualization.html)
    article
  - [Low-level
    operations](https://krlmlr.github.io/dm/articles/dm-low-level.html)
    article
    <!-- FIXME: vignettes missing;  once there, needs to be linked -->

## Standing on the shoulders of giants

The {dm} package follows the tidyverse principles:

  - `dm` objects are immutable (your data will never be overwritten in
    place)
  - many functions used on `dm` objects are pipeable (i.e., return new
    `dm` objects)
  - tidy evaluation is used (unquoted function parameters are supported)

The {dm} package builds heavily upon the [{datamodelr}
package](https://github.com/bergant/datamodelr), and upon the
[tidyverse](https://www.tidyverse.org/). We’re looking forward to a good
collaboration\!

The [{polyply} package](https://github.com/russHyde/polyply) has a
similar intent with a slightly different interface.

The [{data.cube} package](https://github.com/jangorecki/data.cube) has
quite the same intent using `array`-like interface.

Articles in the [{rquery} package](https://github.com/WinVector/rquery)
discuss [join
controllers](https://github.com/WinVector/rquery/blob/master/extras/JoinController.md)
and [join dependency
sorting](https://github.com/WinVector/rquery/blob/master/extras/DependencySorting.md),
with the intent to move the declaration of table relationships from code
to data.

The [{tidygraph} package](https://github.com/thomasp85/tidygraph) stores
a network as two related tables of `nodes` and `edges`, compatible with
{dplyr} workflows.

In object-oriented programming languages, [object-relational
mapping](https://en.wikipedia.org/wiki/Object-relational_mapping) is a
similar concept that attempts to map a set of related tables to a class
hierarchy.

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
