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
nameEx("dm_is_referenced")
### * dm_is_referenced

flush(stderr()); flush(stdout())

### Name: dm_is_referenced
### Title: Check foreign key reference
### Aliases: dm_is_referenced

### ** Examples

## Don't show: 
if (rlang::is_installed("nycflights13")) (if (getRversion() >= "3.4") withAutoprint else force)({ # examplesIf
## End(Don't show)
dm_nycflights13() %>%
  dm_is_referenced(airports)
dm_nycflights13() %>%
  dm_is_referenced(flights)
## Don't show: 
}) # examplesIf
## End(Don't show)



cleanEx()
nameEx("dm_join_to_tbl")
### * dm_join_to_tbl

flush(stderr()); flush(stdout())

### Name: dm_join_to_tbl
### Title: Join two tables
### Aliases: dm_join_to_tbl

### ** Examples

## Don't show: 
if (rlang::is_installed("nycflights13")) (if (getRversion() >= "3.4") withAutoprint else force)({ # examplesIf
## End(Don't show)
dm_nycflights13() %>%
  dm_join_to_tbl(airports, flights)

# same result is achieved with:
dm_nycflights13() %>%
  dm_join_to_tbl(flights, airports)

# this gives an error, because the tables are not directly linked to each other:
try(
  dm_nycflights13() %>%
    dm_join_to_tbl(airlines, airports)
)
## Don't show: 
}) # examplesIf
## End(Don't show)



cleanEx()
nameEx("dm_mutate_tbl")
### * dm_mutate_tbl

flush(stderr()); flush(stdout())

### Name: dm_mutate_tbl
### Title: Update tables in a 'dm'
### Aliases: dm_mutate_tbl

### ** Examples

## Don't show: 
if (rlang::is_installed("nycflights13")) (if (getRversion() >= "3.4") withAutoprint else force)({ # examplesIf
## End(Don't show)
dm_nycflights13() %>%
  dm_mutate_tbl(flights = nycflights13::flights[1:3, ])
## Don't show: 
}) # examplesIf
## End(Don't show)



cleanEx()
nameEx("dm_nest_tbl")
### * dm_nest_tbl

flush(stderr()); flush(stdout())

### Name: dm_nest_tbl
### Title: Nest a table inside its dm
### Aliases: dm_nest_tbl

### ** Examples

nested_dm <-
  dm_nycflights13() %>%
  dm_select_tbl(airlines, flights) %>%
  dm_nest_tbl(flights)

nested_dm

nested_dm$airlines



cleanEx()
nameEx("dm_nrow")
### * dm_nrow

flush(stderr()); flush(stdout())

### Name: dm_nrow
### Title: Number of rows
### Aliases: dm_nrow

### ** Examples

## Don't show: 
if (rlang::is_installed("nycflights13")) (if (getRversion() >= "3.4") withAutoprint else force)({ # examplesIf
## End(Don't show)
dm_nycflights13() %>%
  dm_filter(airports, faa %in% c("EWR", "LGA")) %>%
  dm_apply_filters() %>%
  dm_nrow()
## Don't show: 
}) # examplesIf
## End(Don't show)



cleanEx()
nameEx("dm_nycflights13")
### * dm_nycflights13

flush(stderr()); flush(stdout())

### Name: dm_nycflights13
### Title: Creates a dm object for the 'nycflights13' data
### Aliases: dm_nycflights13

### ** Examples

## Don't show: 
if (rlang::is_installed("nycflights13") && rlang::is_installed("DiagrammeR")) (if (getRversion() >= "3.4") withAutoprint else force)({ # examplesIf
## End(Don't show)
dm_nycflights13() %>%
  dm_draw()
## Don't show: 
}) # examplesIf
## End(Don't show)



cleanEx()
nameEx("dm_pack_tbl")
### * dm_pack_tbl

flush(stderr()); flush(stdout())

### Name: dm_pack_tbl
### Title: dm_pack_tbl()
### Aliases: dm_pack_tbl

### ** Examples

dm_packed <-
  dm_nycflights13() %>%
  dm_pack_tbl(planes)

dm_packed

dm_packed$flights

dm_packed$flights$planes



cleanEx()
nameEx("dm_paste")
### * dm_paste

flush(stderr()); flush(stdout())

### Name: dm_paste
### Title: Create R code for a dm object
### Aliases: dm_paste

