test_that("dm_infer_keys() infers keys from shared column names", {
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

  expect_equal(nrow(dm_get_all_pks(my_dm)), 0)
  expect_equal(nrow(dm_get_all_fks(my_dm)), 0)

  expect_message(
    result <- dm_infer_keys(my_dm, heuristics = "column_name"),
    "dm_add_pk"
  )

  pks <- dm_get_all_pks(result)
  expect_equal(nrow(pks), 1)
  expect_equal(pks$table, "customers")

  fks <- dm_get_all_fks(result)
  expect_equal(nrow(fks), 1)
  expect_equal(fks$child_table, "orders")
  expect_equal(fks$parent_table, "customers")
})

test_that("dm_infer_keys() handles multiple shared columns", {
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
  result <- dm_infer_keys(my_dm, heuristics = "column_name", quiet = TRUE)

  pks <- dm_get_all_pks(result)
  expect_equal(nrow(pks), 2)
  expect_true(all(c("customers", "products") %in% pks$table))

  fks <- dm_get_all_fks(result)
  expect_equal(nrow(fks), 2)
})

test_that("dm_infer_keys() skips ambiguous columns (all unique)", {
  tbl1 <- tibble(id = 1:3, val = c("a", "b", "c"))
  tbl2 <- tibble(id = 4:6, val = c("d", "e", "f"))

  my_dm <- dm(tbl1, tbl2)
  result <- dm_infer_keys(my_dm, heuristics = "column_name", quiet = TRUE)

  expect_equal(nrow(dm_get_all_pks(result)), 0)
  expect_equal(nrow(dm_get_all_fks(result)), 0)
})

test_that("dm_infer_keys() skips columns with no unique table", {
  tbl1 <- tibble(id = c(1L, 1L, 2L))
  tbl2 <- tibble(id = c(2L, 2L, 3L))

  my_dm <- dm(tbl1, tbl2)
  result <- dm_infer_keys(my_dm, heuristics = "column_name", quiet = TRUE)

  expect_equal(nrow(dm_get_all_pks(result)), 0)
  expect_equal(nrow(dm_get_all_fks(result)), 0)
})

test_that("dm_infer_keys() returns unchanged dm with single table", {
  single <- tibble(id = 1:3, val = c("a", "b", "c"))
  my_dm <- dm(single)

  result <- dm_infer_keys(my_dm, quiet = TRUE)
  expect_equal(nrow(dm_get_all_pks(result)), 0)
})

test_that("dm_infer_keys() preserves existing keys", {
  orders <- tibble(
    order_id = 1:5,
    customer_id = c(1L, 2L, 1L, 3L, 2L)
  )

  customers <- tibble(
    customer_id = 1:3,
    name = c("Alice", "Bob", "Charlie")
  )

  my_dm <- dm(orders, customers) %>%
    dm_add_pk(customers, customer_id)

  result <- dm_infer_keys(my_dm, heuristics = "column_name", quiet = TRUE)

  expect_equal(nrow(dm_get_all_pks(result)), 1)
  expect_equal(nrow(dm_get_all_fks(result)), 1)
})

test_that("dm_infer_keys() emits message when quiet = FALSE", {
  orders <- tibble(order_id = 1:3, customer_id = c(1L, 2L, 1L))
  customers <- tibble(customer_id = 1:2, name = c("A", "B"))

  my_dm <- dm(orders, customers)

  expect_message(
    dm_infer_keys(my_dm, heuristics = "column_name"),
    "dm_add_pk"
  )

  expect_message(
    dm_infer_keys(my_dm, heuristics = "column_name"),
    "dm_add_fk"
  )
})

test_that("dm_infer_keys() is quiet when quiet = TRUE", {
  orders <- tibble(order_id = 1:3, customer_id = c(1L, 2L, 1L))
  customers <- tibble(customer_id = 1:2, name = c("A", "B"))

  my_dm <- dm(orders, customers)
  expect_silent(dm_infer_keys(my_dm, heuristics = "column_name", quiet = TRUE))
})

