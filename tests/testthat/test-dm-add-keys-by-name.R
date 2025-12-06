test_that("dm_add_keys_by_name() infers keys from shared column names", {
  orders <- tibble(
    order_id = 1:5,
    customer_id = c(1L, 2L, 1L, 3L, 2L),
    amount = c(100, 200, 150, 300, 250)
  )

  customers <- tibble(
    customer_id = 1:3,
    name = c("Alice", "Bob", "Charlie")
  )

  my_dm <- dm(orders, customers)

  # Before: no keys

  expect_equal(nrow(dm_get_all_pks(my_dm)), 0)
  expect_equal(nrow(dm_get_all_fks(my_dm)), 0)

  # Add keys by name
  result <- dm_add_keys_by_name(my_dm, quiet = TRUE)

  # After: PK on customers.customer_id, FK from orders
  pks <- dm_get_all_pks(result)
  expect_equal(nrow(pks), 1)
  expect_equal(pks$table, "customers")

  fks <- dm_get_all_fks(result)
  expect_equal(nrow(fks), 1)
  expect_equal(fks$child_table, "orders")
  expect_equal(fks$parent_table, "customers")
})

test_that("dm_add_keys_by_name() handles multiple shared columns", {
  orders <- tibble(
    order_id = 1:5,
    customer_id = c(1L, 2L, 1L, 3L, 2L),
    product_id = c(10L, 20L, 10L, 30L, 20L)
  )

  customers <- tibble(
    customer_id = 1:3,
    name = c("Alice", "Bob", "Charlie")
  )

  products <- tibble(
    product_id = c(10L, 20L, 30L),
    description = c("Widget", "Gadget", "Gizmo")
  )

  my_dm <- dm(orders, customers, products)
  result <- dm_add_keys_by_name(my_dm, quiet = TRUE)

  # Should have 2 PKs and 2 FKs
  pks <- dm_get_all_pks(result)
  expect_equal(nrow(pks), 2)
  expect_setequal(pks$table, c("customers", "products"))

  fks <- dm_get_all_fks(result)
  expect_equal(nrow(fks), 2)
  expect_equal(unique(fks$child_table), "orders")
})

test_that("dm_add_keys_by_name() skips ambiguous columns", {
  # Both tables have unique values - ambiguous which should be PK
  tbl1 <- tibble(id = 1:3, val = c("a", "b", "c"))
  tbl2 <- tibble(id = 4:6, val = c("d", "e", "f"))

  my_dm <- dm(tbl1, tbl2)
  result <- dm_add_keys_by_name(my_dm, quiet = TRUE)

  # No keys should be added (both have unique values)
  expect_equal(nrow(dm_get_all_pks(result)), 0)
  expect_equal(nrow(dm_get_all_fks(result)), 0)
})

test_that("dm_add_keys_by_name() returns unchanged dm with single table", {
  single <- tibble(id = 1:3, val = c("a", "b", "c"))
  my_dm <- dm(single)

  result <- dm_add_keys_by_name(my_dm, quiet = TRUE)
  expect_equal(nrow(dm_get_all_pks(result)), 0)
})

test_that("dm_add_keys_by_name() preserves existing keys", {
  orders <- tibble(
    order_id = 1:5,
    customer_id = c(1L, 2L, 1L, 3L, 2L)
  )

  customers <- tibble(
    customer_id = 1:3,
    name = c("Alice", "Bob", "Charlie")
  )

  # Pre-set a PK
  my_dm <- dm(orders, customers) %>%
    dm_add_pk(customers, customer_id)

  result <- dm_add_keys_by_name(my_dm, quiet = TRUE)

  # Should still have 1 PK and add the FK
  expect_equal(nrow(dm_get_all_pks(result)), 1)
  expect_equal(nrow(dm_get_all_fks(result)), 1)
})

test_that("dm_add_keys_by_name() shows messages when quiet = FALSE", {
  orders <- tibble(order_id = 1:3, customer_id = c(1L, 2L, 1L))
  customers <- tibble(customer_id = 1:2, name = c("A", "B"))

  my_dm <- dm(orders, customers)

  expect_message(
    dm_add_keys_by_name(my_dm, quiet = FALSE),
    "Added primary key"
  )
})

test_that("dm_add_keys_by_name() handles no shared columns", {
  tbl1 <- tibble(a = 1:3)
  tbl2 <- tibble(b = 4:6)

  my_dm <- dm(tbl1, tbl2)

  expect_message(
    result <- dm_add_keys_by_name(my_dm, quiet = FALSE),
    "No shared column names"
  )
  expect_equal(nrow(dm_get_all_pks(result)), 0)
})
