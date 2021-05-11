# FIXME NEXT

- un-skip tests

# Later

- Store `keys` objects in dm, much easier for debugging
- Abolish `skip_if_local_src()`: all tests that run only remotely always run at least with SQLite, to avoid hassle with distorted snapshots and late failures
- Add "strict mode" to GitHub Actions: validation in `new_dm3()`
- Named PK and unique constraints: https://github.com/r-dbi/DBI/pull/351#issuecomment-833438890
- `dm_paste()`: remove `select` argument from documentation, via `_impl()` function that takes dots and this argument, like `dm_rm_pk()`
