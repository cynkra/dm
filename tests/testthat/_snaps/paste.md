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
        dm::dm_add_pk(tf_1, a, autoincrement = TRUE) %>%
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
          dm::dm_add_pk(tf_1, a, autoincrement = TRUE) %>%
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
        dm::dm_add_pk(tf_1_new, a, autoincrement = TRUE) %>%
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
      dm_for_filter() %>% dm_select(tf_5, k = k, m) %>% dm_select(tf_1, a) %>% dm(x = copy_to_my_test_src(
        tibble(q = 1L), qq)) %>% dm_paste(options = "select")
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
        dm::dm_select(tf_6, zz, n, o) %>%
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
        dm::dm_add_pk(tf_1, a, autoincrement = TRUE) %>%
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
      dm_for_filter() %>% dm_add_uk(tf_5, l) %>% dm_add_uk(tf_6, n) %>% dm_paste()
    Message
      dm::dm(
        tf_1,
        tf_2,
        tf_3,
        tf_4,
        tf_5,
        tf_6,
      ) %>%
        dm::dm_add_pk(tf_1, a, autoincrement = TRUE) %>%
        dm::dm_add_pk(tf_2, c) %>%
        dm::dm_add_pk(tf_3, c(f, f1)) %>%
        dm::dm_add_pk(tf_4, h) %>%
        dm::dm_add_pk(tf_5, k) %>%
        dm::dm_add_pk(tf_6, o) %>%
        dm::dm_add_uk(tf_5, l) %>%
        dm::dm_add_uk(tf_6, n) %>%
        dm::dm_add_fk(tf_2, d, tf_1) %>%
        dm::dm_add_fk(tf_2, c(e, e1), tf_3) %>%
        dm::dm_add_fk(tf_4, c(j, j1), tf_3) %>%
        dm::dm_add_fk(tf_5, l, tf_4, on_delete = "cascade") %>%
        dm::dm_add_fk(tf_5, m, tf_6, n)
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
      i Please use the `options` argument instead.
    Message
      dm::dm(
      )
    Code
      # error for bad option
      writeLines(conditionMessage(expect_error(dm_paste(dm(), options = c("bogus",
        "all", "mad")))))
    Output
      Option unknown: "bogus", "mad". Must be one of "all", "tables", "keys", "select", "color".

# output 2

    Code
      # no error for factor column that leads to code with width > 500
      dm(tibble(a = factor(levels = expand.grid(letters, as.character(1:5)) %>%
        transmute(x = paste0(Var1, Var2)) %>% pull()))) %>% dm_paste(options = "tables")
    Message
      `tibble(...)` <- tibble::tibble(
        a = structure(integer(0), class = "factor", levels = c("a1", "b1", "c1", "d1", "e1", "f1", "g1", "h1", "i1", "j1", "k1", "l1", "m1", "n1", "o1", "p1", "q1", "r1", "s1", "t1", "u1", "v1", "w1", "x1", "y1", "z1", "a2", "b2", "c2", "d2", "e2", "f2", "g2", "h2", "i2", "j2", "k2", "l2", "m2", "n2", "o2", "p2", "q2", "r2", "s2", "t2", "u2", "v2", "w2", "x2", "y2", "z2", "a3", "b3", "c3", "d3", "e3", "f3", "g3", "h3", "i3", "j3", "k3", "l3", "m3", "n3", "o3", "p3", "q3", "r3", "s3", "t3", "u3", "v3", "w3", "x3", "y3", "z3", "a4", "b4", "c4", "d4", "e4", "f4", "g4", "h4", "i4", "j4", "k4", "l4", "m4", "n4", "o4", "p4", "q4", "r4", "s4", "t4", "u4", "v4", "w4", "x4", "y4", "z4", "a5", "b5", "c5", "d5", "e5", "f5", "g5", "h5", "i5", "j5", "k5", "l5", "m5", "n5", "o5", "p5", "q5", "r5", "s5", "t5", "u5", "v5", "w5", "x5", "y5", "z5")),
      )
      dm::dm(
        `tibble(...)`,
      )

