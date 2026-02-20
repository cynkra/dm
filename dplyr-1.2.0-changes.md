# dm updates for dplyr 1.2.0

## New methods

- `filter_out()` methods for `dm` and `dm_zoomed`: Companion to `filter()` for specifying rows to drop. The `dm` method raises an informative error directing users to zoom first, consistent with `filter()`.

- `reframe()` methods for `dm`, `dm_zoomed`, and `dm_keyed_tbl`: Now stable in dplyr 1.2.0. Works like `summarise()` but can return any number of rows per group. The `dm` method raises an informative error directing users to zoom first.

- `cross_join()` methods for `dm`, `dm_zoomed`, and `dm_keyed_tbl`: Performs a cross join (Cartesian product) between the zoomed table and another table in the dm. The `dm` method raises an informative error directing users to zoom first.

## Other changes

- Minimum dplyr version bumped from 1.1.0 to 1.2.0.
- Tests added for all new methods.
