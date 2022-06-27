# snapshot of code_generation_middleware.R is unchanged

    Code
      parent <- tibble(a = c(1L, 1:3), b = -1)
      child <- tibble(a = 1:4, c = 3)
      dm <- dm(parent, child)
      ops <- enum_ops(dm)
      ops
    Output
      $input
      $input$dm
      -- Metadata --------------------------------------------------------------------
      Tables: `parent`, `child`
      Columns: 4
      Primary keys: 0
      Foreign keys: 0
      
      
      $single
      $single$op_name
      [1] "dm_rm_fk"
      
      
      $multiple
      $multiple$table_names
      [1] "parent" "child" 
      
      
    Code
      enum_ops(dm, op_name = "dm_add_pk")
    Output
      $input
      $input$dm
      -- Metadata --------------------------------------------------------------------
      Tables: `parent`, `child`
      Columns: 4
      Primary keys: 0
      Foreign keys: 0
      
      $input$op_name
      [1] "dm_add_pk"
      
      
      $single
      named list()
      
      $multiple
      $multiple$table_names
      [1] "parent" "child" 
      
      
    Code
      enum_ops(dm, op_name = "dm_add_pk", table_names = "parent")
    Output
      $input
      $input$dm
      -- Metadata --------------------------------------------------------------------
      Tables: `parent`, `child`
      Columns: 4
      Primary keys: 0
      Foreign keys: 0
      
      $input$op_name
      [1] "dm_add_pk"
      
      $input$table_names
      [1] "parent"
      
      
      $single
      named list()
      
      $multiple
      $multiple$column_names
      [1] "a" "b"
      
      
    Code
      enum_ops(dm, op_name = "dm_add_pk", table_names = "parent", column_names = "a")$
        call
    Output
      dm_add_pk(., parent, a)
    Code
      enum_ops(dm, op_name = "dm_add_pk", table_names = "parent", column_names = c(
        "a", "b"))$call
    Output
      dm_add_pk(., parent, c(a, b))

# snapshot of code_generation_middleware_2.R is unchanged

    Code
      parent <- tibble(a = c(1L, 1:3), b = -1)
      child <- tibble(a = 1:4, c = 3)
      dm <- dm(parent, child)
      ops <- enum_ops(dm)
      ops
    Output
      $input
      $input$dm
      -- Metadata --------------------------------------------------------------------
      Tables: `parent`, `child`
      Columns: 4
      Primary keys: 0
      Foreign keys: 0
      
      
      $single
      $single$op_name
      [1] "dm_rm_fk"
      
      
      $multiple
      $multiple$table_names
      [1] "parent" "child" 
      
      
    Code
      ops$multiple
    Output
      $table_names
      [1] "parent" "child" 
      
    Code
      user_choice <- list(table_names = "parent")
      ops_2 <- exec(enum_ops, !!!ops$input, !!!user_choice)
      ops_2
    Output
      $input
      $input$dm
      -- Metadata --------------------------------------------------------------------
      Tables: `parent`, `child`
      Columns: 4
      Primary keys: 0
      Foreign keys: 0
      
      $input$table_names
      [1] "parent"
      
      
      $single
      $single$op_name
      [1] "dm_add_pk" "dm_rm_fk" 
      
      
      $multiple
      $multiple$column_names
      [1] "a" "b"
      
      
    Code
      ops_2$single
    Output
      $op_name
      [1] "dm_add_pk" "dm_rm_fk" 
      
    Code
      user_choice_2 <- list(op_name = "dm_add_pk")
      ops_3 <- exec(enum_ops, !!!ops_2$input, !!!user_choice_2)
      ops_3
    Output
      $input
      $input$dm
      -- Metadata --------------------------------------------------------------------
      Tables: `parent`, `child`
      Columns: 4
      Primary keys: 0
      Foreign keys: 0
      
      $input$op_name
      [1] "dm_add_pk"
      
      $input$table_names
      [1] "parent"
      
      
      $single
      named list()
      
      $multiple
      $multiple$column_names
      [1] "a" "b"
      
      
    Code
      ops_3$multiple
    Output
      $column_names
      [1] "a" "b"
      
    Code
      user_choice_3 <- list(column_names = c("a"))
      ops_4 <- exec(enum_ops, !!!ops_3$input, !!!user_choice_3)
      ops_4
    Output
      $input
      $input$dm
      -- Metadata --------------------------------------------------------------------
      Tables: `parent`, `child`
      Columns: 4
      Primary keys: 0
      Foreign keys: 0
      
      $input$table_names
      [1] "parent"
      
      $input$column_names
      [1] "a"
      
      $input$op_name
      [1] "dm_add_pk"
      
      
      $call
      dm_add_pk(., parent, a)
      
    Code
      ops_4$call
    Output
      dm_add_pk(., parent, a)

