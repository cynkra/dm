# dm updates for dplyr 1.2.0

## New methods

- `filter_out()` methods for `dm`, `dm_zoomed`, and `dm_keyed_tbl`: Companion to `filter()` for specifying rows to drop.

- `reframe()` methods for `dm`, `dm_zoomed`, and `dm_keyed_tbl`: Like `summarise()` but can return any number of rows per group. PK intentionally dropped in keyed variant.

- `cross_join()` methods for `dm`, `dm_zoomed`, and `dm_keyed_tbl`: Performs a cross join (Cartesian product).

## New `dm_keyed_tbl` methods

- `filter.dm_keyed_tbl()`, `filter_out.dm_keyed_tbl()` — row filtering, keys preserved
- `mutate.dm_keyed_tbl()`, `transmute.dm_keyed_tbl()` — column transformation, keys preserved
- `select.dm_keyed_tbl()`, `relocate.dm_keyed_tbl()`, `rename.dm_keyed_tbl()` — column selection/reordering, keys preserved
- `distinct.dm_keyed_tbl()` — duplicate removal, keys preserved
- `arrange.dm_keyed_tbl()` — row ordering, keys preserved
- `slice.dm_keyed_tbl()` — row slicing, keys preserved
- `ungroup.dm_keyed_tbl()` — remove grouping, keys preserved
- `count.dm_keyed_tbl()`, `tally.dm_keyed_tbl()` — aggregation, PK dropped (structure changes)

## Signature alignment

All dm methods now match their dplyr data.frame method signatures. Named arguments from the data.frame method are explicitly listed in each dm method and forwarded to the underlying dplyr call. dm-specific extensions (e.g. `select`, `.keep_pk`) appear after the data.frame method's parameters.

### `filter()`

- dplyr data.frame: `(.data, ..., .by, .preserve)`
- `filter.dm(.data, ..., .by, .preserve)`, `filter.dm_zoomed(.data, ..., .by, .preserve)`, `filter.dm_keyed_tbl(.data, ..., .by, .preserve)`

### `filter_out()` (new)

- dplyr data.frame: `(.data, ..., .by, .preserve)`
- `filter_out.dm(.data, ..., .by, .preserve)`, `filter_out.dm_zoomed(.data, ..., .by, .preserve)`, `filter_out.dm_keyed_tbl(.data, ..., .by, .preserve)`

### `mutate()`

- dplyr data.frame: `(.data, ..., .by, .keep, .before, .after)`
- Before: `mutate.dm(.data, ...)`, `mutate.dm_zoomed(.data, ...)`
- After: all now `(.data, ..., .by, .keep, .before, .after)` — `.by`, `.keep`, `.before`, `.after` forwarded

### `transmute()`

- dplyr data.frame: `(.data, ...)`
- No change needed, signatures already match.

### `select()`

- dplyr data.frame: `(.data, ...)`
- No change needed, signatures already match. Added `select.dm_keyed_tbl(.data, ...)`.

### `relocate()`

- dplyr data.frame: `(.data, ..., .before, .after)`
- All methods match. Added `relocate.dm_keyed_tbl(.data, ..., .before, .after)`.

### `rename()`

- dplyr data.frame: `(.data, ...)`
- No change needed. Added `rename.dm_keyed_tbl(.data, ...)`.

### `distinct()`

- dplyr data.frame: `(.data, ..., .keep_all)`
- All methods match. Added `distinct.dm_keyed_tbl(.data, ..., .keep_all)`.

### `arrange()`

- dplyr data.frame: `(.data, ..., .by_group, .locale)`
- Before: `arrange.dm(.data, ..., .by_group)`, `arrange.dm_zoomed(.data, ..., .by_group)`
- After: all now `(.data, ..., .by_group, .locale)` — `.locale` forwarded. Added `arrange.dm_keyed_tbl`.

### `slice()`

