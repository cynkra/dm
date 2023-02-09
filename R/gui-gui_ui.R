# do not add 'btn-default' class, so we can customize
actionButton2 <- function(inputId, label, icon = NULL, width = NULL, ...) {
  value <- shiny::restoreInput(id = inputId, default = NULL)
  shiny::tags$button(
    id = inputId, style = htmltools::css(width = htmltools::validateCssUnit(width)),
    type = "button", class = "btn action-button",
    `data-val` = value, list(("shiny" %:::% "validateIcon")(icon), label),
    ...
  )
}




# FIXME no need for custom HTML (I guess)
html_logo <- function() {
  shiny::tags$span(class = "logo", shiny::span(style = "font-size: 100%; font-weight: bold; letter-spacing: .1rem;", "DM"), shiny::span(style = "font-size: 70%; letter-spacing: .1rem;", "R DATA MODELS"))
}

html_header <- function() {
  shiny::tags$header(
    class = "main-header",
    html_logo(),
    shiny::tags$nav(
      class = "navbar navbar-static-top", role = "navigation",
      shiny::tags$span(
        style = "display:none;",
        shiny::tags$i(class = "fa fa-bars")
      ),
      shiny::tags$a(
        href = "#", class = "sidebar-toggle", `data-toggle` = "offcanvas", role = "button",
        shiny::tags$span(class = "sr-only", "Toggle navigation")
      ),
      shiny::tags$div(
        class = "navbar-custom-menu",
        shiny::tags$ul(
          class = "nav navbar-nav",
          shiny::tags$div(
            class = "navbar-custom-menu",
            shiny::tags$ul(
              class = "nav navbar-nav",
              shiny::tags$li(actionButton2("i_undo", label = NULL, icon = shiny::icon(verify_fa = FALSE, "undo"), class = "btn btn-default", style = "margin-top: 9px; margin-right: 15px;")),
              shiny::tags$li(actionButton2("i_redo", label = NULL, icon = shiny::icon(verify_fa = FALSE, "redo"), class = "btn btn-default", style = "margin-top: 9px; margin-right: 15px;")),
              shiny::tags$li(shiny::tags$button(
                id = "i_return", style = "margin-top: 9px; margin-right: 15px;", href = "#", type = "button",
                class = "btn btn-primary btn action-button btn-navbar",
                shiny::icon(verify_fa = FALSE, "fas fa-sign-out-alt", ), "To Console"
              ))
            )
          )
        )
      )
    )
  )
}






gui_ui <- function(ns, select_tables = TRUE) {
  shinydashboard::dashboardPage(
    skin = "black",
    html_header(),
    shinydashboard::dashboardSidebar(
      disable = TRUE
    ),
    shinydashboard::dashboardBody(
      shiny::tags$head(
        shiny::tags$link(href = "docs.css", rel = "stylesheet")
      ),
      shiny::fluidRow(
        shiny::column(6,
          style = "padding: 0px;",
          shinydashboard::box(
            status = "primary",
            width = 12,
            # FIXME: Incorporate selectize into dmSVG(), manage state internally
            if (select_tables) {
              shiny::tagList(
                shiny::selectizeInput(
                  "i_selected_tables",
                  label = NULL,
                  multiple = TRUE,
                  choices = NULL,
                  options = list(
                    placeholder = "Select or search one or several tables",
                    plugins = list("remove_button")
                  ),
                  width = "100%"
                ),
                dmSVGOutput("o_svg", height = "570px")
              )
            } else {
              dmSVGOutput("o_svg", height = "626px")
            },
            footer = shiny::tagList(
              actionButton2("i_zoom_to_selected", "Zoom", icon = shiny::icon(verify_fa = FALSE, "binoculars"), class = "btn btn-info btn-app"),
              actionButton2("i_rm_tbl", "Delete table", icon = shiny::icon(verify_fa = FALSE, "trash-alt"), class = "btn btn-info btn-app"),
              actionButton2("i_select_tbl", "Select table", icon = shiny::icon(verify_fa = FALSE, "table"), class = "btn btn-info btn-app"),
              actionButton2("i_rm_fk", "Remove foreign key", icon = shiny::icon(verify_fa = FALSE, "unlink"), class = "btn btn-info btn-app"),
              actionButton2("i_disentangle", "Remove cycles", icon = shiny::icon(verify_fa = FALSE, "circle-notch"), class = "btn btn-info btn-app"),
              shiny::tags$style(htmltools::HTML("
                #colorpicker-user>.shiny-input-container {
                  display: inline-block !important;
                  float: right !important;
                  width: 140px !important;
                  margin-right: 10px !important;
                }
                .colourpicker-panel {
                  left: -50px;
                  top: -130px;
                }
              ")),
              htmltools::span(
                id = "colorpicker-user",
                colourpicker::colourInput(
                  "i_choose_color",
                  label = "Choose color",
                  value = "white",
                  showColour = "text",
                  returnName = TRUE,
                  palette = "limited",
                  closeOnClick = TRUE
                )
              )
            )
          )
        ),
        shinydashboard::box(
          title = "DM Call",
          # status = "default",
          width = 6,
          shinyAce::aceEditor(
            outputId = "i_call",
            fontSize = 18,
            mode = "r",
            readOnly = TRUE,
            theme = "tomorrow",
            height = "224px"
          )
        ),
        shiny::conditionalPanel(
          condition = "output.is_one_table_selected",
          shinydashboard::box(
            title = "Edit Table",
            status = "success",
            width = 6,
            reactable::reactableOutput("o_column"),
            footer =
              shiny::conditionalPanel(
                condition = "output.is_one_table_selected",
                shiny::tagList(
                  actionButton2("i_add_pk", "Add primary key", icon = shiny::icon(verify_fa = FALSE, "key"), class = "btn btn-info btn-app"),
                  # actionButton("i_rename_col", "Rename columns"),
                  actionButton2("i_rm_col", "Delete column", icon = shiny::icon(verify_fa = FALSE, "trash"), class = "btn btn-app")
                )
              )
          )
        ),
        shiny::conditionalPanel(
          condition = "output.are_two_tables_selected",
          shinydashboard::box(
            title = "Manage relationships between two tables",
            status = "warning",
            width = 6,
            shiny::fluidRow(
              shiny::column(6, reactable::reactableOutput("o_column_1")),
              shiny::column(6, reactable::reactableOutput("o_column_2")),
            ),
            footer = shiny::tagList(
              # p("Select two tables to manage the relationship between them."),
              actionButton2("i_add_fk", "Add foreign key", icon = shiny::icon(verify_fa = FALSE, "link"), class = "btn btn-info btn-app"),
              actionButton2("i_switch_tbls", "Switch tables", icon = shiny::icon(verify_fa = FALSE, "exchange-alt"), class = "btn btn-info btn-app")
            )
          )
        )
      )
    )
  )
}
