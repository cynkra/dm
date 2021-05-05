dm_upgrade <- function(dm) {
  is_v1 <- inherits(dm, "dm_v1")
  is_v2 <- inherits(dm, "dm_v2")

  # Versioned dm objects introduced in dm 0.2.0, unversioned dm same as dm_v1
  is_v1 <- is_v1 || (!is_v2)

  if (is_v1) {
    message("Upgrading dm object")
    def <- unclass(dm)$def
    def$fks <- map2(def$fks, def$pks, ~ {
      list(.x)
    })
  }

  dm
}
