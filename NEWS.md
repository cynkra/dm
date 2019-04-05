# dm 0.0.0.9001

Initial version.

- `rowSelector()` and `selectable()` modules, with corresponding `...UI()` functions.
- `decompose_table()` to split a table in two.
- `reunite_parent_child_from_list()`, inverse to `decompose_table()`.
- `reunite_parent_child()`, as a shortcut for `reunite_parent_child_from_list()`.
- `check_cardinality_0_1()`, `check_cardinality_0_n()`, `check_cardinality_1_1()` and `check_cardinality_1_n()` to check relationships between tables, powered by `check_if_subset()`, `check_key()` and `check_set_equality()`.
