test_that("`check_suggested()` works",{
  withr::local_envvar("TESTTHAT"="")
  expect_snapshot({
    check_suggested("rlang","foo")
    check_suggested("dm","foo",use=NA)  
    check_suggested("iurtnkjvmomweicopbt","foo",use=NA)
    check_suggested("iurtnkjvmomweicopbt",use=NA)

    check_suggested("dm","foo",use=F)
    check_suggested("iurtnkjvmomweicopbt","foo",use=F)
    check_suggested("iurtnkjvmomweicopbt",use=F)
})  
})

  
test_that("`check_suggested()` works for error messages",{
  withr::local_envvar("TESTTHAT"="")
  expect_snapshot(error=T,{
    check_suggested("iurtnkjvmomweicopbt","foo")
})
  rlang::local_interactive(T)
  expect_snapshot({
    # A message
    check_suggested(c("iurtnkjvmomweicopbt (>= 0.5)","xxx","cli"),"foo",use=NA)
})
})

test_that("`check_suggested()` will skip.",{
  # this should be skipped.
  check_suggested("iurtnkjvmomweicopbt","foo")
  # Catching an error if it is not skipped.
  expect_equal("skipped","not skipped")
})
