is_dark_color <- function(rgb) {
  # according to https://stackoverflow.com/questions/3942878/how-to-decide-font-color-in-white-or-black-depending-on-background-color
  # and https://www.w3.org/WAI/WCAG21/Techniques/general/G18.html
  # you should calculate luminance first and then compare its contrast to white and black
  #
  # But after evaluating results from this approach, it seems more natural to use a formula like this:
  sum(rgb / 255. * c(0.3, 0.5, 0.2)) < 0.6
  # the weights are inspired by the sources mentioned above (only the differences between them are much smaller here)
}
