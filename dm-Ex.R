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
nameEx("dm_add_pk")
### * dm_add_pk

flush(stderr()); flush(stdout())

### Name: dm_add_pk
### Title: Add a primary key
### Aliases: dm_add_pk

### ** Examples

## Don't show: 
if (rlang::is_installed("nycflights13") && rlang::is_installed("DiagrammeR")) (if (getRversion() >= "3.4") withAutoprint else force)({ # examplesIf
## End(Don't show)
nycflights_dm <- dm(
  planes = nycflights13::planes,
  airports = nycflights13::airports,
  weather = nycflights13::weather
)

nycflights_dm %>%
  dm_draw()

# Create primary keys:
nycflights_dm %>%
  dm_add_pk(planes, tailnum) %>%
  dm_add_pk(airports, faa, check = TRUE) %>%
  dm_add_pk(weather, c(origin, time_hour)) %>%
  dm_draw()

# Keys can be checked during creation:
try(
  nycflights_dm %>%
    dm_add_pk(planes, manufacturer, check = TRUE)
)
## Don't show: 
}) # examplesIf
## End(Don't show)



cleanEx()
nameEx("dm_add_tbl")
### * dm_add_tbl

flush(stderr()); flush(stdout())

### Name: dm_add_tbl
### Title: Add tables to a 'dm'
### Aliases: dm_add_tbl

### ** Examples

dm() %>%
  dm_add_tbl(mtcars, flowers = iris)

# renaming table names if necessary (depending on the `repair` argument)
dm() %>%
  dm_add_tbl(new_tbl = mtcars, new_tbl = iris)



cleanEx()
nameEx("dm_bind")
### * dm_bind

flush(stderr()); flush(stdout())

### Name: dm_bind
### Title: Merge several 'dm'
### Aliases: dm_bind

### ** Examples

## Don't show: 
if (rlang::is_installed("nycflights13")) (if (getRversion() >= "3.4") withAutoprint else force)({ # examplesIf
## End(Don't show)
dm_1 <- dm_nycflights13()
dm_2 <- dm(mtcars, iris)
dm_bind(dm_1, dm_2)
## Don't show: 
}) # examplesIf
## End(Don't show)



cleanEx()
nameEx("dm_disambiguate_cols")
### * dm_disambiguate_cols

flush(stderr()); flush(stdout())

### Name: dm_disambiguate_cols
### Title: Resolve column name ambiguities
### Aliases: dm_disambiguate_cols

### ** Examples

## Don't show: 
if (rlang::is_installed("nycflights13")) (if (getRversion() >= "3.4") withAutoprint else force)({ # examplesIf
## End(Don't show)
dm_nycflights13() %>%
  dm_disambiguate_cols()
## Don't show: 
}) # examplesIf
## End(Don't show)



cleanEx()
nameEx("dm_draw")
### * dm_draw

flush(stderr()); flush(stdout())

### Name: dm_draw
### Title: Draw a diagram of the data model
### Aliases: dm_draw

### ** Examples

## Don't show: 
if (rlang::is_installed("nycflights13") && rlang::is_installed("DiagrammeR")) (if (getRversion() >= "3.4") withAutoprint else force)({ # examplesIf
## End(Don't show)
dm_nycflights13() %>%
  dm_draw()

dm_nycflights13(cycle = TRUE) %>%
  dm_draw(view_type = "title_only")

head(dm_get_available_colors())
length(dm_get_available_colors())

dm_nycflights13() %>%
  dm_get_colors()
## Don't show: 
}) # examplesIf
## End(Don't show)



cleanEx()
nameEx("dm_enum_fk_candidates")
### * dm_enum_fk_candidates

flush(stderr()); flush(stdout())

### Name: dm_enum_fk_candidates
### Title: Foreign key candidates
### Aliases: dm_enum_fk_candidates enum_fk_candidates

### ** Examples

## Don't show: 
if (rlang::is_installed("nycflights13")) (if (getRversion() >= "3.4") withAutoprint else force)({ # examplesIf
## End(Don't show)
dm_nycflights13() %>%
  dm_enum_fk_candidates(flights, airports)

dm_nycflights13() %>%
  dm_zoom_to(flights) %>%
  enum_fk_candidates(airports)
## Don't show: 
}) # examplesIf
## End(Don't show)



cleanEx()
nameEx("dm_examine_cardinalities")
### * dm_examine_cardinalities

flush(stderr()); flush(stdout())

### Name: dm_examine_cardinalities
### Title: Learn about your data model
### Aliases: dm_examine_cardinalities

### ** Examples

## Don't show: 
if (rlang::is_installed("nycflights13")) (if (getRversion() >= "3.4") withAutoprint else force)({ # examplesIf
## End(Don't show)
dm_nycflights13() %>%
  dm_examine_cardinalities()
## Don't show: 
}) # examplesIf
## End(Don't show)



cleanEx()
nameEx("dm_examine_constraints")
### * dm_examine_constraints

flush(stderr()); flush(stdout())

### Name: dm_examine_constraints
### Title: Validate your data model
### Aliases: dm_examine_constraints

### ** Examples

## Don't show: 
if (rlang::is_installed("nycflights13")) (if (getRversion() >= "3.4") withAutoprint else force)({ # examplesIf
## End(Don't show)
dm_nycflights13() %>%
  dm_examine_constraints()
## Don't show: 
}) # examplesIf
## End(Don't show)



