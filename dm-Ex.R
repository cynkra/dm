pkgname <- "dm"
source(file.path(R.home("share"), "R", "examples-header.R"))
options(warn = 1)
library('dm')

base::assign(".oldSearch", base::search(), pos = 'CheckExEnv')
base::assign(".old_wd", base::getwd(), pos = 'CheckExEnv')
cleanEx()
nameEx("dm_from_con")
### * dm_from_con

flush(stderr()); flush(stdout())

### Name: dm_from_con
### Title: Load a dm from a remote data source
### Aliases: dm_from_con

### ** Examples

## Don't show: 
if (dm:::dm_has_financial()) (if (getRversion() >= "3.4") withAutoprint else force)({ # examplesIf
## End(Don't show)
con <- dm_get_con(dm_financial())

dm_from_src(con)

DBI::dbDisconnect(con)
## Don't show: 
}) # examplesIf
## End(Don't show)



cleanEx()
nameEx("dm_get_con")
### * dm_get_con

flush(stderr()); flush(stdout())

### Name: dm_get_con
### Title: Get connection
### Aliases: dm_get_con

### ** Examples

## Don't show: 
## End(Don't show)
dm_financial() %>%
  dm_get_con()
## Don't show: 
## End(Don't show)



cleanEx()
