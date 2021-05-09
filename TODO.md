# FIXME NEXT

- finish PR
- expose optional `ref_column` in `dm_rm_fk()`
    - optional arguments in `dm_rm_*()`, set `NULL` defaults
    - show message what is removed if ambiguous, as piped code
    - throw error if no constraints matched
- optional argument in `dm_rm_pk()`, set `NULL` defaults?
- un-skip tests
- rename `parent_pk_cols` to something more suitable

# Later

- Abolish `skip_if_local_src()`: all tests that run only remotely always run at least with SQLite, to avoid hassle with distorted snapshots and late failures
- Add "strict mode" to GitHub Actions: validation in `new_dm3()`
- Named PK and unique constraints: https://github.com/r-dbi/DBI/pull/351#issuecomment-833438890
