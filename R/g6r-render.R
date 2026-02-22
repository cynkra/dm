# g6R backend for dm_draw() ------------------------------------------------

#' Escape special HTML characters to prevent XSS
#' @noRd
html_escape <- function(x) {
  x <- gsub("&", "&amp;", x, fixed = TRUE)
  x <- gsub("<", "&lt;", x, fixed = TRUE)
  x <- gsub(">", "&gt;", x, fixed = TRUE)
  x <- gsub("\"", "&quot;", x, fixed = TRUE)
  x <- gsub("'", "&#39;", x, fixed = TRUE)
  x
}

#' Render dm graph using g6R
#'
#' @param data_model Data model from `dm_get_data_model()`.
#' @param rankdir Graph direction: "LR" (left-right), "TB" (top-bottom), etc.
#' @param view_type Column display level.
#' @param top_level_fun Name of calling function for error messages
#' @noRd
bdm_render_g6r <- function(
  data_model,
  rankdir = "LR",
  view_type = "keys_only",
  top_level_fun = NULL
) {
  check_suggested("g6R", top_level_fun)

  nodes <- g6r_nodes_from_data_model(data_model, view_type)
  edges <- g6r_edges_from_data_model(data_model)

  # Map rankdir to g6R layout direction
  g6r_rankdir <- switch(rankdir, "LR" = "LR", "RL" = "RL", "TB" = "TB", "BT" = "BT", "LR")

  widget <- g6R::g6(nodes = nodes, edges = edges)
  widget <- g6R::g6_layout(
    widget,
    g6R::antv_dagre_layout(
      rankdir = g6r_rankdir,
      nodesep = 15,
      ranksep = 45
    )
  )

  # HTML template for nodes - creates styled table cards
  innerHTML_fn <- '(d) => {
    const data = d.data || {};
    const name = data.name || d.id;
    const columns = data.columns || "";
    const color = data.color || "#EFEBDD";
    const headerColor = data.headerColor || "#D4D0C0";
    return `<div style="background:${color};border-radius:5px;overflow:hidden;box-shadow:0 1px 4px rgba(0,0,0,0.15);font-family:system-ui,-apple-system,sans-serif;font-size:11px;color:white;min-width:70px;">
      <div style="background:${headerColor};padding:5px 8px;font-weight:600;">${name}</div>
      ${columns ? `<div style="padding:4px 8px;line-height:1.4;">${columns}</div>` : ""}
    </div>`;
  }'

  widget <- g6R::g6_options(
    widget,
    autoFit = "view",
    animation = FALSE,
    node = list(
      type = "html",
      style = list(
        size = htmlwidgets::JS("(d) => [d.data?.width || 90, d.data?.height || 50]"),
        innerHTML = htmlwidgets::JS(innerHTML_fn)
      )
    ),
    edge = list(
      style = list(
        endArrow = TRUE,
        stroke = "#666666",
        lineWidth = 1.2
      )
    )
  )
  widget <- g6R::g6_behaviors(
    widget,
    "zoom-canvas",
    g6R::drag_canvas()
  )

  widget
}

