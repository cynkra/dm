g_table_names <- character()


gui_server <- function(input, output, session) {

  # debug <- isTRUE(getOption("shiny.fullstacktrace"))
  # if (!debug) {
  #   print <- function(x, ...) invisible(x)
  # }

  # data and filters -------------------------------------------------------------

  r_ops_stack <- shiny::reactiveVal(
    ops_stack(new_mw_cg(getOption("dm.gui_init_dm")))
  )

  r_ops <- shiny::reactive({
    ops_stack_current(r_ops_stack())
  })

  r_svg_elements <- shiny::reactiveVal()
  shiny::observe({
    r_svg_elements(input$svg_elements)
  })

  r_dm <- shiny::reactive({
    r_ops()$dm
  })


  # Not every update in dm needs to reset the svg values
  # trigger by: r_reset_svg(r_reset_svg() + 1)
  r_reset_svg <- shiny::reactiveVal(0)
  shiny::observeEvent(r_reset_svg(), {
    # reset input reactive value
    # FIXME: Move to htmlwidget
    session$sendCustomMessage(type = "reset_value", message = "svg_elements")
    r_svg_elements(NULL)
  })

  r_call <- shiny::reactive({
    paste(utils::capture.output(print.cg_code_block(r_ops()$cg)), collapse = "\n")
    # format(r_ops()$cg)
  })

  shiny::observe({
    shinyAce::updateAceEditor(session, "i_call", r_call())
  })


  # edge selector -----------------------------------------------------------

  r_edge_names <- shiny::reactive({
    dm <- shiny::req(r_dm())
    svg_elements <- r_svg_elements()
    as.character(svg_elements$edge)
  })

  r_edge_table <- shiny::reactive({
    dm <- shiny::req(r_dm())
    all_fks <- dm_get_all_fks_impl(r_dm(), id = TRUE) %>%
      filter(id %in% r_edge_names()) %>%
      select(-on_delete, -id)
  })


  # table selector -------------------------------------------------------------

  # a) from SVG
  r_table_names_svg <- shiny::reactive({
    dm <- shiny::req(r_dm())
    svg_elements <- r_svg_elements()
    as.character(svg_elements$nodes)
  })

  # Update by:
  # - svg
  # - switch
  # - select works through svg
  r_table_names_ordered <- shiny::reactiveVal()

  shiny::observe({
    table_names <- r_table_names_svg()
    table_names <- c(intersect(g_table_names, table_names), setdiff(table_names, g_table_names))
    g_table_names <<- table_names
    r_table_names_ordered(table_names)
  })
  shiny::observeEvent(input$i_switch_tbls, {
    table_names <- rev(r_table_names_ordered())
    g_table_names <<- table_names
    r_table_names_ordered(table_names)
  })


  # Is there a better solution for this? Seems like a standard problem:
  # Two input widgets that update each other.

  g_table_names_select <- character()
  g_update_time <- Sys.time()

  r_table_names_select <- shiny::reactive({
    selected_tables <- input$i_selected_tables
    if (is.null(selected_tables)) {
      selected_tables <- character(0)
      session$sendCustomMessage(type = "reset_value", message = "svg_elements")
    }
    g_table_names_select <<- selected_tables
    g_update_time <<- Sys.time()

    selected_tables
  })


  # On start, after new dm, remove choices
  shiny::observe({
    choices <- names(r_dm())
    shiny::updateSelectizeInput(
      session,
      "i_selected_tables",
      choices = choices,
      selected = shiny::isolate(r_table_names_ordered())
    )
  })

  shiny::observeEvent(input$i_selected_tables,
    {
      selected_tables <- input$i_selected_tables
      r_table_names_ordered(selected_tables)
    },
    ignoreInit = TRUE
  )


  # Update select only if changed by svg or switch
  shiny::observe({
    choices <- names(shiny::isolate(r_dm()))
    table_names <- r_table_names_ordered()

    # do not self-update: changes in svg or should only trigger an update of
    # select if it was NOT induced by select itself.
    if (identical(table_names, g_table_names_select)) return(NULL)

    # To avoid infite loops
    # Not perfect: One could update and then click on SVG
    if (Sys.time() - g_update_time < 0.3) return(NULL)

    shiny::updateSelectizeInput(
      session,
      "i_selected_tables",
      choices = choices,
      selected = table_names
    )
  })


  # view modes -----------------------------------------------------------------

  # so we can use shiny::conditionalPanel() and avoid renderUI for now
  output$are_tables_selected <- shiny::reactive({
    length(r_table_names_ordered()) > 0
  })
  shiny::outputOptions(output, "are_tables_selected", suspendWhenHidden = FALSE)

  output$are_two_tables_selected <- shiny::reactive({
    length(r_table_names_ordered()) == 2
  })
  shiny::outputOptions(output, "are_two_tables_selected", suspendWhenHidden = FALSE)

  output$is_one_table_selected <- shiny::reactive({
    length(r_table_names_ordered()) == 1
  })
  shiny::outputOptions(output, "is_one_table_selected", suspendWhenHidden = FALSE)

  output$is_one_or_two_table_selected <- shiny::reactive({
    length(r_table_names_ordered()) %in% 1:2
  })
  shiny::outputOptions(output, "is_one_or_two_table_selected", suspendWhenHidden = FALSE)


  # table mode (1 table selected) ----------------------------------------------

  r_data_column <- shiny::reactiveVal()

  shiny::observe({
    table_name <- r_table_names_ordered()
    if (!(length(table_name) %in% 1:2)) {
      r_data_column(NULL)
    } else {
      dm <- r_dm()
      data <- data_column(dm, table_name[[1]])
      r_data_column(data)
    }
  })

  output$o_column <- reactable::renderReactable({
    table_name <- shiny::req(r_table_names_ordered())
    data <- shiny::req(r_data_column())
    reactable_column(data, table_name[1])
  })

  # FIXME: Clean up
  r_column_names <- shiny::reactive({
    table_name <- r_table_names_ordered()
    if (length(table_name) == 1) {
      n <- reactable::getReactableState("o_column", "selected")
      shiny::req(r_data_column())[n, ] |> dplyr::pull(name)
    } else if (length(table_name) == 2) {
      n <- reactable::getReactableState("o_column_1", "selected")
      shiny::req(r_data_column())[n, ] |> dplyr::pull(name)
    }
  })

  # so we can use shiny::conditionalPanel() and avoid renderUI for now
  output$are_columns_selected <- shiny::reactive({
    length(r_column_names()) > 0
  })
  shiny::outputOptions(output, "are_columns_selected", suspendWhenHidden = FALSE)

  # 2 table mode (2 tables selected) -------------------------------------------

  r_data_column_2 <- shiny::reactiveVal()

  shiny::observe({
    table_name <- r_table_names_ordered()
    if (length(table_name) != 2) {
      r_data_column_2(NULL)
    } else {
      dm <- r_dm()
      data <- data_column(dm, table_name[[2]])
      r_data_column_2(data)
    }
  })

  output$o_column_2 <- reactable::renderReactable({
    data <- shiny::req(r_data_column_2())
    table_name <- shiny::req(r_table_names_ordered())
    reactable_column(data, table_name = table_name[2])
  })

  # FIXME: single view is most likely different from dual view
  output$o_column_1 <- reactable::renderReactable({
    table_name <- shiny::req(r_table_names_ordered())
    data <- shiny::req(r_data_column())
    reactable_column(data, table_name[1])
  })


  r_column_2_names <- shiny::reactive({
    n <- reactable::getReactableState("o_column_2", "selected")
    shiny::req(r_data_column_2())[n, ] |> dplyr::pull(name)
  })

  # so we can use shiny::conditionalPanel() and avoid renderUI for now
  output$are_columns_2_selected <- shiny::reactive({
    length(r_column_2_names()) > 0
  })
  shiny::outputOptions(output, "are_columns_2_selected", suspendWhenHidden = FALSE)


  # calls to middleware --------------------------------------------------------

  # update a reactive r_obs in each step

  shiny::observeEvent(input$i_rm_tbl, {
    ans <- mw_cg_run(
      r_ops(), "dm_select_tbl",
      table_names = r_table_names_ordered(),
      rm = TRUE,
      abort_function = ~ showNotification(.x, type = "error")
    )
    r_reset_svg(r_reset_svg() + 1)
    r_ops_stack(ops_stack_append(r_ops_stack(), ans))
  })

  shiny::observeEvent(input$i_select_tbl, {
    ans <- mw_cg_run(
      r_ops(), "dm_select_tbl",
      table_names = r_table_names_ordered(),
      abort_function = ~ showNotification(.x, type = "error")
    )
    r_reset_svg(r_reset_svg() + 1)
    r_ops_stack(ops_stack_append(r_ops_stack(), ans))
  })

  shiny::observeEvent(input$i_add_pk, {
    ans <- mw_cg_run(
      r_ops(), "dm_add_pk",
      table_names = r_table_names_ordered(),
      column_names = r_column_names(),
      abort_function = ~ showNotification(.x, type = "error")
    )
    r_ops_stack(ops_stack_append(r_ops_stack(), ans))
  })

  shiny::observeEvent(input$i_add_fk, {
    ans <- mw_cg_run(
      r_ops(), "dm_add_fk",
      table_names = r_table_names_ordered(),
      column_names = r_column_names(),
      other_column_names = r_column_2_names(),
      abort_function = ~ showNotification(.x, type = "error")
    )
    r_ops_stack(ops_stack_append(r_ops_stack(), ans))
  })

  shiny::observeEvent(input$i_rm_fk, {
    ans <- mw_cg_run(
      r_ops(), "dm_rm_fk",
      edge_table = r_edge_table(),
      abort_function = ~ showNotification(.x, type = "error")
    )

    r_ops_stack(ops_stack_append(r_ops_stack(), ans))
  })

  shiny::observeEvent(input$i_disentangle, {
    ans <- mw_cg_run(
      r_ops(), "dm_disentangle",
      table_names = r_table_names_ordered(),
      abort_function = ~ showNotification(.x, type = "error")
    )

    r_ops_stack(ops_stack_append(r_ops_stack(), ans))
  })

  shiny::observeEvent(input$i_choose_color, {
    ans <- mw_cg_run(
      r_ops(), "dm_set_colors",
      table_names = r_table_names_ordered(),
      color_name = input$i_choose_color,
      abort_function = ~ showNotification(.x, type = "error")
    )

    r_ops_stack(ops_stack_append(r_ops_stack(), ans))
  }, ignoreInit = TRUE)

  shiny::observeEvent(input$i_rm_col, {
    ans <- mw_cg_run(
      r_ops(), "dm_select",
      table_names = r_table_names_ordered(),
      column_names = r_column_names(),
      rm = TRUE,
      abort_function = ~ showNotification(.x, type = "error")
    )

    r_ops_stack(ops_stack_append(r_ops_stack(), ans))
  })

  shiny::observeEvent(input$i_return, {
    shiny::stopApp(r_call())
  })

  shiny::observeEvent(input$i_undo, {
    # ops_stack_can_undo(r_ops_stack())
    r_ops_stack(ops_stack_undo(r_ops_stack()))
  })

  shiny::observeEvent(input$i_redo, {
    # ops_stack_can_redo(r_ops_stack())
    r_ops_stack(ops_stack_redo(r_ops_stack()))
  })


  # output ---------------------------------------------------------------------

  r_node_to_zoom <- shiny::reactiveVal(character())
  shiny::observeEvent(input$i_zoom_to_selected, {
    r_node_to_zoom(r_table_names_ordered())
  })

  output$o_svg <- renderDmSVG({
    dm <- r_dm()
    dmSVG(dm, viewBox = FALSE, node_to_zoom = r_node_to_zoom(), nodes_to_select = I(r_table_names_select()))
  })
}
