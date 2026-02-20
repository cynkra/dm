# `dm_set_colors()` works

    Code
      dm_nycflights_small() %>% dm_set_colors(blue = "flights", green = "airports") %>%
        dm_get_colors()
    Output
         default  #00FF00FF  #0000FFFF    default    default 
      "airlines" "airports"  "flights"   "planes"  "weather" 

