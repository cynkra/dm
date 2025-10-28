# tidyr table manipulation methods for zoomed dm objects

Use these methods without the '.dm_zoomed' suffix (see examples).

## Usage

``` r
# S3 method for class 'dm_zoomed'
unite(data, col, ..., sep = "_", remove = TRUE, na.rm = FALSE)

# S3 method for class 'dm_keyed_tbl'
unite(data, ...)

# S3 method for class 'dm_zoomed'
separate(data, col, into, sep = "[^[:alnum:]]+", remove = TRUE, ...)

# S3 method for class 'dm_keyed_tbl'
separate(data, ...)
```

## Arguments

- data:

  object of class `dm_zoomed`

- col:

  For `unite.dm_zoomed`: see
  [`tidyr::unite()`](https://tidyr.tidyverse.org/reference/unite.html)

  For `separate.dm_zoomed`: see
  [`tidyr::separate()`](https://tidyr.tidyverse.org/reference/separate.html)

- ...:

  For `unite.dm_zoomed`: see
  [`tidyr::unite()`](https://tidyr.tidyverse.org/reference/unite.html)

  For `separate.dm_zoomed`: see
  [`tidyr::separate()`](https://tidyr.tidyverse.org/reference/separate.html)

- sep:

  For `unite.dm_zoomed`: see
  [`tidyr::unite()`](https://tidyr.tidyverse.org/reference/unite.html)

  For `separate.dm_zoomed`: see
  [`tidyr::separate()`](https://tidyr.tidyverse.org/reference/separate.html)

- remove:

  For `unite.dm_zoomed`: see
  [`tidyr::unite()`](https://tidyr.tidyverse.org/reference/unite.html)

  For `separate.dm_zoomed`: see
  [`tidyr::separate()`](https://tidyr.tidyverse.org/reference/separate.html)

- na.rm:

  see
  [`tidyr::unite()`](https://tidyr.tidyverse.org/reference/unite.html)

- into:

  see
  [`tidyr::separate()`](https://tidyr.tidyverse.org/reference/separate.html)

## Examples

``` r
zoom_united <- dm_nycflights13() %>%
  dm_zoom_to(flights) %>%
  select(year, month, day) %>%
  unite("month_day", month, day)
zoom_united
#> # Zoomed table: flights
#> # A tibble:     1,761 × 2
#>     year month_day
#>    <int> <chr>    
#>  1  2013 1_10     
#>  2  2013 1_10     
#>  3  2013 1_10     
#>  4  2013 1_10     
#>  5  2013 1_10     
#>  6  2013 1_10     
#>  7  2013 1_10     
#>  8  2013 1_10     
#>  9  2013 1_10     
#> 10  2013 1_10     
#> # ℹ 1,751 more rows
zoom_united %>%
  separate(month_day, c("month", "day"))
#> # Zoomed table: flights
#> # A tibble:     1,761 × 3
#>     year month day  
#>    <int> <chr> <chr>
#>  1  2013 1     10   
#>  2  2013 1     10   
#>  3  2013 1     10   
#>  4  2013 1     10   
#>  5  2013 1     10   
#>  6  2013 1     10   
#>  7  2013 1     10   
#>  8  2013 1     10   
#>  9  2013 1     10   
#> 10  2013 1     10   
#> # ℹ 1,751 more rows
```
