
<!-- README.md is generated from README.Rmd. Please edit that file -->

# [dm](https://krlmlr.github.io/dm)

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

## Overview

dm bridges the gap in the data pipeline between individual data frames
and relational databases. It’s a [grammar of joined
tables](https://twitter.com/drob/status/1224851726068527106) that
provides a consistent set of verbs for building, using and deploying
relational data models. For individual researchers, it broadens the
scope of datasets they can work with and how they work with them. For
organizations, it enables teams to quickly and efficiently create and
share large, complex datasets.

dm objects encapsulate relational data models constructed from local
data frames or lazy tables connected to an RDBMS. dm objects support the
full suite of dplyr data manipulation verbs along with additional
methods for constructing and verifying relational data models, including
key selection, key creation, and rigorous constraint checking. Once a
data model is complete, dm provides methods for deploying it to an
RDBMS. This allows it to scale from datasets that fit in memory to
databases with billions of rows.

## Why use dm

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

<img src="data:PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiIHN0YW5kYWxvbmU9Im5vIj8+PCFET0NUWVBFIHN2ZyBQVUJMSUMgIi0vL1czQy8vRFREIFNWRyAxLjEvL0VOIiAiaHR0cDovL3d3dy53My5vcmcvR3JhcGhpY3MvU1ZHLzEuMS9EVEQvc3ZnMTEuZHRkIj48IS0tIEdlbmVyYXRlZCBieSBncmFwaHZpeiB2ZXJzaW9uIDIuNDAuMSAoMjAxNjEyMjUuMDMwNCkgLS0+PCEtLSBUaXRsZTogJTAgUGFnZXM6IDEgLS0+PHN2ZyB3aWR0aD0iMTUycHQiIGhlaWdodD0iMTg0cHQiIHZpZXdCb3g9IjAuMDAgMC4wMCAxNTIuMDAgMTg0LjAwIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHhtbG5zOnhsaW5rPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5L3hsaW5rIj48ZyBpZD0iZ3JhcGgwIiBjbGFzcz0iZ3JhcGgiIHRyYW5zZm9ybT0ic2NhbGUoMSAxKSByb3RhdGUoMCkgdHJhbnNsYXRlKDQgMTgwKSI+PHRpdGxlPiUwPC90aXRsZT48ZyBpZD0iYV9ncmFwaDAiPjxhIHhsaW5rOnRpdGxlPSJEYXRhIE1vZGVsIj48cG9seWdvbiBmaWxsPSIjZmZmZmZmIiBzdHJva2U9InRyYW5zcGFyZW50IiBwb2ludHM9Ii00LDQgLTQsLTE4MCAxNDgsLTE4MCAxNDgsNCAtNCw0Ii8+PC9hPjwvZz48IS0tIGFpcmxpbmVzIC0tPjxnIGlkPSJub2RlMSIgY2xhc3M9Im5vZGUiPjx0aXRsZT5haXJsaW5lczwvdGl0bGU+PHBvbHlnb24gZmlsbD0iI2VkN2QzMSIgc3Ryb2tlPSJ0cmFuc3BhcmVudCIgcG9pbnRzPSI5NSwtMTQxIDk1LC0xNjEgMTQwLC0xNjEgMTQwLC0xNDEgOTUsLTE0MSIvPjx0ZXh0IHRleHQtYW5jaG9yPSJzdGFydCIgeD0iOTYuODk2OSIgeT0iLTE0Ni40IiBmb250LWZhbWlseT0iVGltZXMsc2VyaWYiIGZvbnQtc2l6ZT0iMTQuMDAiIGZpbGw9IiNmZmZmZmYiPmFpcmxpbmVzPC90ZXh0Pjxwb2x5Z29uIGZpbGw9IiNmYmU1ZDUiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iOTUsLTEyMSA5NSwtMTQxIDE0MCwtMTQxIDE0MCwtMTIxIDk1LC0xMjEiLz48dGV4dCB0ZXh0LWFuY2hvcj0ic3RhcnQiIHg9Ijk3IiB5PSItMTI3LjQiIGZvbnQtZmFtaWx5PSJUaW1lcyxzZXJpZiIgdGV4dC1kZWNvcmF0aW9uPSJ1bmRlcmxpbmUiIGZvbnQtc2l6ZT0iMTQuMDAiIGZpbGw9IiM0NDQ0NDQiPmNhcnJpZXI8L3RleHQ+PHBvbHlnb24gZmlsbD0ibm9uZSIgc3Ryb2tlPSIjOWU1MzIwIiBzdHJva2Utb3BhY2l0eT0iMC42NjY2NjciIHBvaW50cz0iOTMuNSwtMTIwIDkzLjUsLTE2MiAxNDAuNSwtMTYyIDE0MC41LC0xMjAgOTMuNSwtMTIwIi8+PC9nPjwhLS0gYWlycG9ydHMgLS0+PGcgaWQ9Im5vZGUyIiBjbGFzcz0ibm9kZSI+PHRpdGxlPmFpcnBvcnRzPC90aXRsZT48cG9seWdvbiBmaWxsPSIjZWQ3ZDMxIiBzdHJva2U9InRyYW5zcGFyZW50IiBwb2ludHM9Ijk0LC0yMSA5NCwtNDEgMTQwLC00MSAxNDAsLTIxIDk0LC0yMSIvPjx0ZXh0IHRleHQtYW5jaG9yPSJzdGFydCIgeD0iOTUuNjE5MiIgeT0iLTI2LjQiIGZvbnQtZmFtaWx5PSJUaW1lcyxzZXJpZiIgZm9udC1zaXplPSIxNC4wMCIgZmlsbD0iI2ZmZmZmZiI+YWlycG9ydHM8L3RleHQ+PHBvbHlnb24gZmlsbD0iI2ZiZTVkNSIgc3Ryb2tlPSJ0cmFuc3BhcmVudCIgcG9pbnRzPSI5NCwtMSA5NCwtMjEgMTQwLC0yMSAxNDAsLTEgOTQsLTEiLz48dGV4dCB0ZXh0LWFuY2hvcj0ic3RhcnQiIHg9Ijk2IiB5PSItNy40IiBmb250LWZhbWlseT0iVGltZXMsc2VyaWYiIHRleHQtZGVjb3JhdGlvbj0idW5kZXJsaW5lIiBmb250LXNpemU9IjE0LjAwIiBmaWxsPSIjNDQ0NDQ0Ij5mYWE8L3RleHQ+PHBvbHlnb24gZmlsbD0ibm9uZSIgc3Ryb2tlPSIjOWU1MzIwIiBzdHJva2Utb3BhY2l0eT0iMC42NjY2NjciIHBvaW50cz0iOTMsMCA5MywtNDIgMTQxLC00MiAxNDEsMCA5MywwIi8+PC9nPjwhLS0gZmxpZ2h0cyAtLT48ZyBpZD0ibm9kZTMiIGNsYXNzPSJub2RlIj48dGl0bGU+ZmxpZ2h0czwvdGl0bGU+PHBvbHlnb24gZmlsbD0iIzViOWJkNSIgc3Ryb2tlPSJ0cmFuc3BhcmVudCIgcG9pbnRzPSI0LC0xMDEgNCwtMTIxIDUwLC0xMjEgNTAsLTEwMSA0LC0xMDEiLz48dGV4dCB0ZXh0LWFuY2hvcj0ic3RhcnQiIHg9IjkuMTExNSIgeT0iLTEwNi40IiBmb250LWZhbWlseT0iVGltZXMsc2VyaWYiIGZvbnQtc2l6ZT0iMTQuMDAiIGZpbGw9IiNmZmZmZmYiPmZsaWdodHM8L3RleHQ+PHBvbHlnb24gZmlsbD0iI2RlZWJmNiIgc3Ryb2tlPSJ0cmFuc3BhcmVudCIgcG9pbnRzPSI0LC04MSA0LC0xMDEgNTAsLTEwMSA1MCwtODEgNCwtODEiLz48dGV4dCB0ZXh0LWFuY2hvcj0ic3RhcnQiIHg9IjYiIHk9Ii04Ni40IiBmb250LWZhbWlseT0iVGltZXMsc2VyaWYiIGZvbnQtc2l6ZT0iMTQuMDAiIGZpbGw9IiM0NDQ0NDQiPmNhcnJpZXI8L3RleHQ+PHBvbHlnb24gZmlsbD0iI2RlZWJmNiIgc3Ryb2tlPSJ0cmFuc3BhcmVudCIgcG9pbnRzPSI0LC02MSA0LC04MSA1MCwtODEgNTAsLTYxIDQsLTYxIi8+PHRleHQgdGV4dC1hbmNob3I9InN0YXJ0IiB4PSI1LjYxMTUiIHk9Ii02Ni40IiBmb250LWZhbWlseT0iVGltZXMsc2VyaWYiIGZvbnQtc2l6ZT0iMTQuMDAiIGZpbGw9IiM0NDQ0NDQiPnRhaWxudW08L3RleHQ+PHBvbHlnb24gZmlsbD0iI2RlZWJmNiIgc3Ryb2tlPSJ0cmFuc3BhcmVudCIgcG9pbnRzPSI0LC00MSA0LC02MSA1MCwtNjEgNTAsLTQxIDQsLTQxIi8+PHRleHQgdGV4dC1hbmNob3I9InN0YXJ0IiB4PSI2IiB5PSItNDYuNCIgZm9udC1mYW1pbHk9IlRpbWVzLHNlcmlmIiBmb250LXNpemU9IjE0LjAwIiBmaWxsPSIjNDQ0NDQ0Ij5vcmlnaW48L3RleHQ+PHBvbHlnb24gZmlsbD0ibm9uZSIgc3Ryb2tlPSIjM2M2NzhlIiBzdHJva2Utb3BhY2l0eT0iMC42NjY2NjciIHBvaW50cz0iMywtNDAgMywtMTIyIDUxLC0xMjIgNTEsLTQwIDMsLTQwIi8+PC9nPjwhLS0gZmxpZ2h0cyYjNDU7Jmd0O2FpcmxpbmVzIC0tPjxnIGlkPSJlZGdlMSIgY2xhc3M9ImVkZ2UiPjx0aXRsZT5mbGlnaHRzOmNhcnJpZXImIzQ1OyZndDthaXJsaW5lczpjYXJyaWVyPC90aXRsZT48cGF0aCBmaWxsPSJub25lIiBzdHJva2U9IiM1NTU1NTUiIGQ9Ik01MCwtOTFDNzIuNzg3LC05MSA2OS45OTI1LC0xMjAuMDA2MyA4NS4xODQ5LC0xMjguNjE3NiIvPjxwb2x5Z29uIGZpbGw9IiM1NTU1NTUiIHN0cm9rZT0iIzU1NTU1NSIgcG9pbnRzPSI4NC40NTY2LC0xMzIuMDQyNCA5NSwtMTMxIDg2LjEwNzgsLTEyNS4yMzk5IDg0LjQ1NjYsLTEzMi4wNDI0Ii8+PC9nPjwhLS0gZmxpZ2h0cyYjNDU7Jmd0O2FpcnBvcnRzIC0tPjxnIGlkPSJlZGdlMiIgY2xhc3M9ImVkZ2UiPjx0aXRsZT5mbGlnaHRzOm9yaWdpbiYjNDU7Jmd0O2FpcnBvcnRzOmZhYTwvdGl0bGU+PHBhdGggZmlsbD0ibm9uZSIgc3Ryb2tlPSIjNTU1NTU1IiBkPSJNNTAsLTUxQzcyLjI5OTEsLTUxIDY5LjQ3NzgsLTIyLjUyMzQgODMuOTI2OCwtMTMuNjI0NSIvPjxwb2x5Z29uIGZpbGw9IiM1NTU1NTUiIHN0cm9rZT0iIzU1NTU1NSIgcG9pbnRzPSI4NS4yMDU1LC0xNi45MDgzIDk0LC0xMSA4My40NDA2LC0xMC4xMzQ0IDg1LjIwNTUsLTE2LjkwODMiLz48L2c+PCEtLSBwbGFuZXMgLS0+PGcgaWQ9Im5vZGU0IiBjbGFzcz0ibm9kZSI+PHRpdGxlPnBsYW5lczwvdGl0bGU+PHBvbHlnb24gZmlsbD0iI2VkN2QzMSIgc3Ryb2tlPSJ0cmFuc3BhcmVudCIgcG9pbnRzPSI5NCwtODEgOTQsLTEwMSAxNDAsLTEwMSAxNDAsLTgxIDk0LC04MSIvPjx0ZXh0IHRleHQtYW5jaG9yPSJzdGFydCIgeD0iOTkuMTE3OCIgeT0iLTg2LjQiIGZvbnQtZmFtaWx5PSJUaW1lcyxzZXJpZiIgZm9udC1zaXplPSIxNC4wMCIgZmlsbD0iI2ZmZmZmZiI+cGxhbmVzPC90ZXh0Pjxwb2x5Z29uIGZpbGw9IiNmYmU1ZDUiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iOTQsLTYxIDk0LC04MSAxNDAsLTgxIDE0MCwtNjEgOTQsLTYxIi8+PHRleHQgdGV4dC1hbmNob3I9InN0YXJ0IiB4PSI5NS42MTE1IiB5PSItNjcuNCIgZm9udC1mYW1pbHk9IlRpbWVzLHNlcmlmIiB0ZXh0LWRlY29yYXRpb249InVuZGVybGluZSIgZm9udC1zaXplPSIxNC4wMCIgZmlsbD0iIzQ0NDQ0NCI+dGFpbG51bTwvdGV4dD48cG9seWdvbiBmaWxsPSJub25lIiBzdHJva2U9IiM5ZTUzMjAiIHN0cm9rZS1vcGFjaXR5PSIwLjY2NjY2NyIgcG9pbnRzPSI5MywtNjAgOTMsLTEwMiAxNDEsLTEwMiAxNDEsLTYwIDkzLC02MCIvPjwvZz48IS0tIGZsaWdodHMmIzQ1OyZndDtwbGFuZXMgLS0+PGcgaWQ9ImVkZ2UzIiBjbGFzcz0iZWRnZSI+PHRpdGxlPmZsaWdodHM6dGFpbG51bSYjNDU7Jmd0O3BsYW5lczp0YWlsbnVtPC90aXRsZT48cGF0aCBmaWxsPSJub25lIiBzdHJva2U9IiM1NTU1NTUiIGQ9Ik01MCwtNzFDNjUuNTgzMywtNzEgNzEuODUzMiwtNzEgODMuNjUyOSwtNzEiLz48cG9seWdvbiBmaWxsPSIjNTU1NTU1IiBzdHJva2U9IiM1NTU1NTUiIHBvaW50cz0iODQsLTc0LjUwMDEgOTQsLTcxIDg0LC02Ny41MDAxIDg0LC03NC41MDAxIi8+PC9nPjwhLS0gd2VhdGhlciAtLT48ZyBpZD0ibm9kZTUiIGNsYXNzPSJub2RlIj48dGl0bGU+d2VhdGhlcjwvdGl0bGU+PHBvbHlnb24gZmlsbD0iIzcwYWQ0NyIgc3Ryb2tlPSJ0cmFuc3BhcmVudCIgcG9pbnRzPSIzLC0xNDggMywtMTY4IDUxLC0xNjggNTEsLTE0OCAzLC0xNDgiLz48dGV4dCB0ZXh0LWFuY2hvcj0ic3RhcnQiIHg9IjQuODQ5MiIgeT0iLTE1My40IiBmb250LWZhbWlseT0iVGltZXMsc2VyaWYiIGZvbnQtc2l6ZT0iMTQuMDAiIGZpbGw9IiNmZmZmZmYiPndlYXRoZXI8L3RleHQ+PHBvbHlnb24gZmlsbD0ibm9uZSIgc3Ryb2tlPSIjNGE3MzJmIiBzdHJva2Utb3BhY2l0eT0iMC42NjY2NjciIHBvaW50cz0iMiwtMTQ3IDIsLTE2OSA1MiwtMTY5IDUyLC0xNDcgMiwtMTQ3Ii8+PC9nPjwvZz48L3N2Zz4=" width="100%" />

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
#> [33m![39m Unsatisfied constraints:
```

<PRE class="fansi fansi-output"><CODE>#&gt; <span style='color: #BB0000;'>●</span><span> Table `flights`: foreign key tailnum into table `planes`: 1640 entries (14.6%) of `flights$tailnum` not in `planes$tailnum`: N722MQ (27), N725MQ (20), N520MQ (19), N723MQ (19), N508MQ (16), …
</span></CODE></PRE>

Learn more in the [dm
intro](https://krlmlr.github.io/dm/articles/dm.html).

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
