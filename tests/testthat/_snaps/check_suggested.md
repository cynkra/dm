# `check_suggested()` works

    Code
      check_suggested("rlang", TRUE, top_level_fun = "foo")
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
      check_suggested("iurtnkjvmomweicopbt", NA)
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
      check_suggested("iurtnkjvmomweicopbt", FALSE)
    Output
      [1] FALSE

# `check_suggested()` works for error messages

    Code
      check_suggested("iurtnkjvmomweicopbt", TRUE, top_level_fun = "foo")
    Condition
      Error:
      ! The package "iurtnkjvmomweicopbt" is required to use `foo()`.
    Code
      check_suggested("iurtnkjvmomweicopbt", TRUE)
    Condition
      Error:
      ! The package "iurtnkjvmomweicopbt" is required.

