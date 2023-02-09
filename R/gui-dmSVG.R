#' dmSVG
#'
#' Widget
#'
#' @noRd
dmSVG <- function(dm, viewBox = TRUE, node_to_zoom = NULL, nodes_to_select = NULL, ..., width = NULL, height = NULL, elementId = NULL) {
  svg_text <- dm_to_svg(dm)

  # forward options using x
  x <- list(
    svg = htmltools::HTML(svg_text),
    config = list(...),
    options = list(
      viewBox = viewBox
    ),
    panZoomOpts = list(
      node_id = node_to_zoom,
      nodes_to_select = nodes_to_select
    )
  )

  # create widget
  htmlwidgets::createWidget(
    name = "dmSVG",
    x,
    width = width,
    height = height,
    package = utils::packageName(),
    elementId = elementId
  )
}

#' Shiny bindings for dmSVG
#'
#' Output and render functions for using dmSVG within Shiny
#' applications and interactive Rmd documents.
#'
#' @param outputId output variable to read from
#' @param width,height Must be a valid CSS unit (like \code{'100\%'},
#'   \code{'400px'}, \code{'auto'}) or a number, which will be coerced to a
#'   string and have \code{'px'} appended.
#' @param expr An expression that generates a dmSVG
#' @param env The environment in which to evaluate \code{expr}.
#' @param quoted Is \code{expr} a quoted expression (with \code{quote()})? This
#'   is useful if you want to save an expression in a variable.
#'
#' @name dmSVG-shiny
#'
#' @noRd
dmSVGOutput <- function(outputId, width = "100%", height = "400px") {
  htmlwidgets::shinyWidgetOutput(outputId, "dmSVG", width, height, package = "dm")
}

#' @rdname dmSVG-shiny
#' @noRd
renderDmSVG <- function(expr, env = parent.frame(), quoted = FALSE) {
  if (!quoted) {
    expr <- substitute(expr)
  } # force quoted
  htmlwidgets::shinyRenderWidget(expr, dmSVGOutput, env, quoted = TRUE)
}