### ** Examples

dm() %>%
  dm_paste()
## Don't show: 
if (rlang::is_installed("nycflights13")) (if (getRversion() >= "3.4") withAutoprint else force)({ # examplesIf
## End(Don't show)

dm_nycflights13() %>%
  dm_paste()

dm_nycflights13() %>%
  dm_paste(options = "select")
## Don't show: 
}) # examplesIf
## End(Don't show)



cleanEx()
nameEx("dm_pixarfilms")
### * dm_pixarfilms

flush(stderr()); flush(stdout())

### Name: dm_pixarfilms
### Title: Creates a dm object for the 'pixarfilms' data
### Aliases: dm_pixarfilms

### ** Examples

## Don't show: 
if (rlang::is_installed("pixarfilms") && rlang::is_installed("DiagrammeR")) (if (getRversion() >= "3.4") withAutoprint else force)({ # examplesIf
## End(Don't show)
dm_pixarfilms()
dm_pixarfilms() %>%
  dm_draw()
## Don't show: 
}) # examplesIf
## End(Don't show)



cleanEx()
nameEx("dm_ptype")
### * dm_ptype

flush(stderr()); flush(stdout())

### Name: dm_ptype
### Title: Prototype for a dm object
### Aliases: dm_ptype

### ** Examples

## Don't show: 
if (dm:::dm_has_financial()) (if (getRversion() >= "3.4") withAutoprint else force)({ # examplesIf
## End(Don't show)
dm_financial() %>%
  dm_ptype()

dm_financial() %>%
  dm_ptype() %>%
  dm_nrow()
## Don't show: 
}) # examplesIf
## End(Don't show)



cleanEx()
nameEx("dm_rename")
### * dm_rename

flush(stderr()); flush(stdout())

### Name: dm_rename
### Title: Rename columns
### Aliases: dm_rename

### ** Examples

## Don't show: 
if (rlang::is_installed("nycflights13")) (if (getRversion() >= "3.4") withAutoprint else force)({ # examplesIf
## End(Don't show)
dm_nycflights13() %>%
  dm_rename(airports, code = faa, altitude = alt)
## Don't show: 
}) # examplesIf
## End(Don't show)



cleanEx()
nameEx("dm_rm_fk")
### * dm_rm_fk

flush(stderr()); flush(stdout())

### Name: dm_rm_fk
### Title: Remove foreign keys
### Aliases: dm_rm_fk

### ** Examples

## Don't show: 
if (rlang::is_installed("nycflights13") && rlang::is_installed("DiagrammeR")) (if (getRversion() >= "3.4") withAutoprint else force)({ # examplesIf
## End(Don't show)
dm_nycflights13(cycle = TRUE) %>%
  dm_rm_fk(flights, dest, airports) %>%
  dm_draw()
## Don't show: 
}) # examplesIf
## End(Don't show)



cleanEx()
nameEx("dm_rm_pk")
### * dm_rm_pk

flush(stderr()); flush(stdout())

### Name: dm_rm_pk
### Title: Remove a primary key
### Aliases: dm_rm_pk

### ** Examples

## Don't show: 
if (rlang::is_installed("nycflights13") && rlang::is_installed("DiagrammeR")) (if (getRversion() >= "3.4") withAutoprint else force)({ # examplesIf
## End(Don't show)
dm_nycflights13() %>%
  dm_rm_pk(airports, fail_fk = FALSE) %>%
  dm_draw()
## Don't show: 
}) # examplesIf
## End(Don't show)



cleanEx()
nameEx("dm_rm_tbl")
### * dm_rm_tbl

flush(stderr()); flush(stdout())

### Name: dm_rm_tbl
### Title: Remove tables
### Aliases: dm_rm_tbl

### ** Examples

## Don't show: 
if (rlang::is_installed("nycflights13")) (if (getRversion() >= "3.4") withAutoprint else force)({ # examplesIf
## End(Don't show)
dm_nycflights13() %>%
  dm_rm_tbl(airports)
## Don't show: 
}) # examplesIf
## End(Don't show)



cleanEx()
nameEx("dm_select")
### * dm_select

flush(stderr()); flush(stdout())

### Name: dm_select
### Title: Select columns
### Aliases: dm_select

### ** Examples

