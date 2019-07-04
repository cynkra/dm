do_package_checks()

get_stage("install") %>%
  add_step(step_install_github("r-lib/pkgdown"))

if (ci_on_travis()) {
  do_pkgdown()
}
