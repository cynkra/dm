# column -----------------------------------------------------------------------

null_to_character0 <- function(x) {
  if (is.null(x)) return(character())
  x
}

get_child_fk_cols <- function(dm, table_name = "flights") {
  child_fk_cols <-
    dm_get_all_fks(dm) |>
    filter(child_table == table_name) |>
    dplyr::pull(child_fk_cols)
  null_to_character0(unlist(child_fk_cols))
}

get_parent_key_cols <- function(dm, table_name = "flights") {
  parent_key_cols <-
    dm_get_all_fks(dm) |>
    filter(parent_table == table_name) |>
    dplyr::pull(parent_key_cols)
  null_to_character0(unlist(parent_key_cols))
}

get_pk_cols <- function(dm, table_name = "flights") {
  pk_cols <-
    dm_get_all_pks(dm) |>
    filter(table == table_name) |>
    dplyr::pull(pk_col)
  null_to_character0(unlist(pk_cols))
}


# dm = dm_nycflights13()
# data_column(dm, "flights")
data_column <- function(dm, table_name = "airports") {
  stopifnot(length(table_name) == 1)
  table_colnames <- colnames(dm[[table_name]])
  table_types <- vapply(dm[[table_name]], vctrs::vec_ptype_abbr, "", USE.NAMES = FALSE)

  tibble(
    name = table_colnames,
    type = table_types,
    is_pk = table_colnames %in% get_pk_cols(dm, table_name),
    is_child_fk = table_colnames %in% get_child_fk_cols(dm, table_name),
    is_parent_key = table_colnames %in% get_parent_key_cols(dm, table_name)
  )
}




# data <- tibble(
#   name = c("col1", "col2"),
#   type = c("numeric", "character"),
#   is_pk = c(TRUE, FALSE),
#   is_fk = c(FALSE, TRUE)
# )

# table_name <- "bla"

reactable_column <- function(data, table_name) {
  # browser()
  data |>
    reactable::reactable(
      columns = list(
        name = reactable::colDef(
          name = table_name,
          # FIXME: filterable hides the first row with scrollable = TRUE
          # filterable = TRUE,
          cell = function(value, index) {
            type <- shiny::div(
              style = list(float = "right"),
              dplyr::if_else(
                data$is_pk[index],
                list(htmltools::span(style = "margin-right: 10px;", title = "Primary key", shiny::icon("key"))),
                NULL
              ),
              dplyr::if_else(
                data$is_child_fk[index],
                list(htmltools::span(style = "margin-right: 10px;", title = "Child in foreign key", shiny::icon("angle-double-right"))),
                NULL
              ),
              dplyr::if_else(
                data$is_parent_key[index],
                list(htmltools::span(style = "margin-right: 10px;", title = "Parent key", shiny::icon("angle-double-left"))),
                NULL
              ),
              shiny::span(class = "tag", style = "color: #999; border-color: #999;", title = paste0("Data type: ", data$type[index]), data$type[index])
            )
            shiny::tagList(value, type)
          }
        ),
        type = reactable::colDef(
          show = FALSE,
          filterable = TRUE,
          cell = function(value) {
            shiny::span(class = "tag", value)
          }
        ),
        is_pk = reactable::colDef(show = FALSE),
        is_child_fk = reactable::colDef(show = FALSE),
        is_parent_key = reactable::colDef(show = FALSE)
      ),
      # searchable = TRUE,
      height = "272px",
      pagination = FALSE,
      sortable = FALSE,
      highlight = TRUE,
      selection = "multiple",
      onClick = "select",
      # minRows = 5,
      # maxRows = 5,
      bordered = TRUE,
      theme = dm_theme()
    )
}
# reactable_column(data, table_name)

# theme ------------------------------------------------------------------------

dm_theme <- function() {
  reactable::reactableTheme(
    # Full-width search bar with search icon
    searchInputStyle = list(
      width = "100%"
    ),

    # cellPadding = "10px 8px",
    style = list(
      ".tag" = list(
        display = "inline-block",
        width = "28px",
        textAlign = "center",
        padding = "0.125rem 0.25rem",
        color = "#999",
        fontSize = "0.9rem",
        border = "1px solid #777",
        borderRadius = "2px"
      )
    )
  )
}
