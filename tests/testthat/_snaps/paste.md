# output

    Code
      # empty
      empty_dm() %>% dm_paste()
    Message
      dm::dm(
      )
    Code
      # empty table
      dm(a = tibble()) %>% dm_paste(options = "tables")
    Message
      a <- tibble::tibble(
      )
      dm::dm(
        a,
      )
    Code
      # baseline
      dm_for_filter() %>% dm_paste()
    Message
      dm::dm(
        tf_1,
        tf_2,
        tf_3,
        tf_4,
        tf_5,
        tf_6,
      ) %>%
        dm::dm_add_pk(tf_1, a) %>%
        dm::dm_add_pk(tf_2, c) %>%
        dm::dm_add_pk(tf_3, c(f, f1)) %>%
        dm::dm_add_pk(tf_4, h) %>%
        dm::dm_add_pk(tf_5, k) %>%
        dm::dm_add_pk(tf_6, o) %>%
        dm::dm_add_fk(tf_2, d, tf_1) %>%
        dm::dm_add_fk(tf_2, c(e, e1), tf_3) %>%
        dm::dm_add_fk(tf_4, c(j, j1), tf_3) %>%
        dm::dm_add_fk(tf_5, l, tf_4, on_delete = "cascade") %>%
        dm::dm_add_fk(tf_5, m, tf_6, n)
    Code
      # changing the tab width
      dm_for_filter() %>% dm_paste(tab_width = 4)
    Message
      dm::dm(
          tf_1,
          tf_2,
          tf_3,
          tf_4,
          tf_5,
          tf_6,
      ) %>%
          dm::dm_add_pk(tf_1, a) %>%
          dm::dm_add_pk(tf_2, c) %>%
          dm::dm_add_pk(tf_3, c(f, f1)) %>%
          dm::dm_add_pk(tf_4, h) %>%
          dm::dm_add_pk(tf_5, k) %>%
          dm::dm_add_pk(tf_6, o) %>%
          dm::dm_add_fk(tf_2, d, tf_1) %>%
          dm::dm_add_fk(tf_2, c(e, e1), tf_3) %>%
          dm::dm_add_fk(tf_4, c(j, j1), tf_3) %>%
          dm::dm_add_fk(tf_5, l, tf_4, on_delete = "cascade") %>%
          dm::dm_add_fk(tf_5, m, tf_6, n)
    Code
      # we don't care if the tables really exist
      dm_for_filter() %>% dm_rename_tbl(tf_1_new = tf_1) %>% dm_paste()
    Message
      dm::dm(
        tf_1_new,
        tf_2,
        tf_3,
        tf_4,
        tf_5,
        tf_6,
      ) %>%
        dm::dm_add_pk(tf_1_new, a) %>%
        dm::dm_add_pk(tf_2, c) %>%
        dm::dm_add_pk(tf_3, c(f, f1)) %>%
        dm::dm_add_pk(tf_4, h) %>%
        dm::dm_add_pk(tf_5, k) %>%
        dm::dm_add_pk(tf_6, o) %>%
        dm::dm_add_fk(tf_2, d, tf_1_new) %>%
        dm::dm_add_fk(tf_2, c(e, e1), tf_3) %>%
        dm::dm_add_fk(tf_4, c(j, j1), tf_3) %>%
        dm::dm_add_fk(tf_5, l, tf_4, on_delete = "cascade") %>%
        dm::dm_add_fk(tf_5, m, tf_6, n)
    Code
      # produce `dm_select()` statements in addition to the rest
      dm_for_filter() %>% dm_select(tf_5, k = k, m) %>% dm_select(tf_1, a) %>%
        dm_add_tbl(x = copy_to_my_test_src(tibble(q = 1L), qq)) %>% dm_paste(options = "select")
    Message
      dm::dm(
        tf_1,
        tf_2,
        tf_3,
        tf_4,
        tf_5,
        tf_6,
        x,
      ) %>%
        dm::dm_select(tf_1, a) %>%
        dm::dm_select(tf_2, c, d, e, e1) %>%
        dm::dm_select(tf_3, f, f1, g) %>%
        dm::dm_select(tf_4, h, i, j, j1) %>%
        dm::dm_select(tf_5, k, m) %>%
        dm::dm_select(tf_6, n, o) %>%
        dm::dm_select(x, q)
    Code
      # produce code with colors
      dm_for_filter() %>% dm_set_colors(orange = tf_1:tf_3, darkgreen = tf_5:tf_6) %>%
        dm_paste()
    Message
      dm::dm(
        tf_1,
        tf_2,
        tf_3,
        tf_4,
        tf_5,
        tf_6,
      ) %>%
        dm::dm_add_pk(tf_1, a) %>%
        dm::dm_add_pk(tf_2, c) %>%
        dm::dm_add_pk(tf_3, c(f, f1)) %>%
        dm::dm_add_pk(tf_4, h) %>%
        dm::dm_add_pk(tf_5, k) %>%
        dm::dm_add_pk(tf_6, o) %>%
        dm::dm_add_fk(tf_2, d, tf_1) %>%
        dm::dm_add_fk(tf_2, c(e, e1), tf_3) %>%
        dm::dm_add_fk(tf_4, c(j, j1), tf_3) %>%
        dm::dm_add_fk(tf_5, l, tf_4, on_delete = "cascade") %>%
        dm::dm_add_fk(tf_5, m, tf_6, n) %>%
        dm::dm_set_colors(`#FFA500FF` = tf_1) %>%
        dm::dm_set_colors(`#FFA500FF` = tf_2) %>%
        dm::dm_set_colors(`#FFA500FF` = tf_3) %>%
        dm::dm_set_colors(`#006400FF` = tf_5) %>%
        dm::dm_set_colors(`#006400FF` = tf_6)
    Code
      # tick if needed
      a <- tibble(x = 1)
      names(a) <- "a b"
      dm(a) %>% dm_zoom_to(a) %>% dm_insert_zoomed("a b") %>% dm_add_pk(a, "a b") %>%
        dm_add_fk("a b", "a b", a) %>% dm_set_colors(green = "a b") %>% dm_paste(
        options = "all")
    Message
      a <- tibble::tibble(
        `a b` = numeric(0),
      )
      `a b` <- tibble::tibble(
        `a b` = numeric(0),
      )
      dm::dm(
        a,
        `a b`,
      ) %>%
        dm::dm_add_pk(a, `a b`) %>%
        dm::dm_add_fk(`a b`, `a b`, a) %>%
        dm::dm_set_colors(`#00FF00FF` = `a b`)
    Code
      # FK referencing non default PK
      b <- tibble(x = 1, y = "A", z = "A")
      c <- tibble(x = "A", y = "A")
      dm(b, c) %>% dm_add_pk(c, x) %>% dm_add_fk(b, y, c) %>% dm_add_fk(b, z, c, y) %>%
        dm_paste()
    Message
      dm::dm(
        b,
        c,
      ) %>%
        dm::dm_add_pk(c, x) %>%
        dm::dm_add_fk(b, y, c) %>%
        dm::dm_add_fk(b, z, c, y)
    Code
      # on_delete if needed
      dm(b, c) %>% dm_add_pk(c, x) %>% dm_add_fk(b, y, c, on_delete = "cascade") %>%
        dm_add_fk(b, z, c, y, on_delete = "no_action") %>% dm_paste()
    Message
      dm::dm(
        b,
        c,
      ) %>%
        dm::dm_add_pk(c, x) %>%
        dm::dm_add_fk(b, y, c, on_delete = "cascade") %>%
        dm::dm_add_fk(b, z, c, y)
    Code
      # all of nycflights13
      dm_nycflights13() %>% dm_paste(options = "all")
    Message
      airlines <- tibble::tibble(
        carrier = character(0),
        name = character(0),
      )
      airports <- tibble::tibble(
        faa = character(0),
        name = character(0),
        lat = numeric(0),
        lon = numeric(0),
        alt = numeric(0),
        tz = numeric(0),
        dst = character(0),
        tzone = character(0),
      )
      flights <- tibble::tibble(
        year = integer(0),
        month = integer(0),
        day = integer(0),
        dep_time = integer(0),
        sched_dep_time = integer(0),
        dep_delay = numeric(0),
        arr_time = integer(0),
        sched_arr_time = integer(0),
        arr_delay = numeric(0),
        carrier = character(0),
        flight = integer(0),
        tailnum = character(0),
        origin = character(0),
        dest = character(0),
        air_time = numeric(0),
        distance = numeric(0),
        hour = numeric(0),
        minute = numeric(0),
        time_hour = structure(numeric(0), class = c("POSIXct", "POSIXt"), tzone = "America/New_York"),
      )
      planes <- tibble::tibble(
        tailnum = character(0),
        year = integer(0),
        type = character(0),
        manufacturer = character(0),
        model = character(0),
        engines = integer(0),
        seats = integer(0),
        speed = integer(0),
        engine = character(0),
      )
      weather <- tibble::tibble(
        origin = character(0),
        year = integer(0),
        month = integer(0),
        day = integer(0),
        hour = integer(0),
        temp = numeric(0),
        dewp = numeric(0),
        humid = numeric(0),
        wind_dir = numeric(0),
        wind_speed = numeric(0),
        wind_gust = numeric(0),
        precip = numeric(0),
        pressure = numeric(0),
        visib = numeric(0),
        time_hour = structure(numeric(0), class = c("POSIXct", "POSIXt"), tzone = "America/New_York"),
      )
      dm::dm(
        airlines,
        airports,
        flights,
        planes,
        weather,
      ) %>%
        dm::dm_add_pk(airlines, carrier) %>%
        dm::dm_add_pk(airports, faa) %>%
        dm::dm_add_pk(planes, tailnum) %>%
        dm::dm_add_pk(weather, c(origin, time_hour)) %>%
        dm::dm_add_fk(flights, carrier, airlines) %>%
        dm::dm_add_fk(flights, origin, airports) %>%
        dm::dm_add_fk(flights, tailnum, planes) %>%
        dm::dm_add_fk(flights, c(origin, time_hour), weather) %>%
        dm::dm_set_colors(`#ED7D31FF` = airlines) %>%
        dm::dm_set_colors(`#ED7D31FF` = airports) %>%
        dm::dm_set_colors(`#5B9BD5FF` = flights) %>%
        dm::dm_set_colors(`#ED7D31FF` = planes) %>%
        dm::dm_set_colors(`#70AD47FF` = weather)
    Code
      # deprecation warning for select argument
      dm() %>% dm_paste(select = TRUE)
    Condition
      Warning:
      The `select` argument of `dm_paste()` is deprecated as of dm 0.1.2.
      Please use the `options` argument instead.
    Message
      dm::dm(
      )
    Code
      # error for bad option
      writeLines(conditionMessage(expect_error(dm_paste(dm(), options = c("bogus",
        "all", "mad")))))
    Output
      Option unknown: "bogus", "mad". Must be one of "all", "tables", "keys", "select", "color".