## Don't show: 
if (rlang::is_installed("nycflights13")) (if (getRversion() >= "3.4") withAutoprint else force)({ # examplesIf
## End(Don't show)
dm_nycflights13() %>%
  dm_select(airports, code = faa, altitude = alt)
## Don't show: 
}) # examplesIf
## End(Don't show)



cleanEx()
nameEx("dm_select_tbl")
### * dm_select_tbl

flush(stderr()); flush(stdout())

### Name: dm_select_tbl
### Title: Select and rename tables
### Aliases: dm_select_tbl dm_rename_tbl

### ** Examples

## Don't show: 
if (rlang::is_installed("nycflights13")) (if (getRversion() >= "3.4") withAutoprint else force)({ # examplesIf
## End(Don't show)
dm_nycflights13() %>%
  dm_select_tbl(airports, fl = flights)
## Don't show: 
}) # examplesIf
## End(Don't show)
## Don't show: 
if (rlang::is_installed("nycflights13")) (if (getRversion() >= "3.4") withAutoprint else force)({ # examplesIf
## End(Don't show)
dm_nycflights13() %>%
  dm_rename_tbl(ap = airports, fl = flights)
## Don't show: 
}) # examplesIf
## End(Don't show)



cleanEx()
nameEx("dm_set_colors")
### * dm_set_colors

flush(stderr()); flush(stdout())

### Name: dm_set_colors
### Title: Color in database diagrams
### Aliases: dm_set_colors dm_get_colors dm_get_available_colors

### ** Examples

## Don't show: 
if (rlang::is_installed("nycflights13") && rlang::is_installed("DiagrammeR")) (if (getRversion() >= "3.4") withAutoprint else force)({ # examplesIf
## End(Don't show)
dm_nycflights13(color = FALSE) %>%
  dm_set_colors(
    darkblue = starts_with("air"),
    "#5986C4" = flights
  ) %>%
  dm_draw()

# Splicing is supported:
nyc_cols <-
  dm_nycflights13() %>%
  dm_get_colors()
nyc_cols

dm_nycflights13(color = FALSE) %>%
  dm_set_colors(!!!nyc_cols) %>%
  dm_draw()
## Don't show: 
}) # examplesIf
## End(Don't show)



cleanEx()
nameEx("dm_unnest_tbl")
### * dm_unnest_tbl

flush(stderr()); flush(stdout())

### Name: dm_unnest_tbl
### Title: Unnest columns from a wrapped table
### Aliases: dm_unnest_tbl

### ** Examples

airlines_wrapped <-
  dm_nycflights13() %>%
  dm_wrap_tbl(airlines)

# The ptype is required for reconstruction.
# It can be an empty dm, only primary and foreign keys are considered.
ptype <- dm_ptype(dm_nycflights13())

airlines_wrapped %>%
  dm_unnest_tbl(airlines, flights, ptype)



cleanEx()
nameEx("dm_unpack_tbl")
### * dm_unpack_tbl

flush(stderr()); flush(stdout())

### Name: dm_unpack_tbl
### Title: Unpack columns from a wrapped table
### Aliases: dm_unpack_tbl

### ** Examples

flights_wrapped <-
  dm_nycflights13() %>%
  dm_wrap_tbl(flights)

# The ptype is required for reconstruction.
# It can be an empty dm, only primary and foreign keys are considered.
ptype <- dm_ptype(dm_nycflights13())

flights_wrapped %>%
  dm_unpack_tbl(flights, airlines, ptype)



cleanEx()
nameEx("dm_unwrap_tbl")
### * dm_unwrap_tbl

flush(stderr()); flush(stdout())

### Name: dm_unwrap_tbl
### Title: Unwrap a single table dm
### Aliases: dm_unwrap_tbl

### ** Examples


roundtrip <-
  dm_nycflights13() %>%
  dm_wrap_tbl(root = flights) %>%
  dm_unwrap_tbl(ptype = dm_ptype(dm_nycflights13()))
roundtrip

# The roundtrip has the same structure but fewer rows:
dm_nrow(dm_nycflights13())
dm_nrow(roundtrip)



cleanEx()
nameEx("dm_validate")
### * dm_validate

flush(stderr()); flush(stdout())

### Name: dm_validate
### Title: Validator
### Aliases: dm_validate

### ** Examples

dm_validate(dm())

bad_dm <- structure(list(bad = "dm"), class = "dm")
try(dm_validate(bad_dm))



