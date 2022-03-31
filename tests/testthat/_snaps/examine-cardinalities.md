# dm_examine_cardinalities() works

    Code
      dm_examine_cardinalities(dm_for_card())
    Output
      * FK: dc_2$(`a`, `b`) -> dc_1$(`a`, `b`): injective mapping (child: 0 or 1 -> parent: 1)
      * FK: dc_3$(`a`, `b`) -> dc_1$(`a`, `b`): surjective mapping (child: 1 to n -> parent: 1)
      * FK: dc_5$(`b`, `a`) -> dc_1$(`b`, `a`): bijective mapping (child: 1 -> parent: 1)
      * FK: dc_3$(`b`, `a`) -> dc_4$(`b`, `a`): generic mapping (child: 0 to n -> parent: 1)
      * FK: dc_6$(`c`) -> dc_1$(`a`): Column (`c`) of table `dc_6` not a subset of column (`a`) of table `dc_1`.
      * FK: dc_4$(`b`, `a`) -> dc_3$(`b`, `a`): Columns (`b`, `a`) not a unique key of `dc_3`.
    Message
      ! Not all FK constraints satisfied, call `dm_examine_constraints()` for details.
    Code
      dm_examine_cardinalities(dm_for_card()) %>% as_tibble()
    Output
      # A tibble: 6 x 5
        child_table child_fk_cols parent_table parent_key_cols cardinality            
        <chr>       <keys>        <chr>        <keys>          <chr>                  
      1 dc_2        a, b          dc_1         a, b            injective mapping (chi~
      2 dc_3        a, b          dc_1         a, b            surjective mapping (ch~
      3 dc_5        b, a          dc_1         b, a            bijective mapping (chi~
      4 dc_6        c             dc_1         a               Column (`c`) of table ~
      5 dc_4        b, a          dc_3         b, a            Columns (`b`, `a`) not~
      6 dc_3        b, a          dc_4         b, a            generic mapping (child~
    Code
      dm_for_card() %>% dm_rm_fk(dc_6, c, dc_1, a) %>% dm_rm_fk(dc_4, c(b, a), dc_3,
      c(b, a)) %>% dm_examine_cardinalities()
    Output
      * FK: dc_2$(`a`, `b`) -> dc_1$(`a`, `b`): injective mapping (child: 0 or 1 -> parent: 1)
      * FK: dc_3$(`a`, `b`) -> dc_1$(`a`, `b`): surjective mapping (child: 1 to n -> parent: 1)
      * FK: dc_5$(`b`, `a`) -> dc_1$(`b`, `a`): bijective mapping (child: 1 -> parent: 1)
      * FK: dc_3$(`b`, `a`) -> dc_4$(`b`, `a`): generic mapping (child: 0 to n -> parent: 1)
    Code
      dm_examine_cardinalities(dm())
    Message
      ! No FKs available in `dm`.

