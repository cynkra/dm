# dm_add_tbl() and dm_rm_tbl() for compound keys

    Code
      dm_add_tbl(dm_for_flatten(), res_flat = result_from_flatten()) |> dm_paste(
        options = c("select", "keys"))
    Message <cliMessage>
      dm::dm(fact, dim_1, dim_2, dim_3, dim_4, res_flat) |>
        dm::dm_select(fact, fact, dim_1_key_1, dim_1_key_2, dim_2_key, dim_3_key, dim_4_key, something) |>
        dm::dm_select(dim_1, dim_1_pk_1, dim_1_pk_2, something) |>
        dm::dm_select(dim_2, dim_2_pk, something) |>
        dm::dm_select(dim_3, dim_3_pk, something) |>
        dm::dm_select(dim_4, dim_4_pk, something) |>
        dm::dm_select(res_flat, fact, dim_1_key_1, dim_1_key_2, dim_2_key, dim_3_key, dim_4_key, fact.something, dim_1.something, dim_2.something, dim_3.something, dim_4.something) |>
        dm::dm_add_pk(dim_1, c(dim_1_pk_1, dim_1_pk_2)) |>
        dm::dm_add_pk(dim_2, dim_2_pk) |>
        dm::dm_add_pk(dim_3, dim_3_pk) |>
        dm::dm_add_pk(dim_4, dim_4_pk) |>
        dm::dm_add_fk(fact, c(dim_1_key_1, dim_1_key_2), dim_1) |>
        dm::dm_add_fk(fact, dim_2_key, dim_2) |>
        dm::dm_add_fk(fact, dim_3_key, dim_3) |>
        dm::dm_add_fk(fact, dim_4_key, dim_4)
    Code
      dm_rm_tbl(dm_for_flatten(), dim_1) |> dm_paste(options = c("select", "keys"))
    Message <cliMessage>
      dm::dm(fact, dim_2, dim_3, dim_4) |>
        dm::dm_select(fact, fact, dim_1_key_1, dim_1_key_2, dim_2_key, dim_3_key, dim_4_key, something) |>
        dm::dm_select(dim_2, dim_2_pk, something) |>
        dm::dm_select(dim_3, dim_3_pk, something) |>
        dm::dm_select(dim_4, dim_4_pk, something) |>
        dm::dm_add_pk(dim_2, dim_2_pk) |>
        dm::dm_add_pk(dim_3, dim_3_pk) |>
        dm::dm_add_pk(dim_4, dim_4_pk) |>
        dm::dm_add_fk(fact, dim_2_key, dim_2) |>
        dm::dm_add_fk(fact, dim_3_key, dim_3) |>
        dm::dm_add_fk(fact, dim_4_key, dim_4)
    Code
      dm_rm_tbl(dm_for_flatten(), fact) |> dm_paste(options = c("select", "keys"))
    Message <cliMessage>
      dm::dm(dim_1, dim_2, dim_3, dim_4) |>
        dm::dm_select(dim_1, dim_1_pk_1, dim_1_pk_2, something) |>
        dm::dm_select(dim_2, dim_2_pk, something) |>
        dm::dm_select(dim_3, dim_3_pk, something) |>
        dm::dm_select(dim_4, dim_4_pk, something) |>
        dm::dm_add_pk(dim_1, c(dim_1_pk_1, dim_1_pk_2)) |>
        dm::dm_add_pk(dim_2, dim_2_pk) |>
        dm::dm_add_pk(dim_3, dim_3_pk) |>
        dm::dm_add_pk(dim_4, dim_4_pk)

