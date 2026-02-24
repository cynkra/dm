# Simple duckplyr test

    Code
      summarize(dm_zoom_to(dm(a = duckplyr::duckdb_tibble(x = 1:3, .prudence = "stingy")),
      a), mean_x = mean(x))
    Output
      [1] "name_df"
      # Zoomed table:          a
      # A duckplyr data frame: 1 variable
        mean_x
         <dbl>
      1      2

