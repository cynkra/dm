# FIXME NEXT

- Postgres: define unique constraints if no PK defined
    - in separate branch: define constraints inside `CREATE TABLE`, avoid `ALTER TABLE`
- MSSQL: what is failing here?
- Perhaps skip learning tests for now if necessary
- Revisit PK constraints: https://github.com/r-dbi/DBI/pull/351#issuecomment-833438890
- expose optional `ref_column` in `dm_rm_fk()`
    - optional arguments in `dm_rm_*()`, set `NULL` defaults
    - show message what is removed, as piped code
    - throw error if no constraints matched
- optional argument in `dm_rm_pk()`, set `NULL` defaults?
- un-skip tests

# Later

- Abolish `skip_if_local_src()`: all tests that run only remotely always run at least with SQLite, to avoid hassle with distorted snapshots and late failures
- Add "strict mode" to GitHub Actions: validation in `new_dm3()`
