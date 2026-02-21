# `check_suggested()` works

    Code
      check_suggested("rlang", "foo")
    Output
      [1] TRUE
    Code
      check_suggested("dm", "foo", use = NA)
    Output
      [1] FALSE
    Code
      check_suggested("iurtnkjvmomweicopbt", "foo", use = NA)
    Output
      [1] FALSE
    Code
      check_suggested("iurtnkjvmomweicopbt", use = NA)
    Output
      [1] FALSE
    Code
      check_suggested("dm", "foo", use = FALSE)
    Output
      [1] FALSE
    Code
      check_suggested("iurtnkjvmomweicopbt", "foo", use = FALSE)
    Output
      [1] FALSE
    Code
      check_suggested("iurtnkjvmomweicopbt", use = FALSE)
    Output
      [1] FALSE

# `check_suggested()` works for error messages

    Code
      check_suggested("iurtnkjvmomweicopbt", "foo")
    Condition
      Error:
      ! The package "iurtnkjvmomweicopbt" is required to use `foo()`.

---

    Code
      check_suggested(c("iurtnkjvmomweicopbt (>= 0.5)", "xxx", "cli"), "foo", use = NA)
    Message
      `foo()` is improved by the "iurtnkjvmomweicopbt (>= 0.5)" and "xxx" packages. Consider installing them.
    Output
      [1] FALSE

