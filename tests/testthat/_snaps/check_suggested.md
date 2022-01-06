# `check_suggested()` works

    Code
      check_suggested("dm", TRUE, top_level_fun = "foo")
    Output
      [1] TRUE
    Code
      check_suggested("dm", NA, top_level_fun = "foo")
    Output
      [1] FALSE
    Code
      check_suggested("not-a-package", NA, top_level_fun = "foo")
    Output
      [1] FALSE
    Code
      check_suggested("not-a-package", NA, message = "not installed!")
    Output
      [1] FALSE
    Code
      check_suggested("dm", FALSE, top_level_fun = "foo")
    Output
      [1] FALSE
    Code
      check_suggested("not-a-package", FALSE, top_level_fun = "foo")
    Output
      [1] FALSE
    Code
      check_suggested("not-a-package", FALSE, message = "not installed!")
    Output
      [1] FALSE

# `check_suggested()` works for error messages

    Code
      check_suggested("not-a-package", TRUE, top_level_fun = "foo")
    Error <rlang_error>
      Must supply valid package names.
      x Problematic names:
      * "not-a-package"
    Code
      check_suggested("not-a-package", TRUE, message = "not installed!")
    Error <rlang_error>
      Must supply valid package names.
      x Problematic names:
      * "not-a-package"

