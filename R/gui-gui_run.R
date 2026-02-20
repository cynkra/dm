gui_run <- function(dm = dm_nycflights13(), select_tables = TRUE, debug = FALSE) {
  stopifnot(is_dm(dm))
  local_options(dm.gui_init_dm = dm)

  app <- shiny::shinyApp(ui = gui_ui(select_tables = select_tables), server = gui_server)

  if (debug) {
    local_options(shiny.fullstacktrace = debug)
  }

  code <- shiny::runApp(app)
  rstudioapi::sendToConsole(code, execute = FALSE)
}