cleanEx()
nameEx("dm_wrap_tbl")
### * dm_wrap_tbl

flush(stderr()); flush(stdout())

### Name: dm_wrap_tbl
### Title: Wrap dm into a single tibble dm
### Aliases: dm_wrap_tbl

### ** Examples

dm_nycflights13() %>%
  dm_wrap_tbl(root = airlines)



cleanEx()
nameEx("dm_zoom_to")
### * dm_zoom_to

flush(stderr()); flush(stdout())

### Name: dm_zoom_to
### Title: Mark table for manipulation
### Aliases: dm_zoom_to dm_insert_zoomed dm_update_zoomed dm_discard_zoomed

### ** Examples

## Don't show: 
if (rlang::is_installed("nycflights13") && rlang::is_installed("DiagrammeR")) (if (getRversion() >= "3.4") withAutoprint else force)({ # examplesIf
## End(Don't show)
flights_zoomed <- dm_zoom_to(dm_nycflights13(), flights)

flights_zoomed

flights_zoomed_transformed <-
  flights_zoomed %>%
  mutate(am_pm_dep = ifelse(dep_time < 1200, "am", "pm")) %>%
  # `by`-argument of `left_join()` can be explicitly given
  # otherwise the key-relation is used
  left_join(airports) %>%
  select(year:dep_time, am_pm_dep, everything())

flights_zoomed_transformed

# replace table `flights` with the zoomed table
flights_zoomed_transformed %>%
  dm_update_zoomed()

# insert the zoomed table as a new table
flights_zoomed_transformed %>%
  dm_insert_zoomed("extended_flights") %>%
  dm_draw()

# discard the zoomed table
flights_zoomed_transformed %>%
  dm_discard_zoomed()
## Don't show: 
}) # examplesIf
## End(Don't show)



cleanEx()
nameEx("dplyr_join")
### * dplyr_join

flush(stderr()); flush(stdout())

### Name: dplyr_join
### Title: 'dplyr' join methods for zoomed dm objects
### Aliases: dplyr_join left_join.zoomed_dm inner_join.zoomed_dm
###   full_join.zoomed_dm right_join.zoomed_dm semi_join.zoomed_dm
###   anti_join.zoomed_dm

### ** Examples

## Don't show: 
if (rlang::is_installed("nycflights13")) (if (getRversion() >= "3.4") withAutoprint else force)({ # examplesIf
## End(Don't show)
flights_dm <- dm_nycflights13()
dm_zoom_to(flights_dm, flights) %>%
  left_join(airports, select = c(faa, name))

# this should illustrate that tables don't necessarily need to be connected
dm_zoom_to(flights_dm, airports) %>%
  semi_join(airlines, by = "name")
## Don't show: 
}) # examplesIf
## End(Don't show)



cleanEx()
nameEx("dplyr_table_manipulation")
### * dplyr_table_manipulation

flush(stderr()); flush(stdout())

### Name: dplyr_table_manipulation
### Title: 'dplyr' table manipulation methods for zoomed dm objects
### Aliases: dplyr_table_manipulation filter.zoomed_dm mutate.zoomed_dm
###   transmute.zoomed_dm select.zoomed_dm relocate.zoomed_dm
###   rename.zoomed_dm distinct.zoomed_dm arrange.zoomed_dm slice.zoomed_dm
###   group_by.zoomed_dm ungroup.zoomed_dm summarise.zoomed_dm
###   count.zoomed_dm tally.zoomed_dm pull.zoomed_dm compute.zoomed_dm

### ** Examples

## Don't show: 
if (rlang::is_installed("nycflights13")) (if (getRversion() >= "3.4") withAutoprint else force)({ # examplesIf
## End(Don't show)
zoomed <- dm_nycflights13() %>%
  dm_zoom_to(flights) %>%
  group_by(month) %>%
  arrange(desc(day)) %>%
  summarize(avg_air_time = mean(air_time, na.rm = TRUE))
zoomed
dm_insert_zoomed(zoomed, new_tbl_name = "avg_air_time_per_month")
## Don't show: 
}) # examplesIf
## End(Don't show)



cleanEx()
nameEx("enum_pk_candidates")
### * enum_pk_candidates

flush(stderr()); flush(stdout())

### Name: enum_pk_candidates
### Title: Primary key candidate
### Aliases: enum_pk_candidates dm_enum_pk_candidates

