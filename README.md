<!-- README.md is generated from README.Rmd. Please edit that file -->

# [dm](https://krlmlr.github.io/dm/)

<!-- badges: start -->

[![Lifecycle: maturing](https://img.shields.io/badge/lifecycle-maturing-blue.svg)](https://www.tidyverse.org/lifecycle/#maturing) [![R build status](https://github.com/krlmlr/dm/workflows/tic/badge.svg)](https://github.com/krlmlr/dm/actions) [![Codecov test coverage](https://codecov.io/gh/krlmlr/dm/branch/master/graph/badge.svg)](https://codecov.io/gh/krlmlr/dm?branch=master) [![CRAN status](https://www.r-pkg.org/badges/version/dm)](https://CRAN.R-project.org/package=dm) [![Launch rstudio.cloud](https://img.shields.io/badge/rstudio-cloud-blue.svg)](https://rstudio.cloud/project/523482)

<!-- badges: end -->

## TL;DR

Are you using multiple data frames or database tables in R? Organize them with dm.

-   Use it today (if only like a list of tables).
-   Build data models tomorrow.
-   Deploy the data models to your organization’s RDBMS the day after.

## Overview

dm bridges the gap in the data pipeline between individual data frames and relational databases. It’s a [grammar of joined tables](https://twitter.com/drob/status/1224851726068527106) that provides a consistent set of verbs for consuming, creating, and deploying relational data models. For individual researchers, it broadens the scope of datasets they can work with and how they work with them. For organizations, it enables teams to quickly and efficiently create and share large, complex datasets.

dm objects encapsulate relational data models constructed from local data frames or lazy tables connected to an RDBMS. dm objects support the full suite of dplyr data manipulation verbs along with additional methods for constructing and verifying relational data models, including key selection, key creation, and rigorous constraint checking. Once a data model is complete, dm provides methods for deploying it to an RDBMS. This allows it to scale from datasets that fit in memory to databases with billions of rows.

## Features

dm makes it easy to bring an existing relational data model into your R session. As the dm object behaves like a named list of tables it requires little change to incorporate it within existing workflows. The dm interface and behavior is modeled after dplyr, so you may already be familiar with many of its verbs. dm also offers:

-   visualization to help you understand relationships between entities represented by the tables
-   simpler joins that “know” how tables are related, including a “flatten” operation that automatically follows keys and performs column name disambiguation
-   consistency and constraint checks to help you understand (and fix) the limitations of your data

That’s just the tip of the iceberg. See [Getting started](https://krlmlr.github.io/dm/articles/dm.html) to hit the ground running and explore all the features.

## Installation

The latest stable version of the {dm} package can be obtained from [CRAN](https://CRAN.R-project.org/package=dm) with the command

<pre class='chroma'>
<span class='nf'><a href='https://rdrr.io/r/utils/install.packages.html'>install.packages</a></span><span class='o'>(</span><span class='s'>"dm"</span><span class='o'>)</span></pre>

The latest development version of {dm} can be installed from GitHub.

<pre class='chroma'>
<span class='c'># install.packages("devtools")</span>
<span class='nf'>devtools</span><span class='nf'>::</span><span class='nf'><a href='https://devtools.r-lib.org//reference/remote-reexports.html'>install_github</a></span><span class='o'>(</span><span class='s'>"krlmlr/dm"</span><span class='o'>)</span></pre>

## Usage

Create a dm object (see [Getting started](https://krlmlr.github.io/dm/articles/dm.html) for details).

<pre class='chroma'>
<span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://krlmlr.github.io/dm/'>dm</a></span><span class='o'>)</span>
<span class='nv'>dm</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://krlmlr.github.io/dm/reference/dm_nycflights13.html'>dm_nycflights13</a></span><span class='o'>(</span><span class='o'>)</span>
<span class='nv'>dm</span>
<span class='c'>#&gt; <span style='color: #FFAFFF;'>──</span><span> </span><span style='color: #FFAFFF;'>Metadata</span><span> </span><span style='color: #FFAFFF;'>────────────────────────────────────────────────────────────────────</span></span>
<span class='c'>#&gt; Tables: `airlines`, `airports`, `flights`, `planes`, `weather`</span>
<span class='c'>#&gt; Columns: 53</span>
<span class='c'>#&gt; Primary keys: 3</span>
<span class='c'>#&gt; Foreign keys: 3</span></pre>

dm is a named list of tables:

<pre class='chroma'>
<span class='nf'><a href='https://rdrr.io/r/base/names.html'>names</a></span><span class='o'>(</span><span class='nv'>dm</span><span class='o'>)</span>
<span class='c'>#&gt; [1] "airlines" "airports" "flights"  "planes"   "weather"</span>
<span class='nf'><a href='https://rdrr.io/r/base/nrow.html'>nrow</a></span><span class='o'>(</span><span class='nv'>dm</span><span class='o'>$</span><span class='nv'>airports</span><span class='o'>)</span>
<span class='c'>#&gt; [1] 1458</span>
<span class='nv'>dm</span><span class='o'>$</span><span class='nv'>flights</span> <span class='o'>%&gt;%</span>
  <span class='nf'>count</span><span class='o'>(</span><span class='nv'>origin</span><span class='o'>)</span>
<span class='c'>#&gt; <span style='color: #949494;'># A tibble: 3 x 2</span></span>
<span class='c'>#&gt;   <span style='font-weight: bold;'>origin</span><span>     </span><span style='font-weight: bold;'>n</span></span>
<span class='c'>#&gt; <span style='color: #BCBCBC;'>*</span><span> </span><span style='color: #949494;font-style: italic;'>&lt;chr&gt;</span><span>  </span><span style='color: #949494;font-style: italic;'>&lt;int&gt;</span></span>
<span class='c'>#&gt; <span style='color: #BCBCBC;'>1</span><span> EWR     </span><span style='text-decoration: underline;'>4</span><span>043</span></span>
<span class='c'>#&gt; <span style='color: #BCBCBC;'>2</span><span> JFK     </span><span style='text-decoration: underline;'>3</span><span>661</span></span>
<span class='c'>#&gt; <span style='color: #BCBCBC;'>3</span><span> LGA     </span><span style='text-decoration: underline;'>3</span><span>523</span></span></pre>

Visualize relationships at any time:

<pre class='chroma'>
<span class='nv'>dm</span> <span class='o'>%&gt;%</span>
  <span class='nf'><a href='https://krlmlr.github.io/dm/reference/dm_draw.html'>dm_draw</a></span><span class='o'>(</span><span class='o'>)</span></pre>
<img src="man/figures/README-draw.svg" />

Simple joins:

<pre class='chroma'>
<span class='nv'>dm</span> <span class='o'>%&gt;%</span>
  <span class='nf'><a href='https://krlmlr.github.io/dm/reference/dm_flatten_to_tbl.html'>dm_flatten_to_tbl</a></span><span class='o'>(</span><span class='nv'>flights</span><span class='o'>)</span>
<span class='c'>#&gt; Renamed columns:</span>
<span class='c'>#&gt; * year -&gt; flights.year, planes.year</span>
<span class='c'>#&gt; * name -&gt; airlines.name, airports.name</span>
<span class='c'>#&gt; <span style='color: #949494;'># A tibble: 11,227 x 35</span></span>
<span class='c'>#&gt;    <span style='font-weight: bold;'>flights.year</span><span> </span><span style='font-weight: bold;'>month</span><span>   </span><span style='font-weight: bold;'>day</span><span> </span><span style='font-weight: bold;'>dep_time</span><span> </span><span style='font-weight: bold;'>sched_dep_time</span><span> </span><span style='font-weight: bold;'>dep_delay</span><span> </span><span style='font-weight: bold;'>arr_time</span></span>
<span class='c'>#&gt;           <span style='color: #949494;font-style: italic;'>&lt;int&gt;</span><span> </span><span style='color: #949494;font-style: italic;'>&lt;int&gt;</span><span> </span><span style='color: #949494;font-style: italic;'>&lt;int&gt;</span><span>    </span><span style='color: #949494;font-style: italic;'>&lt;int&gt;</span><span>          </span><span style='color: #949494;font-style: italic;'>&lt;int&gt;</span><span>     </span><span style='color: #949494;font-style: italic;'>&lt;dbl&gt;</span><span>    </span><span style='color: #949494;font-style: italic;'>&lt;int&gt;</span></span>
<span class='c'>#&gt; <span style='color: #BCBCBC;'> 1</span><span>         </span><span style='text-decoration: underline;'>2</span><span>013     1    10        3           </span><span style='text-decoration: underline;'>2</span><span>359         4      426</span></span>
<span class='c'>#&gt; <span style='color: #BCBCBC;'> 2</span><span>         </span><span style='text-decoration: underline;'>2</span><span>013     1    10       16           </span><span style='text-decoration: underline;'>2</span><span>359        17      447</span></span>
<span class='c'>#&gt; <span style='color: #BCBCBC;'> 3</span><span>         </span><span style='text-decoration: underline;'>2</span><span>013     1    10      450            500       -</span><span style='color: #BB0000;'>10</span><span>      634</span></span>
<span class='c'>#&gt; <span style='color: #BCBCBC;'> 4</span><span>         </span><span style='text-decoration: underline;'>2</span><span>013     1    10      520            525        -</span><span style='color: #BB0000;'>5</span><span>      813</span></span>
<span class='c'>#&gt; <span style='color: #BCBCBC;'> 5</span><span>         </span><span style='text-decoration: underline;'>2</span><span>013     1    10      530            530         0      824</span></span>
<span class='c'>#&gt; <span style='color: #BCBCBC;'> 6</span><span>         </span><span style='text-decoration: underline;'>2</span><span>013     1    10      531            540        -</span><span style='color: #BB0000;'>9</span><span>      832</span></span>
<span class='c'>#&gt; <span style='color: #BCBCBC;'> 7</span><span>         </span><span style='text-decoration: underline;'>2</span><span>013     1    10      535            540        -</span><span style='color: #BB0000;'>5</span><span>     </span><span style='text-decoration: underline;'>1</span><span>015</span></span>
<span class='c'>#&gt; <span style='color: #BCBCBC;'> 8</span><span>         </span><span style='text-decoration: underline;'>2</span><span>013     1    10      546            600       -</span><span style='color: #BB0000;'>14</span><span>      645</span></span>
<span class='c'>#&gt; <span style='color: #BCBCBC;'> 9</span><span>         </span><span style='text-decoration: underline;'>2</span><span>013     1    10      549            600       -</span><span style='color: #BB0000;'>11</span><span>      652</span></span>
<span class='c'>#&gt; <span style='color: #BCBCBC;'>10</span><span>         </span><span style='text-decoration: underline;'>2</span><span>013     1    10      550            600       -</span><span style='color: #BB0000;'>10</span><span>      649</span></span>
<span class='c'>#&gt; <span style='color: #949494;'># … with 11,217 more rows, and 28 more variables: </span><span style='color: #949494;font-weight: bold;'>sched_arr_time</span><span style='color: #949494;'> </span><span style='color: #949494;font-style: italic;'>&lt;int&gt;</span><span style='color: #949494;'>,</span></span>
<span class='c'>#&gt; <span style='color: #949494;'>#   </span><span style='color: #949494;font-weight: bold;'>arr_delay</span><span style='color: #949494;'> </span><span style='color: #949494;font-style: italic;'>&lt;dbl&gt;</span><span style='color: #949494;'>, </span><span style='color: #949494;font-weight: bold;'>carrier</span><span style='color: #949494;'> </span><span style='color: #949494;font-style: italic;'>&lt;chr&gt;</span><span style='color: #949494;'>, </span><span style='color: #949494;font-weight: bold;'>flight</span><span style='color: #949494;'> </span><span style='color: #949494;font-style: italic;'>&lt;int&gt;</span><span style='color: #949494;'>, </span><span style='color: #949494;font-weight: bold;'>tailnum</span><span style='color: #949494;'> </span><span style='color: #949494;font-style: italic;'>&lt;chr&gt;</span><span style='color: #949494;'>, </span><span style='color: #949494;font-weight: bold;'>origin</span><span style='color: #949494;'> </span><span style='color: #949494;font-style: italic;'>&lt;chr&gt;</span><span style='color: #949494;'>,</span></span>
<span class='c'>#&gt; <span style='color: #949494;'>#   </span><span style='color: #949494;font-weight: bold;'>dest</span><span style='color: #949494;'> </span><span style='color: #949494;font-style: italic;'>&lt;chr&gt;</span><span style='color: #949494;'>, </span><span style='color: #949494;font-weight: bold;'>air_time</span><span style='color: #949494;'> </span><span style='color: #949494;font-style: italic;'>&lt;dbl&gt;</span><span style='color: #949494;'>, </span><span style='color: #949494;font-weight: bold;'>distance</span><span style='color: #949494;'> </span><span style='color: #949494;font-style: italic;'>&lt;dbl&gt;</span><span style='color: #949494;'>, </span><span style='color: #949494;font-weight: bold;'>hour</span><span style='color: #949494;'> </span><span style='color: #949494;font-style: italic;'>&lt;dbl&gt;</span><span style='color: #949494;'>, </span><span style='color: #949494;font-weight: bold;'>minute</span><span style='color: #949494;'> </span><span style='color: #949494;font-style: italic;'>&lt;dbl&gt;</span><span style='color: #949494;'>,</span></span>
<span class='c'>#&gt; <span style='color: #949494;'>#   </span><span style='color: #949494;font-weight: bold;'>time_hour</span><span style='color: #949494;'> </span><span style='color: #949494;font-style: italic;'>&lt;dttm&gt;</span><span style='color: #949494;'>, </span><span style='color: #949494;font-weight: bold;'>airlines.name</span><span style='color: #949494;'> </span><span style='color: #949494;font-style: italic;'>&lt;chr&gt;</span><span style='color: #949494;'>, </span><span style='color: #949494;font-weight: bold;'>airports.name</span><span style='color: #949494;'> </span><span style='color: #949494;font-style: italic;'>&lt;chr&gt;</span><span style='color: #949494;'>, </span><span style='color: #949494;font-weight: bold;'>lat</span><span style='color: #949494;'> </span><span style='color: #949494;font-style: italic;'>&lt;dbl&gt;</span><span style='color: #949494;'>,</span></span>
<span class='c'>#&gt; <span style='color: #949494;'>#   </span><span style='color: #949494;font-weight: bold;'>lon</span><span style='color: #949494;'> </span><span style='color: #949494;font-style: italic;'>&lt;dbl&gt;</span><span style='color: #949494;'>, </span><span style='color: #949494;font-weight: bold;'>alt</span><span style='color: #949494;'> </span><span style='color: #949494;font-style: italic;'>&lt;dbl&gt;</span><span style='color: #949494;'>, </span><span style='color: #949494;font-weight: bold;'>tz</span><span style='color: #949494;'> </span><span style='color: #949494;font-style: italic;'>&lt;dbl&gt;</span><span style='color: #949494;'>, </span><span style='color: #949494;font-weight: bold;'>dst</span><span style='color: #949494;'> </span><span style='color: #949494;font-style: italic;'>&lt;chr&gt;</span><span style='color: #949494;'>, </span><span style='color: #949494;font-weight: bold;'>tzone</span><span style='color: #949494;'> </span><span style='color: #949494;font-style: italic;'>&lt;chr&gt;</span><span style='color: #949494;'>, </span><span style='color: #949494;font-weight: bold;'>planes.year</span><span style='color: #949494;'> </span><span style='color: #949494;font-style: italic;'>&lt;int&gt;</span><span style='color: #949494;'>,</span></span>
<span class='c'>#&gt; <span style='color: #949494;'>#   </span><span style='color: #949494;font-weight: bold;'>type</span><span style='color: #949494;'> </span><span style='color: #949494;font-style: italic;'>&lt;chr&gt;</span><span style='color: #949494;'>, </span><span style='color: #949494;font-weight: bold;'>manufacturer</span><span style='color: #949494;'> </span><span style='color: #949494;font-style: italic;'>&lt;chr&gt;</span><span style='color: #949494;'>, </span><span style='color: #949494;font-weight: bold;'>model</span><span style='color: #949494;'> </span><span style='color: #949494;font-style: italic;'>&lt;chr&gt;</span><span style='color: #949494;'>, </span><span style='color: #949494;font-weight: bold;'>engines</span><span style='color: #949494;'> </span><span style='color: #949494;font-style: italic;'>&lt;int&gt;</span><span style='color: #949494;'>, </span><span style='color: #949494;font-weight: bold;'>seats</span><span style='color: #949494;'> </span><span style='color: #949494;font-style: italic;'>&lt;int&gt;</span><span style='color: #949494;'>,</span></span>
<span class='c'>#&gt; <span style='color: #949494;'>#   </span><span style='color: #949494;font-weight: bold;'>speed</span><span style='color: #949494;'> </span><span style='color: #949494;font-style: italic;'>&lt;int&gt;</span><span style='color: #949494;'>, </span><span style='color: #949494;font-weight: bold;'>engine</span><span style='color: #949494;'> </span><span style='color: #949494;font-style: italic;'>&lt;chr&gt;</span></span></pre>

Check consistency:

<pre class='chroma'>
<span class='nv'>dm</span> <span class='o'>%&gt;%</span>
  <span class='nf'><a href='https://krlmlr.github.io/dm/reference/dm_examine_constraints.html'>dm_examine_constraints</a></span><span class='o'>(</span><span class='o'>)</span>
<span class='c'>#&gt; <span style='color: #BBBB00;'>!</span><span> Unsatisfied constraints:</span></span>
<span class='c'>#&gt; <span style='color: #BB0000;'>●</span><span> Table `flights`: foreign key tailnum into table `planes`: 1640 entries (14.6%) of `flights$tailnum` not in `planes$tailnum`: N722MQ (27), N725MQ (20), N520MQ (19), N723MQ (19), N508MQ (16), …</span></span></pre>

Learn more in the [Getting started](https://krlmlr.github.io/dm/articles/dm.html) article.

## Getting help

If you encounter a clear bug, please file an issue with a minimal reproducible example on [GitHub](https://github.com/krlmlr/dm/issues). For questions and other discussion, please use [community.rstudio.com](https://community.rstudio.com/).

------------------------------------------------------------------------

License: MIT © cynkra GmbH.

Funded by:

[![energie360°](man/figures/energie-72.png)](https://www.energie360.ch/de/) <span style="padding-right:50px"> </span> [![cynkra](man/figures/cynkra-72.png)](https://www.cynkra.com/)

------------------------------------------------------------------------

Please note that the ‘dm’ project is released with a [Contributor Code of Conduct](https://krlmlr.github.io/dm/CODE_OF_CONDUCT.html). By contributing to this project, you agree to abide by its terms.
