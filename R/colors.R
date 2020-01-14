is_dark_color <- function(rgb) {
  # according to https://stackoverflow.com/questions/3942878/how-to-decide-font-color-in-white-or-black-depending-on-background-color
  # and https://www.w3.org/WAI/WCAG21/Techniques/general/G18.html
  # calculate luminance first, according to the source this would be:
  # L = 0.2126 * r + 0.7152 * g + 0.0722 * b
  # (this is for RGB with each component max 1, we have max 255)
  L <- 0.2126 * rgb[1] / 255 + 0.7152 * rgb[2] / 255 + 0.0722 * rgb[3] / 255

  # contrast is defined by: (L1 + 0.05) / (L2 + 0.05)
  # with L1 being the lighter color and L(black) = 0 and L(white) = 1
  # so the condition for a dark color is: is contrast with white greater than contrast with black?
  # (1.0 + 0.05) / (L + 0.05) > (L + 0.05) / (0.0 + 0.05)
  # but then e.g. "#503250" would have larger contrast with black than with white, and that just doesn't look right
  # so -- after evaluating L in small steps from 0. to 1. and looking at sample output -- I tweak the formula to:
  (1.0 + 1.) / (L + 1.) > (L + 1.) / (0.0 + 1.)
}
