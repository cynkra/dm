
<!-- README.md is generated from README.Rmd. Please edit that file -->



# [dm](https://dm.cynkra.com/)

<!-- badges: start -->
[![Lifecycle: stable](https://img.shields.io/badge/lifecycle-stable-brightgreen.svg)](https://lifecycle.r-lib.org/articles/stages.html)
[![R build status](https://github.com/cynkra/dm/workflows/rcc/badge.svg)](https://github.com/cynkra/dm/actions)
[![Codecov test coverage](https://codecov.io/gh/cynkra/dm/branch/main/graph/badge.svg)](https://app.codecov.io/gh/cynkra/dm?branch=main)
[![CRAN status](https://www.r-pkg.org/badges/version/dm)](https://CRAN.R-project.org/package=dm)
[![Launch rstudio.cloud](https://img.shields.io/badge/rstudio-cloud-blue.svg)](https://rstudio.cloud/project/523482)
<!-- badges: end -->

> Are you using multiple data frames or database tables in R? Organize them with dm.
>
> - Use it for data analysis today.
> - Build data models tomorrow.
> - Deploy the data models to your organization's Relational Database Management System (RDBMS) the day after.


## Overview

dm bridges the gap in the data pipeline between individual data frames and relational databases.
It's a grammar of joined tables that provides a consistent set of verbs for consuming, creating, and deploying relational data models.
For individual researchers, it broadens the scope of datasets they can work with and how they work with them.
For organizations, it enables teams to quickly and efficiently create and share large, complex datasets.

dm objects encapsulate relational data models constructed from local data frames or lazy tables connected to an RDBMS.
dm objects support the full suite of dplyr data manipulation verbs along with additional methods for constructing and verifying relational data models, including key selection, key creation, and rigorous constraint checking.
Once a data model is complete, dm provides methods for deploying it to an RDBMS.
This allows it to scale from datasets that fit in memory to databases with billions of rows.

## Features

dm makes it easy to bring an existing relational data model into your R session.
As the dm object behaves like a named list of tables it requires little change to incorporate it within existing workflows.
The dm interface and behavior is modeled after dplyr, so you may already be familiar with many of its verbs.
dm also offers:

- visualization to help you understand relationships between entities represented by the tables
- simpler joins that "know" how tables are related, including a "flatten" operation that automatically follows keys and performs column name disambiguation
- consistency and constraint checks to help you understand (and fix) the limitations of your data

That's just the tip of the iceberg.
See [Getting started](https://dm.cynkra.com/articles/dm.html) to hit the ground running and explore all the features.


## Installation

The latest stable version of the {dm} package can be obtained from [CRAN](https://CRAN.R-project.org/package=dm) with the command

```r
install.packages("dm")
```

The latest development version of {dm} can be installed from R-universe:

```r
# Enable repository from cynkra
options(
  repos = c(
    cynkra = "https://cynkra.r-universe.dev",
    CRAN = "https://cloud.r-project.org"
  )
)
# Download and install dm in R
install.packages('dm')
```

or from GitHub:

```r
# install.packages("devtools")
devtools::install_github("cynkra/dm")
```

## Usage

Create a dm object (see [Getting started](https://dm.cynkra.com/articles/dm.html) for details).


``` r
library(dm)
dm <- dm_nycflights13(table_description = TRUE)
dm
#> [38;5;219m--[39m [38;5;219mMetadata[39m [38;5;219m--------------------------------------------------------------------[39m
#> Tables: `airlines`, `airports`, `flights`, `planes`, `weather`
#> Columns: 53
#> Primary keys: 4
#> Foreign keys: 4
```

dm is a named list of tables:


``` r
names(dm)
#> [1] "airlines" "airports" "flights"  "planes"   "weather"
nrow(dm$airports)
#> [1] 86
dm$flights %>%
  count(origin)
#> [38;5;246m# A tibble: 3 × 2[39m
#>   [1morigin[22m     [1mn[22m
#>   [3m[38;5;246m<chr>[39m[23m  [3m[38;5;246m<int>[39m[23m
#> [38;5;250m1[39m EWR      641
#> [38;5;250m2[39m JFK      602
#> [38;5;250m3[39m LGA      518
```

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
#> Renaming ambiguous columns: %>%
#>   dm_rename(flights, year.flights = year) %>%
#>   dm_rename(flights, month.flights = month) %>%
#>   dm_rename(flights, day.flights = day) %>%
#>   dm_rename(flights, hour.flights = hour) %>%
#>   dm_rename(airlines, name.airlines = name) %>%
#>   dm_rename(airports, name.airports = name) %>%
#>   dm_rename(planes, year.planes = year) %>%
#>   dm_rename(weather, year.weather = year) %>%
#>   dm_rename(weather, month.weather = month) %>%
#>   dm_rename(weather, day.weather = day) %>%
#>   dm_rename(weather, hour.weather = hour)
#> [38;5;246m# A tibble: 1,761 × 48[39m
#>    [1myear.flights[22m [1mmonth.…¹[22m [1mday.f…²[22m [1mdep_t…³[22m [1msched…⁴[22m [1mdep_d…⁵[22m [1marr_t…⁶[22m [1msched…⁷[22m [1marr_d…⁸[22m
#>           [3m[38;5;246m<int>[39m[23m    [3m[38;5;246m<int>[39m[23m   [3m[38;5;246m<int>[39m[23m   [3m[38;5;246m<int>[39m[23m   [3m[38;5;246m<int>[39m[23m   [3m[38;5;246m<dbl>[39m[23m   [3m[38;5;246m<int>[39m[23m   [3m[38;5;246m<int>[39m[23m   [3m[38;5;246m<dbl>[39m[23m
#> [38;5;250m 1[39m         [4m2[24m013        1      10       3    [4m2[24m359       4     426     437     -[31m11[39m
#> [38;5;250m 2[39m         [4m2[24m013        1      10      16    [4m2[24m359      17     447     444       3
#> [38;5;250m 3[39m         [4m2[24m013        1      10     450     500     -[31m10[39m     634     648     -[31m14[39m
#> [38;5;250m 4[39m         [4m2[24m013        1      10     520     525      -[31m5[39m     813     820      -[31m7[39m
#> [38;5;250m 5[39m         [4m2[24m013        1      10     530     530       0     824     829      -[31m5[39m
#> [38;5;250m 6[39m         [4m2[24m013        1      10     531     540      -[31m9[39m     832     850     -[31m18[39m
#> [38;5;250m 7[39m         [4m2[24m013        1      10     535     540      -[31m5[39m    [4m1[24m015    [4m1[24m017      -[31m2[39m
#> [38;5;250m 8[39m         [4m2[24m013        1      10     546     600     -[31m14[39m     645     709     -[31m24[39m
#> [38;5;250m 9[39m         [4m2[24m013        1      10     549     600     -[31m11[39m     652     724     -[31m32[39m
#> [38;5;250m10[39m         [4m2[24m013        1      10     550     600     -[31m10[39m     649     703     -[31m14[39m
#> [38;5;246m# ℹ 1,751 more rows[39m
#> [38;5;246m# ℹ abbreviated names: ¹​month.flights, ²​day.flights, ³​dep_time,[39m
#> [38;5;246m#   ⁴​sched_dep_time, ⁵​dep_delay, ⁶​arr_time, ⁷​sched_arr_time, ⁸​arr_delay[39m
#> [38;5;246m# ℹ 39 more variables: [1mcarrier[22m <chr>, [1mflight[22m <int>, [1mtailnum[22m <chr>,[39m
#> [38;5;246m#   [1morigin[22m <chr>, [1mdest[22m <chr>, [1mair_time[22m <dbl>, [1mdistance[22m <dbl>,[39m
#> [38;5;246m#   [1mhour.flights[22m <dbl>, [1mminute[22m <dbl>, [1mtime_hour[22m <dttm>, [1mname.airlines[22m <chr>,[39m
#> [38;5;246m#   [1mname.airports[22m <chr>, [1mlat[22m <dbl>, [1mlon[22m <dbl>, [1malt[22m <dbl>, [1mtz[22m <dbl>, [1mdst[22m <chr>,[39m
#> [38;5;246m#   [1mtzone[22m <chr>, [1myear.planes[22m <int>, [1mtype[22m <chr>, [1mmanufacturer[22m <chr>,[39m
#> [38;5;246m#   [1mmodel[22m <chr>, [1mengines[22m <int>, [1mseats[22m <int>, [1mspeed[22m <int>, [1mengine[22m <chr>,[39m
#> [38;5;246m#   [1myear.weather[22m <int>, [1mmonth.weather[22m <int>, [1mday.weather[22m <int>,[39m
#> [38;5;246m#   [1mhour.weather[22m <int>, [1mtemp[22m <dbl>, [1mdewp[22m <dbl>, [1mhumid[22m <dbl>, [1mwind_dir[22m <dbl>,[39m
#> [38;5;246m#   [1mwind_speed[22m <dbl>, [1mwind_gust[22m <dbl>, [1mprecip[22m <dbl>, [1mpressure[22m <dbl>, …[39m
```

Check consistency:


``` r
dm %>%
  dm_examine_constraints()
#> [33m![39m Unsatisfied constraints:
#> [31m•[39m Table `flights`: foreign key `tailnum` into table `planes`: values of `flights$tailnum` not in `planes$tailnum`: N725MQ (6), N537MQ (5), N722MQ (5), N730MQ (5), N736MQ (5), …
```

Learn more in the [Getting started](https://dm.cynkra.com/articles/dm.html) article.

## Getting help

If you encounter a clear bug, please file an issue with a minimal reproducible example on [GitHub](https://github.com/cynkra/dm/issues).
For questions and other discussion, please use [community.rstudio.com](https://community.rstudio.com/).