### ** Examples

## Don't show: 
if (rlang::is_installed("nycflights13")) (if (getRversion() >= "3.4") withAutoprint else force)({ # examplesIf
## End(Don't show)
nycflights13::flights %>%
  enum_pk_candidates()
## Don't show: 
}) # examplesIf
## End(Don't show)
## Don't show: 
if (rlang::is_installed("nycflights13")) (if (getRversion() >= "3.4") withAutoprint else force)({ # examplesIf
## End(Don't show)

dm_nycflights13() %>%
  dm_enum_pk_candidates(airports)
## Don't show: 
}) # examplesIf
## End(Don't show)



cleanEx()
nameEx("examine_cardinality")
### * examine_cardinality

flush(stderr()); flush(stdout())

### Name: examine_cardinality
### Title: Check table relations
### Aliases: examine_cardinality check_cardinality_0_n
###   check_cardinality_1_n check_cardinality_1_1 check_cardinality_0_1

### ** Examples

d1 <- tibble::tibble(a = 1:5)
d2 <- tibble::tibble(c = c(1:5, 5))
d3 <- tibble::tibble(c = 1:4)
# This does not pass, `c` is not unique key of d2:
try(check_cardinality_0_n(d2, c, d1, a))

# This passes, multiple values in d2$c are allowed:
check_cardinality_0_n(d1, a, d2, c)

# This does not pass, injectivity is violated:
try(check_cardinality_1_1(d1, a, d2, c))

# This passes:
check_cardinality_0_1(d1, a, d3, c)

# Returns the kind of cardinality
examine_cardinality(d1, a, d2, c)



cleanEx()
nameEx("json_nest")
### * json_nest

flush(stderr()); flush(stdout())

### Name: json_nest
### Title: JSON nest
### Aliases: json_nest

### ** Examples

df <- tibble::tibble(x = c(1, 1, 1, 2, 2, 3), y = 1:6, z = 6:1)
nested <- json_nest(df, data = c(y, z))
nested



cleanEx()
nameEx("json_nest_join")
### * json_nest_join

flush(stderr()); flush(stdout())

### Name: json_nest_join
### Title: JSON nest join
### Aliases: json_nest_join

### ** Examples

df1 <- tibble::tibble(x = 1:3)
df2 <- tibble::tibble(x = c(1, 1, 2), y = c("first", "second", "third"))
df3 <- json_nest_join(df1, df2)
df3
df3$df2



cleanEx()
nameEx("json_pack")
### * json_pack

flush(stderr()); flush(stdout())

### Name: json_pack
### Title: JSON pack
### Aliases: json_pack

### ** Examples

df <- tibble::tibble(x1 = 1:3, x2 = 4:6, x3 = 7:9, y = 1:3)
packed <- json_pack(df, x = c(x1, x2, x3), y = y)
packed



cleanEx()
nameEx("json_pack_join")
### * json_pack_join

flush(stderr()); flush(stdout())

### Name: json_pack_join
### Title: JSON pack join
### Aliases: json_pack_join

### ** Examples

df1 <- tibble::tibble(x = 1:3)
df2 <- tibble::tibble(x = c(1, 1, 2), y = c("first", "second", "third"))
df3 <- json_pack_join(df1, df2)
df3
df3$df2



cleanEx()
nameEx("materialize")
### * materialize

flush(stderr()); flush(stdout())

### Name: materialize
### Title: Materialize
### Aliases: materialize compute.dm collect.dm

### ** Examples

## Don't show: 
if (dm:::dm_has_financial()) (if (getRversion() >= "3.4") withAutoprint else force)({ # examplesIf
## End(Don't show)
financial <- dm_financial_sqlite()

financial %>%
  pull_tbl(districts) %>%
  dbplyr::remote_name()

# compute() copies the data to new tables:
financial %>%
  compute() %>%
  pull_tbl(districts) %>%
  dbplyr::remote_name()

# collect() returns a local dm:
financial %>%
  collect() %>%
  pull_tbl(districts) %>%
  class()
## Don't show: 
}) # examplesIf
## End(Don't show)



cleanEx()
nameEx("pack_join")
### * pack_join

flush(stderr()); flush(stdout())

### Name: pack_join
### Title: Pack Join
### Aliases: pack_join

### ** Examples

