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
nameEx("check_set_equality")
### * check_set_equality

flush(stderr()); flush(stdout())

### Name: check_set_equality
### Title: Check column values for set equality
### Aliases: check_set_equality

### ** Examples

data_1 <- tibble::tibble(a = c(1, 2, 1), b = c(1, 4, 1), c = c(5, 6, 7))
data_2 <- tibble::tibble(a = c(1, 2, 3), b = c(4, 5, 6), c = c(7, 8, 9))
# this is failing:
try(check_set_equality(data_1, a, data_2, a))

data_3 <- tibble::tibble(a = c(2, 1, 2), b = c(4, 5, 6), c = c(7, 8, 9))
# this is passing:
check_set_equality(data_1, a, data_3, a)



cleanEx()
nameEx("check_subset")
### * check_subset

flush(stderr()); flush(stdout())

### Name: check_subset
### Title: Check column values for subset
### Aliases: check_subset

### ** Examples

data_1 <- tibble::tibble(a = c(1, 2, 1), b = c(1, 4, 1), c = c(5, 6, 7))
data_2 <- tibble::tibble(a = c(1, 2, 3), b = c(4, 5, 6), c = c(7, 8, 9))
# this is passing:
check_subset(data_1, a, data_2, a)

# this is failing:
try(check_subset(data_2, a, data_1, a))



cleanEx()
nameEx("copy_dm_to")
### * copy_dm_to

flush(stderr()); flush(stdout())

### Name: copy_dm_to
### Title: Copy data model to data source
### Aliases: copy_dm_to

### ** Examples

## Don't show: 
if (rlang::is_installed("RSQLite") && rlang::is_installed("nycflights13") && rlang::is_installed("dbplyr")) (if (getRversion() >= "3.4") withAutoprint else force)({ # examplesIf
## End(Don't show)
con <- DBI::dbConnect(RSQLite::SQLite())

# Copy to temporary tables, unique table names by default:
temp_dm <- copy_dm_to(
  con,
  dm_nycflights13(),
  set_key_constraints = FALSE
)

# Persist, explicitly specify table names:
persistent_dm <- copy_dm_to(
  con,
  dm_nycflights13(),
  temporary = FALSE,
  table_names = ~ paste0("flights_", .x)
)
dbplyr::remote_name(persistent_dm$planes)

DBI::dbDisconnect(con)
## Don't show: 
}) # examplesIf
## End(Don't show)



cleanEx()
nameEx("decompose_table")
### * decompose_table

flush(stderr()); flush(stdout())

### Name: decompose_table
### Title: Decompose a table into two linked tables
### Aliases: decompose_table

### ** Examples

decomposed_table <- decompose_table(mtcars, new_id, am, gear, carb)
decomposed_table$child_table
decomposed_table$parent_table



cleanEx()
nameEx("dm")
### * dm

flush(stderr()); flush(stdout())

### Name: dm
### Title: Data model class
### Aliases: dm new_dm dm_get_tables is_dm as_dm

### ** Examples

dm(trees, mtcars)

new_dm(list(trees = trees, mtcars = mtcars))

as_dm(list(trees = trees, mtcars = mtcars))
## Don't show: 
if (rlang::is_installed("nycflights13") && rlang::is_installed("dbplyr")) (if (getRversion() >= "3.4") withAutoprint else force)({ # examplesIf
## End(Don't show)

is_dm(dm_nycflights13())

dm_nycflights13()$airports

dm_nycflights13()["airports"]

dm_nycflights13()[["airports"]]

dm_nycflights13() %>% names()

dm_nycflights13() %>% dm_get_tables()
## Don't show: 
}) # examplesIf
## End(Don't show)



cleanEx()
nameEx("dm_add_fk")
### * dm_add_fk

flush(stderr()); flush(stdout())

### Name: dm_add_fk
### Title: Add foreign keys
### Aliases: dm_add_fk

### ** Examples

## Don't show: 
if (rlang::is_installed("nycflights13") && rlang::is_installed("DiagrammeR")) (if (getRversion() >= "3.4") withAutoprint else force)({ # examplesIf
## End(Don't show)
nycflights_dm <- dm(
  planes = nycflights13::planes,
  flights = nycflights13::flights,
  weather = nycflights13::weather
)

nycflights_dm %>%
  dm_draw()

# Create foreign keys:
nycflights_dm %>%
  dm_add_pk(planes, tailnum) %>%
  dm_add_fk(flights, tailnum, planes) %>%
  dm_add_pk(weather, c(origin, time_hour)) %>%
  dm_add_fk(flights, c(origin, time_hour), weather) %>%
  dm_draw()

# Keys can be checked during creation:
try(
  nycflights_dm %>%
    dm_add_pk(planes, tailnum) %>%
    dm_add_fk(flights, tailnum, planes, check = TRUE)
)
## Don't show: 
}) # examplesIf
## End(Don't show)



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
