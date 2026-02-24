# Package index

## Basic

Construct a `dm` object from data frames, see also
[`vignette("howto-dm-df")`](https://dm.cynkra.com/articles/howto-dm-df.md).

- [`dm()`](https://dm.cynkra.com/reference/dm.md)
  [`new_dm()`](https://dm.cynkra.com/reference/dm.md)
  [`is_dm()`](https://dm.cynkra.com/reference/dm.md)
  [`as_dm()`](https://dm.cynkra.com/reference/dm.md) : Data model class
- [`dm_validate()`](https://dm.cynkra.com/reference/dm_validate.md) :
  Validator

## Database

Construct a `dm` object from a database, see also
[`vignette("howto-dm-db")`](https://dm.cynkra.com/articles/howto-dm-db.md).

- [`dm_from_con()`](https://dm.cynkra.com/reference/dm_from_con.md) :
  Load a dm from a remote data source
- [`dm_get_con()`](https://dm.cynkra.com/reference/dm_get_con.md) : Get
  connection

## Tables and columns

Operate on the tables and columns stored in a `dm` object.

- [`dm_select_tbl()`](https://dm.cynkra.com/reference/dm_select_tbl.md)
  [`dm_rename_tbl()`](https://dm.cynkra.com/reference/dm_select_tbl.md)
  : Select and rename tables

- [`dm_get_tables()`](https://dm.cynkra.com/reference/dm_get_tables.md)
  : Get tables

- [`pull_tbl()`](https://dm.cynkra.com/reference/pull_tbl.md) : Retrieve
  a table

- [`dm_mutate_tbl()`](https://dm.cynkra.com/reference/dm_mutate_tbl.md)
  **\[experimental\]** :

  Update tables in a `dm`

- [`dm_nrow()`](https://dm.cynkra.com/reference/dm_nrow.md) : Number of
  rows

- [`dm_select()`](https://dm.cynkra.com/reference/dm_select.md) : Select
  columns

- [`dm_rename()`](https://dm.cynkra.com/reference/dm_rename.md) : Rename
  columns

## Primary keys

Primary keys uniquely identify rows in a table. A table can have at most
one primary key. See also
[`vignette("howto-dm-theory")`](https://dm.cynkra.com/articles/howto-dm-theory.md).

- [`dm_add_pk()`](https://dm.cynkra.com/reference/dm_add_pk.md) : Add a
  primary key

- [`dm_get_all_pks()`](https://dm.cynkra.com/reference/dm_get_all_pks.md)
  :

  Get all primary keys of a `dm` object

- [`dm_has_pk()`](https://dm.cynkra.com/reference/dm_has_pk.md) : Check
  for primary key

- [`dm_rm_pk()`](https://dm.cynkra.com/reference/dm_rm_pk.md) : Remove a
  primary key

## Unique keys

Unique keys are similar to primary keys. Each table can have at most one
record for each combination of values in a unique key. A table can have
more than one unique key.

- [`dm_add_uk()`](https://dm.cynkra.com/reference/dm_add_uk.md) : Add a
  unique key

- [`dm_get_all_uks()`](https://dm.cynkra.com/reference/dm_get_all_uks.md)
  :

  Get all unique keys of a `dm` object

- [`dm_rm_uk()`](https://dm.cynkra.com/reference/dm_rm_uk.md) : Remove a
  unique key

## Foreign keys

Foreign keys establish links between tables by pointing to a primary or
unique key in another table. See also
[`vignette("howto-dm-theory")`](https://dm.cynkra.com/articles/howto-dm-theory.md).

- [`dm_add_fk()`](https://dm.cynkra.com/reference/dm_add_fk.md) : Add
  foreign keys
- [`dm_get_all_fks()`](https://dm.cynkra.com/reference/dm_get_all_fks.md)
  : Get foreign key constraints
- [`dm_rm_fk()`](https://dm.cynkra.com/reference/dm_rm_fk.md) : Remove
  foreign keys

## Visualize

Show a `dm` object, see also
[`vignette("tech-dm-draw")`](https://dm.cynkra.com/articles/tech-dm-draw.md).

- [`dm_gui()`](https://dm.cynkra.com/reference/dm_gui.md)
  **\[experimental\]** : Shiny app for defining dm objects
- [`dm_draw()`](https://dm.cynkra.com/reference/dm_draw.md) : Draw a
  diagram of the data model
- [`dm_set_colors()`](https://dm.cynkra.com/reference/dm_set_colors.md)
  [`dm_get_colors()`](https://dm.cynkra.com/reference/dm_set_colors.md)
  [`dm_get_available_colors()`](https://dm.cynkra.com/reference/dm_set_colors.md)
  : Color in database diagrams
- [`dm_set_table_description()`](https://dm.cynkra.com/reference/dm_set_table_description.md)
  [`dm_get_table_description()`](https://dm.cynkra.com/reference/dm_set_table_description.md)
  [`dm_reset_table_description()`](https://dm.cynkra.com/reference/dm_set_table_description.md)
  : Add info about a dm's tables

## Deconstruct

Rip a `dm` object apart and put it together, see also
[`vignette("tech-dm-keyed")`](https://dm.cynkra.com/articles/tech-dm-keyed.md).

- [`dm_deconstruct()`](https://dm.cynkra.com/reference/dm_deconstruct.md)
  **\[experimental\]** : Create code to deconstruct a dm object

## Flatten

Combine multiple related tables, see also
[`vignette("tech-dm-join")`](https://dm.cynkra.com/articles/tech-dm-join.md).

- [`dm_flatten()`](https://dm.cynkra.com/reference/dm_flatten.md)
  **\[experimental\]** :

  Flatten a table in a `dm` by joining its parent tables

- [`dm_flatten_to_tbl()`](https://dm.cynkra.com/reference/dm_flatten_to_tbl.md)
  :

  Flatten a part of a `dm` into a wide table

- [`dm_disambiguate_cols()`](https://dm.cynkra.com/reference/dm_disambiguate_cols.md)
  : Resolve column name ambiguities

## Filter

Filter across multiple tables, see also
[`vignette("tech-dm-filter")`](https://dm.cynkra.com/articles/tech-dm-filter.md).

- [`dm_filter()`](https://dm.cynkra.com/reference/dm_filter.md) :
  Filtering

## Zoom

Focus on a single table, see also
[`vignette("tech-dm-zoom")`](https://dm.cynkra.com/articles/tech-dm-zoom.md).

- [`dm_zoom_to()`](https://dm.cynkra.com/reference/dm_zoom_to.md)
  [`dm_insert_zoomed()`](https://dm.cynkra.com/reference/dm_zoom_to.md)
  [`dm_update_zoomed()`](https://dm.cynkra.com/reference/dm_zoom_to.md)
  [`dm_discard_zoomed()`](https://dm.cynkra.com/reference/dm_zoom_to.md)
  : Mark table for manipulation

- [`left_join(`*`<dm_zoomed>`*`)`](https://dm.cynkra.com/reference/dplyr_join.md)
  [`left_join(`*`<dm_keyed_tbl>`*`)`](https://dm.cynkra.com/reference/dplyr_join.md)
  [`inner_join(`*`<dm_zoomed>`*`)`](https://dm.cynkra.com/reference/dplyr_join.md)
  [`inner_join(`*`<dm_keyed_tbl>`*`)`](https://dm.cynkra.com/reference/dplyr_join.md)
  [`full_join(`*`<dm_zoomed>`*`)`](https://dm.cynkra.com/reference/dplyr_join.md)
  [`full_join(`*`<dm_keyed_tbl>`*`)`](https://dm.cynkra.com/reference/dplyr_join.md)
  [`right_join(`*`<dm_zoomed>`*`)`](https://dm.cynkra.com/reference/dplyr_join.md)
  [`right_join(`*`<dm_keyed_tbl>`*`)`](https://dm.cynkra.com/reference/dplyr_join.md)
  [`semi_join(`*`<dm_zoomed>`*`)`](https://dm.cynkra.com/reference/dplyr_join.md)
  [`semi_join(`*`<dm_keyed_tbl>`*`)`](https://dm.cynkra.com/reference/dplyr_join.md)
  [`anti_join(`*`<dm_zoomed>`*`)`](https://dm.cynkra.com/reference/dplyr_join.md)
  [`anti_join(`*`<dm_keyed_tbl>`*`)`](https://dm.cynkra.com/reference/dplyr_join.md)
  [`nest_join(`*`<dm_zoomed>`*`)`](https://dm.cynkra.com/reference/dplyr_join.md)
  [`cross_join(`*`<dm_zoomed>`*`)`](https://dm.cynkra.com/reference/dplyr_join.md)
  [`cross_join(`*`<dm_keyed_tbl>`*`)`](https://dm.cynkra.com/reference/dplyr_join.md)
  :

  dplyr join methods for zoomed dm objects

- [`filter(`*`<dm_zoomed>`*`)`](https://dm.cynkra.com/reference/dplyr_table_manipulation.md)
  [`filter(`*`<dm_keyed_tbl>`*`)`](https://dm.cynkra.com/reference/dplyr_table_manipulation.md)
  [`filter_out(`*`<dm_zoomed>`*`)`](https://dm.cynkra.com/reference/dplyr_table_manipulation.md)
  [`filter_out(`*`<dm_keyed_tbl>`*`)`](https://dm.cynkra.com/reference/dplyr_table_manipulation.md)
  [`mutate(`*`<dm_zoomed>`*`)`](https://dm.cynkra.com/reference/dplyr_table_manipulation.md)
  [`mutate(`*`<dm_keyed_tbl>`*`)`](https://dm.cynkra.com/reference/dplyr_table_manipulation.md)
  [`transmute(`*`<dm_zoomed>`*`)`](https://dm.cynkra.com/reference/dplyr_table_manipulation.md)
  [`transmute(`*`<dm_keyed_tbl>`*`)`](https://dm.cynkra.com/reference/dplyr_table_manipulation.md)
  [`select(`*`<dm_zoomed>`*`)`](https://dm.cynkra.com/reference/dplyr_table_manipulation.md)
  [`select(`*`<dm_keyed_tbl>`*`)`](https://dm.cynkra.com/reference/dplyr_table_manipulation.md)
  [`relocate(`*`<dm_zoomed>`*`)`](https://dm.cynkra.com/reference/dplyr_table_manipulation.md)
  [`relocate(`*`<dm_keyed_tbl>`*`)`](https://dm.cynkra.com/reference/dplyr_table_manipulation.md)
  [`rename(`*`<dm_zoomed>`*`)`](https://dm.cynkra.com/reference/dplyr_table_manipulation.md)
  [`rename(`*`<dm_keyed_tbl>`*`)`](https://dm.cynkra.com/reference/dplyr_table_manipulation.md)
  [`distinct(`*`<dm_zoomed>`*`)`](https://dm.cynkra.com/reference/dplyr_table_manipulation.md)
  [`distinct(`*`<dm_keyed_tbl>`*`)`](https://dm.cynkra.com/reference/dplyr_table_manipulation.md)
  [`arrange(`*`<dm_zoomed>`*`)`](https://dm.cynkra.com/reference/dplyr_table_manipulation.md)
  [`arrange(`*`<dm_keyed_tbl>`*`)`](https://dm.cynkra.com/reference/dplyr_table_manipulation.md)
  [`slice(`*`<dm_zoomed>`*`)`](https://dm.cynkra.com/reference/dplyr_table_manipulation.md)
  [`slice(`*`<dm_keyed_tbl>`*`)`](https://dm.cynkra.com/reference/dplyr_table_manipulation.md)
  [`group_by(`*`<dm_zoomed>`*`)`](https://dm.cynkra.com/reference/dplyr_table_manipulation.md)
  [`group_by(`*`<dm_keyed_tbl>`*`)`](https://dm.cynkra.com/reference/dplyr_table_manipulation.md)
  [`ungroup(`*`<dm_zoomed>`*`)`](https://dm.cynkra.com/reference/dplyr_table_manipulation.md)
  [`ungroup(`*`<dm_keyed_tbl>`*`)`](https://dm.cynkra.com/reference/dplyr_table_manipulation.md)
  [`summarise(`*`<dm_zoomed>`*`)`](https://dm.cynkra.com/reference/dplyr_table_manipulation.md)
  [`summarise(`*`<dm_keyed_tbl>`*`)`](https://dm.cynkra.com/reference/dplyr_table_manipulation.md)
  [`reframe(`*`<dm_zoomed>`*`)`](https://dm.cynkra.com/reference/dplyr_table_manipulation.md)
  [`reframe(`*`<dm_keyed_tbl>`*`)`](https://dm.cynkra.com/reference/dplyr_table_manipulation.md)
  [`count(`*`<dm_zoomed>`*`)`](https://dm.cynkra.com/reference/dplyr_table_manipulation.md)
  [`count(`*`<dm_keyed_tbl>`*`)`](https://dm.cynkra.com/reference/dplyr_table_manipulation.md)
  [`tally(`*`<dm_zoomed>`*`)`](https://dm.cynkra.com/reference/dplyr_table_manipulation.md)
  [`tally(`*`<dm_keyed_tbl>`*`)`](https://dm.cynkra.com/reference/dplyr_table_manipulation.md)
  [`pull(`*`<dm_zoomed>`*`)`](https://dm.cynkra.com/reference/dplyr_table_manipulation.md)
  [`compute(`*`<dm_zoomed>`*`)`](https://dm.cynkra.com/reference/dplyr_table_manipulation.md)
  :

  dplyr table manipulation methods for zoomed dm objects

- [`glimpse(`*`<dm>`*`)`](https://dm.cynkra.com/reference/glimpse.dm.md)
  [`glimpse(`*`<dm_zoomed>`*`)`](https://dm.cynkra.com/reference/glimpse.dm.md)
  :

  Get a glimpse of your `dm` object

- [`unite(`*`<dm_zoomed>`*`)`](https://dm.cynkra.com/reference/tidyr_table_manipulation.md)
  [`unite(`*`<dm_keyed_tbl>`*`)`](https://dm.cynkra.com/reference/tidyr_table_manipulation.md)
  [`separate(`*`<dm_zoomed>`*`)`](https://dm.cynkra.com/reference/tidyr_table_manipulation.md)
  [`separate(`*`<dm_keyed_tbl>`*`)`](https://dm.cynkra.com/reference/tidyr_table_manipulation.md)
  :

  tidyr table manipulation methods for zoomed dm objects

- [`head(`*`<dm_zoomed>`*`)`](https://dm.cynkra.com/reference/utils_table_manipulation.md)
  [`tail(`*`<dm_zoomed>`*`)`](https://dm.cynkra.com/reference/utils_table_manipulation.md)
  :

  utils table manipulation methods for `dm_zoomed` objects

## Wrap

Turn a `dm` object into a single table and back.

- [`dm_wrap_tbl()`](https://dm.cynkra.com/reference/dm_wrap_tbl.md)
  **\[experimental\]** : Wrap dm into a single tibble dm
- [`dm_unwrap_tbl()`](https://dm.cynkra.com/reference/dm_unwrap_tbl.md)
  **\[experimental\]** : Unwrap a single table dm
- [`dm_nest_tbl()`](https://dm.cynkra.com/reference/dm_nest_tbl.md)
  **\[experimental\]** : Nest a table inside its dm
- [`dm_pack_tbl()`](https://dm.cynkra.com/reference/dm_pack_tbl.md)
  **\[experimental\]** : dm_pack_tbl()
- [`dm_unnest_tbl()`](https://dm.cynkra.com/reference/dm_unnest_tbl.md)
  **\[experimental\]** : Unnest columns from a wrapped table
- [`dm_unpack_tbl()`](https://dm.cynkra.com/reference/dm_unpack_tbl.md)
  **\[experimental\]** : Unpack columns from a wrapped table

## Nested and packed data

New verbs that power wrapping.

- [`pack_join()`](https://dm.cynkra.com/reference/pack_join.md)
  **\[experimental\]** : Pack Join
- [`json_nest()`](https://dm.cynkra.com/reference/json_nest.md)
  **\[experimental\]** : JSON nest
- [`json_nest_join()`](https://dm.cynkra.com/reference/json_nest_join.md)
  **\[experimental\]** : JSON nest join
- [`json_pack()`](https://dm.cynkra.com/reference/json_pack.md)
  **\[experimental\]** : JSON pack
- [`json_pack_join()`](https://dm.cynkra.com/reference/json_pack_join.md)
  **\[experimental\]** : JSON pack join
- [`json_unnest()`](https://dm.cynkra.com/reference/json_unnest.md) :
  Unnest a JSON column
- [`json_unpack()`](https://dm.cynkra.com/reference/json_unpack.md) :
  Unpack a JSON column

## Materialize and upload

Get data from and to the database, see also
[`vignette("howto-dm-copy")`](https://dm.cynkra.com/articles/howto-dm-copy.md).

- [`compute(`*`<dm>`*`)`](https://dm.cynkra.com/reference/materialize.md)
  [`collect(`*`<dm>`*`)`](https://dm.cynkra.com/reference/materialize.md)
  : Materialize

- [`copy_dm_to()`](https://dm.cynkra.com/reference/copy_dm_to.md) : Copy
  data model to data source

- [`dm_sql()`](https://dm.cynkra.com/reference/dm_sql.md)
  [`dm_ddl_pre()`](https://dm.cynkra.com/reference/dm_sql.md)
  [`dm_dml_load()`](https://dm.cynkra.com/reference/dm_sql.md)
  [`dm_ddl_post()`](https://dm.cynkra.com/reference/dm_sql.md)
  **\[experimental\]** :

  Create *DDL* and *DML* scripts for a `dm` a and database connection

## Modify

Manipulate individual rows on the database, see also
[`vignette("howto-dm-rows")`](https://dm.cynkra.com/articles/howto-dm-rows.md).

- [`dm_rows_insert()`](https://dm.cynkra.com/reference/rows-dm.md)
  [`dm_rows_append()`](https://dm.cynkra.com/reference/rows-dm.md)
  [`dm_rows_update()`](https://dm.cynkra.com/reference/rows-dm.md)
  [`dm_rows_patch()`](https://dm.cynkra.com/reference/rows-dm.md)
  [`dm_rows_upsert()`](https://dm.cynkra.com/reference/rows-dm.md)
  [`dm_rows_delete()`](https://dm.cynkra.com/reference/rows-dm.md)
  **\[experimental\]** : Modifying rows for multiple tables

## Keys and cardinalities

Check fulfillment and nature of relationships between tables.

- [`dm_examine_constraints()`](https://dm.cynkra.com/reference/dm_examine_constraints.md)
  : Validate your data model
- [`enum_pk_candidates()`](https://dm.cynkra.com/reference/dm_enum_pk_candidates.md)
  [`dm_enum_pk_candidates()`](https://dm.cynkra.com/reference/dm_enum_pk_candidates.md)
  **\[experimental\]** : Primary key candidate
- [`dm_enum_fk_candidates()`](https://dm.cynkra.com/reference/dm_enum_fk_candidates.md)
  [`enum_fk_candidates()`](https://dm.cynkra.com/reference/dm_enum_fk_candidates.md)
  **\[experimental\]** : Foreign key candidates
- [`dm_examine_cardinalities()`](https://dm.cynkra.com/reference/dm_examine_cardinalities.md)
  **\[experimental\]** : Learn about your data model
- [`check_cardinality_0_n()`](https://dm.cynkra.com/reference/examine_cardinality.md)
  [`check_cardinality_1_n()`](https://dm.cynkra.com/reference/examine_cardinality.md)
  [`check_cardinality_1_1()`](https://dm.cynkra.com/reference/examine_cardinality.md)
  [`check_cardinality_0_1()`](https://dm.cynkra.com/reference/examine_cardinality.md)
  [`examine_cardinality()`](https://dm.cynkra.com/reference/examine_cardinality.md)
  : Check table relations
- [`check_key()`](https://dm.cynkra.com/reference/check_key.md) : Check
  if column(s) can be used as keys
- [`check_set_equality()`](https://dm.cynkra.com/reference/check_set_equality.md)
  : Check column values for set equality
- [`check_subset()`](https://dm.cynkra.com/reference/check_subset.md) :
  Check column values for subset

## Table surgery

Normalize and denormalize tables.

- [`decompose_table()`](https://dm.cynkra.com/reference/decompose_table.md)
  **\[experimental\]** : Decompose a table into two linked tables
- [`reunite_parent_child()`](https://dm.cynkra.com/reference/reunite_parent_child.md)
  [`reunite_parent_child_from_list()`](https://dm.cynkra.com/reference/reunite_parent_child.md)
  **\[experimental\]** : Merge two tables that are linked by a foreign
  key relation

## Database schemas

New verbs that power access to database schemas.

- [`db_schema_create()`](https://dm.cynkra.com/reference/db_schema_create.md)
  **\[experimental\]** : Create a schema on a database
- [`db_schema_drop()`](https://dm.cynkra.com/reference/db_schema_drop.md)
  **\[experimental\]** : Remove a schema from a database
- [`db_schema_exists()`](https://dm.cynkra.com/reference/db_schema_exists.md)
  **\[experimental\]** : Check for existence of a schema on a database
- [`db_schema_list()`](https://dm.cynkra.com/reference/db_schema_list.md)
  **\[experimental\]** : List schemas on a database

## Example dm objects

Ready to use and play with.

- [`dm_nycflights13()`](https://dm.cynkra.com/reference/dm_nycflights13.md)
  :

  Creates a dm object for the nycflights13 data

- [`dm_financial()`](https://dm.cynkra.com/reference/dm_financial.md)
  [`dm_financial_sqlite()`](https://dm.cynkra.com/reference/dm_financial.md)
  : Creates a dm object for the Financial data

- [`dm_pixarfilms()`](https://dm.cynkra.com/reference/dm_pixarfilms.md)
  :

  Creates a dm object for the pixarfilms data

## Structure and contents

Recreate a `dm` object.

- [`dm_paste()`](https://dm.cynkra.com/reference/dm_paste.md) : Create R
  code for a dm object
- [`dm_ptype()`](https://dm.cynkra.com/reference/dm_ptype.md) :
  Prototype for a dm object
