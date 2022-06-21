test_that("enum_ops() works", {
  parent <- tibble(a = c(1L, 1:3), b = -1)
  child <- tibble(a = 1:4, c = 3)
  dm <- dm(parent, child)
  expect_equal(
    enum_ops(dm),
    list(input = list(dm = dm),
         single = list(op_name = "dm_rm_fk"),
         multiple = list(table_names = names(dm)))
  )
  expect_equal(
    enum_ops(dm, op_name = "dm_add_pk"),
    list(input = list(dm = dm, op_name = "dm_add_pk"),
         single = `names<-`(list(), character(0)),
         multiple = list(table_names = names(dm)))
  )
  expect_equal(
    enum_ops(dm, op_name = "dm_add_pk", table_names = "parent"),
    list(input = list(dm = dm,
                      table_names = "parent",
                      column_names = NULL,
                      op_name = "dm_add_pk"),
         multiple = list(column_names = colnames(dm[["parent"]])))
  )
  expect_equal(
    enum_ops(dm, op_name = "dm_add_pk", table_names = "parent", column_names = "a"),
    list(input = list(dm = dm,
                      table_names = "parent",
                      column_names = "a",
                      op_name = "dm_add_pk"),
         call = quote(dm_add_pk(., parent, a)))
  )
})
