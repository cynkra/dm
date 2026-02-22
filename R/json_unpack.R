#' Unpack a JSON column
#'
#' A wrapper around [tidyr::unpack()] that extracts its data from a JSON column.
#' The inverse of [json_pack()].
#'
#' @param data A data frame, a data frame extension (e.g. a tibble), or  a lazy
#'   data frame (e.g. from dbplyr or dtplyr).
#' @inheritParams rlang::args_dots_used
#' @inheritParams tidyr::unpack
#'
#' @return An object of the same type as `data`
#' @export
#' @examples
#' tibble(a = 1, b = '{ "c": 2, "d": 3 }') %>%
#'   json_unpack(b)
json_unpack <- function(data, cols, ..., names_sep = NULL, names_repair = "check_unique") {
  check_dots_used()

  UseMethod("json_unpack")
}

#' @export
json_unpack.data.frame <- function(
  data,
  cols,
  ...,
  names_sep = NULL,
  names_repair = "check_unique"
) {
  if (missing(cols)) {
    cli::cli_abort("The {.arg cols} argument must be provided.")
  }
  data %>%
    mutate(across({{ cols }}, ~ map_dfr(., ~ jsonlite::fromJSON(.) %>% as_tibble()))) %>%
    unpack(
      {{ cols }},
      names_sep = names_sep,
      names_repair = names_repair
    )
}

# @export
# json_unpack.tbl_lazy <- function(data, cols, ..., names_sep = NULL, names_repair = "check_unique") {
# select string_agg(quotename(k) + case t
#                   when 0 then ' nchar(1)'       -- javascript null
#                   when 1 then ' nvarchar(max)'  -- javascript string
#                   when 2 then ' float'          -- javascript number
#                   when 3 then ' bit'            -- javascript boolean
#                   else ' nvarchar(max) as json' -- javascript array or object
#                   end, ', ') within group (order by k)
# from (
#   select j2.[key], max(j2.[type])
#   from test
#   cross apply openjson(case when json_col like '{%}' then '[' + json_col + ']' else json_col end) as j1
#   cross apply openjson(j1.value) as j2
#   group by j2.[key]
# ) as kt(k, t)
# }
