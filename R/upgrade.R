dm_upgrade <- function(dm) {
  # Versioned dm objects introduced in dm 0.2.1, unversioned dm same as version 0
  version <- attr(dm, "version") %||% 0L

  if (version < 1) {
    message("Upgrading dm object created with dm <= 0.2.1.")
    def <- unclass(dm)$def
    def$fks <- map2(def$fks, def$pks, ~ {
      list(.x)
    })
  }

  dm
}