- dplyr data.frame: `(.data, ..., .by, .preserve)`
- All methods match. `slice.dm_zoomed` adds `.keep_pk` as a dm-specific extension.
- Added `slice.dm_keyed_tbl(.data, ..., .by, .preserve)`.

### `group_by()`

- dplyr data.frame: `(.data, ..., .add, .drop)`
- Before: `group_by.dm(.data, ...)`, `group_by.dm_zoomed(.data, ...)`, `group_by.dm_keyed_tbl(.data, ...)`
- After: all now `(.data, ..., .add, .drop)` — `.add` and `.drop` forwarded

### `ungroup()`

- dplyr data.frame: `(x, ...)`
- No change needed. Added `ungroup.dm_keyed_tbl(x, ...)`.

### `summarise()`

- dplyr data.frame: `(.data, ..., .by, .groups)`
- Before: `summarise.dm(.data, ...)`, `summarise.dm_zoomed(.data, ...)`, `summarise.dm_keyed_tbl(.data, ...)`
- After: all now `(.data, ..., .by, .groups)` — `.by` and `.groups` forwarded

### `reframe()` (new)

- dplyr data.frame: `(.data, ..., .by)`
- `reframe.dm(.data, ..., .by)`, `reframe.dm_zoomed(.data, ..., .by)`, `reframe.dm_keyed_tbl(.data, ..., .by)`

### `count()`

- dplyr data.frame: `(x, ..., wt, sort, name, .drop)`
- Before: `count.dm(x, ...)`
- After: `count.dm(x, ..., wt, sort, name, .drop)`, `count.dm_keyed_tbl(x, ..., wt, sort, name, .drop)` (new)
- `count.dm_zoomed` already matched.

### `tally()`

- dplyr data.frame: `(x, wt, sort, name)`
- Before: `tally.dm(x, ...)`, `tally.dm_zoomed(x, ...)`
- After: `tally.dm(x, wt, sort, name)`, `tally.dm_zoomed(x, wt, sort, name)`, `tally.dm_keyed_tbl(x, wt, sort, name)` (new)

### `pull()`

- dplyr data.frame: `(.data, var, name, ...)`
- Before: `pull.dm_zoomed(.data, var, ...)`
- After: `pull.dm(.data, var, name, ...)`, `pull.dm_zoomed(.data, var, name, ...)`

### `left_join()`, `right_join()`, `inner_join()`

- dplyr data.frame: `(x, y, by, copy, suffix, ..., keep, na_matches, multiple, unmatched, relationship)`
- Before (stub): `(x, ..., keep)`; Before (zoomed): `(x, y, by, copy, suffix, ..., keep, select)`
- After: all now include `na_matches`, `multiple`, `unmatched`, `relationship`. `select` retained as dm extension after data.frame args.

### `full_join()`

- dplyr data.frame: `(x, y, by, copy, suffix, ..., keep, na_matches, multiple, relationship)`
- Same as above but without `unmatched`.

### `semi_join()`, `anti_join()`

- dplyr data.frame: `(x, y, by, copy, ..., na_matches)`
- Before: `(x, y, by, copy, ...)` / `(x, y, by, copy, ..., suffix, select)`
- After: all now include `na_matches`. `suffix` and `select` retained as dm extensions.

### `nest_join()`

- dplyr data.frame: `(x, y, by, copy, keep, name, ..., na_matches, unmatched)`
- Before: `(x, y, by, copy, keep, name, ...)`
- After: all now include `na_matches`, `unmatched`.

### `cross_join()` (new)

- dplyr data.frame: `(x, y, ..., copy, suffix)`
- `cross_join.dm(x, y, ..., copy, suffix)`, `cross_join.dm_zoomed(x, y, ..., copy, suffix)`, `cross_join.dm_keyed_tbl(x, y, ..., copy, suffix)`

## Other changes

- Minimum dplyr version bumped from 1.1.0 to 1.2.0.
- Tests added for all new methods.
