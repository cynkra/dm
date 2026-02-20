dm_to_svg <- function(dm) {
  svg <-
    dm %>%
    dm::dm_draw(graph_attrs = 'bgcolor="transparent"', node_attrs = 'fontname="Helvetica"') %>%
    DiagrammeRsvg::export_svg()

  gsub('( class="(edge|node)")', '\\1 onclick="\\2Style(this.id)"', svg)
}
