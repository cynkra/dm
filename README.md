<!-- README.md is generated from README.Rmd. Please edit that file -->

# [dm](https://dm.cynkra.com/)

<!-- badges: start -->

[![Lifecycle: stable](https://img.shields.io/badge/lifecycle-stable-brightgreen.svg)](https://lifecycle.r-lib.org/articles/stages.html) [![R build status](https://github.com/cynkra/dm/workflows/rcc/badge.svg)](https://github.com/cynkra/dm/actions) [![Codecov test coverage](https://codecov.io/gh/cynkra/dm/branch/main/graph/badge.svg)](https://app.codecov.io/gh/cynkra/dm?branch=main) [![CRAN status](https://www.r-pkg.org/badges/version/dm)](https://CRAN.R-project.org/package=dm) [![Launch rstudio.cloud](https://img.shields.io/badge/rstudio-cloud-blue.svg)](https://rstudio.cloud/project/523482)

<!-- badges: end -->

> Are you using multiple data frames or database tables in R? Organize them with dm.
>
> - Use it for data analysis today.
> - Build data models tomorrow.
> - Deploy the data models to your organization’s Relational Database Management System (RDBMS) the day after.

## Overview

dm bridges the gap in the data pipeline between individual data frames and relational databases. It’s a grammar of joined tables that provides a consistent set of verbs for consuming, creating, and deploying relational data models. For individual researchers, it broadens the scope of datasets they can work with and how they work with them. For organizations, it enables teams to quickly and efficiently create and share large, complex datasets.

dm objects encapsulate relational data models constructed from local data frames or lazy tables connected to an RDBMS. dm objects support the full suite of dplyr data manipulation verbs along with additional methods for constructing and verifying relational data models, including key selection, key creation, and rigorous constraint checking. Once a data model is complete, dm provides methods for deploying it to an RDBMS. This allows it to scale from datasets that fit in memory to databases with billions of rows.

## Features

dm makes it easy to bring an existing relational data model into your R session. As the dm object behaves like a named list of tables it requires little change to incorporate it within existing workflows. The dm interface and behavior is modeled after dplyr, so you may already be familiar with many of its verbs. dm also offers:

- visualization to help you understand relationships between entities represented by the tables
- simpler joins that “know” how tables are related, including a “flatten” operation that automatically follows keys and performs column name disambiguation
- consistency and constraint checks to help you understand (and fix) the limitations of your data

That’s just the tip of the iceberg. See [Getting started](https://dm.cynkra.com/articles/dm.html) to hit the ground running and explore all the features.

## Installation

The latest stable version of the {dm} package can be obtained from [CRAN](https://CRAN.R-project.org/package=dm) with the command

<pre class='chroma'>
<span><span class='nf'><a href='https://rdrr.io/r/utils/install.packages.html'>install.packages</a></span><span class='o'>(</span><span class='s'>"dm"</span><span class='o'>)</span></span></pre>

The latest development version of {dm} can be installed from R-universe:

<pre class='chroma'>
<span><span class='c'># Enable repository from cynkra</span></span>
<span><span class='nf'><a href='https://rdrr.io/r/base/options.html'>options</a></span><span class='o'>(</span></span>
<span>  repos <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span></span>
<span>    cynkra <span class='o'>=</span> <span class='s'>"https://cynkra.r-universe.dev"</span>,</span>
<span>    CRAN <span class='o'>=</span> <span class='s'>"https://cloud.r-project.org"</span></span>
<span>  <span class='o'>)</span></span>
<span><span class='o'>)</span></span>
<span><span class='c'># Download and install dm in R</span></span>
<span><span class='nf'><a href='https://rdrr.io/r/utils/install.packages.html'>install.packages</a></span><span class='o'>(</span><span class='s'>'dm'</span><span class='o'>)</span></span></pre>

or from GitHub:

<pre class='chroma'>
<span><span class='c'># install.packages("devtools")</span></span>
<span><span class='nf'>devtools</span><span class='nf'>::</span><span class='nf'><a href='https://remotes.r-lib.org/reference/install_github.html'>install_github</a></span><span class='o'>(</span><span class='s'>"cynkra/dm"</span><span class='o'>)</span></span></pre>

## Usage

Create a dm object (see [Getting started](https://dm.cynkra.com/articles/dm.html) for details).

<pre class='chroma'>
<span><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://dm.cynkra.com/'>dm</a></span><span class='o'>)</span></span>
<span><span class='nv'>dm</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://dm.cynkra.com/reference/dm_nycflights13.html'>dm_nycflights13</a></span><span class='o'>(</span>table_description <span class='o'>=</span> <span class='kc'>TRUE</span><span class='o'>)</span></span>
<span><span class='nv'>dm</span></span>
<span><span class='c'>#&gt; <span style='color: #FFAFFF;'>──</span> <span style='color: #FFAFFF;'>Metadata</span> <span style='color: #FFAFFF;'>────────────────────────────────────────────────────────────────────</span></span></span>
<span><span class='c'>#&gt; Tables: `airlines`, `airports`, `flights`, `planes`, `weather`</span></span>
<span><span class='c'>#&gt; Columns: 53</span></span>
<span><span class='c'>#&gt; Primary keys: 4</span></span>
<span><span class='c'>#&gt; Foreign keys: 4</span></span></pre>

dm is a named list of tables:

<pre class='chroma'>
<span><span class='nf'><a href='https://rdrr.io/r/base/names.html'>names</a></span><span class='o'>(</span><span class='nv'>dm</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; [1] "airlines" "airports" "flights"  "planes"   "weather"</span></span>
<span><span class='nf'><a href='https://rdrr.io/r/base/nrow.html'>nrow</a></span><span class='o'>(</span><span class='nv'>dm</span><span class='o'>$</span><span class='nv'>airports</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; [1] 86</span></span>
<span><span class='nv'>dm</span><span class='o'>$</span><span class='nv'>flights</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span></span>
<span>  <span class='nf'>count</span><span class='o'>(</span><span class='nv'>origin</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #949494;'># A tibble: 3 × 2</span></span></span>
<span><span class='c'>#&gt;   <span style='font-weight: bold;'>origin</span>     <span style='font-weight: bold;'>n</span></span></span>
<span><span class='c'>#&gt;   <span style='color: #949494; font-style: italic;'>&lt;chr&gt;</span>  <span style='color: #949494; font-style: italic;'>&lt;int&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #BCBCBC;'>1</span> EWR      641</span></span>
<span><span class='c'>#&gt; <span style='color: #BCBCBC;'>2</span> JFK      602</span></span>
<span><span class='c'>#&gt; <span style='color: #BCBCBC;'>3</span> LGA      518</span></span></pre>

Visualize relationships at any time:

<pre class='chroma'>
<span><span class='nv'>dm</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span></span>
<span>  <span class='nf'><a href='https://dm.cynkra.com/reference/dm_draw.html'>dm_draw</a></span><span class='o'>(</span><span class='o'>)</span></span></pre>
<img src="man/figures/README-draw.svg" />

Simple joins:

<pre class='chroma'>
<span><span class='nv'>dm</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span></span>
<span>  <span class='nf'><a href='https://dm.cynkra.com/reference/dm_flatten_to_tbl.html'>dm_flatten_to_tbl</a></span><span class='o'>(</span><span class='nv'>flights</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; Renaming ambiguous columns: %&gt;%</span></span>
<span><span class='c'>#&gt;   dm_rename(flights, year.flights = year) %&gt;%</span></span>
<span><span class='c'>#&gt;   dm_rename(flights, month.flights = month) %&gt;%</span></span>
<span><span class='c'>#&gt;   dm_rename(flights, day.flights = day) %&gt;%</span></span>
<span><span class='c'>#&gt;   dm_rename(flights, hour.flights = hour) %&gt;%</span></span>
<span><span class='c'>#&gt;   dm_rename(airlines, name.airlines = name) %&gt;%</span></span>
<span><span class='c'>#&gt;   dm_rename(airports, name.airports = name) %&gt;%</span></span>
<span><span class='c'>#&gt;   dm_rename(planes, year.planes = year) %&gt;%</span></span>
<span><span class='c'>#&gt;   dm_rename(weather, year.weather = year) %&gt;%</span></span>
<span><span class='c'>#&gt;   dm_rename(weather, month.weather = month) %&gt;%</span></span>
<span><span class='c'>#&gt;   dm_rename(weather, day.weather = day) %&gt;%</span></span>
<span><span class='c'>#&gt;   dm_rename(weather, hour.weather = hour)</span></span>
<span><span class='c'>#&gt; <span style='color: #949494;'># A tibble: 1,761 × 48</span></span></span>
<span><span class='c'>#&gt;    <span style='font-weight: bold;'>year.flights</span> <span style='font-weight: bold;'>month.…¹</span> <span style='font-weight: bold;'>day.f…²</span> <span style='font-weight: bold;'>dep_t…³</span> <span style='font-weight: bold;'>sched…⁴</span> <span style='font-weight: bold;'>dep_d…⁵</span> <span style='font-weight: bold;'>arr_t…⁶</span> <span style='font-weight: bold;'>sched…⁷</span> <span style='font-weight: bold;'>arr_d…⁸</span></span></span>
<span><span class='c'>#&gt;           <span style='color: #949494; font-style: italic;'>&lt;int&gt;</span>    <span style='color: #949494; font-style: italic;'>&lt;int&gt;</span>   <span style='color: #949494; font-style: italic;'>&lt;int&gt;</span>   <span style='color: #949494; font-style: italic;'>&lt;int&gt;</span>   <span style='color: #949494; font-style: italic;'>&lt;int&gt;</span>   <span style='color: #949494; font-style: italic;'>&lt;dbl&gt;</span>   <span style='color: #949494; font-style: italic;'>&lt;int&gt;</span>   <span style='color: #949494; font-style: italic;'>&lt;int&gt;</span>   <span style='color: #949494; font-style: italic;'>&lt;dbl&gt;</span></span></span>
<span><span class='c'>#&gt; <span style='color: #BCBCBC;'> 1</span>         <span style='text-decoration: underline;'>2</span>013        1      10       3    <span style='text-decoration: underline;'>2</span>359       4     426     437     -<span style='color: #BB0000;'>11</span></span></span>
<span><span class='c'>#&gt; <span style='color: #BCBCBC;'> 2</span>         <span style='text-decoration: underline;'>2</span>013        1      10      16    <span style='text-decoration: underline;'>2</span>359      17     447     444       3</span></span>
<span><span class='c'>#&gt; <span style='color: #BCBCBC;'> 3</span>         <span style='text-decoration: underline;'>2</span>013        1      10     450     500     -<span style='color: #BB0000;'>10</span>     634     648     -<span style='color: #BB0000;'>14</span></span></span>
<span><span class='c'>#&gt; <span style='color: #BCBCBC;'> 4</span>         <span style='text-decoration: underline;'>2</span>013        1      10     520     525      -<span style='color: #BB0000;'>5</span>     813     820      -<span style='color: #BB0000;'>7</span></span></span>
<span><span class='c'>#&gt; <span style='color: #BCBCBC;'> 5</span>         <span style='text-decoration: underline;'>2</span>013        1      10     530     530       0     824     829      -<span style='color: #BB0000;'>5</span></span></span>
<span><span class='c'>#&gt; <span style='color: #BCBCBC;'> 6</span>         <span style='text-decoration: underline;'>2</span>013        1      10     531     540      -<span style='color: #BB0000;'>9</span>     832     850     -<span style='color: #BB0000;'>18</span></span></span>
<span><span class='c'>#&gt; <span style='color: #BCBCBC;'> 7</span>         <span style='text-decoration: underline;'>2</span>013        1      10     535     540      -<span style='color: #BB0000;'>5</span>    <span style='text-decoration: underline;'>1</span>015    <span style='text-decoration: underline;'>1</span>017      -<span style='color: #BB0000;'>2</span></span></span>
<span><span class='c'>#&gt; <span style='color: #BCBCBC;'> 8</span>         <span style='text-decoration: underline;'>2</span>013        1      10     546     600     -<span style='color: #BB0000;'>14</span>     645     709     -<span style='color: #BB0000;'>24</span></span></span>
<span><span class='c'>#&gt; <span style='color: #BCBCBC;'> 9</span>         <span style='text-decoration: underline;'>2</span>013        1      10     549     600     -<span style='color: #BB0000;'>11</span>     652     724     -<span style='color: #BB0000;'>32</span></span></span>
<span><span class='c'>#&gt; <span style='color: #BCBCBC;'>10</span>         <span style='text-decoration: underline;'>2</span>013        1      10     550     600     -<span style='color: #BB0000;'>10</span>     649     703     -<span style='color: #BB0000;'>14</span></span></span>
<span><span class='c'>#&gt; <span style='color: #949494;'># ℹ 1,751 more rows</span></span></span>
<span><span class='c'>#&gt; <span style='color: #949494;'># ℹ abbreviated names: ¹​month.flights, ²​day.flights, ³​dep_time,</span></span></span>
<span><span class='c'>#&gt; <span style='color: #949494;'>#   ⁴​sched_dep_time, ⁵​dep_delay, ⁶​arr_time, ⁷​sched_arr_time, ⁸​arr_delay</span></span></span>
<span><span class='c'>#&gt; <span style='color: #949494;'># ℹ 39 more variables: </span><span style='color: #949494; font-weight: bold;'>carrier</span><span style='color: #949494;'> &lt;chr&gt;, </span><span style='color: #949494; font-weight: bold;'>flight</span><span style='color: #949494;'> &lt;int&gt;, </span><span style='color: #949494; font-weight: bold;'>tailnum</span><span style='color: #949494;'> &lt;chr&gt;,</span></span></span>
<span><span class='c'>#&gt; <span style='color: #949494;'>#   </span><span style='color: #949494; font-weight: bold;'>origin</span><span style='color: #949494;'> &lt;chr&gt;, </span><span style='color: #949494; font-weight: bold;'>dest</span><span style='color: #949494;'> &lt;chr&gt;, </span><span style='color: #949494; font-weight: bold;'>air_time</span><span style='color: #949494;'> &lt;dbl&gt;, </span><span style='color: #949494; font-weight: bold;'>distance</span><span style='color: #949494;'> &lt;dbl&gt;,</span></span></span>
<span><span class='c'>#&gt; <span style='color: #949494;'>#   </span><span style='color: #949494; font-weight: bold;'>hour.flights</span><span style='color: #949494;'> &lt;dbl&gt;, </span><span style='color: #949494; font-weight: bold;'>minute</span><span style='color: #949494;'> &lt;dbl&gt;, </span><span style='color: #949494; font-weight: bold;'>time_hour</span><span style='color: #949494;'> &lt;dttm&gt;, </span><span style='color: #949494; font-weight: bold;'>name.airlines</span><span style='color: #949494;'> &lt;chr&gt;,</span></span></span>
<span><span class='c'>#&gt; <span style='color: #949494;'>#   </span><span style='color: #949494; font-weight: bold;'>name.airports</span><span style='color: #949494;'> &lt;chr&gt;, </span><span style='color: #949494; font-weight: bold;'>lat</span><span style='color: #949494;'> &lt;dbl&gt;, </span><span style='color: #949494; font-weight: bold;'>lon</span><span style='color: #949494;'> &lt;dbl&gt;, </span><span style='color: #949494; font-weight: bold;'>alt</span><span style='color: #949494;'> &lt;dbl&gt;, </span><span style='color: #949494; font-weight: bold;'>tz</span><span style='color: #949494;'> &lt;dbl&gt;, </span><span style='color: #949494; font-weight: bold;'>dst</span><span style='color: #949494;'> &lt;chr&gt;,</span></span></span>
<span><span class='c'>#&gt; <span style='color: #949494;'>#   </span><span style='color: #949494; font-weight: bold;'>tzone</span><span style='color: #949494;'> &lt;chr&gt;, </span><span style='color: #949494; font-weight: bold;'>year.planes</span><span style='color: #949494;'> &lt;int&gt;, </span><span style='color: #949494; font-weight: bold;'>type</span><span style='color: #949494;'> &lt;chr&gt;, </span><span style='color: #949494; font-weight: bold;'>manufacturer</span><span style='color: #949494;'> &lt;chr&gt;,</span></span></span>
<span><span class='c'>#&gt; <span style='color: #949494;'>#   </span><span style='color: #949494; font-weight: bold;'>model</span><span style='color: #949494;'> &lt;chr&gt;, </span><span style='color: #949494; font-weight: bold;'>engines</span><span style='color: #949494;'> &lt;int&gt;, </span><span style='color: #949494; font-weight: bold;'>seats</span><span style='color: #949494;'> &lt;int&gt;, </span><span style='color: #949494; font-weight: bold;'>speed</span><span style='color: #949494;'> &lt;int&gt;, </span><span style='color: #949494; font-weight: bold;'>engine</span><span style='color: #949494;'> &lt;chr&gt;,</span></span></span>
<span><span class='c'>#&gt; <span style='color: #949494;'>#   </span><span style='color: #949494; font-weight: bold;'>year.weather</span><span style='color: #949494;'> &lt;int&gt;, </span><span style='color: #949494; font-weight: bold;'>month.weather</span><span style='color: #949494;'> &lt;int&gt;, </span><span style='color: #949494; font-weight: bold;'>day.weather</span><span style='color: #949494;'> &lt;int&gt;,</span></span></span>
<span><span class='c'>#&gt; <span style='color: #949494;'>#   </span><span style='color: #949494; font-weight: bold;'>hour.weather</span><span style='color: #949494;'> &lt;int&gt;, </span><span style='color: #949494; font-weight: bold;'>temp</span><span style='color: #949494;'> &lt;dbl&gt;, </span><span style='color: #949494; font-weight: bold;'>dewp</span><span style='color: #949494;'> &lt;dbl&gt;, </span><span style='color: #949494; font-weight: bold;'>humid</span><span style='color: #949494;'> &lt;dbl&gt;, </span><span style='color: #949494; font-weight: bold;'>wind_dir</span><span style='color: #949494;'> &lt;dbl&gt;,</span></span></span>
<span><span class='c'>#&gt; <span style='color: #949494;'>#   </span><span style='color: #949494; font-weight: bold;'>wind_speed</span><span style='color: #949494;'> &lt;dbl&gt;, </span><span style='color: #949494; font-weight: bold;'>wind_gust</span><span style='color: #949494;'> &lt;dbl&gt;, </span><span style='color: #949494; font-weight: bold;'>precip</span><span style='color: #949494;'> &lt;dbl&gt;, </span><span style='color: #949494; font-weight: bold;'>pressure</span><span style='color: #949494;'> &lt;dbl&gt;, …</span></span></span></pre>

Check consistency:

<pre class='chroma'>
<span><span class='nv'>dm</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span></span>
<span>  <span class='nf'><a href='https://dm.cynkra.com/reference/dm_examine_constraints.html'>dm_examine_constraints</a></span><span class='o'>(</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #BBBB00;'>!</span> Unsatisfied constraints:</span></span>
<span><span class='c'>#&gt; <span style='color: #BB0000;'>•</span> Table `flights`: foreign key `tailnum` into table `planes`: values of `flights$tailnum` not in `planes$tailnum`: N725MQ (6), N537MQ (5), N722MQ (5), N730MQ (5), N736MQ (5), …</span></span></pre>

Learn more in the [Getting started](https://dm.cynkra.com/articles/dm.html) article.

## Getting help

If you encounter a clear bug, please file an issue with a minimal reproducible example on [GitHub](https://github.com/cynkra/dm/issues). For questions and other discussion, please use [community.rstudio.com](https://community.rstudio.com/).

------------------------------------------------------------------------

License: MIT © cynkra GmbH.

Funded by:

[![energie360°](man/figures/energie-72.png)](https://www.energie360.ch/de/) <span style="padding-right:50px"> </span> [![cynkra](man/figures/cynkra-72.png)](https://www.cynkra.com/)

------------------------------------------------------------------------

Please note that the ‘dm’ project is released with a [Contributor Code of Conduct](https://dm.cynkra.com/CODE_OF_CONDUCT.html). By contributing to this project, you agree to abide by its terms.