cleanEx()
nameEx("dm_filter")
### * dm_filter

flush(stderr()); flush(stdout())

### Name: dm_filter
### Title: Filtering
### Aliases: dm_filter dm_apply_filters dm_apply_filters_to_tbl

### ** Examples

## Don't show: 
if (rlang::is_installed("nycflights13")) (if (getRversion() >= "3.4") withAutoprint else force)({ # examplesIf
## End(Don't show)
dm_nyc <- dm_nycflights13()
dm_nyc_filtered <-
  dm_nycflights13() %>%
  dm_filter(airports, name == "John F Kennedy Intl")

dm_apply_filters_to_tbl(dm_nyc_filtered, flights)

dm_nyc_filtered %>%
  dm_apply_filters()

# If you want to keep only those rows in the parent tables
# whose primary key values appear as foreign key values in
# `flights`, you can set a `TRUE` filter in `flights`:
dm_nyc %>%
  dm_filter(flights, 1 == 1) %>%
  dm_apply_filters() %>%
  dm_nrow()
# note that in this example, the only affected table is
# `airports` because the departure airports in `flights` are
# only the three New York airports.
## Don't show: 
}) # examplesIf
## End(Don't show)
## Don't show: 
if (rlang::is_installed("nycflights13")) (if (getRversion() >= "3.4") withAutoprint else force)({ # examplesIf
## End(Don't show)

dm_nyc %>%
  dm_filter(planes, engine %in% c("Reciprocating", "4 Cycle")) %>%
  compute()
## Don't show: 
}) # examplesIf
## End(Don't show)



cleanEx()
nameEx("dm_financial")
### * dm_financial

flush(stderr()); flush(stdout())

### Name: dm_financial
### Title: Creates a dm object for the Financial data
### Aliases: dm_financial dm_financial_sqlite

### ** Examples

## Don't show: 
if (dm:::dm_has_financial() && rlang::is_installed("DiagrammeR")) (if (getRversion() >= "3.4") withAutoprint else force)({ # examplesIf
## End(Don't show)
dm_financial() %>%
  dm_draw()
## Don't show: 
}) # examplesIf
## End(Don't show)



cleanEx()
nameEx("dm_flatten_to_tbl")
### * dm_flatten_to_tbl

flush(stderr()); flush(stdout())

### Name: dm_flatten_to_tbl
### Title: Flatten a part of a 'dm' into a wide table
### Aliases: dm_flatten_to_tbl dm_squash_to_tbl

### ** Examples

## Don't show: 
if (rlang::is_installed("nycflights13")) (if (getRversion() >= "3.4") withAutoprint else force)({ # examplesIf
## End(Don't show)
dm_nycflights13() %>%
  dm_select_tbl(-weather) %>%
  dm_flatten_to_tbl(flights)
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
nameEx("dm_get_all_pks")
### * dm_get_all_pks

flush(stderr()); flush(stdout())

### Name: dm_get_all_pks
### Title: Get all primary keys of a 'dm' object
### Aliases: dm_get_all_pks

### ** Examples

## Don't show: 
if (rlang::is_installed("nycflights13")) (if (getRversion() >= "3.4") withAutoprint else force)({ # examplesIf
## End(Don't show)
dm_nycflights13() %>%
  dm_get_all_pks()
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
if (dm:::dm_has_financial()) (if (getRversion() >= "3.4") withAutoprint else force)({ # examplesIf
## End(Don't show)
dm_financial() %>%
  dm_get_con()
## Don't show: 
}) # examplesIf
## End(Don't show)



cleanEx()
nameEx("dm_get_filters")
### * dm_get_filters

flush(stderr()); flush(stdout())

### Name: dm_get_filters
### Title: Get filter expressions
### Aliases: dm_get_filters

### ** Examples

## Don't show: 
if (rlang::is_installed("nycflights13") && rlang::is_installed("dbplyr")) (if (getRversion() >= "3.4") withAutoprint else force)({ # examplesIf
## End(Don't show)
dm_nycflights13() %>%
  dm_get_filters()
## Don't show: 
}) # examplesIf
## End(Don't show)



cleanEx()
nameEx("dm_get_referencing_tables")
### * dm_get_referencing_tables

flush(stderr()); flush(stdout())

### Name: dm_get_referencing_tables
### Title: Get the names of referencing tables
### Aliases: dm_get_referencing_tables

### ** Examples

## Don't show: 
if (rlang::is_installed("nycflights13")) (if (getRversion() >= "3.4") withAutoprint else force)({ # examplesIf
## End(Don't show)
dm_nycflights13() %>%
  dm_get_referencing_tables(airports)
dm_nycflights13() %>%
  dm_get_referencing_tables(flights)
## Don't show: 
}) # examplesIf
## End(Don't show)



cleanEx()
nameEx("dm_has_pk")
### * dm_has_pk

flush(stderr()); flush(stdout())

### Name: dm_has_pk
### Title: Check for primary key
### Aliases: dm_has_pk

### ** Examples

## Don't show: 
if (rlang::is_installed("nycflights13")) (if (getRversion() >= "3.4") withAutoprint else force)({ # examplesIf
## End(Don't show)
dm_nycflights13() %>%
  dm_has_pk(flights)
dm_nycflights13() %>%
  dm_has_pk(planes)
## Don't show: 
}) # examplesIf
## End(Don't show)



cleanEx()
