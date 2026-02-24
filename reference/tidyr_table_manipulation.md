# tidyr table manipulation methods for zoomed dm objects

Use these methods without the '.dm_zoomed' suffix (see examples).

## Usage

``` r
# S3 method for class 'dm_zoomed'
unite(data, col, ..., sep = "_", remove = TRUE, na.rm = FALSE)

# S3 method for class 'dm_keyed_tbl'
unite(data, col, ..., sep = "_", remove = TRUE, na.rm = FALSE)

# S3 method for class 'dm_zoomed'
separate(
  data,
  col,
  into,
  sep = "[^[:alnum:]]+",
  remove = TRUE,
  convert = FALSE,
  extra = "warn",
  fill = "warn",
  ...
)

# S3 method for class 'dm_keyed_tbl'
separate(
  data,
  col,
  into,
  sep = "[^[:alnum:]]+",
  remove = TRUE,
  convert = FALSE,
  extra = "warn",
  fill = "warn",
  ...
)
```

## Arguments

- data:

  object of class `dm_zoomed`

- col:

  The name of the new column, as a string or symbol.

  This argument is passed by expression and supports
  [quasiquotation](https://rlang.r-lib.org/reference/topic-inject.html)
  (you can unquote strings and symbols). The name is captured from the
  expression with
  [`rlang::ensym()`](https://rlang.r-lib.org/reference/defusing-advanced.html)
  (note that this kind of interface where symbols do not represent
  actual objects is now discouraged in the tidyverse; we support it here
  for backward compatibility).

- ...:

  For `unite.dm_zoomed`: see
  [`tidyr::unite()`](https://tidyr.tidyverse.org/reference/unite.html)

  For `separate.dm_zoomed`: see
  [`tidyr::separate()`](https://tidyr.tidyverse.org/reference/separate.html)

- sep:

  Separator to use between values.

- remove:

  If `TRUE`, remove input columns from output data frame.

- na.rm:

  If `TRUE`, missing values will be removed prior to uniting each value.

- into:

  Names of new variables to create as character vector. Use `NA` to omit
  the variable in the output.

- convert:

  If `TRUE`, will run
  [`type.convert()`](https://rdrr.io/r/utils/type.convert.html) with
  `as.is = TRUE` on new columns. This is useful if the component columns
  are integer, numeric or logical.

  NB: this will cause string `"NA"`s to be converted to `NA`s.

- extra:

  If `sep` is a character vector, this controls what happens when there
  are too many pieces. There are three valid options:

  - `"warn"` (the default): emit a warning and drop extra values.

  - `"drop"`: drop any extra values without a warning.

  - `"merge"`: only splits at most `length(into)` times

- fill:

  If `sep` is a character vector, this controls what happens when there
  are not enough pieces. There are three valid options:

  - `"warn"` (the default): emit a warning and fill from the right

  - `"right"`: fill with missing values on the right

  - `"left"`: fill with missing values on the left

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
