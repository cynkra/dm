#' @export
rowSelectorUI <- function(id) {
  ns <- NS(id)

  div(
    fluidRow(
      box(
        width = 6,
        selectableUI(ns("tb_left"), ">>")
      ),
      box(
        width = 6,
        selectableUI(ns("tb_right"), "<<")
      )
    )
  )
}

#' @export
selectableUI <- function(id, move_caption) {
  ns <- NS(id)

  div(
    p(
      actionButton(ns("sel_all_vis"), "+ all visible"),
      actionButton(ns("desel_all_vis"), "- all visible"),
      actionButton(ns("toggle_vis"), "* visible"),
      actionButton(ns("sel_non_vis"), "+ all invisible"),
      actionButton(ns("sel_all"), "+ all"),
      actionButton(ns("desel_all"), "- all"),
      actionButton(ns("clear_search"), "clear search"),
      actionButton(ns("move"), move_caption)
    ),
    dataTableOutput(ns("tb"))
  )
}

#' @export
rowSelector <- function(input, output, session, app_data, avail) {

  selected <- reactiveVal(rep(FALSE, nrow(app_data)))

  avail_data <- reactive({
    app_data %>%
      mutate(.available = avail()) %>%
      un_sf()
  })

  data_left <- reactive(avail_data()[!selected(), ])
  data_right <- reactive(avail_data()[selected(), ])

  sel_left <- callModule(selectable, "tb_left", data = data_left)
  sel_right <- callModule(selectable, "tb_right", data = data_right)

  observeEvent(sel_left$move(), {
    curr_sel <- selected()
    new_sel <- which(!curr_sel)[sel_left$selected()]
    curr_sel[ new_sel ] <- TRUE

    app_data[[".selected"]] <<- FALSE
    app_data[[".selected"]][new_sel] <<- TRUE

    selected(curr_sel)
  })

  observeEvent(sel_right$move(), {
    curr_sel <- selected()
    new_sel <- which(curr_sel)[sel_right$selected()]
    curr_sel[ new_sel ] <- FALSE

    app_data[[".selected"]] <<- FALSE
    app_data[[".selected"]][new_sel] <<- TRUE

    selected(curr_sel)
  })

  # return selection
  list(
    selected = reactive(which(selected())),
    data = reactive(app_data)
  )
}

#' @export
selectable <- function(input, output, session, data) {
  dt <-
    datatable(
      isolate(data()[0, ]),
      extensions = "Scroller",
      options = list(
        deferRender = TRUE, # Elements will be created only when the are required
        scrollX = TRUE,
        scrollY = 200, # height of displayed table
        scroller = TRUE
      )
    ) %>%
    formatStyle(
      ".available",
      target = "row",
      color = styleEqual(c(0, 1), c("gray", "black"))
    )

  sorted_data <- reactive({
    unsorted_data <- data()
    order <- order(!unsorted_data$.available)

    list(
      order = order,
      data = unsorted_data[order, ]
    )
  })

  output$tb <- DT::renderDataTable(dt, server = TRUE)

  dtp <- dataTableProxy("tb")

  observe({
    # Dieser Observer wird bei der Initialisierung gefeurt.
    # Das Befüllen funktioniert aus irgendeinem Grund aber nur,
    # wenn das DT-Control zum Zeitpunkt der Initialisierung auch sichtbar ist.
    # Aus diesem Grund werden die tabItems verzögert initialisiert.
    dtpp <- dtp

    # https://github.com/rstudio/DT/issues/357#issuecomment-465073059
    dtpp$rawId <- dtpp$id

    new_data <- sorted_data()$data

    selected <- integer()
    if (".selected" %in% names(new_data)) {
      selected <- which(new_data[[".selected"]])
      new_data[[".selected"]] <- NULL
    }

    dtpp %>%
      replaceData(new_data)

    if (rlang::has_length(selected)) {
      dtp %>%
        selectRows(selected)
    }
  })

  observeEvent(input$sel_all_vis, {

    rs <- input$tb_rows_selected # rows selected

    dtp %>%
      selectRows(union(rs, input$tb_rows_all))
  })

  observeEvent(input$desel_all_vis, {

    rs <- input$tb_rows_selected # rows selected
    avr <- input$tb_rows_all # all visible rows

    dtp %>%
      selectRows(union(rs, avr) %>% setdiff(avr)) # only rows that are not visible should be kept in selection
  })

  observeEvent(input$sel_non_vis, {

    rs <- input$tb_rows_selected # rows selected

    ar <- 1:nrow(data()) # all rows
    avr <- input$tb_rows_all # all visible rows

    dtp %>%
      selectRows(union(rs, setdiff(ar, avr))) # all rows that are not visible should be selected
  })

  observeEvent(input$toggle_vis, {

    rs <- input$tb_rows_selected # rows selected
    avr <- input$tb_rows_all # all visible rows

    dtp %>%
      selectRows(setdiff(avr, intersect(rs, avr))) # all rows that are visible but not selected should be selected
  })

  observeEvent(input$sel_all, {

    ar <- 1:nrow(data()) # rows selected

    dtp %>%
      selectRows(ar) # all rows that are not visible should be selected
  })

  observeEvent(input$desel_all, {

    dtp %>%
      selectRows(numeric()) # all rows that are not visible should be selected
  })

  observeEvent(input$clear_search, {

    dtp %>%
      clearSearch()

  })

  list(
    all = reactive(sorted_data()$order[input$tb_rows_all]),
    selected = reactive(sorted_data()$order[input$tb_rows_selected]),
    state = reactive(input$tb_state),
    move = reactive(input$move),
    data = data
  )
}
