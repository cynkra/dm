# No longer needed for dbplyr >= 2.4.0
# https://github.com/tidyverse/dbplyr/pull/1190
rlang::on_load({
  if (rlang::is_installed("dbplyr") && getNamespaceInfo("dbplyr", "spec")["version"] <= "2.3.4") {
    dbplyr <- asNamespace("dbplyr")
    unlockBinding("sql_values_subquery.MariaDBConnection", dbplyr)
    try(dbplyr$sql_values_subquery.MariaDBConnection <- dbplyr$sql_values_subquery.DBIConnection, silent = TRUE)
    lockBinding("sql_values_subquery.MariaDBConnection", dbplyr)
  }
})
