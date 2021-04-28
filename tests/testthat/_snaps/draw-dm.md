# `dm_set_colors()` works

    Code
      dm_nycflights_small() %>% dm_set_colors(blue = starts_with("air"), green = contains(
        "h")) %>% dm_get_colors()
    Output
       #0000FFFF  #0000FFFF  #00FF00FF    default  #00FF00FF 
      "airlines" "airports"  "flights"   "planes"  "weather" 

---

    Code
      dm_nycflights_small() %>% dm_set_colors(blue = "flights", green = "airports") %>%
        dm_get_colors()
    Output
         default  #00FF00FF  #0000FFFF    default    default 
      "airlines" "airports"  "flights"   "planes"  "weather" 

