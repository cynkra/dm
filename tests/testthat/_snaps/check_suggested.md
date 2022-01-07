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
      check_suggested("iurtnkjvmomweicopbt", NA, top_level_fun = "foo")
    Output
      [1] FALSE
    Code
      check_suggested("iurtnkjvmomweicopbt", NA, message = "not installed!")
    Output
      [1] FALSE
    Code
      check_suggested("dm", FALSE, top_level_fun = "foo")
    Output
      [1] FALSE
    Code
      check_suggested("iurtnkjvmomweicopbt", FALSE, top_level_fun = "foo")
    Output
      [1] FALSE
    Code
      check_suggested("iurtnkjvmomweicopbt", FALSE, message = "not installed!")
    Output
      [1] FALSE

# `check_suggested()` works for error messages

    Code
      check_suggested("iurtnkjvmomweicopbt", TRUE, top_level_fun = "foo")
    Error <rlang_error>
      `foo()` needs the 'iurtnkjvmomweicopbt' package. Do you need `install.packages("iurtnkjvmomweicopbt")` ?
    Code
      check_suggested("iurtnkjvmomweicopbt", TRUE, message = "not installed!")
    Error <rlang_error>
      not installed!