test_that("dm_infer_keys() handles no shared columns", {
  tbl1 <- tibble(a = 1:3)
  tbl2 <- tibble(b = 4:6)

  my_dm <- dm(tbl1, tbl2)
  expect_message(
    result <- dm_infer_keys(my_dm, heuristics = "column_name"),
    "No keys could be inferred"
  )
  expect_equal(nrow(dm_get_all_pks(result)), 0)
})

test_that("dm_infer_keys() id_column heuristic works", {
  customers <- tibble(
    id = 1:3,
    name = c("Alice", "Bob", "Charlie")
  )

  orders <- tibble(
    id = 1:5,
    customers_id = c(1L, 2L, 1L, 3L, 2L),
    amount = c(100, 200, 150, 300, 250)
  )

  my_dm <- dm(customers, orders)
  result <- dm_infer_keys(my_dm, heuristics = "id_column", quiet = TRUE)

  pks <- dm_get_all_pks(result)
  expect_true("customers" %in% pks$table)

  fks <- dm_get_all_fks(result)
  expect_equal(nrow(fks), 1)
  expect_equal(fks$child_table, "orders")
  expect_equal(fks$parent_table, "customers")
})

test_that("dm_infer_keys() id_column heuristic handles singular form", {
  customers <- tibble(
    id = 1:3,
    name = c("Alice", "Bob", "Charlie")
  )

  orders <- tibble(
    id = 1:5,
    customer_id = c(1L, 2L, 1L, 3L, 2L),
    amount = c(100, 200, 150, 300, 250)
  )

  my_dm <- dm(customers, orders)
  result <- dm_infer_keys(my_dm, heuristics = "id_column", quiet = TRUE)

  fks <- dm_get_all_fks(result)
  expect_equal(nrow(fks), 1)
  expect_equal(fks$child_table, "orders")
  expect_equal(fks$parent_table, "customers")
})

test_that("dm_infer_keys() auto heuristic uses all heuristics", {
  customers <- tibble(
    id = 1:3,
    name = c("Alice", "Bob", "Charlie")
  )

  orders <- tibble(
    id = 1:5,
    customer_id = c(1L, 2L, 1L, 3L, 2L),
    amount = c(100, 200, 150, 300, 250)
  )

  my_dm <- dm(customers, orders)
  result <- dm_infer_keys(my_dm, heuristics = "auto", quiet = TRUE)

  fks <- dm_get_all_fks(result)
  expect_true(nrow(fks) >= 1)
})

test_that("dm_infer_keys() emits dm_add_fk code with ref_columns for id_column heuristic", {
  customers <- tibble(
    id = 1:3,
    name = c("Alice", "Bob", "Charlie")
  )

  orders <- tibble(
    id = 1:5,
    customer_id = c(1L, 2L, 1L, 3L, 2L)
  )

  my_dm <- dm(customers, orders)

  expect_message(
    dm_infer_keys(my_dm, heuristics = "id_column"),
    "dm_add_fk.*customer_id.*customers.*id"
  )
})

test_that("dm_infer_keys() default heuristics is auto", {
  orders <- tibble(
    order_id = 1:5,
    customer_id = c(1L, 2L, 1L, 3L, 2L)
  )

  customers <- tibble(
    customer_id = 1:3,
    name = c("Alice", "Bob", "Charlie")
  )

  my_dm <- dm(orders, customers)

  result_auto <- dm_infer_keys(my_dm, quiet = TRUE)
  result_explicit <- dm_infer_keys(my_dm, heuristics = "auto", quiet = TRUE)

  expect_equal(
    nrow(dm_get_all_pks(result_auto)),
    nrow(dm_get_all_pks(result_explicit))
  )
  expect_equal(
    nrow(dm_get_all_fks(result_auto)),
    nrow(dm_get_all_fks(result_explicit))
  )
})

test_that("singularize() handles common patterns", {
  expect_equal(dm:::singularize("customers"), "customer")
  expect_equal(dm:::singularize("categories"), "category")
  expect_equal(dm:::singularize("addresses"), "address")
  expect_equal(dm:::singularize("boxes"), "box")
  expect_equal(dm:::singularize("matches"), "match")
  expect_equal(dm:::singularize("customer"), "customer")
})
