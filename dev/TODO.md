# FIXME NEXT

- un-skip tests

# Later

- Store `keys` objects in dm, much easier for debugging
- Add “strict mode” to GitHub Actions: validation in `dm_from_def()`
- Named PK and unique constraints:
  <https://github.com/r-dbi/DBI/pull/351#issuecomment-833438890>
- [`dm_paste()`](https://dm.cynkra.com/dev/reference/dm_paste.md):
  remove `select` argument from documentation, via `_impl()` function
  that takes dots and this argument, like
  [`dm_rm_pk()`](https://dm.cynkra.com/dev/reference/dm_rm_pk.md)
- Persistent test dm objects
  - Use `copy_to(temporary = FALSE)`
  - sqlite and duckdb: use file that can be discarded
  - Requires schema support for all databases
