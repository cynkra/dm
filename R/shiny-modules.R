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