df1 <- tibble::tibble(x = 1:3)
df2 <- tibble::tibble(x = c(1, 1, 2), y = c("first", "second", "third"))
pack_join(df1, df2)



cleanEx()
nameEx("pull_tbl")
### * pull_tbl

flush(stderr()); flush(stdout())

### Name: pull_tbl
### Title: Retrieve a table
### Aliases: pull_tbl

### ** Examples

## Don't show: 
if (rlang::is_installed("nycflights13")) (if (getRversion() >= "3.4") withAutoprint else force)({ # examplesIf
## End(Don't show)
# For an unzoomed dm you need to specify the table to pull:
dm_nycflights13() %>%
  pull_tbl(airports)

# If zoomed, pulling detaches the zoomed table from the dm:
dm_nycflights13() %>%
  dm_zoom_to(airports) %>%
  pull_tbl()
## Don't show: 
}) # examplesIf
## End(Don't show)



cleanEx()
nameEx("reunite_parent_child")
### * reunite_parent_child

flush(stderr()); flush(stdout())

### Name: reunite_parent_child
### Title: Merge two tables that are linked by a foreign key relation
### Aliases: reunite_parent_child reunite_parent_child_from_list

### ** Examples

decomposed_table <- decompose_table(mtcars, new_id, am, gear, carb)
ct <- decomposed_table$child_table
pt <- decomposed_table$parent_table

reunite_parent_child(ct, pt, new_id)
reunite_parent_child_from_list(decomposed_table, new_id)



cleanEx()
nameEx("rows-db")
### * rows-db

flush(stderr()); flush(stdout())

### Name: rows-db
### Title: Updating database tables
### Aliases: rows-db rows_insert.tbl_lazy rows_append.tbl_lazy
###   rows_update.tbl_lazy rows_patch.tbl_lazy rows_upsert.tbl_lazy
###   rows_delete.tbl_lazy sql_rows_insert sql_rows_update sql_rows_patch
###   sql_rows_delete sql_returning_cols sql_output_cols

### ** Examples

## Don't show: 
if (rlang::is_installed("dbplyr")) (if (getRversion() >= "3.4") withAutoprint else force)({ # examplesIf
## End(Don't show)
data <- dbplyr::memdb_frame(a = 1:3, b = letters[c(1:2, NA)], c = 0.5 + 0:2)
data

try(rows_insert(data, tibble::tibble(a = 4, b = "z"), conflict = "ignore"))
rows_insert(data, tibble::tibble(a = 4, b = "z"), conflict = "ignore", copy = TRUE)
rows_append(data, tibble::tibble(a = 4, b = "v"), copy = TRUE)
rows_update(data, tibble::tibble(a = 2:3, b = "w"), unmatched = "ignore", copy = TRUE)
rows_patch(data, dbplyr::memdb_frame(a = 1:4, c = 0), unmatched = "ignore")
rows_delete(data, dbplyr::memdb_frame(a = 2L), unmatched = "ignore")

rows_insert(data, dbplyr::memdb_frame(a = 4, b = "z"), conflict = "ignore", in_place = TRUE)
data
rows_append(data, dbplyr::memdb_frame(a = 4, b = "v"), in_place = TRUE)
data
rows_update(data, dbplyr::memdb_frame(a = 2:3, b = "w"), unmatched = "ignore", in_place = TRUE)
data
rows_patch(data, dbplyr::memdb_frame(a = 1:4, c = 0), unmatched = "ignore", in_place = TRUE)
data
rows_delete(data, dbplyr::memdb_frame(a = 2L), unmatched = "ignore", in_place = TRUE)
data
## Don't show: 
}) # examplesIf
## End(Don't show)



cleanEx()
nameEx("rows-dm")
### * rows-dm

flush(stderr()); flush(stdout())

### Name: rows-dm
### Title: Modifying rows for multiple tables
### Aliases: rows-dm dm_rows_insert dm_rows_append dm_rows_update
###   dm_rows_patch dm_rows_upsert dm_rows_delete dm_rows_truncate

### ** Examples

