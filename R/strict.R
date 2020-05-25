# Infrastructure for "strict mode" of a dm
# where re-adding existing keys gives an error
#
# Idea: "strict mode" is set during construction of a dm
#
# For now, strict mode only, easier to relax later
# than to strengthen after the fact

dm_is_strict_keys <- function(dm) {
  TRUE
}
