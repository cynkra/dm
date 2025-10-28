# Draw a diagram of the data model

`dm_draw()` draws a diagram, a visual representation of the data model.

## Usage

``` r
dm_draw(
  dm,
  rankdir = "LR",
  ...,
  col_attr = NULL,
  view_type = c("keys_only", "all", "title_only"),
  columnArrows = TRUE,
  graph_attrs = "",
  node_attrs = "",
  edge_attrs = "",
  focus = NULL,
  graph_name = "Data Model",
  column_types = NULL,
  backend = "DiagrammeR",
  font_size = NULL
)
```

## Arguments

- dm:

  A [`dm`](https://dm.cynkra.com/dev/reference/dm.md) object.

- rankdir:

  Graph attribute for direction (e.g., 'BT' = bottom –\> top).

- ...:

  These dots are for future extensions and must be empty.

- col_attr:

  Deprecated, use `colummn_types` instead.

- view_type:

  Can be "keys_only" (default), "all" or "title_only". It defines the
  level of details for rendering tables (only primary and foreign keys,
  all columns, or no columns).

- columnArrows:

  Edges from columns to columns (default: `TRUE`).

- graph_attrs:

  Additional graph attributes.

- node_attrs:

  Additional node attributes.

- edge_attrs:

  Additional edge attributes.

- focus:

  A list of parameters for rendering (table filter).

- graph_name:

  The name of the graph.

- column_types:

  Set to `TRUE` to show column types.

- backend:

  Currently, only the default `"DiagrammeR"` is accepted. Pass this
  value explicitly if your code not only uses this function to display a
  data model but relies on the type of the return value.

- font_size:

  **\[experimental\]**

  Font size for:

  - `header`, defaults to `16`

  - `column`, defaults to `16`

  - `table_description`, defaults to `8`

  Can be set as a named integer vector, e.g.
  `c(table_headers = 18L, table_description = 6L)`.

## Value

An object with a [`print()`](https://rdrr.io/r/base/print.html) method,
which, when printed, produces the output seen in the viewer as a side
effect. Currently, this is an object of class `grViz` (see also
[`DiagrammeR::grViz()`](https://rich-iannone.github.io/DiagrammeR/reference/grViz.html)),
but this is subject to change.

## Details

Currently, dm uses DiagrammeR to draw diagrams. Use
[`DiagrammeRsvg::export_svg()`](https://rdrr.io/pkg/DiagrammeRsvg/man/export_svg.html)
to convert the diagram to an SVG file.

The backend for drawing the diagrams might change in the future. If you
rely on DiagrammeR, pass an explicit value for the `backend` argument.

## See also

[`dm_set_colors()`](https://dm.cynkra.com/dev/reference/dm_set_colors.md)
for defining the table colors.

[`dm_set_table_description()`](https://dm.cynkra.com/dev/reference/dm_set_table_description.md)
for adding details to one or more tables in the diagram

## Examples

``` r
dm_nycflights13() %>%
  dm_draw()
%0


airlines
airlinescarrierairports
airportsfaaflights
flightscarriertailnumoriginorigin, time_hourflights:carrier->airlines:carrier
flights:origin->airports:faa
planes
planestailnumflights:tailnum->planes:tailnum
weather
weatherorigin, time_hourflights:origin, time_hour->weather:origin, time_hour

dm_nycflights13(cycle = TRUE) %>%
  dm_draw(view_type = "title_only")
%0


airlines
airlinesairports
airportsflights
flightsflights:carrier->airlines:carrier
flights:origin->airports:faa
flights:dest->airports:faa
planes
planesflights:tailnum->planes:tailnum
weather
weatherflights:origin, time_hour->weather:origin, time_hour

head(dm_get_available_colors())
#> [1] "default"       "white"         "aliceblue"     "antiquewhite" 
#> [5] "antiquewhite1" "antiquewhite2"
length(dm_get_available_colors())
#> [1] 658

dm_nycflights13() %>%
  dm_get_colors()
#>  #ED7D31FF  #ED7D31FF  #5B9BD5FF  #ED7D31FF  #70AD47FF 
#> "airlines" "airports"  "flights"   "planes"  "weather" 
```
