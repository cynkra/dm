# FIXME NEXT

- continue with stashes, goal: expose optional `ref_column` in `dm_add_fk()` and `dm_rm_fk()`
- optional arguments in `dm_rm_*()`?

# Later

- Abolish `skip_if_local_src()`: all tests that run only remotely always run at least with SQLite, to avoid hassle with distorted snapshots and late failures
- Add "strict mode" to GitHub Actions: validation in `new_dm3()`
