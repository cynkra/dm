
test_that("dm_to_tibble and friends work", {
  dm1 <- dm_for_filter()

  ## from tf_4
  tbl_keys_from_dm_tf_4 <- dm_to_tibble(dm1, "tf_4")
  serialized_from_tf_4 <- serialize_list_cols(tbl_keys_from_dm_tf_4$tbl)
  unserialized_from_tf_4 <- unserialize_json_cols(serialized_from_tf_4)
  roundtrip_dm_from_tf_4 <- tibble_to_dm(unserialized_from_tf_4, tbl_keys_from_dm_tf_4$keys, "tf_4")

  # tibble from dm (no json)
  expect_snapshot({
    print(tbl_keys_from_dm_tf_4$tbl)
    print(tbl_keys_from_dm_tf_4$tbl$tf_3$tf_2)
    print(tbl_keys_from_dm_tf_4$tbl$tf_5)
  })

  # tibble from dm (json)
  expect_snapshot({
    print(serialized_from_tf_4)
    print(serialized_from_tf_4$tf_5_json_child)
    print(serialized_from_tf_4$tf_3_json_parent)
  })

  # unserialized (back to tibble no json)
  expect_snapshot({
    print(unserialized_from_tf_4)
    print(unserialized_from_tf_4$tf_3$tf_2)
    print(unserialized_from_tf_4$tf_5)
  })

  # round trip dm
  expect_snapshot({
    print(roundtrip_dm_from_tf_4$tf_1)
    print(roundtrip_dm_from_tf_4$tf_4)
    print(roundtrip_dm_from_tf_4$tf_6)
  })

  ## from tf_6
  tbl_keys_from_dm_tf_6 <- dm_to_tibble(dm1, "tf_6")
  serialized_from_tf_6 <- serialize_list_cols(tbl_keys_from_dm_tf_6$tbl)
  unserialized_from_tf_6 <- unserialize_json_cols(serialized_from_tf_6)
  roundtrip_dm_from_tf_6 <- tibble_to_dm(unserialized_from_tf_6, tbl_keys_from_dm_tf_6$keys, "tf_6")

  # tibble from dm (no json)
  expect_snapshot({
    print(tbl_keys_from_dm_tf_6$tbl)
    print(tbl_keys_from_dm_tf_6$tbl$tf_5[[1]]$tf_4$tf_3$tf_2)
  })

  # tibble from dm (json)
  expect_snapshot({
    print(serialized_from_tf_6)
    print(serialized_from_tf_6$tf_5_json_child)
  })

  # unserialized (back to tibble no json)
  expect_snapshot({
    print(unserialized_from_tf_6)
    print(unserialized_from_tf_6$tf_5[[1]]$tf_4$tf_3$tf_2)
  })

  # round trip dm
  expect_snapshot({
    print(roundtrip_dm_from_tf_6$tf_1)
    print(roundtrip_dm_from_tf_6$tf_4)
    print(roundtrip_dm_from_tf_6$tf_6)
  })

  ## from tf_1
  tbl_keys_from_dm_tf_1 <- dm_to_tibble(dm1, "tf_1")
  serialized_from_tf_1 <- serialize_list_cols(tbl_keys_from_dm_tf_1$tbl)
  unserialized_from_tf_1 <- unserialize_json_cols(serialized_from_tf_1)
  roundtrip_dm_from_tf_1 <- tibble_to_dm(unserialized_from_tf_1, tbl_keys_from_dm_tf_1$keys, "tf_1")

  # tibble from dm (no json)
  expect_snapshot({
    print(tbl_keys_from_dm_tf_1$tbl)
    print(tbl_keys_from_dm_tf_1$tbl$tf_2[[2]]$tf_3$tf_4[[1]]$tf_5)
  })

  # tibble from dm (json)
  expect_snapshot({
    print(serialized_from_tf_1)
    print(serialized_from_tf_1$tf_2_json_child)
  })

  # unserialized (back to tibble no json)
  expect_snapshot({
    print(unserialized_from_tf_1)
    print(unserialized_from_tf_1$tf_2[[2]]$tf_3$tf_4[[1]]$tf_5)
  })

  # round trip dm
  expect_snapshot({
    print(roundtrip_dm_from_tf_1$tf_1)
    print(roundtrip_dm_from_tf_1$tf_4)
    print(roundtrip_dm_from_tf_1$tf_6)
  })
})
