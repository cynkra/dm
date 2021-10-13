dm_upgrade <- function(dm, quiet) {
  # Versioned dm objects introduced in dm 0.2.1, unversioned dm same as version 0
  version <- attr(dm, "version") %||% 0L

  if (version < 1) {
    # FIXME: Can't give unconditional message, because IDE can tickle object in environment,
    # and this also produces a message. Don't emit message when calling str()?
    if (!quiet) {
      message("Upgrading dm object created with dm <= 0.2.1.")
    }
    def <- unclass(dm)$def
    def$fks <- list_of(!!!map2(def$fks, def$pks, ~ {
      .x[["ref_column"]] <- .y[["column"]]
      .x <- .x[c("ref_column", "table", "column")]
      .x
    }))
    dm <- new_dm3(def, zoomed = is_zoomed(dm))
  } else if (version < 2) {
    # FIXME: Can't give unconditional message, because IDE can tickle object in environment,
    # and this also produces a message. Don't emit message when calling str()?
    if (!quiet) {
      message("Upgrading dm object created with dm <= 0.2.4.")
    }
    def <- unclass(dm)$def
    def$fks <- list_of(!!!map(def$fks, mutate, on_delete = "no_action"))
    dm <- new_dm3(def, zoomed = is_zoomed(dm))
  }

  dm
}
