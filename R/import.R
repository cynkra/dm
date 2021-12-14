#' @import cli
#' @importFrom glue glue
#' @import rlang
#' @importFrom vctrs vec_ptype2 vec_ptype_abbr vec_slice vec_cast vec_proxy_compare vec_data vec_c
#' @importFrom vctrs vec_names vec_as_names vec_cbind vec_rbind vec_recycle
#' @importFrom vctrs list_of as_list_of new_list_of is_list_of
#' @importFrom vctrs vec_size vec_match s3_register vec_duplicate_detect vec_split
#' @import dplyr
#' @import DBI
#' @import tibble
#' @rawNamespace import(tidyr, except = c(extract))
#' @rawNamespace import(purrr, except = c(list_along, rep_along, invoke, modify, as_function, flatten_dbl, flatten_lgl, flatten_int, flatten_raw, flatten_chr, splice, flatten, prepend, `%@%`, `%||%`))
#' @rawNamespace import(magrittr, except = c(set_names))
#' @importFrom methods is
#' @rawNamespace import(glue, except = c(collapse))
#' @importFrom igraph V E
#' @importFrom utils head tail str packageVersion
#' @import lifecycle
#' @import ellipsis
#' @importFrom grDevices col2rgb colors rgb
#' @importFrom pillar pillar_shaft
#' @importFrom stats na.omit
NULL
