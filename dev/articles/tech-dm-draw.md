# Visualizing dm objects

Once you have all your primary keys set and all foreign key relations
defined, a graphical representation of your data model offers a
condensed view of the tables and the relationships between the tables.
The following functions can be used to visualize the `dm`
object:[¹](#fn1)

1.  [`dm_draw()`](https://dm.cynkra.com/dev/reference/dm_draw.md)
2.  [`dm_set_colors()`](https://dm.cynkra.com/dev/reference/dm_set_colors.md)
3.  [`dm_get_colors()`](https://dm.cynkra.com/dev/reference/dm_set_colors.md)
4.  [`dm_get_available_colors()`](https://dm.cynkra.com/dev/reference/dm_set_colors.md)

We use the prepared example `dm` object `dm_nycflights13(cycle = TRUE)`:

``` r
library(dm)
library(dplyr)
flights_dm_w_many_keys <- dm_nycflights13(cycle = TRUE, color = FALSE)
flights_dm_w_many_keys
```

``` fansi
#> ── Metadata ───────────────────────────────────────────────────────────────
#> Tables: `airlines`, `airports`, `flights`, `planes`, `weather`
#> Columns: 53
#> Primary keys: 4
#> Foreign keys: 5
```

The schema is drawn with
[`dm_draw()`](https://dm.cynkra.com/dev/reference/dm_draw.md).

``` r
dm_draw(flights_dm_w_many_keys)
```

![](data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMjUwcHQiIGhlaWdodD0iMjMwcHQiIHZpZXdib3g9IjAuMDAgMC4wMCAyNTAuMDAgMjMwLjAwIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHhtbG5zOnhsaW5rPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5L3hsaW5rIj48ZyBpZD0iZ3JhcGgwIiBjbGFzcz0iZ3JhcGgiIHRyYW5zZm9ybT0ic2NhbGUoMSAxKSByb3RhdGUoMCkgdHJhbnNsYXRlKDQgMjI2KSI+PHRpdGxlPiUwPC90aXRsZT4KPGcgaWQ9ImFfZ3JhcGgwIj48YSB4bGluazp0aXRsZT0iRGF0YSBNb2RlbCI+Cjxwb2x5Z29uIGZpbGw9IiNmZmZmZmYiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iLTQsNCAtNCwtMjI2IDI0NiwtMjI2IDI0Niw0IC00LDQiPjwvcG9seWdvbj48L2E+CjwvZz48IS0tIGFpcmxpbmVzIC0tPjxnIGlkPSJhaXJsaW5lcyIgY2xhc3M9Im5vZGUiPjx0aXRsZT5haXJsaW5lczwvdGl0bGU+Cjxwb2x5Z29uIGZpbGw9IiNlZmViZGQiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iMTY4LjUsLTIwMSAxNjguNSwtMjIxIDIxMy41LC0yMjEgMjEzLjUsLTIwMSAxNjguNSwtMjAxIj48L3BvbHlnb24+PHRleHQgdGV4dC1hbmNob3I9InN0YXJ0IiB4PSIxNzAuMzk2OSIgeT0iLTIwNi40IiBmb250LWZhbWlseT0iVGltZXMsc2VyaWYiIGZvbnQtc2l6ZT0iMTQuMDAiIGZpbGw9IiMwMDAwMDAiPmFpcmxpbmVzPC90ZXh0Pjxwb2x5Z29uIGZpbGw9IiNmZmZmZmYiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iMTY4LjUsLTE4MSAxNjguNSwtMjAxIDIxMy41LC0yMDEgMjEzLjUsLTE4MSAxNjguNSwtMTgxIj48L3BvbHlnb24+PHRleHQgdGV4dC1hbmNob3I9InN0YXJ0IiB4PSIxNzAuNSIgeT0iLTE4Ny40IiBmb250LWZhbWlseT0iVGltZXMsc2VyaWYiIHRleHQtZGVjb3JhdGlvbj0idW5kZXJsaW5lIiBmb250LXNpemU9IjE0LjAwIiBmaWxsPSIjNDQ0NDQ0Ij5jYXJyaWVyPC90ZXh0Pjxwb2x5Z29uIGZpbGw9Im5vbmUiIHN0cm9rZT0iIzU1NTU1NSIgcG9pbnRzPSIxNjcsLTE4MCAxNjcsLTIyMiAyMTQsLTIyMiAyMTQsLTE4MCAxNjcsLTE4MCI+PC9wb2x5Z29uPjwvZz48IS0tIGFpcnBvcnRzIC0tPjxnIGlkPSJhaXJwb3J0cyIgY2xhc3M9Im5vZGUiPjx0aXRsZT5haXJwb3J0czwvdGl0bGU+Cjxwb2x5Z29uIGZpbGw9IiNlZmViZGQiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iMTY3LjUsLTgxIDE2Ny41LC0xMDEgMjEzLjUsLTEwMSAyMTMuNSwtODEgMTY3LjUsLTgxIj48L3BvbHlnb24+PHRleHQgdGV4dC1hbmNob3I9InN0YXJ0IiB4PSIxNjkuMTE5MiIgeT0iLTg2LjQiIGZvbnQtZmFtaWx5PSJUaW1lcyxzZXJpZiIgZm9udC1zaXplPSIxNC4wMCIgZmlsbD0iIzAwMDAwMCI+YWlycG9ydHM8L3RleHQ+PHBvbHlnb24gZmlsbD0iI2ZmZmZmZiIgc3Ryb2tlPSJ0cmFuc3BhcmVudCIgcG9pbnRzPSIxNjcuNSwtNjEgMTY3LjUsLTgxIDIxMy41LC04MSAyMTMuNSwtNjEgMTY3LjUsLTYxIj48L3BvbHlnb24+PHRleHQgdGV4dC1hbmNob3I9InN0YXJ0IiB4PSIxNjkuNSIgeT0iLTY3LjQiIGZvbnQtZmFtaWx5PSJUaW1lcyxzZXJpZiIgdGV4dC1kZWNvcmF0aW9uPSJ1bmRlcmxpbmUiIGZvbnQtc2l6ZT0iMTQuMDAiIGZpbGw9IiM0NDQ0NDQiPmZhYTwvdGV4dD48cG9seWdvbiBmaWxsPSJub25lIiBzdHJva2U9IiM1NTU1NTUiIHBvaW50cz0iMTY2LjUsLTYwIDE2Ni41LC0xMDIgMjE0LjUsLTEwMiAyMTQuNSwtNjAgMTY2LjUsLTYwIj48L3BvbHlnb24+PC9nPjwhLS0gZmxpZ2h0cyAtLT48ZyBpZD0iZmxpZ2h0cyIgY2xhc3M9Im5vZGUiPjx0aXRsZT5mbGlnaHRzPC90aXRsZT4KPHBvbHlnb24gZmlsbD0iI2VmZWJkZCIgc3Ryb2tlPSJ0cmFuc3BhcmVudCIgcG9pbnRzPSIxLjUsLTE0MSAxLjUsLTE2MSAxMDIuNSwtMTYxIDEwMi41LC0xNDEgMS41LC0xNDEiPjwvcG9seWdvbj48dGV4dCB0ZXh0LWFuY2hvcj0ic3RhcnQiIHg9IjM0LjExMTUiIHk9Ii0xNDYuNCIgZm9udC1mYW1pbHk9IlRpbWVzLHNlcmlmIiBmb250LXNpemU9IjE0LjAwIiBmaWxsPSIjMDAwMDAwIj5mbGlnaHRzPC90ZXh0Pjxwb2x5Z29uIGZpbGw9IiNmZmZmZmYiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iMS41LC0xMjEgMS41LC0xNDEgMTAyLjUsLTE0MSAxMDIuNSwtMTIxIDEuNSwtMTIxIj48L3BvbHlnb24+PHRleHQgdGV4dC1hbmNob3I9InN0YXJ0IiB4PSIzLjUiIHk9Ii0xMjYuNCIgZm9udC1mYW1pbHk9IlRpbWVzLHNlcmlmIiBmb250LXNpemU9IjE0LjAwIiBmaWxsPSIjNDQ0NDQ0Ij5jYXJyaWVyPC90ZXh0Pjxwb2x5Z29uIGZpbGw9IiNmZmZmZmYiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iMS41LC0xMDEgMS41LC0xMjEgMTAyLjUsLTEyMSAxMDIuNSwtMTAxIDEuNSwtMTAxIj48L3BvbHlnb24+PHRleHQgdGV4dC1hbmNob3I9InN0YXJ0IiB4PSIzLjUiIHk9Ii0xMDYuNCIgZm9udC1mYW1pbHk9IlRpbWVzLHNlcmlmIiBmb250LXNpemU9IjE0LjAwIiBmaWxsPSIjNDQ0NDQ0Ij50YWlsbnVtPC90ZXh0Pjxwb2x5Z29uIGZpbGw9IiNmZmZmZmYiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iMS41LC04MSAxLjUsLTEwMSAxMDIuNSwtMTAxIDEwMi41LC04MSAxLjUsLTgxIj48L3BvbHlnb24+PHRleHQgdGV4dC1hbmNob3I9InN0YXJ0IiB4PSIzLjUiIHk9Ii04Ni40IiBmb250LWZhbWlseT0iVGltZXMsc2VyaWYiIGZvbnQtc2l6ZT0iMTQuMDAiIGZpbGw9IiM0NDQ0NDQiPm9yaWdpbjwvdGV4dD48cG9seWdvbiBmaWxsPSIjZmZmZmZmIiBzdHJva2U9InRyYW5zcGFyZW50IiBwb2ludHM9IjEuNSwtNjEgMS41LC04MSAxMDIuNSwtODEgMTAyLjUsLTYxIDEuNSwtNjEiPjwvcG9seWdvbj48dGV4dCB0ZXh0LWFuY2hvcj0ic3RhcnQiIHg9IjMuNSIgeT0iLTY2LjQiIGZvbnQtZmFtaWx5PSJUaW1lcyxzZXJpZiIgZm9udC1zaXplPSIxNC4wMCIgZmlsbD0iIzQ0NDQ0NCI+ZGVzdDwvdGV4dD48cG9seWdvbiBmaWxsPSIjZmZmZmZmIiBzdHJva2U9InRyYW5zcGFyZW50IiBwb2ludHM9IjEuNSwtNDEgMS41LC02MSAxMDIuNSwtNjEgMTAyLjUsLTQxIDEuNSwtNDEiPjwvcG9seWdvbj48dGV4dCB0ZXh0LWFuY2hvcj0ic3RhcnQiIHg9IjMuMDA1NiIgeT0iLTQ2LjQiIGZvbnQtZmFtaWx5PSJUaW1lcyxzZXJpZiIgZm9udC1zaXplPSIxNC4wMCIgZmlsbD0iIzQ0NDQ0NCI+b3JpZ2luLCB0aW1lX2hvdXI8L3RleHQ+PHBvbHlnb24gZmlsbD0ibm9uZSIgc3Ryb2tlPSIjNTU1NTU1IiBwb2ludHM9IjAsLTQwIDAsLTE2MiAxMDMsLTE2MiAxMDMsLTQwIDAsLTQwIj48L3BvbHlnb24+PC9nPjwhLS0gZmxpZ2h0cyYjNDU7Jmd0O2FpcmxpbmVzIC0tPjxnIGlkPSJmbGlnaHRzXzEiIGNsYXNzPSJlZGdlIj48dGl0bGU+ZmxpZ2h0czpjYXJyaWVyLSZndDthaXJsaW5lczpjYXJyaWVyPC90aXRsZT4KPHBhdGggZmlsbD0ibm9uZSIgc3Ryb2tlPSIjNTU1NTU1IiBkPSJNMTAyLjUsLTEzMUMxMjYuNTY2OCwtMTMxIDEyMC44MDI5LC0xNTUuMjQ5NiAxMzksLTE3MSAxNDcuNzk1NiwtMTc4LjYxMyAxNTEuMDM5NCwtMTg1LjgzMDUgMTU4LjQxNTcsLTE4OS4xMjc3IiAvPjxwb2x5Z29uIGZpbGw9IiM1NTU1NTUiIHN0cm9rZT0iIzU1NTU1NSIgcG9pbnRzPSIxNTguMDI5MSwtMTkyLjYxNTcgMTY4LjUsLTE5MSAxNTkuMzA3LC0xODUuNzMzMyAxNTguMDI5MSwtMTkyLjYxNTciPjwvcG9seWdvbj48L2c+PCEtLSBmbGlnaHRzJiM0NTsmZ3Q7YWlycG9ydHMgLS0+PGcgaWQ9ImZsaWdodHNfMiIgY2xhc3M9ImVkZ2UiPjx0aXRsZT5mbGlnaHRzOm9yaWdpbi0mZ3Q7YWlycG9ydHM6ZmFhPC90aXRsZT4KPHBhdGggZmlsbD0ibm9uZSIgc3Ryb2tlPSIjNTU1NTU1IiBkPSJNMTAyLjUsLTkxQzEyOC45NDczLC05MSAxMzUuNzM2MSwtNzUuNjg3NSAxNTcuMjY4NywtNzEuODU5NCIgLz48cG9seWdvbiBmaWxsPSIjNTU1NTU1IiBzdHJva2U9IiM1NTU1NTUiIHBvaW50cz0iMTU3LjgyODEsLTc1LjMyNDggMTY3LjUsLTcxIDE1Ny4yNDIxLC02OC4zNDk0IDE1Ny44MjgxLC03NS4zMjQ4Ij48L3BvbHlnb24+PC9nPjwhLS0gZmxpZ2h0cyYjNDU7Jmd0O2FpcnBvcnRzIC0tPjxnIGlkPSJmbGlnaHRzXzMiIGNsYXNzPSJlZGdlIj48dGl0bGU+ZmxpZ2h0czpkZXN0LSZndDthaXJwb3J0czpmYWE8L3RpdGxlPgo8cGF0aCBmaWxsPSJub25lIiBzdHJva2U9IiM1NTU1NTUiIGQ9Ik0xMDIuNSwtNzFDMTI3LjY2NDksLTcxIDEzNi4zODkxLC03MSAxNTcuMzE1NCwtNzEiIC8+PHBvbHlnb24gZmlsbD0iIzU1NTU1NSIgc3Ryb2tlPSIjNTU1NTU1IiBwb2ludHM9IjE1Ny41LC03NC41MDAxIDE2Ny41LC03MSAxNTcuNSwtNjcuNTAwMSAxNTcuNSwtNzQuNTAwMSI+PC9wb2x5Z29uPjwvZz48IS0tIHBsYW5lcyAtLT48ZyBpZD0icGxhbmVzIiBjbGFzcz0ibm9kZSI+PHRpdGxlPnBsYW5lczwvdGl0bGU+Cjxwb2x5Z29uIGZpbGw9IiNlZmViZGQiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iMTY3LjUsLTE0MSAxNjcuNSwtMTYxIDIxMy41LC0xNjEgMjEzLjUsLTE0MSAxNjcuNSwtMTQxIj48L3BvbHlnb24+PHRleHQgdGV4dC1hbmNob3I9InN0YXJ0IiB4PSIxNzIuNjE3OCIgeT0iLTE0Ni40IiBmb250LWZhbWlseT0iVGltZXMsc2VyaWYiIGZvbnQtc2l6ZT0iMTQuMDAiIGZpbGw9IiMwMDAwMDAiPnBsYW5lczwvdGV4dD48cG9seWdvbiBmaWxsPSIjZmZmZmZmIiBzdHJva2U9InRyYW5zcGFyZW50IiBwb2ludHM9IjE2Ny41LC0xMjEgMTY3LjUsLTE0MSAyMTMuNSwtMTQxIDIxMy41LC0xMjEgMTY3LjUsLTEyMSI+PC9wb2x5Z29uPjx0ZXh0IHRleHQtYW5jaG9yPSJzdGFydCIgeD0iMTY5LjExMTUiIHk9Ii0xMjcuNCIgZm9udC1mYW1pbHk9IlRpbWVzLHNlcmlmIiB0ZXh0LWRlY29yYXRpb249InVuZGVybGluZSIgZm9udC1zaXplPSIxNC4wMCIgZmlsbD0iIzQ0NDQ0NCI+dGFpbG51bTwvdGV4dD48cG9seWdvbiBmaWxsPSJub25lIiBzdHJva2U9IiM1NTU1NTUiIHBvaW50cz0iMTY2LjUsLTEyMCAxNjYuNSwtMTYyIDIxNC41LC0xNjIgMjE0LjUsLTEyMCAxNjYuNSwtMTIwIj48L3BvbHlnb24+PC9nPjwhLS0gZmxpZ2h0cyYjNDU7Jmd0O3BsYW5lcyAtLT48ZyBpZD0iZmxpZ2h0c180IiBjbGFzcz0iZWRnZSI+PHRpdGxlPmZsaWdodHM6dGFpbG51bS0mZ3Q7cGxhbmVzOnRhaWxudW08L3RpdGxlPgo8cGF0aCBmaWxsPSJub25lIiBzdHJva2U9IiM1NTU1NTUiIGQ9Ik0xMDIuNSwtMTExQzEyOC45NDczLC0xMTEgMTM1LjczNjEsLTEyNi4zMTI1IDE1Ny4yNjg3LC0xMzAuMTQwNiIgLz48cG9seWdvbiBmaWxsPSIjNTU1NTU1IiBzdHJva2U9IiM1NTU1NTUiIHBvaW50cz0iMTU3LjI0MjEsLTEzMy42NTA2IDE2Ny41LC0xMzEgMTU3LjgyODEsLTEyNi42NzUyIDE1Ny4yNDIxLC0xMzMuNjUwNiI+PC9wb2x5Z29uPjwvZz48IS0tIHdlYXRoZXIgLS0+PGcgaWQ9IndlYXRoZXIiIGNsYXNzPSJub2RlIj48dGl0bGU+d2VhdGhlcjwvdGl0bGU+Cjxwb2x5Z29uIGZpbGw9IiNlZmViZGQiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iMTQwLjUsLTIxIDE0MC41LC00MSAyNDEuNSwtNDEgMjQxLjUsLTIxIDE0MC41LC0yMSI+PC9wb2x5Z29uPjx0ZXh0IHRleHQtYW5jaG9yPSJzdGFydCIgeD0iMTY4Ljg0OTIiIHk9Ii0yNi40IiBmb250LWZhbWlseT0iVGltZXMsc2VyaWYiIGZvbnQtc2l6ZT0iMTQuMDAiIGZpbGw9IiMwMDAwMDAiPndlYXRoZXI8L3RleHQ+PHBvbHlnb24gZmlsbD0iI2ZmZmZmZiIgc3Ryb2tlPSJ0cmFuc3BhcmVudCIgcG9pbnRzPSIxNDAuNSwtMSAxNDAuNSwtMjEgMjQxLjUsLTIxIDI0MS41LC0xIDE0MC41LC0xIj48L3BvbHlnb24+PHRleHQgdGV4dC1hbmNob3I9InN0YXJ0IiB4PSIxNDIuMDA1NiIgeT0iLTcuNCIgZm9udC1mYW1pbHk9IlRpbWVzLHNlcmlmIiB0ZXh0LWRlY29yYXRpb249InVuZGVybGluZSIgZm9udC1zaXplPSIxNC4wMCIgZmlsbD0iIzQ0NDQ0NCI+b3JpZ2luLCB0aW1lX2hvdXI8L3RleHQ+PHBvbHlnb24gZmlsbD0ibm9uZSIgc3Ryb2tlPSIjNTU1NTU1IiBwb2ludHM9IjEzOSwwIDEzOSwtNDIgMjQyLC00MiAyNDIsMCAxMzksMCI+PC9wb2x5Z29uPjwvZz48IS0tIGZsaWdodHMmIzQ1OyZndDt3ZWF0aGVyIC0tPjxnIGlkPSJmbGlnaHRzXzUiIGNsYXNzPSJlZGdlIj48dGl0bGU+ZmxpZ2h0czpvcmlnaW4sIHRpbWVfaG91ci0mZ3Q7d2VhdGhlcjpvcmlnaW4sIHRpbWVfaG91cjwvdGl0bGU+CjxwYXRoIGZpbGw9Im5vbmUiIHN0cm9rZT0iIzU1NTU1NSIgZD0iTTEwMi41LC01MUMxMjIuODA2NSwtNTEgMTE4LjcyNDEsLTIzLjU2ODQgMTMwLjY0NjksLTE0LjEzODciIC8+PHBvbHlnb24gZmlsbD0iIzU1NTU1NSIgc3Ryb2tlPSIjNTU1NTU1IiBwb2ludHM9IjEzMi4wMzQxLC0xNy4zNzAyIDE0MC41LC0xMSAxMjkuOTA5NCwtMTAuNzAwNCAxMzIuMDM0MSwtMTcuMzcwMiI+PC9wb2x5Z29uPjwvZz48L2c+PC9zdmc+)

You can use colors to visually group your tables into families to
reflect their logical grouping. The available colors are either hexcoded
colors or the standard R color names. The function
[`dm_get_available_colors()`](https://dm.cynkra.com/dev/reference/dm_set_colors.md)
forwards to
[`grDevices::colors()`](https://rdrr.io/r/grDevices/colors.html):

``` r
dm_get_available_colors()
#>   [1] "default"              "white"                "aliceblue"           
#>   [4] "antiquewhite"         "antiquewhite1"        "antiquewhite2"       
#>   [7] "antiquewhite3"        "antiquewhite4"        "aquamarine"          
#>  [10] "aquamarine1"          "aquamarine2"          "aquamarine3"         
#>  [13] "aquamarine4"          "azure"                "azure1"              
#>  [16] "azure2"               "azure3"               "azure4"              
#>  [19] "beige"                "bisque"               "bisque1"             
#>  [22] "bisque2"              "bisque3"              "bisque4"             
#>  [25] "black"                "blanchedalmond"       "blue"                
#>  [28] "blue1"                "blue2"                "blue3"               
#>  [31] "blue4"                "blueviolet"           "brown"               
#>  [34] "brown1"               "brown2"               "brown3"              
#>  [37] "brown4"               "burlywood"            "burlywood1"          
#>  [40] "burlywood2"           "burlywood3"           "burlywood4"          
#>  [43] "cadetblue"            "cadetblue1"           "cadetblue2"          
#>  [46] "cadetblue3"           "cadetblue4"           "chartreuse"          
#>  [49] "chartreuse1"          "chartreuse2"          "chartreuse3"         
#>  [52] "chartreuse4"          "chocolate"            "chocolate1"          
#>  [55] "chocolate2"           "chocolate3"           "chocolate4"          
#>  [58] "coral"                "coral1"               "coral2"              
#>  [61] "coral3"               "coral4"               "cornflowerblue"      
#>  [64] "cornsilk"             "cornsilk1"            "cornsilk2"           
#>  [67] "cornsilk3"            "cornsilk4"            "cyan"                
#>  [70] "cyan1"                "cyan2"                "cyan3"               
#>  [73] "cyan4"                "darkblue"             "darkcyan"            
#>  [76] "darkgoldenrod"        "darkgoldenrod1"       "darkgoldenrod2"      
#>  [79] "darkgoldenrod3"       "darkgoldenrod4"       "darkgray"            
#>  [82] "darkgreen"            "darkgrey"             "darkkhaki"           
#>  [85] "darkmagenta"          "darkolivegreen"       "darkolivegreen1"     
#>  [88] "darkolivegreen2"      "darkolivegreen3"      "darkolivegreen4"     
#>  [91] "darkorange"           "darkorange1"          "darkorange2"         
#>  [94] "darkorange3"          "darkorange4"          "darkorchid"          
#>  [97] "darkorchid1"          "darkorchid2"          "darkorchid3"         
#> [100] "darkorchid4"          "darkred"              "darksalmon"          
#> [103] "darkseagreen"         "darkseagreen1"        "darkseagreen2"       
#> [106] "darkseagreen3"        "darkseagreen4"        "darkslateblue"       
#> [109] "darkslategray"        "darkslategray1"       "darkslategray2"      
#> [112] "darkslategray3"       "darkslategray4"       "darkslategrey"       
#> [115] "darkturquoise"        "darkviolet"           "deeppink"            
#> [118] "deeppink1"            "deeppink2"            "deeppink3"           
#> [121] "deeppink4"            "deepskyblue"          "deepskyblue1"        
#> [124] "deepskyblue2"         "deepskyblue3"         "deepskyblue4"        
#> [127] "dimgray"              "dimgrey"              "dodgerblue"          
#> [130] "dodgerblue1"          "dodgerblue2"          "dodgerblue3"         
#> [133] "dodgerblue4"          "firebrick"            "firebrick1"          
#> [136] "firebrick2"           "firebrick3"           "firebrick4"          
#> [139] "floralwhite"          "forestgreen"          "gainsboro"           
#> [142] "ghostwhite"           "gold"                 "gold1"               
#> [145] "gold2"                "gold3"                "gold4"               
#> [148] "goldenrod"            "goldenrod1"           "goldenrod2"          
#> [151] "goldenrod3"           "goldenrod4"           "gray"                
#> [154] "gray0"                "gray1"                "gray2"               
#> [157] "gray3"                "gray4"                "gray5"               
#> [160] "gray6"                "gray7"                "gray8"               
#> [163] "gray9"                "gray10"               "gray11"              
#> [166] "gray12"               "gray13"               "gray14"              
#> [169] "gray15"               "gray16"               "gray17"              
#> [172] "gray18"               "gray19"               "gray20"              
#> [175] "gray21"               "gray22"               "gray23"              
#> [178] "gray24"               "gray25"               "gray26"              
#> [181] "gray27"               "gray28"               "gray29"              
#> [184] "gray30"               "gray31"               "gray32"              
#> [187] "gray33"               "gray34"               "gray35"              
#> [190] "gray36"               "gray37"               "gray38"              
#> [193] "gray39"               "gray40"               "gray41"              
#> [196] "gray42"               "gray43"               "gray44"              
#> [199] "gray45"               "gray46"               "gray47"              
#> [202] "gray48"               "gray49"               "gray50"              
#> [205] "gray51"               "gray52"               "gray53"              
#> [208] "gray54"               "gray55"               "gray56"              
#> [211] "gray57"               "gray58"               "gray59"              
#> [214] "gray60"               "gray61"               "gray62"              
#> [217] "gray63"               "gray64"               "gray65"              
#> [220] "gray66"               "gray67"               "gray68"              
#> [223] "gray69"               "gray70"               "gray71"              
#> [226] "gray72"               "gray73"               "gray74"              
#> [229] "gray75"               "gray76"               "gray77"              
#> [232] "gray78"               "gray79"               "gray80"              
#> [235] "gray81"               "gray82"               "gray83"              
#> [238] "gray84"               "gray85"               "gray86"              
#> [241] "gray87"               "gray88"               "gray89"              
#> [244] "gray90"               "gray91"               "gray92"              
#> [247] "gray93"               "gray94"               "gray95"              
#> [250] "gray96"               "gray97"               "gray98"              
#> [253] "gray99"               "gray100"              "green"               
#> [256] "green1"               "green2"               "green3"              
#> [259] "green4"               "greenyellow"          "grey"                
#> [262] "grey0"                "grey1"                "grey2"               
#> [265] "grey3"                "grey4"                "grey5"               
#> [268] "grey6"                "grey7"                "grey8"               
#> [271] "grey9"                "grey10"               "grey11"              
#> [274] "grey12"               "grey13"               "grey14"              
#> [277] "grey15"               "grey16"               "grey17"              
#> [280] "grey18"               "grey19"               "grey20"              
#> [283] "grey21"               "grey22"               "grey23"              
#> [286] "grey24"               "grey25"               "grey26"              
#> [289] "grey27"               "grey28"               "grey29"              
#> [292] "grey30"               "grey31"               "grey32"              
#> [295] "grey33"               "grey34"               "grey35"              
#> [298] "grey36"               "grey37"               "grey38"              
#> [301] "grey39"               "grey40"               "grey41"              
#> [304] "grey42"               "grey43"               "grey44"              
#> [307] "grey45"               "grey46"               "grey47"              
#> [310] "grey48"               "grey49"               "grey50"              
#> [313] "grey51"               "grey52"               "grey53"              
#> [316] "grey54"               "grey55"               "grey56"              
#> [319] "grey57"               "grey58"               "grey59"              
#> [322] "grey60"               "grey61"               "grey62"              
#> [325] "grey63"               "grey64"               "grey65"              
#> [328] "grey66"               "grey67"               "grey68"              
#> [331] "grey69"               "grey70"               "grey71"              
#> [334] "grey72"               "grey73"               "grey74"              
#> [337] "grey75"               "grey76"               "grey77"              
#> [340] "grey78"               "grey79"               "grey80"              
#> [343] "grey81"               "grey82"               "grey83"              
#> [346] "grey84"               "grey85"               "grey86"              
#> [349] "grey87"               "grey88"               "grey89"              
#> [352] "grey90"               "grey91"               "grey92"              
#> [355] "grey93"               "grey94"               "grey95"              
#> [358] "grey96"               "grey97"               "grey98"              
#> [361] "grey99"               "grey100"              "honeydew"            
#> [364] "honeydew1"            "honeydew2"            "honeydew3"           
#> [367] "honeydew4"            "hotpink"              "hotpink1"            
#> [370] "hotpink2"             "hotpink3"             "hotpink4"            
#> [373] "indianred"            "indianred1"           "indianred2"          
#> [376] "indianred3"           "indianred4"           "ivory"               
#> [379] "ivory1"               "ivory2"               "ivory3"              
#> [382] "ivory4"               "khaki"                "khaki1"              
#> [385] "khaki2"               "khaki3"               "khaki4"              
#> [388] "lavender"             "lavenderblush"        "lavenderblush1"      
#> [391] "lavenderblush2"       "lavenderblush3"       "lavenderblush4"      
#> [394] "lawngreen"            "lemonchiffon"         "lemonchiffon1"       
#> [397] "lemonchiffon2"        "lemonchiffon3"        "lemonchiffon4"       
#> [400] "lightblue"            "lightblue1"           "lightblue2"          
#> [403] "lightblue3"           "lightblue4"           "lightcoral"          
#> [406] "lightcyan"            "lightcyan1"           "lightcyan2"          
#> [409] "lightcyan3"           "lightcyan4"           "lightgoldenrod"      
#> [412] "lightgoldenrod1"      "lightgoldenrod2"      "lightgoldenrod3"     
#> [415] "lightgoldenrod4"      "lightgoldenrodyellow" "lightgray"           
#> [418] "lightgreen"           "lightgrey"            "lightpink"           
#> [421] "lightpink1"           "lightpink2"           "lightpink3"          
#> [424] "lightpink4"           "lightsalmon"          "lightsalmon1"        
#> [427] "lightsalmon2"         "lightsalmon3"         "lightsalmon4"        
#> [430] "lightseagreen"        "lightskyblue"         "lightskyblue1"       
#> [433] "lightskyblue2"        "lightskyblue3"        "lightskyblue4"       
#> [436] "lightslateblue"       "lightslategray"       "lightslategrey"      
#> [439] "lightsteelblue"       "lightsteelblue1"      "lightsteelblue2"     
#> [442] "lightsteelblue3"      "lightsteelblue4"      "lightyellow"         
#> [445] "lightyellow1"         "lightyellow2"         "lightyellow3"        
#> [448] "lightyellow4"         "limegreen"            "linen"               
#> [451] "magenta"              "magenta1"             "magenta2"            
#> [454] "magenta3"             "magenta4"             "maroon"              
#> [457] "maroon1"              "maroon2"              "maroon3"             
#> [460] "maroon4"              "mediumaquamarine"     "mediumblue"          
#> [463] "mediumorchid"         "mediumorchid1"        "mediumorchid2"       
#> [466] "mediumorchid3"        "mediumorchid4"        "mediumpurple"        
#> [469] "mediumpurple1"        "mediumpurple2"        "mediumpurple3"       
#> [472] "mediumpurple4"        "mediumseagreen"       "mediumslateblue"     
#> [475] "mediumspringgreen"    "mediumturquoise"      "mediumvioletred"     
#> [478] "midnightblue"         "mintcream"            "mistyrose"           
#> [481] "mistyrose1"           "mistyrose2"           "mistyrose3"          
#> [484] "mistyrose4"           "moccasin"             "navajowhite"         
#> [487] "navajowhite1"         "navajowhite2"         "navajowhite3"        
#> [490] "navajowhite4"         "navy"                 "navyblue"            
#> [493] "oldlace"              "olivedrab"            "olivedrab1"          
#> [496] "olivedrab2"           "olivedrab3"           "olivedrab4"          
#> [499] "orange"               "orange1"              "orange2"             
#> [502] "orange3"              "orange4"              "orangered"           
#> [505] "orangered1"           "orangered2"           "orangered3"          
#> [508] "orangered4"           "orchid"               "orchid1"             
#> [511] "orchid2"              "orchid3"              "orchid4"             
#> [514] "palegoldenrod"        "palegreen"            "palegreen1"          
#> [517] "palegreen2"           "palegreen3"           "palegreen4"          
#> [520] "paleturquoise"        "paleturquoise1"       "paleturquoise2"      
#> [523] "paleturquoise3"       "paleturquoise4"       "palevioletred"       
#> [526] "palevioletred1"       "palevioletred2"       "palevioletred3"      
#> [529] "palevioletred4"       "papayawhip"           "peachpuff"           
#> [532] "peachpuff1"           "peachpuff2"           "peachpuff3"          
#> [535] "peachpuff4"           "peru"                 "pink"                
#> [538] "pink1"                "pink2"                "pink3"               
#> [541] "pink4"                "plum"                 "plum1"               
#> [544] "plum2"                "plum3"                "plum4"               
#> [547] "powderblue"           "purple"               "purple1"             
#> [550] "purple2"              "purple3"              "purple4"             
#> [553] "red"                  "red1"                 "red2"                
#> [556] "red3"                 "red4"                 "rosybrown"           
#> [559] "rosybrown1"           "rosybrown2"           "rosybrown3"          
#> [562] "rosybrown4"           "royalblue"            "royalblue1"          
#> [565] "royalblue2"           "royalblue3"           "royalblue4"          
#> [568] "saddlebrown"          "salmon"               "salmon1"             
#> [571] "salmon2"              "salmon3"              "salmon4"             
#> [574] "sandybrown"           "seagreen"             "seagreen1"           
#> [577] "seagreen2"            "seagreen3"            "seagreen4"           
#> [580] "seashell"             "seashell1"            "seashell2"           
#> [583] "seashell3"            "seashell4"            "sienna"              
#> [586] "sienna1"              "sienna2"              "sienna3"             
#> [589] "sienna4"              "skyblue"              "skyblue1"            
#> [592] "skyblue2"             "skyblue3"             "skyblue4"            
#> [595] "slateblue"            "slateblue1"           "slateblue2"          
#> [598] "slateblue3"           "slateblue4"           "slategray"           
#> [601] "slategray1"           "slategray2"           "slategray3"          
#> [604] "slategray4"           "slategrey"            "snow"                
#> [607] "snow1"                "snow2"                "snow3"               
#> [610] "snow4"                "springgreen"          "springgreen1"        
#> [613] "springgreen2"         "springgreen3"         "springgreen4"        
#> [616] "steelblue"            "steelblue1"           "steelblue2"          
#> [619] "steelblue3"           "steelblue4"           "tan"                 
#> [622] "tan1"                 "tan2"                 "tan3"                
#> [625] "tan4"                 "thistle"              "thistle1"            
#> [628] "thistle2"             "thistle3"             "thistle4"            
#> [631] "tomato"               "tomato1"              "tomato2"             
#> [634] "tomato3"              "tomato4"              "turquoise"           
#> [637] "turquoise1"           "turquoise2"           "turquoise3"          
#> [640] "turquoise4"           "violet"               "violetred"           
#> [643] "violetred1"           "violetred2"           "violetred3"          
#> [646] "violetred4"           "wheat"                "wheat1"              
#> [649] "wheat2"               "wheat3"               "wheat4"              
#> [652] "whitesmoke"           "yellow"               "yellow1"             
#> [655] "yellow2"              "yellow3"              "yellow4"             
#> [658] "yellowgreen"
```

Colors are assigned with
[`dm_set_colors()`](https://dm.cynkra.com/dev/reference/dm_set_colors.md)
using syntax known in the {tidyverse} as {tidyselect}-syntax, here in
the form: `color = table`. [Select helper
functions](https://tidyselect.r-lib.org/reference/language.html) are
supported. The result of
[`dm_set_colors()`](https://dm.cynkra.com/dev/reference/dm_set_colors.md)
is a `dm` object. The information about the color is stored together
with the rest of the metadata.

``` r
flights_dm_w_many_keys_and_colors <-
  flights_dm_w_many_keys %>%
  dm_set_colors(
    maroon4 = flights,
    orange = starts_with("air"),
    "#5986C4" = planes
  )
```

Draw the schema with
[`dm_draw()`](https://dm.cynkra.com/dev/reference/dm_draw.md).

``` r
dm_draw(flights_dm_w_many_keys_and_colors)
```

![](data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMjUwcHQiIGhlaWdodD0iMjMwcHQiIHZpZXdib3g9IjAuMDAgMC4wMCAyNTAuMDAgMjMwLjAwIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHhtbG5zOnhsaW5rPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5L3hsaW5rIj48ZyBpZD0iZ3JhcGgwIiBjbGFzcz0iZ3JhcGgiIHRyYW5zZm9ybT0ic2NhbGUoMSAxKSByb3RhdGUoMCkgdHJhbnNsYXRlKDQgMjI2KSI+PHRpdGxlPiUwPC90aXRsZT4KPGcgaWQ9ImFfZ3JhcGgwIj48YSB4bGluazp0aXRsZT0iRGF0YSBNb2RlbCI+Cjxwb2x5Z29uIGZpbGw9IiNmZmZmZmYiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iLTQsNCAtNCwtMjI2IDI0NiwtMjI2IDI0Niw0IC00LDQiPjwvcG9seWdvbj48L2E+CjwvZz48IS0tIGFpcmxpbmVzIC0tPjxnIGlkPSJhaXJsaW5lcyIgY2xhc3M9Im5vZGUiPjx0aXRsZT5haXJsaW5lczwvdGl0bGU+Cjxwb2x5Z29uIGZpbGw9IiNmZmE1MDAiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iMTY4LjUsLTIwMSAxNjguNSwtMjIxIDIxMy41LC0yMjEgMjEzLjUsLTIwMSAxNjguNSwtMjAxIj48L3BvbHlnb24+PHRleHQgdGV4dC1hbmNob3I9InN0YXJ0IiB4PSIxNzAuMzk2OSIgeT0iLTIwNi40IiBmb250LWZhbWlseT0iVGltZXMsc2VyaWYiIGZvbnQtc2l6ZT0iMTQuMDAiIGZpbGw9IiMwMDAwMDAiPmFpcmxpbmVzPC90ZXh0Pjxwb2x5Z29uIGZpbGw9IiNmZmVkY2MiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iMTY4LjUsLTE4MSAxNjguNSwtMjAxIDIxMy41LC0yMDEgMjEzLjUsLTE4MSAxNjguNSwtMTgxIj48L3BvbHlnb24+PHRleHQgdGV4dC1hbmNob3I9InN0YXJ0IiB4PSIxNzAuNSIgeT0iLTE4Ny40IiBmb250LWZhbWlseT0iVGltZXMsc2VyaWYiIHRleHQtZGVjb3JhdGlvbj0idW5kZXJsaW5lIiBmb250LXNpemU9IjE0LjAwIiBmaWxsPSIjNDQ0NDQ0Ij5jYXJyaWVyPC90ZXh0Pjxwb2x5Z29uIGZpbGw9Im5vbmUiIHN0cm9rZT0iI2FhNmUwMCIgc3Ryb2tlLW9wYWNpdHk9IjAuNjY2NjY3IiBwb2ludHM9IjE2NywtMTgwIDE2NywtMjIyIDIxNCwtMjIyIDIxNCwtMTgwIDE2NywtMTgwIj48L3BvbHlnb24+PC9nPjwhLS0gYWlycG9ydHMgLS0+PGcgaWQ9ImFpcnBvcnRzIiBjbGFzcz0ibm9kZSI+PHRpdGxlPmFpcnBvcnRzPC90aXRsZT4KPHBvbHlnb24gZmlsbD0iI2ZmYTUwMCIgc3Ryb2tlPSJ0cmFuc3BhcmVudCIgcG9pbnRzPSIxNjcuNSwtODEgMTY3LjUsLTEwMSAyMTMuNSwtMTAxIDIxMy41LC04MSAxNjcuNSwtODEiPjwvcG9seWdvbj48dGV4dCB0ZXh0LWFuY2hvcj0ic3RhcnQiIHg9IjE2OS4xMTkyIiB5PSItODYuNCIgZm9udC1mYW1pbHk9IlRpbWVzLHNlcmlmIiBmb250LXNpemU9IjE0LjAwIiBmaWxsPSIjMDAwMDAwIj5haXJwb3J0czwvdGV4dD48cG9seWdvbiBmaWxsPSIjZmZlZGNjIiBzdHJva2U9InRyYW5zcGFyZW50IiBwb2ludHM9IjE2Ny41LC02MSAxNjcuNSwtODEgMjEzLjUsLTgxIDIxMy41LC02MSAxNjcuNSwtNjEiPjwvcG9seWdvbj48dGV4dCB0ZXh0LWFuY2hvcj0ic3RhcnQiIHg9IjE2OS41IiB5PSItNjcuNCIgZm9udC1mYW1pbHk9IlRpbWVzLHNlcmlmIiB0ZXh0LWRlY29yYXRpb249InVuZGVybGluZSIgZm9udC1zaXplPSIxNC4wMCIgZmlsbD0iIzQ0NDQ0NCI+ZmFhPC90ZXh0Pjxwb2x5Z29uIGZpbGw9Im5vbmUiIHN0cm9rZT0iI2FhNmUwMCIgc3Ryb2tlLW9wYWNpdHk9IjAuNjY2NjY3IiBwb2ludHM9IjE2Ni41LC02MCAxNjYuNSwtMTAyIDIxNC41LC0xMDIgMjE0LjUsLTYwIDE2Ni41LC02MCI+PC9wb2x5Z29uPjwvZz48IS0tIGZsaWdodHMgLS0+PGcgaWQ9ImZsaWdodHMiIGNsYXNzPSJub2RlIj48dGl0bGU+ZmxpZ2h0czwvdGl0bGU+Cjxwb2x5Z29uIGZpbGw9IiM4YjFjNjIiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iMS41LC0xNDEgMS41LC0xNjEgMTAyLjUsLTE2MSAxMDIuNSwtMTQxIDEuNSwtMTQxIj48L3BvbHlnb24+PHRleHQgdGV4dC1hbmNob3I9InN0YXJ0IiB4PSIzNC4xMTE1IiB5PSItMTQ2LjQiIGZvbnQtZmFtaWx5PSJUaW1lcyxzZXJpZiIgZm9udC1zaXplPSIxNC4wMCIgZmlsbD0iI2ZmZmZmZiI+ZmxpZ2h0czwvdGV4dD48cG9seWdvbiBmaWxsPSIjZTdkMWRmIiBzdHJva2U9InRyYW5zcGFyZW50IiBwb2ludHM9IjEuNSwtMTIxIDEuNSwtMTQxIDEwMi41LC0xNDEgMTAyLjUsLTEyMSAxLjUsLTEyMSI+PC9wb2x5Z29uPjx0ZXh0IHRleHQtYW5jaG9yPSJzdGFydCIgeD0iMy41IiB5PSItMTI2LjQiIGZvbnQtZmFtaWx5PSJUaW1lcyxzZXJpZiIgZm9udC1zaXplPSIxNC4wMCIgZmlsbD0iIzQ0NDQ0NCI+Y2FycmllcjwvdGV4dD48cG9seWdvbiBmaWxsPSIjZTdkMWRmIiBzdHJva2U9InRyYW5zcGFyZW50IiBwb2ludHM9IjEuNSwtMTAxIDEuNSwtMTIxIDEwMi41LC0xMjEgMTAyLjUsLTEwMSAxLjUsLTEwMSI+PC9wb2x5Z29uPjx0ZXh0IHRleHQtYW5jaG9yPSJzdGFydCIgeD0iMy41IiB5PSItMTA2LjQiIGZvbnQtZmFtaWx5PSJUaW1lcyxzZXJpZiIgZm9udC1zaXplPSIxNC4wMCIgZmlsbD0iIzQ0NDQ0NCI+dGFpbG51bTwvdGV4dD48cG9seWdvbiBmaWxsPSIjZTdkMWRmIiBzdHJva2U9InRyYW5zcGFyZW50IiBwb2ludHM9IjEuNSwtODEgMS41LC0xMDEgMTAyLjUsLTEwMSAxMDIuNSwtODEgMS41LC04MSI+PC9wb2x5Z29uPjx0ZXh0IHRleHQtYW5jaG9yPSJzdGFydCIgeD0iMy41IiB5PSItODYuNCIgZm9udC1mYW1pbHk9IlRpbWVzLHNlcmlmIiBmb250LXNpemU9IjE0LjAwIiBmaWxsPSIjNDQ0NDQ0Ij5vcmlnaW48L3RleHQ+PHBvbHlnb24gZmlsbD0iI2U3ZDFkZiIgc3Ryb2tlPSJ0cmFuc3BhcmVudCIgcG9pbnRzPSIxLjUsLTYxIDEuNSwtODEgMTAyLjUsLTgxIDEwMi41LC02MSAxLjUsLTYxIj48L3BvbHlnb24+PHRleHQgdGV4dC1hbmNob3I9InN0YXJ0IiB4PSIzLjUiIHk9Ii02Ni40IiBmb250LWZhbWlseT0iVGltZXMsc2VyaWYiIGZvbnQtc2l6ZT0iMTQuMDAiIGZpbGw9IiM0NDQ0NDQiPmRlc3Q8L3RleHQ+PHBvbHlnb24gZmlsbD0iI2U3ZDFkZiIgc3Ryb2tlPSJ0cmFuc3BhcmVudCIgcG9pbnRzPSIxLjUsLTQxIDEuNSwtNjEgMTAyLjUsLTYxIDEwMi41LC00MSAxLjUsLTQxIj48L3BvbHlnb24+PHRleHQgdGV4dC1hbmNob3I9InN0YXJ0IiB4PSIzLjAwNTYiIHk9Ii00Ni40IiBmb250LWZhbWlseT0iVGltZXMsc2VyaWYiIGZvbnQtc2l6ZT0iMTQuMDAiIGZpbGw9IiM0NDQ0NDQiPm9yaWdpbiwgdGltZV9ob3VyPC90ZXh0Pjxwb2x5Z29uIGZpbGw9Im5vbmUiIHN0cm9rZT0iIzVjMTI0MSIgc3Ryb2tlLW9wYWNpdHk9IjAuNjY2NjY3IiBwb2ludHM9IjAsLTQwIDAsLTE2MiAxMDMsLTE2MiAxMDMsLTQwIDAsLTQwIj48L3BvbHlnb24+PC9nPjwhLS0gZmxpZ2h0cyYjNDU7Jmd0O2FpcmxpbmVzIC0tPjxnIGlkPSJmbGlnaHRzXzEiIGNsYXNzPSJlZGdlIj48dGl0bGU+ZmxpZ2h0czpjYXJyaWVyLSZndDthaXJsaW5lczpjYXJyaWVyPC90aXRsZT4KPHBhdGggZmlsbD0ibm9uZSIgc3Ryb2tlPSIjNTU1NTU1IiBkPSJNMTAyLjUsLTEzMUMxMjYuNTY2OCwtMTMxIDEyMC44MDI5LC0xNTUuMjQ5NiAxMzksLTE3MSAxNDcuNzk1NiwtMTc4LjYxMyAxNTEuMDM5NCwtMTg1LjgzMDUgMTU4LjQxNTcsLTE4OS4xMjc3IiAvPjxwb2x5Z29uIGZpbGw9IiM1NTU1NTUiIHN0cm9rZT0iIzU1NTU1NSIgcG9pbnRzPSIxNTguMDI5MSwtMTkyLjYxNTcgMTY4LjUsLTE5MSAxNTkuMzA3LC0xODUuNzMzMyAxNTguMDI5MSwtMTkyLjYxNTciPjwvcG9seWdvbj48L2c+PCEtLSBmbGlnaHRzJiM0NTsmZ3Q7YWlycG9ydHMgLS0+PGcgaWQ9ImZsaWdodHNfMiIgY2xhc3M9ImVkZ2UiPjx0aXRsZT5mbGlnaHRzOm9yaWdpbi0mZ3Q7YWlycG9ydHM6ZmFhPC90aXRsZT4KPHBhdGggZmlsbD0ibm9uZSIgc3Ryb2tlPSIjNTU1NTU1IiBkPSJNMTAyLjUsLTkxQzEyOC45NDczLC05MSAxMzUuNzM2MSwtNzUuNjg3NSAxNTcuMjY4NywtNzEuODU5NCIgLz48cG9seWdvbiBmaWxsPSIjNTU1NTU1IiBzdHJva2U9IiM1NTU1NTUiIHBvaW50cz0iMTU3LjgyODEsLTc1LjMyNDggMTY3LjUsLTcxIDE1Ny4yNDIxLC02OC4zNDk0IDE1Ny44MjgxLC03NS4zMjQ4Ij48L3BvbHlnb24+PC9nPjwhLS0gZmxpZ2h0cyYjNDU7Jmd0O2FpcnBvcnRzIC0tPjxnIGlkPSJmbGlnaHRzXzMiIGNsYXNzPSJlZGdlIj48dGl0bGU+ZmxpZ2h0czpkZXN0LSZndDthaXJwb3J0czpmYWE8L3RpdGxlPgo8cGF0aCBmaWxsPSJub25lIiBzdHJva2U9IiM1NTU1NTUiIGQ9Ik0xMDIuNSwtNzFDMTI3LjY2NDksLTcxIDEzNi4zODkxLC03MSAxNTcuMzE1NCwtNzEiIC8+PHBvbHlnb24gZmlsbD0iIzU1NTU1NSIgc3Ryb2tlPSIjNTU1NTU1IiBwb2ludHM9IjE1Ny41LC03NC41MDAxIDE2Ny41LC03MSAxNTcuNSwtNjcuNTAwMSAxNTcuNSwtNzQuNTAwMSI+PC9wb2x5Z29uPjwvZz48IS0tIHBsYW5lcyAtLT48ZyBpZD0icGxhbmVzIiBjbGFzcz0ibm9kZSI+PHRpdGxlPnBsYW5lczwvdGl0bGU+Cjxwb2x5Z29uIGZpbGw9IiM1OTg2YzQiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iMTY3LjUsLTE0MSAxNjcuNSwtMTYxIDIxMy41LC0xNjEgMjEzLjUsLTE0MSAxNjcuNSwtMTQxIj48L3BvbHlnb24+PHRleHQgdGV4dC1hbmNob3I9InN0YXJ0IiB4PSIxNzIuNjE3OCIgeT0iLTE0Ni40IiBmb250LWZhbWlseT0iVGltZXMsc2VyaWYiIGZvbnQtc2l6ZT0iMTQuMDAiIGZpbGw9IiNmZmZmZmYiPnBsYW5lczwvdGV4dD48cG9seWdvbiBmaWxsPSIjZGRlNmYzIiBzdHJva2U9InRyYW5zcGFyZW50IiBwb2ludHM9IjE2Ny41LC0xMjEgMTY3LjUsLTE0MSAyMTMuNSwtMTQxIDIxMy41LC0xMjEgMTY3LjUsLTEyMSI+PC9wb2x5Z29uPjx0ZXh0IHRleHQtYW5jaG9yPSJzdGFydCIgeD0iMTY5LjExMTUiIHk9Ii0xMjcuNCIgZm9udC1mYW1pbHk9IlRpbWVzLHNlcmlmIiB0ZXh0LWRlY29yYXRpb249InVuZGVybGluZSIgZm9udC1zaXplPSIxNC4wMCIgZmlsbD0iIzQ0NDQ0NCI+dGFpbG51bTwvdGV4dD48cG9seWdvbiBmaWxsPSJub25lIiBzdHJva2U9IiMzYjU5ODIiIHN0cm9rZS1vcGFjaXR5PSIwLjY2NjY2NyIgcG9pbnRzPSIxNjYuNSwtMTIwIDE2Ni41LC0xNjIgMjE0LjUsLTE2MiAyMTQuNSwtMTIwIDE2Ni41LC0xMjAiPjwvcG9seWdvbj48L2c+PCEtLSBmbGlnaHRzJiM0NTsmZ3Q7cGxhbmVzIC0tPjxnIGlkPSJmbGlnaHRzXzQiIGNsYXNzPSJlZGdlIj48dGl0bGU+ZmxpZ2h0czp0YWlsbnVtLSZndDtwbGFuZXM6dGFpbG51bTwvdGl0bGU+CjxwYXRoIGZpbGw9Im5vbmUiIHN0cm9rZT0iIzU1NTU1NSIgZD0iTTEwMi41LC0xMTFDMTI4Ljk0NzMsLTExMSAxMzUuNzM2MSwtMTI2LjMxMjUgMTU3LjI2ODcsLTEzMC4xNDA2IiAvPjxwb2x5Z29uIGZpbGw9IiM1NTU1NTUiIHN0cm9rZT0iIzU1NTU1NSIgcG9pbnRzPSIxNTcuMjQyMSwtMTMzLjY1MDYgMTY3LjUsLTEzMSAxNTcuODI4MSwtMTI2LjY3NTIgMTU3LjI0MjEsLTEzMy42NTA2Ij48L3BvbHlnb24+PC9nPjwhLS0gd2VhdGhlciAtLT48ZyBpZD0id2VhdGhlciIgY2xhc3M9Im5vZGUiPjx0aXRsZT53ZWF0aGVyPC90aXRsZT4KPHBvbHlnb24gZmlsbD0iI2VmZWJkZCIgc3Ryb2tlPSJ0cmFuc3BhcmVudCIgcG9pbnRzPSIxNDAuNSwtMjEgMTQwLjUsLTQxIDI0MS41LC00MSAyNDEuNSwtMjEgMTQwLjUsLTIxIj48L3BvbHlnb24+PHRleHQgdGV4dC1hbmNob3I9InN0YXJ0IiB4PSIxNjguODQ5MiIgeT0iLTI2LjQiIGZvbnQtZmFtaWx5PSJUaW1lcyxzZXJpZiIgZm9udC1zaXplPSIxNC4wMCIgZmlsbD0iIzAwMDAwMCI+d2VhdGhlcjwvdGV4dD48cG9seWdvbiBmaWxsPSIjZmZmZmZmIiBzdHJva2U9InRyYW5zcGFyZW50IiBwb2ludHM9IjE0MC41LC0xIDE0MC41LC0yMSAyNDEuNSwtMjEgMjQxLjUsLTEgMTQwLjUsLTEiPjwvcG9seWdvbj48dGV4dCB0ZXh0LWFuY2hvcj0ic3RhcnQiIHg9IjE0Mi4wMDU2IiB5PSItNy40IiBmb250LWZhbWlseT0iVGltZXMsc2VyaWYiIHRleHQtZGVjb3JhdGlvbj0idW5kZXJsaW5lIiBmb250LXNpemU9IjE0LjAwIiBmaWxsPSIjNDQ0NDQ0Ij5vcmlnaW4sIHRpbWVfaG91cjwvdGV4dD48cG9seWdvbiBmaWxsPSJub25lIiBzdHJva2U9IiM1NTU1NTUiIHBvaW50cz0iMTM5LDAgMTM5LC00MiAyNDIsLTQyIDI0MiwwIDEzOSwwIj48L3BvbHlnb24+PC9nPjwhLS0gZmxpZ2h0cyYjNDU7Jmd0O3dlYXRoZXIgLS0+PGcgaWQ9ImZsaWdodHNfNSIgY2xhc3M9ImVkZ2UiPjx0aXRsZT5mbGlnaHRzOm9yaWdpbiwgdGltZV9ob3VyLSZndDt3ZWF0aGVyOm9yaWdpbiwgdGltZV9ob3VyPC90aXRsZT4KPHBhdGggZmlsbD0ibm9uZSIgc3Ryb2tlPSIjNTU1NTU1IiBkPSJNMTAyLjUsLTUxQzEyMi44MDY1LC01MSAxMTguNzI0MSwtMjMuNTY4NCAxMzAuNjQ2OSwtMTQuMTM4NyIgLz48cG9seWdvbiBmaWxsPSIjNTU1NTU1IiBzdHJva2U9IiM1NTU1NTUiIHBvaW50cz0iMTMyLjAzNDEsLTE3LjM3MDIgMTQwLjUsLTExIDEyOS45MDk0LC0xMC43MDA0IDEzMi4wMzQxLC0xNy4zNzAyIj48L3BvbHlnb24+PC9nPjwvZz48L3N2Zz4=)

The colors can be queried with
[`dm_get_colors()`](https://dm.cynkra.com/dev/reference/dm_set_colors.md).

``` r
dm_get_colors(flights_dm_w_many_keys_and_colors)
#>  #FFA500FF  #FFA500FF  #8B1C62FF  #5986C4FF    default 
#> "airlines" "airports"  "flights"   "planes"  "weather"
```

See the documentation for
[`dm_draw()`](https://dm.cynkra.com/dev/reference/dm_draw.md) for
further options. One important argument is `view_type`. Besides the
default `"keys_only"`, it accepts `"all"` to display all columns, and
`"title_only"` to show only the title of the table.

``` r
flights_dm_w_many_keys_and_colors %>%
  dm_draw(view_type = "title_only")
```

![](data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMTUycHQiIGhlaWdodD0iMjA2cHQiIHZpZXdib3g9IjAuMDAgMC4wMCAxNTIuMDAgMjA2LjAwIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHhtbG5zOnhsaW5rPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5L3hsaW5rIj48ZyBpZD0iZ3JhcGgwIiBjbGFzcz0iZ3JhcGgiIHRyYW5zZm9ybT0ic2NhbGUoMSAxKSByb3RhdGUoMCkgdHJhbnNsYXRlKDQgMjAyKSI+PHRpdGxlPiUwPC90aXRsZT4KPGcgaWQ9ImFfZ3JhcGgwIj48YSB4bGluazp0aXRsZT0iRGF0YSBNb2RlbCI+Cjxwb2x5Z29uIGZpbGw9IiNmZmZmZmYiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iLTQsNCAtNCwtMjAyIDE0OCwtMjAyIDE0OCw0IC00LDQiPjwvcG9seWdvbj48L2E+CjwvZz48IS0tIGFpcmxpbmVzIC0tPjxnIGlkPSJhaXJsaW5lcyIgY2xhc3M9Im5vZGUiPjx0aXRsZT5haXJsaW5lczwvdGl0bGU+Cjxwb2x5Z29uIGZpbGw9IiNmZmE1MDAiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iOTUsLTE3MCA5NSwtMTkwIDE0MCwtMTkwIDE0MCwtMTcwIDk1LC0xNzAiPjwvcG9seWdvbj48dGV4dCB0ZXh0LWFuY2hvcj0ic3RhcnQiIHg9Ijk2Ljg5NjkiIHk9Ii0xNzUuNCIgZm9udC1mYW1pbHk9IlRpbWVzLHNlcmlmIiBmb250LXNpemU9IjE0LjAwIiBmaWxsPSIjMDAwMDAwIj5haXJsaW5lczwvdGV4dD48cG9seWdvbiBmaWxsPSJub25lIiBzdHJva2U9IiNhYTZlMDAiIHN0cm9rZS1vcGFjaXR5PSIwLjY2NjY2NyIgcG9pbnRzPSI5My41LC0xNjkgOTMuNSwtMTkxIDE0MC41LC0xOTEgMTQwLjUsLTE2OSA5My41LC0xNjkiPjwvcG9seWdvbj48L2c+PCEtLSBhaXJwb3J0cyAtLT48ZyBpZD0iYWlycG9ydHMiIGNsYXNzPSJub2RlIj48dGl0bGU+YWlycG9ydHM8L3RpdGxlPgo8cG9seWdvbiBmaWxsPSIjZmZhNTAwIiBzdHJva2U9InRyYW5zcGFyZW50IiBwb2ludHM9Ijk0LC0xMTYgOTQsLTEzNiAxNDAsLTEzNiAxNDAsLTExNiA5NCwtMTE2Ij48L3BvbHlnb24+PHRleHQgdGV4dC1hbmNob3I9InN0YXJ0IiB4PSI5NS42MTkyIiB5PSItMTIxLjQiIGZvbnQtZmFtaWx5PSJUaW1lcyxzZXJpZiIgZm9udC1zaXplPSIxNC4wMCIgZmlsbD0iIzAwMDAwMCI+YWlycG9ydHM8L3RleHQ+PHBvbHlnb24gZmlsbD0ibm9uZSIgc3Ryb2tlPSIjYWE2ZTAwIiBzdHJva2Utb3BhY2l0eT0iMC42NjY2NjciIHBvaW50cz0iOTMsLTExNSA5MywtMTM3IDE0MSwtMTM3IDE0MSwtMTE1IDkzLC0xMTUiPjwvcG9seWdvbj48L2c+PCEtLSBmbGlnaHRzIC0tPjxnIGlkPSJmbGlnaHRzIiBjbGFzcz0ibm9kZSI+PHRpdGxlPmZsaWdodHM8L3RpdGxlPgo8cG9seWdvbiBmaWxsPSIjOGIxYzYyIiBzdHJva2U9InRyYW5zcGFyZW50IiBwb2ludHM9IjgsLTExNiA4LC0xMzYgNDcsLTEzNiA0NywtMTE2IDgsLTExNiI+PC9wb2x5Z29uPjx0ZXh0IHRleHQtYW5jaG9yPSJzdGFydCIgeD0iOS42MTE1IiB5PSItMTIxLjQiIGZvbnQtZmFtaWx5PSJUaW1lcyxzZXJpZiIgZm9udC1zaXplPSIxNC4wMCIgZmlsbD0iI2ZmZmZmZiI+ZmxpZ2h0czwvdGV4dD48cG9seWdvbiBmaWxsPSJub25lIiBzdHJva2U9IiM1YzEyNDEiIHN0cm9rZS1vcGFjaXR5PSIwLjY2NjY2NyIgcG9pbnRzPSI2LjUsLTExNSA2LjUsLTEzNyA0Ny41LC0xMzcgNDcuNSwtMTE1IDYuNSwtMTE1Ij48L3BvbHlnb24+PC9nPjwhLS0gZmxpZ2h0cyYjNDU7Jmd0O2FpcmxpbmVzIC0tPjxnIGlkPSJmbGlnaHRzXzEiIGNsYXNzPSJlZGdlIj48dGl0bGU+ZmxpZ2h0czpjYXJyaWVyLSZndDthaXJsaW5lczpjYXJyaWVyPC90aXRsZT4KPHBhdGggZmlsbD0ibm9uZSIgc3Ryb2tlPSIjNTU1NTU1IiBkPSJNNTQuMDAzLC0xNDIuMjAxOEM2Mi40Njg2LC0xNDcuMjgxMiA3MS45NTE2LC0xNTIuOTcxIDgwLjkzODksLTE1OC4zNjM0IiAvPjxwb2x5Z29uIGZpbGw9IiM1NTU1NTUiIHN0cm9rZT0iIzU1NTU1NSIgcG9pbnRzPSI3OS4zMjkzLC0xNjEuNDc5MiA4OS43MDUsLTE2My42MjMgODIuOTMwOCwtMTU1LjQ3NjggNzkuMzI5MywtMTYxLjQ3OTIiPjwvcG9seWdvbj48L2c+PCEtLSBmbGlnaHRzJiM0NTsmZ3Q7YWlycG9ydHMgLS0+PGcgaWQ9ImZsaWdodHNfMiIgY2xhc3M9ImVkZ2UiPjx0aXRsZT5mbGlnaHRzOm9yaWdpbi0mZ3Q7YWlycG9ydHM6ZmFhPC90aXRsZT4KPHBhdGggZmlsbD0ibm9uZSIgc3Ryb2tlPSIjNTU1NTU1IiBkPSJNNTQuMDAzLC0xMTkuNzU0N0M2Mi4wMjc3LC0xMTkuMjgwNCA3MC45NjY1LC0xMTkuMTQwNCA3OS41MzA5LC0xMTkuMzM0NyIgLz48cG9seWdvbiBmaWxsPSIjNTU1NTU1IiBzdHJva2U9IiM1NTU1NTUiIHBvaW50cz0iNzkuNTc0MywtMTIyLjgzOTEgODkuNzA1LC0xMTkuNzM3NiA3OS44NTE0LC0xMTUuODQ0NiA3OS41NzQzLC0xMjIuODM5MSI+PC9wb2x5Z29uPjwvZz48IS0tIGZsaWdodHMmIzQ1OyZndDthaXJwb3J0cyAtLT48ZyBpZD0iZmxpZ2h0c18zIiBjbGFzcz0iZWRnZSI+PHRpdGxlPmZsaWdodHM6ZGVzdC0mZ3Q7YWlycG9ydHM6ZmFhPC90aXRsZT4KPHBhdGggZmlsbD0ibm9uZSIgc3Ryb2tlPSIjNTU1NTU1IiBkPSJNNTQuMDAzLC0xMzIuMjQ1M0M2Mi4wMjc3LC0xMzIuNzE5NiA3MC45NjY1LC0xMzIuODU5NiA3OS41MzA5LC0xMzIuNjY1MyIgLz48cG9seWdvbiBmaWxsPSIjNTU1NTU1IiBzdHJva2U9IiM1NTU1NTUiIHBvaW50cz0iNzkuODUxNCwtMTM2LjE1NTQgODkuNzA1LC0xMzIuMjYyNCA3OS41NzQzLC0xMjkuMTYwOSA3OS44NTE0LC0xMzYuMTU1NCI+PC9wb2x5Z29uPjwvZz48IS0tIHBsYW5lcyAtLT48ZyBpZD0icGxhbmVzIiBjbGFzcz0ibm9kZSI+PHRpdGxlPnBsYW5lczwvdGl0bGU+Cjxwb2x5Z29uIGZpbGw9IiM1OTg2YzQiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iOTgsLTYyIDk4LC04MiAxMzcsLTgyIDEzNywtNjIgOTgsLTYyIj48L3BvbHlnb24+PHRleHQgdGV4dC1hbmNob3I9InN0YXJ0IiB4PSI5OS42MTc4IiB5PSItNjcuNCIgZm9udC1mYW1pbHk9IlRpbWVzLHNlcmlmIiBmb250LXNpemU9IjE0LjAwIiBmaWxsPSIjZmZmZmZmIj5wbGFuZXM8L3RleHQ+PHBvbHlnb24gZmlsbD0ibm9uZSIgc3Ryb2tlPSIjM2I1OTgyIiBzdHJva2Utb3BhY2l0eT0iMC42NjY2NjciIHBvaW50cz0iOTYuNSwtNjEgOTYuNSwtODMgMTM3LjUsLTgzIDEzNy41LC02MSA5Ni41LC02MSI+PC9wb2x5Z29uPjwvZz48IS0tIGZsaWdodHMmIzQ1OyZndDtwbGFuZXMgLS0+PGcgaWQ9ImZsaWdodHNfNCIgY2xhc3M9ImVkZ2UiPjx0aXRsZT5mbGlnaHRzOnRhaWxudW0tJmd0O3BsYW5lczp0YWlsbnVtPC90aXRsZT4KPHBhdGggZmlsbD0ibm9uZSIgc3Ryb2tlPSIjNTU1NTU1IiBkPSJNNTQuMDAzLC0xMDkuNzk4MkM2Mi40Njg2LC0xMDQuNzE4OCA3MS45NTE2LC05OS4wMjkgODAuOTM4OSwtOTMuNjM2NiIgLz48cG9seWdvbiBmaWxsPSIjNTU1NTU1IiBzdHJva2U9IiM1NTU1NTUiIHBvaW50cz0iODIuOTMwOCwtOTYuNTIzMiA4OS43MDUsLTg4LjM3NyA3OS4zMjkzLC05MC41MjA4IDgyLjkzMDgsLTk2LjUyMzIiPjwvcG9seWdvbj48L2c+PCEtLSB3ZWF0aGVyIC0tPjxnIGlkPSJ3ZWF0aGVyIiBjbGFzcz0ibm9kZSI+PHRpdGxlPndlYXRoZXI8L3RpdGxlPgo8cG9seWdvbiBmaWxsPSIjZWZlYmRkIiBzdHJva2U9InRyYW5zcGFyZW50IiBwb2ludHM9IjkzLC04IDkzLC0yOCAxNDEsLTI4IDE0MSwtOCA5MywtOCI+PC9wb2x5Z29uPjx0ZXh0IHRleHQtYW5jaG9yPSJzdGFydCIgeD0iOTQuODQ5MiIgeT0iLTEzLjQiIGZvbnQtZmFtaWx5PSJUaW1lcyxzZXJpZiIgZm9udC1zaXplPSIxNC4wMCIgZmlsbD0iIzAwMDAwMCI+d2VhdGhlcjwvdGV4dD48cG9seWdvbiBmaWxsPSJub25lIiBzdHJva2U9IiM1NTU1NTUiIHBvaW50cz0iOTIsLTcgOTIsLTI5IDE0MiwtMjkgMTQyLC03IDkyLC03Ij48L3BvbHlnb24+PC9nPjwhLS0gZmxpZ2h0cyYjNDU7Jmd0O3dlYXRoZXIgLS0+PGcgaWQ9ImZsaWdodHNfNSIgY2xhc3M9ImVkZ2UiPjx0aXRsZT5mbGlnaHRzOm9yaWdpbiwgdGltZV9ob3VyLSZndDt3ZWF0aGVyOm9yaWdpbiwgdGltZV9ob3VyPC90aXRsZT4KPHBhdGggZmlsbD0ibm9uZSIgc3Ryb2tlPSIjNTU1NTU1IiBkPSJNNDAuMTQ3NCwtMTA3Ljc5MTJDNTIuNDg0NywtOTEuMDI4NiA3MS43MjUyLC02NS43MDEzIDkwLC00NSA5MC40OTM2LC00NC40NDA5IDkwLjk5NTksLTQzLjg3ODggOTEuNTA1MiwtNDMuMzE1MSIgLz48cG9seWdvbiBmaWxsPSIjNTU1NTU1IiBzdHJva2U9IiM1NTU1NTUiIHBvaW50cz0iOTQuMDgxNiwtNDUuNjg0NCA5OC4zODMzLC0zNi4wMDIxIDg4Ljk4MjYsLTQwLjg4ODYgOTQuMDgxNiwtNDUuNjg0NCI+PC9wb2x5Z29uPjwvZz48L2c+PC9zdmc+)

If you would like to visualize only some of the tables, use
[`dm_select_tbl()`](https://dm.cynkra.com/dev/reference/dm_select_tbl.md)
before drawing:

``` r
flights_dm_w_many_keys_and_colors %>%
  dm_select_tbl(flights, airports, planes) %>%
  dm_draw()
```

![](data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMTUycHQiIGhlaWdodD0iMTEwcHQiIHZpZXdib3g9IjAuMDAgMC4wMCAxNTIuMDAgMTEwLjAwIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHhtbG5zOnhsaW5rPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5L3hsaW5rIj48ZyBpZD0iZ3JhcGgwIiBjbGFzcz0iZ3JhcGgiIHRyYW5zZm9ybT0ic2NhbGUoMSAxKSByb3RhdGUoMCkgdHJhbnNsYXRlKDQgMTA2KSI+PHRpdGxlPiUwPC90aXRsZT4KPGcgaWQ9ImFfZ3JhcGgwIj48YSB4bGluazp0aXRsZT0iRGF0YSBNb2RlbCI+Cjxwb2x5Z29uIGZpbGw9IiNmZmZmZmYiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iLTQsNCAtNCwtMTA2IDE0OCwtMTA2IDE0OCw0IC00LDQiPjwvcG9seWdvbj48L2E+CjwvZz48IS0tIGFpcnBvcnRzIC0tPjxnIGlkPSJhaXJwb3J0cyIgY2xhc3M9Im5vZGUiPjx0aXRsZT5haXJwb3J0czwvdGl0bGU+Cjxwb2x5Z29uIGZpbGw9IiNmZmE1MDAiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iOTQsLTIxIDk0LC00MSAxNDAsLTQxIDE0MCwtMjEgOTQsLTIxIj48L3BvbHlnb24+PHRleHQgdGV4dC1hbmNob3I9InN0YXJ0IiB4PSI5NS42MTkyIiB5PSItMjYuNCIgZm9udC1mYW1pbHk9IlRpbWVzLHNlcmlmIiBmb250LXNpemU9IjE0LjAwIiBmaWxsPSIjMDAwMDAwIj5haXJwb3J0czwvdGV4dD48cG9seWdvbiBmaWxsPSIjZmZlZGNjIiBzdHJva2U9InRyYW5zcGFyZW50IiBwb2ludHM9Ijk0LC0xIDk0LC0yMSAxNDAsLTIxIDE0MCwtMSA5NCwtMSI+PC9wb2x5Z29uPjx0ZXh0IHRleHQtYW5jaG9yPSJzdGFydCIgeD0iOTYiIHk9Ii03LjQiIGZvbnQtZmFtaWx5PSJUaW1lcyxzZXJpZiIgdGV4dC1kZWNvcmF0aW9uPSJ1bmRlcmxpbmUiIGZvbnQtc2l6ZT0iMTQuMDAiIGZpbGw9IiM0NDQ0NDQiPmZhYTwvdGV4dD48cG9seWdvbiBmaWxsPSJub25lIiBzdHJva2U9IiNhYTZlMDAiIHN0cm9rZS1vcGFjaXR5PSIwLjY2NjY2NyIgcG9pbnRzPSI5MywwIDkzLC00MiAxNDEsLTQyIDE0MSwwIDkzLDAiPjwvcG9seWdvbj48L2c+PCEtLSBmbGlnaHRzIC0tPjxnIGlkPSJmbGlnaHRzIiBjbGFzcz0ibm9kZSI+PHRpdGxlPmZsaWdodHM8L3RpdGxlPgo8cG9seWdvbiBmaWxsPSIjOGIxYzYyIiBzdHJva2U9InRyYW5zcGFyZW50IiBwb2ludHM9IjQsLTYxIDQsLTgxIDUwLC04MSA1MCwtNjEgNCwtNjEiPjwvcG9seWdvbj48dGV4dCB0ZXh0LWFuY2hvcj0ic3RhcnQiIHg9IjkuMTExNSIgeT0iLTY2LjQiIGZvbnQtZmFtaWx5PSJUaW1lcyxzZXJpZiIgZm9udC1zaXplPSIxNC4wMCIgZmlsbD0iI2ZmZmZmZiI+ZmxpZ2h0czwvdGV4dD48cG9seWdvbiBmaWxsPSIjZTdkMWRmIiBzdHJva2U9InRyYW5zcGFyZW50IiBwb2ludHM9IjQsLTQxIDQsLTYxIDUwLC02MSA1MCwtNDEgNCwtNDEiPjwvcG9seWdvbj48dGV4dCB0ZXh0LWFuY2hvcj0ic3RhcnQiIHg9IjUuNjExNSIgeT0iLTQ2LjQiIGZvbnQtZmFtaWx5PSJUaW1lcyxzZXJpZiIgZm9udC1zaXplPSIxNC4wMCIgZmlsbD0iIzQ0NDQ0NCI+dGFpbG51bTwvdGV4dD48cG9seWdvbiBmaWxsPSIjZTdkMWRmIiBzdHJva2U9InRyYW5zcGFyZW50IiBwb2ludHM9IjQsLTIxIDQsLTQxIDUwLC00MSA1MCwtMjEgNCwtMjEiPjwvcG9seWdvbj48dGV4dCB0ZXh0LWFuY2hvcj0ic3RhcnQiIHg9IjYiIHk9Ii0yNi40IiBmb250LWZhbWlseT0iVGltZXMsc2VyaWYiIGZvbnQtc2l6ZT0iMTQuMDAiIGZpbGw9IiM0NDQ0NDQiPm9yaWdpbjwvdGV4dD48cG9seWdvbiBmaWxsPSIjZTdkMWRmIiBzdHJva2U9InRyYW5zcGFyZW50IiBwb2ludHM9IjQsLTEgNCwtMjEgNTAsLTIxIDUwLC0xIDQsLTEiPjwvcG9seWdvbj48dGV4dCB0ZXh0LWFuY2hvcj0ic3RhcnQiIHg9IjYiIHk9Ii02LjQiIGZvbnQtZmFtaWx5PSJUaW1lcyxzZXJpZiIgZm9udC1zaXplPSIxNC4wMCIgZmlsbD0iIzQ0NDQ0NCI+ZGVzdDwvdGV4dD48cG9seWdvbiBmaWxsPSJub25lIiBzdHJva2U9IiM1YzEyNDEiIHN0cm9rZS1vcGFjaXR5PSIwLjY2NjY2NyIgcG9pbnRzPSIzLDAgMywtODIgNTEsLTgyIDUxLDAgMywwIj48L3BvbHlnb24+PC9nPjwhLS0gZmxpZ2h0cyYjNDU7Jmd0O2FpcnBvcnRzIC0tPjxnIGlkPSJmbGlnaHRzXzEiIGNsYXNzPSJlZGdlIj48dGl0bGU+ZmxpZ2h0czpvcmlnaW4tJmd0O2FpcnBvcnRzOmZhYTwvdGl0bGU+CjxwYXRoIGZpbGw9Im5vbmUiIHN0cm9rZT0iIzU1NTU1NSIgZD0iTTUwLC0zMUM2Ny40NTMzLC0zMSA3MS40MTExLC0xNy43OTY5IDgzLjgwMzUsLTEyLjg0NTciIC8+PHBvbHlnb24gZmlsbD0iIzU1NTU1NSIgc3Ryb2tlPSIjNTU1NTU1IiBwb2ludHM9Ijg0Ljc4MzQsLTE2LjIyNTMgOTQsLTExIDgzLjUzNjUsLTkuMzM3MiA4NC43ODM0LC0xNi4yMjUzIj48L3BvbHlnb24+PC9nPjwhLS0gZmxpZ2h0cyYjNDU7Jmd0O2FpcnBvcnRzIC0tPjxnIGlkPSJmbGlnaHRzXzIiIGNsYXNzPSJlZGdlIj48dGl0bGU+ZmxpZ2h0czpkZXN0LSZndDthaXJwb3J0czpmYWE8L3RpdGxlPgo8cGF0aCBmaWxsPSJub25lIiBzdHJva2U9IiM1NTU1NTUiIGQ9Ik01MCwtMTFDNjUuNTgzMywtMTEgNzEuODUzMiwtMTEgODMuNjUyOSwtMTEiIC8+PHBvbHlnb24gZmlsbD0iIzU1NTU1NSIgc3Ryb2tlPSIjNTU1NTU1IiBwb2ludHM9Ijg0LC0xNC41MDAxIDk0LC0xMSA4NCwtNy41MDAxIDg0LC0xNC41MDAxIj48L3BvbHlnb24+PC9nPjwhLS0gcGxhbmVzIC0tPjxnIGlkPSJwbGFuZXMiIGNsYXNzPSJub2RlIj48dGl0bGU+cGxhbmVzPC90aXRsZT4KPHBvbHlnb24gZmlsbD0iIzU5ODZjNCIgc3Ryb2tlPSJ0cmFuc3BhcmVudCIgcG9pbnRzPSI5NCwtODEgOTQsLTEwMSAxNDAsLTEwMSAxNDAsLTgxIDk0LC04MSI+PC9wb2x5Z29uPjx0ZXh0IHRleHQtYW5jaG9yPSJzdGFydCIgeD0iOTkuMTE3OCIgeT0iLTg2LjQiIGZvbnQtZmFtaWx5PSJUaW1lcyxzZXJpZiIgZm9udC1zaXplPSIxNC4wMCIgZmlsbD0iI2ZmZmZmZiI+cGxhbmVzPC90ZXh0Pjxwb2x5Z29uIGZpbGw9IiNkZGU2ZjMiIHN0cm9rZT0idHJhbnNwYXJlbnQiIHBvaW50cz0iOTQsLTYxIDk0LC04MSAxNDAsLTgxIDE0MCwtNjEgOTQsLTYxIj48L3BvbHlnb24+PHRleHQgdGV4dC1hbmNob3I9InN0YXJ0IiB4PSI5NS42MTE1IiB5PSItNjcuNCIgZm9udC1mYW1pbHk9IlRpbWVzLHNlcmlmIiB0ZXh0LWRlY29yYXRpb249InVuZGVybGluZSIgZm9udC1zaXplPSIxNC4wMCIgZmlsbD0iIzQ0NDQ0NCI+dGFpbG51bTwvdGV4dD48cG9seWdvbiBmaWxsPSJub25lIiBzdHJva2U9IiMzYjU5ODIiIHN0cm9rZS1vcGFjaXR5PSIwLjY2NjY2NyIgcG9pbnRzPSI5MywtNjAgOTMsLTEwMiAxNDEsLTEwMiAxNDEsLTYwIDkzLC02MCI+PC9wb2x5Z29uPjwvZz48IS0tIGZsaWdodHMmIzQ1OyZndDtwbGFuZXMgLS0+PGcgaWQ9ImZsaWdodHNfMyIgY2xhc3M9ImVkZ2UiPjx0aXRsZT5mbGlnaHRzOnRhaWxudW0tJmd0O3BsYW5lczp0YWlsbnVtPC90aXRsZT4KPHBhdGggZmlsbD0ibm9uZSIgc3Ryb2tlPSIjNTU1NTU1IiBkPSJNNTAsLTUxQzY3LjQ1MzMsLTUxIDcxLjQxMTEsLTY0LjIwMzEgODMuODAzNSwtNjkuMTU0MyIgLz48cG9seWdvbiBmaWxsPSIjNTU1NTU1IiBzdHJva2U9IiM1NTU1NTUiIHBvaW50cz0iODMuNTM2NSwtNzIuNjYyOCA5NCwtNzEgODQuNzgzNCwtNjUuNzc0NyA4My41MzY1LC03Mi42NjI4Ij48L3BvbHlnb24+PC9nPjwvZz48L3N2Zz4=)

Finally, for exporting a drawing to `svg` you could use
[`DiagrammeRsvg::export_svg()`](https://rdrr.io/pkg/DiagrammeRsvg/man/export_svg.html):

``` r
flights_dm_w_many_keys_and_colors %>%
  dm_select_tbl(flights, airports, planes) %>%
  dm_draw() %>%
  DiagrammeRsvg::export_svg() %>%
  write("flights_dm_w_many_keys_and_color.svg")
```

------------------------------------------------------------------------

1.  The code for the functions in this section is borrowed from the
    [{datamodelr}](https://github.com/bergant/datamodelr) package.
