# `check_suggested()` works

    Code
      check_suggested("dm", TRUE, top_level_fun = "foo")
    Output
      [1] TRUE
    Code
      try(check_suggested("not-a-package", TRUE, top_level_fun = "foo"))
    Output
      Error : `foo()` needs the 'not-a-package' package. Do you need `install.packages("not-a-package")` ?
    Code
      try(check_suggested("not-a-package", TRUE, message = "not installed!"))
    Output
      Error : not installed!
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