# snapshot of code_generation_middleware_3.R is unchanged

    Code
      parent <- tibble(a = c(1L, 1:3), b = -1)
      child <- tibble(a = 1:4, c = 3)
      dm <- dm(parent, child)
      ops <- enum_ops(dm)
      ops
    Output
      $input
      $input$dm
      -- Metadata --------------------------------------------------------------------
      Tables: `parent`, `child`
      Columns: 4
      Primary keys: 0
      Foreign keys: 0
      
      
      $single
      $single$op_name
      [1] "dm_rm_fk"
      
      
      $multiple
      $multiple$table_names
      [1] "parent" "child" 
      
      
    Code
      ops$multiple
    Output
      $table_names
      [1] "parent" "child" 
      
    Code
      user_choice <- list(table_names = "parent")
      ops_2 <- exec(enum_ops, !!!ops$input, !!!user_choice)
      ops_2
    Output
      $input
      $input$dm
      -- Metadata --------------------------------------------------------------------
      Tables: `parent`, `child`
      Columns: 4
      Primary keys: 0
      Foreign keys: 0
      
      $input$table_names
      [1] "parent"
      
      
      $single
      $single$op_name
      [1] "dm_add_pk" "dm_rm_fk" 
      
      
      $multiple
      $multiple$column_names
      [1] "a" "b"
      
      
    Code
      ops_2$multiple
    Output
      $column_names
      [1] "a" "b"
      
    Code
      user_choice_2 <- list(column_names = c("a"))
      ops_3 <- exec(enum_ops, !!!ops_2$input, !!!user_choice_2)
      ops_3
    Output
      $input
      $input$dm
      -- Metadata --------------------------------------------------------------------
      Tables: `parent`, `child`
      Columns: 4
      Primary keys: 0
      Foreign keys: 0
      
      $input$column_names
      [1] "a"
      
      $input$table_names
      [1] "parent"
      
      
      $single
      $single$op_name
      [1] "dm_add_pk"
      
      
      $multiple
      named list()
      
    Code
      ops_3$single
    Output
      $op_name
      [1] "dm_add_pk"
      
    Code
      user_choice_3 <- list(op_name = "dm_add_pk")
      ops_4 <- exec(enum_ops, !!!ops_3$input, !!!user_choice_3)
      ops_4
    Output
      $input
      $input$dm
      -- Metadata --------------------------------------------------------------------
      Tables: `parent`, `child`
      Columns: 4
      Primary keys: 0
      Foreign keys: 0
      
      $input$table_names
      [1] "parent"
      
      $input$column_names
      [1] "a"
      
      $input$op_name
      [1] "dm_add_pk"
      
      
      $call
      dm_add_pk(., parent, a)
      
    Code
      ops_4$call
    Output
      dm_add_pk(., parent, a)

# snapshot of code_generation_middleware_4.R is unchanged

    Code
      parent <- tibble(a = c(1L, 1:3), b = -1)
      child <- tibble(a = 1:4, c = 3)
      dm <- dm(parent, child) %>% dm_add_pk(parent, b)
      ops <- enum_ops(dm)
      ops
    Output
      $input
      $input$dm
      -- Metadata --------------------------------------------------------------------
      Tables: `parent`, `child`
      Columns: 4
      Primary keys: 1
      Foreign keys: 0
      
      
      $single
      $single$op_name
      [1] "dm_rm_fk"
      
      
      $multiple
      $multiple$table_names
      [1] "parent" "child" 
      
      
    Code
      ops$multiple
    Output
      $table_names
      [1] "parent" "child" 
      
    Code
      user_choice <- list(table_names = "parent")
      ops_2 <- exec(enum_ops, !!!ops$input, !!!user_choice)
      ops_2
    Output
      $input
      $input$dm
      -- Metadata --------------------------------------------------------------------
      Tables: `parent`, `child`
      Columns: 4
      Primary keys: 1
      Foreign keys: 0
      
      $input$table_names
      [1] "parent"
      
      
      $single
      $single$op_name
      [1] "dm_add_pk" "dm_rm_fk" 
      
      
      $multiple
      $multiple$column_names
      [1] "a" "b"
      
      
    Code
      ops_2$multiple
    Output
      $column_names
      [1] "a" "b"
      
    Code
      user_choice_2 <- list(column_names = c("a"))
      ops_3 <- exec(enum_ops, !!!ops_2$input, !!!user_choice_2)
      ops_3
    Output
      $input
      $input$dm
      -- Metadata --------------------------------------------------------------------
      Tables: `parent`, `child`
      Columns: 4
      Primary keys: 1
      Foreign keys: 0
      
      $input$column_names
      [1] "a"
      
      $input$table_names
      [1] "parent"
      
      
      $single
      $single$op_name
      [1] "dm_add_pk"
      
      
      $multiple
      named list()
      
    Code
      ops_3$single
    Output
      $op_name
      [1] "dm_add_pk"
      
    Code
      user_choice_3 <- list(op_name = "dm_add_pk")
      ops_4 <- exec(enum_ops, !!!ops_3$input, !!!user_choice_3)
      ops_4
    Output
      $input
      $input$dm
      -- Metadata --------------------------------------------------------------------
      Tables: `parent`, `child`
      Columns: 4
      Primary keys: 1
      Foreign keys: 0
      
      $input$table_names
      [1] "parent"
      
      $input$column_names
      [1] "a"
      
      $input$op_name
      [1] "dm_add_pk"
      
      
      $call
      dm_add_pk(., parent, a, force = TRUE)
      
      $confirmation_message
      [1] "This table already has a primary key. Please confirm overwriting the existing primary key."
      
    Code
      ops_4$call
    Output
      dm_add_pk(., parent, a, force = TRUE)