#' Create g6R nodes from data model (HTML version)
#' @noRd
g6r_nodes_from_data_model <- function(data_model, view_type = "keys_only") {
  tables <- data_model$tables
  columns <- data_model$columns

  # Filter columns based on view_type
  columns_by_table <- split(columns, columns$table)

  columns_by_table <- switch(
    view_type,
    all = columns_by_table,
    keys_only = lapply(columns_by_table, function(tab) {
      tab[tab[["key"]] > 0 | !is.na(tab[, "ref"]), , drop = FALSE]
    }),
    title_only = lapply(columns_by_table, function(tab) {
      tab[0L, , drop = FALSE]
    }),
    columns_by_table
  )

  # Build node data
  node_ids <- tables$table
  node_colors <- vapply(
    tables$display,
    function(col) {
      if (is.na(col) || col == "default" || col == "show") {
        "#EFEBDD"
      } else {
        # Strip alpha channel if present (e.g., #ED7D31FF -> #ED7D31)
        if (nchar(col) == 9 && startsWith(col, "#")) {
          substr(col, 1, 7)
        } else {
          col
        }
      }
    },
    character(1)
  )

  # Create column HTML for each table with PK/FK markers
  # Returns list with `html` (for rendering) and `plain` (for size calculation)
  node_columns_data <- lapply(
    node_ids,
    function(tbl) {
      cols <- columns_by_table[[tbl]]
      if (is.null(cols) || nrow(cols) == 0) {
        return(list(html = "", plain = character(0)))
      }
      # Escape column names to prevent XSS
      col_names_safe <- html_escape(cols$column)
      plain_labels <- cols$column

      # Append column type when available
      if (!is.null(cols$type) && !all(is.na(cols$type))) {
        type_safe <- html_escape(ifelse(is.na(cols$type), "", cols$type))
        col_names_safe <- ifelse(
          is.na(cols$type) | cols$type == "",
          col_names_safe,
          paste0(
            col_names_safe,
            " <span style='opacity:0.7;font-size:0.85em;'>",
            type_safe,
            "</span>"
          )
        )
        plain_labels <- ifelse(
          is.na(cols$type) | cols$type == "",
          plain_labels,
          paste0(plain_labels, " ", cols$type)
        )
      }

      # Mark primary keys with key symbol
      pk_idx <- which(cols$key == 1 & !is.na(cols$kind) & cols$kind == "PK")
      if (length(pk_idx) > 0) {
        col_names_safe[pk_idx] <- paste0("\U0001F511 ", col_names_safe[pk_idx])
        plain_labels[pk_idx] <- paste0("# ", plain_labels[pk_idx])
      }

      # Mark foreign keys with arrow symbol (columns that reference other tables)
      fk_idx <- which(!is.na(cols$ref))
      if (length(fk_idx) > 0) {
        # Don't double-mark if already marked as PK
        fk_only <- setdiff(fk_idx, pk_idx)
        col_names_safe[fk_only] <- paste0("\U2192 ", col_names_safe[fk_only])
        plain_labels[fk_only] <- paste0("> ", plain_labels[fk_only])
      }

      list(
        html = paste(col_names_safe, collapse = "<br/>"),
        plain = plain_labels
      )
    }
  )

  node_columns_html <- vapply(node_columns_data, `[[`, character(1), "html")

  # Calculate node sizes based on plain text content (not HTML markup)
  node_sizes <- Map(
    function(tbl, col_data) {
      plain_cols <- col_data$plain
      n_cols <- length(plain_cols)
      tbl_width <- nchar(tbl, type = "width")
      col_widths <- if (length(plain_cols) > 0) nchar(plain_cols, type = "width") else integer(0)
      max_chars <- max(c(tbl_width, col_widths), na.rm = TRUE)
      # Width: ~7px per character + padding
      width <- max(70, max_chars * 7 + 20)
      # Height: header (25px) + columns (16px each) + padding
      height <- if (n_cols > 0) 28 + n_cols * 16 else 32
      list(width = width, height = height)
    },
    node_ids,
    node_columns_data
  )

  # Create g6R nodes with data for HTML template
  node_list <- unname(Map(
    function(id, fill, cols_html, size) {
      g6R::g6_node(
        id = id,
        data = list(
          name = html_escape(id),
          columns = cols_html,
          color = fill,
          headerColor = darken_color(fill, 0.85),
          width = size$width,
          height = size$height
        )
      )
    },
    node_ids,
    node_colors,
    node_columns_html,
    node_sizes
  ))

  do.call(g6R::g6_nodes, node_list)
}

#' Create g6R edges from data model
#' @noRd
g6r_edges_from_data_model <- function(data_model) {
  refs <- data_model$references
  if (is.null(refs) || nrow(refs) == 0) {
    return(NULL)
  }

  # Only use first reference per key (ref_col_num == 1)
  refs <- refs[refs$ref_col_num == 1, , drop = FALSE]

  if (nrow(refs) == 0) {
    return(NULL)
  }

  # Use unname() to ensure edges serialize as JSON array, not object
  edge_list <- unname(Map(
    function(id, source, target) {
      g6R::g6_edge(
        id = id,
        source = source,
        target = target
      )
    },
    paste0("fk-", refs$keyId),
    refs$table,
    refs$ref
  ))

  do.call(g6R::g6_edges, edge_list)
}

#' Darken a hex color for borders/headers
#' @noRd
darken_color <- function(hex_color, factor = 0.7) {
  if (is.na(hex_color) || !grepl("^#", hex_color)) {
    return("#AAAAAA")
  }
  rgb_vals <- grDevices::col2rgb(hex_color)
  darkened <- round(rgb_vals * factor)
  grDevices::rgb(darkened[1], darkened[2], darkened[3], maxColorValue = 255)
}
