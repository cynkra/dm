# dm updates for dplyr 1.2.0

## New methods

- `filter_out()` methods for `dm` and `dm_zoomed`: Companion to `filter()` for specifying rows to drop. The `dm` method raises an informative error directing users to zoom first, consistent with `filter()`.

- `reframe()` methods for `dm`, `dm_zoomed`, and `dm_keyed_tbl`: Now stable in dplyr 1.2.0. Works like `summarise()` but can return any number of rows per group. The `dm` method raises an informative error directing users to zoom first.

- `cross_join()` methods for `dm`, `dm_zoomed`, and `dm_keyed_tbl`: Performs a cross join (Cartesian product) between the zoomed table and another table in the dm. The `dm` method raises an informative error directing users to zoom first.

## Signature alignment

All dm methods now match the dplyr 1.2.0 generic signatures. Named arguments from the generic are explicitly listed in each method and forwarded to the underlying dplyr call. dm-specific extensions (e.g. `select`, `.keep_pk`) appear after the generic parameters.

### `filter()`

- dplyr generic: `(.data, ..., .by, .preserve)`
- Before: `filter.dm(.data, ...)`, `filter.dm_zoomed(.data, ...)`
- After: `filter.dm(.data, ..., .by, .preserve)`, `filter.dm_zoomed(.data, ..., .by, .preserve)`

### `filter_out()` (new)

- dplyr generic: `(.data, ..., .by, .preserve)`
- `filter_out.dm(.data, ..., .by, .preserve)`, `filter_out.dm_zoomed(.data, ..., .by, .preserve)`

### `mutate()`

- dplyr generic: `(.data, ...)`
- No change needed, signatures already match.

### `transmute()`

- dplyr generic: `(.data, ...)`
- No change needed, signatures already match.

### `select()`

- dplyr generic: `(.data, ...)`
- No change needed, signatures already match.

### `relocate()`

- dplyr generic: `(.data, ..., .before, .after)`
- Before: `relocate.dm(.data, ...)`
- After: `relocate.dm(.data, ..., .before, .after)`
- `relocate.dm_zoomed` already matched.

### `rename()`

- dplyr generic: `(.data, ...)`
- No change needed, signatures already match.

### `distinct()`

- dplyr generic: `(.data, ..., .keep_all)`
- Before: `distinct.dm(.data, ...)`
- After: `distinct.dm(.data, ..., .keep_all)`
- `distinct.dm_zoomed` already matched.

### `arrange()`

- dplyr generic: `(.data, ..., .by_group)`
- Before: `arrange.dm(.data, ...)`, `arrange.dm_zoomed(.data, ...)`
- After: `arrange.dm(.data, ..., .by_group)`, `arrange.dm_zoomed(.data, ..., .by_group)` — `.by_group` forwarded

### `slice()`

- dplyr generic: `(.data, ..., .by, .preserve)`
- Before: `slice.dm(.data, ...)`, `slice.dm_zoomed(.data, ..., .keep_pk)`
- After: `slice.dm(.data, ..., .by, .preserve)`, `slice.dm_zoomed(.data, ..., .by, .preserve, .keep_pk)` — `.by` and `.preserve` forwarded, `.keep_pk` retained as dm extension

### `group_by()`

- dplyr generic: `(.data, ..., .add, .drop)`
- Before: `group_by.dm(.data, ...)`, `group_by.dm_zoomed(.data, ...)`, `group_by.dm_keyed_tbl(.data, ...)`
- After: all now `(.data, ..., .add, .drop)` — `.add` and `.drop` forwarded

### `group_data()`, `group_keys()`, `group_indices()`, `group_vars()`, `groups()`, `ungroup()`

- No change needed, signatures already match.

### `summarise()`

- dplyr generic: `(.data, ..., .by, .groups)`
- Before: `summarise.dm(.data, ...)`, `summarise.dm_zoomed(.data, ...)`, `summarise.dm_keyed_tbl(.data, ...)`
- After: all now `(.data, ..., .by, .groups)` — `.by` and `.groups` forwarded

### `reframe()` (new)

- dplyr generic: `(.data, ..., .by)`
- `reframe.dm(.data, ..., .by)`, `reframe.dm_zoomed(.data, ..., .by)`, `reframe.dm_keyed_tbl(.data, ..., .by)` — `.by` forwarded

### `count()`

- dplyr generic: `(x, ..., wt, sort, name)`
- Before: `count.dm(x, ...)`
- After: `count.dm(x, ..., wt, sort, name)`
- `count.dm_zoomed` already matched (extends with `.drop`).

### `tally()`

- dplyr generic: `(x, wt, sort, name)`
- Before: `tally.dm(x, ...)`, `tally.dm_zoomed(x, ...)`
- After: `tally.dm(x, wt, sort, name)`, `tally.dm_zoomed(x, wt, sort, name)` — `wt`, `sort`, `name` forwarded

### `pull()`

- dplyr generic: `(.data, var, name, ...)`
- Before: `pull.dm_zoomed(.data, var, ...)`
- After: `pull.dm_zoomed(.data, var, name, ...)` — `name` forwarded
- `pull.dm` already matched.

### `collect()`, `compute()`, `copy_to()`

- dplyr generic signatures are `(x, ...)` / `(dest, df, name, overwrite, ...)`.
- No change needed. dm methods extend via extra named args after generic params.

### `left_join()`, `right_join()`, `inner_join()`, `full_join()`

- dplyr generic: `(x, y, by, copy, suffix, ..., keep)`
- Before (stub): `(x, ...)`; Before (zoomed): `(x, y, by, copy, suffix, select, ...)`
- After (stub): `(x, y, by, copy, suffix, ..., keep)`; After (zoomed): `(x, y, by, copy, suffix, ..., keep, select)` — `keep` forwarded, `select` moved after `...`
- keyed_tbl methods already matched.

### `semi_join()`, `anti_join()`

- dplyr generic: `(x, y, by, copy, ...)`
- Before (stub): `(x, ...)`; Before (zoomed): `(x, y, by, copy, suffix, select, ...)`
- After (stub): `(x, y, by, copy, ...)`; After (zoomed): `(x, y, by, copy, ..., suffix, select)` — `suffix` and `select` moved after `...`
- keyed_tbl methods already matched.

### `nest_join()`

- dplyr generic: `(x, y, by, copy, keep, name, ...)`
- Before (stub): `(x, ...)`; Before (zoomed): `keep = FALSE`
- After (stub): `(x, y, by, copy, keep, name, ...)`; After (zoomed): `keep = NULL` to match generic default
- keyed_tbl method not applicable.

### `cross_join()` (new)

- dplyr generic: `(x, y, ..., copy, suffix)`
- `cross_join.dm(x, y, ..., copy, suffix)`, `cross_join.dm_zoomed(x, y, ..., copy, suffix)`, `cross_join.dm_keyed_tbl(x, y, ..., copy, suffix)`

## Other changes

- Minimum dplyr version bumped from 1.1.0 to 1.2.0.
- Tests added for all new methods.