## Don't show: 
if (rlang::is_installed("RSQLite") && rlang::is_installed("nycflights13")) (if (getRversion() >= "3.4") withAutoprint else force)({ # examplesIf
## End(Don't show)
# Establish database connection:
sqlite <- DBI::dbConnect(RSQLite::SQLite())

# Entire dataset with all dimension tables populated
# with flights and weather data truncated:
flights_init <-
  dm_nycflights13() %>%
  dm_zoom_to(flights) %>%
  filter(FALSE) %>%
  dm_update_zoomed() %>%
  dm_zoom_to(weather) %>%
  filter(FALSE) %>%
  dm_update_zoomed()

# Target database:
flights_sqlite <- copy_dm_to(sqlite, flights_init, temporary = FALSE)
print(dm_nrow(flights_sqlite))

# First update:
flights_jan <-
  dm_nycflights13() %>%
  dm_select_tbl(flights, weather) %>%
  dm_zoom_to(flights) %>%
  filter(month == 1) %>%
  dm_update_zoomed() %>%
  dm_zoom_to(weather) %>%
  filter(month == 1) %>%
  dm_update_zoomed()
print(dm_nrow(flights_jan))

# Copy to temporary tables on the target database:
flights_jan_sqlite <- copy_dm_to(sqlite, flights_jan)

# Dry run by default:
dm_rows_append(flights_sqlite, flights_jan_sqlite)
print(dm_nrow(flights_sqlite))

# Explicitly request persistence:
dm_rows_append(flights_sqlite, flights_jan_sqlite, in_place = TRUE)
print(dm_nrow(flights_sqlite))

# Second update:
flights_feb <-
  dm_nycflights13() %>%
  dm_select_tbl(flights, weather) %>%
  dm_zoom_to(flights) %>%
  filter(month == 2) %>%
  dm_update_zoomed() %>%
  dm_zoom_to(weather) %>%
  filter(month == 2) %>%
  dm_update_zoomed()

# Copy to temporary tables on the target database:
flights_feb_sqlite <- copy_dm_to(sqlite, flights_feb)

# Explicit dry run:
flights_new <- dm_rows_append(
  flights_sqlite,
  flights_feb_sqlite,
  in_place = FALSE
)
print(dm_nrow(flights_new))
print(dm_nrow(flights_sqlite))

# Check for consistency before applying:
flights_new %>%
  dm_examine_constraints()

# Apply:
dm_rows_append(flights_sqlite, flights_feb_sqlite, in_place = TRUE)
print(dm_nrow(flights_sqlite))

DBI::dbDisconnect(sqlite)
## Don't show: 
}) # examplesIf
## End(Don't show)



cleanEx()
nameEx("tidyr_table_manipulation")
### * tidyr_table_manipulation

flush(stderr()); flush(stdout())

### Name: tidyr_table_manipulation
### Title: 'tidyr' table manipulation methods for zoomed dm objects
### Aliases: tidyr_table_manipulation unite.zoomed_dm separate.zoomed_dm

### ** Examples

## Don't show: 
if (rlang::is_installed("nycflights13")) (if (getRversion() >= "3.4") withAutoprint else force)({ # examplesIf
## End(Don't show)
zoom_united <- dm_nycflights13() %>%
  dm_zoom_to(flights) %>%
  select(year, month, day) %>%
  unite("month_day", month, day)
zoom_united
zoom_united %>%
  separate(month_day, c("month", "day"))
## Don't show: 
}) # examplesIf
## End(Don't show)



cleanEx()
nameEx("utils_table_manipulation")
### * utils_table_manipulation

flush(stderr()); flush(stdout())

### Name: head.zoomed_dm
### Title: 'utils' table manipulation methods for 'zoomed_dm' objects
### Aliases: head.zoomed_dm tail.zoomed_dm

### ** Examples

## Don't show: 
if (rlang::is_installed("nycflights13")) (if (getRversion() >= "3.4") withAutoprint else force)({ # examplesIf
## End(Don't show)
zoomed <- dm_nycflights13() %>%
  dm_zoom_to(flights) %>%
  head(4)
zoomed
dm_insert_zoomed(zoomed, new_tbl_name = "head_flights")
## Don't show: 
}) # examplesIf
## End(Don't show)



### * <FOOTER>
###
cleanEx()
options(digits = 7L)
base::cat("Time elapsed: ", proc.time() - base::get("ptime", pos = 'CheckExEnv'),"\n")
grDevices::dev.off()
###
### Local variables: ***
### mode: outline-minor ***
### outline-regexp: "\\(> \\)?### [*]+" ***
### End: ***
quit('no')
