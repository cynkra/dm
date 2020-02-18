is_dark_color <- function(rgb) {
  # according to https://stackoverflow.com/questions/3942878/how-to-decide-font-color-in-white-or-black-depending-on-background-color
  # and https://www.w3.org/WAI/WCAG21/Techniques/general/G18.html
  # you should calculate luminance first and then compare its contrast to white and black
  #
  # But after evaluating results from this approach and taking the alpha channel into account,
  # it seems more natural to use a formula like this:
  sum(rgb[1:3] / 255. * c(0.3, 0.5, 0.2)) + (255. - rgb[4]) / 255. * 0.2 < 0.6
  #  + (255 - rgb[4]) / 255. * 0.15
  # the weights are inspired by the sources mentioned above (only the differences between them are much smaller here)
}

is_hex_color <- function(x) {
  grepl("^#[A-Fa-f0-9]{6}([A-Fa-f0-9]{2})?$", x)
}

col_to_hex <- function(x) {
  # if not all colors that are not hex coded colors are available, abort
  if (!all(x[!is_hex_color(x)] %in% dm_get_available_colors())) {
    abort_cols_not_avail(setdiff(
      x[!is_hex_color(x)],
      dm_get_available_colors()
    ))
  }

  # from hex or name to rgb; "default" should remain "default"
  is_not_default <- which(x != "default")
  x[is_not_default] <- hex_from_rgb(col2rgb(x[is_not_default], alpha = TRUE))
  x
}

hex_from_rgb <- function(col_rgb) {
  rgb(col_rgb[1, ], col_rgb[2, ], col_rgb[3, ], col_rgb[4, ], maxColorValue = 255)
}

calc_bodycol_rgb <- function(header_bgcol_rgb) {
  # alpha channel remains the same for the body color
  header_bgcol_rgb[1:3, ] <- header_bgcol_rgb[1:3, ] + (255 - header_bgcol_rgb[1:3, ]) * 0.8
  header_bgcol_rgb
}
