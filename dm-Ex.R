pkgname <- "dm"
source(file.path(R.home("share"), "R", "examples-header.R"))
options(warn = 1)
library('dm')

base::assign(".oldSearch", base::search(), pos = 'CheckExEnv')
base::assign(".old_wd", base::getwd(), pos = 'CheckExEnv')
cleanEx()
nameEx("check_key")
### * check_key

flush(stderr()); flush(stdout())

### Name: check_key
### Title: Check if column(s) can be used as keys
### Aliases: check_key

### ** Examples

data <- tibble::tibble(a = c(1, 2, 1), b = c(1, 4, 1), c = c(5, 6, 7))
# this is failing:
try(check_key(data, a, b))

# this is passing:
check_key(data, a, c)



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
nameEx("dm_get_all_fks")
### * dm_get_all_fks

flush(stderr()); flush(stdout())

### Name: dm_get_all_fks
### Title: Get foreign key constraints
### Aliases: dm_get_all_fks

### ** Examples

## Don't show: 
if (rlang::is_installed("nycflights13")) (if (getRversion() >= "3.4") withAutoprint else force)({ # examplesIf
## End(Don't show)
dm_nycflights13() %>%
  dm_get_all_fks()
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
