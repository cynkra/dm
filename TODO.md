# FIXME NEXT

- expose optional `ref_column` in `dm_rm_fk()`
    - optional arguments in `dm_rm_*()`, set `NULL` defaults
    - show message what is removed, as piped code
    - throw error if no constraints matched
- optional argument in `dm_rm_pk()`, set `NULL` defaults?

# Later

- Abolish `skip_if_local_src()`: all tests that run only remotely always run at least with SQLite, to avoid hassle with distorted snapshots and late failures
- Add "strict mode" to GitHub Actions: validation in `new_dm3()`
