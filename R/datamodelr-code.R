
# data_model code directly from {datamodelr} --------------------------------------

bdm_from_data_frames <- function(...) {
  df_list <- list(...)
  if (length(df_list) == 1 && inherits(df_list[[1]], "list")) {
    df_list <- df_list[[1]]
  } else {
    if (length(names(df_list)) < length(df_list)) {
      names(df_list) <- as.list(match.call(expand.dots = TRUE)[-1])
    }
  }
  tables <- df_list
  names(tables) <- make.names(names(tables))
  dfdm <-
    do.call(
      rbind,
      lapply(names(tables), function(table_name) {
        t1 <- tables[[table_name]]
        columns <- data.frame(
          column = names(t1),
          type = sapply(t1[0, , drop = FALSE], function(x) paste(class(x), collapse = ", ")),
          stringsAsFactors = FALSE
        )
        columns$table <- table_name
        columns
      })
    )
  as.data_model(dfdm)
}

as.data_model <- function(x) {
  if (!inherits(x, "data.frame")) stop("Not a data.frame")

  if (!all(c("column", "table") %in% names(x))) {
    stop("Data frame must have elements named 'table' and 'column'.")
  }

  # set key to 0 if NA or add key if NULL:
  if (!is.null(x[["key"]])) {
    x[is.na(x[, "key"]), "key"] <- FALSE
  } else {
    x[, "key"] <- FALSE
  }

  # convert logical key markers to numeric (column order in a key)
  # x$table <- factor(x$table, ordered = TRUE)
  # if(max(x$key, na.rm = TRUE) <= 1) {
  #   keys <-
  #     lapply(split(x, x$table), function(t) {
  #       cumsum(t$key) * t$key
  #     })
  #   x$key <- unlist(keys)
  # }

  if (is.null(x[["ref"]])) x[["ref"]] <- NA


  # create references from ref and keys
  ref_table <- bdm_create_references(x)

  table_attrs <- attr(x, "tables")
  if (is.null(table_attrs)) {
    table_attrs <-
      data.frame(
        table = unique(x[["table"]]),
        segment = NA_character_,
        display = NA_character_,
        row.names = NULL,
        stringsAsFactors = FALSE
      )
  }
  attr(x, "tables") <- NULL
  ret <- list(
    tables = table_attrs,
    columns = x,
    references = ref_table
  )
  as.data_model_list(ret)
}

as.data_model_list <- function(x) {
  if (mode(x) != "list") {
    stop("Not a list")
  }
  if (!all(c("columns", "references") %in% (names(x)))) {
    stop("Input must have columns and references")
  }

  class(x) <- c("data_model", class(x))
  x
}

is.data_model <- function(x) {
  inherits(x, "data_model")
}

bdm_create_references <- function(col_table) {
  if (!inherits(col_table, "data.frame")) stop("Input must be a data frame.")

  if (!all(c("table", "column") %in% names(col_table))) {
    stop("Column info table must have table, column and ref variables.")
  }
  if (!"ref" %in% names(col_table)) {
    return(NULL)
  }
  if (all(is.na(col_table[, "ref"]))) {
    return(NULL)
  }


  if (is.null(col_table[["ref_col"]])) {
    col_table[["ref_col"]] <- NA
  }
  ref_table <- col_table[
    !is.na(col_table[["ref"]]), # take only rows with reference
    c("table", "column", "ref", "ref_col")
  ]
  col_table[is.na(col_table$key), "key"] <- FALSE

  ref_col <-
    with(
      ref_table,
      ifelse(is.na(ref_col),
        sapply(ref_table$ref, function(x) {
          col_table[col_table$table == x & col_table$key, "column"][1]
        }),
        ref_col
      )
    )
  ref_table[["ref_col"]] <- ref_col

  # number of columns in primary key
  num_col <- sapply(ref_table$ref, function(x) {
    length(col_table[col_table$table == x & col_table$key, ][["column"]])
  })
  num_col[num_col == 0L] <- 1L

  key_col_num <- {

    # create column index number
    rle1 <- rle(num_col)
    if (lengths(rle1)[1] > 0) {
      col_list <- sapply(1:lengths(rle1)[1], function(i) {
        rep(1:rle1$values[i], rle1$lengths[i] / rle1$values[i])
      })
      col_list[lengths(col_list) == 0] <- 1
      unlist(col_list)
    } else {
      NA
    }
  }

  dim(key_col_num) <- NULL
  if (nrow(ref_table) == length(key_col_num)) {
    ref_table$ref_id <- cumsum(key_col_num == 1)
    ref_table$ref_col_num <- key_col_num
  } else {
    ref_table$ref_col_num <- 1
    ref_table$ref_id <- cumsum(ref_table$ref_col_num)
  }
  ref_table
}

# graph code directly from {datamodelr} -----------------------------------------

bdm_create_graph <- function(
                             data_model,
                             rankdir = "BT",
                             graph_name = "Data Model",
                             graph_attrs = "",
                             node_attrs = "",
                             edge_attrs = "",
                             view_type = "all",
                             focus = NULL,
                             col_attr = "column",
                             columnArrows = FALSE,
                             legacy = FALSE) {
  g_list <-
    bdm_create_graph_list(
      data_model = data_model, view_type = view_type,
      focus = focus, col_attr = col_attr,
      columnArrows = columnArrows,
      legacy = legacy
    )
  if (length(g_list$nodes$nodes) == 0) {
    warning("The number of tables to render is 0.")
  }
  graph <-
    list(
      graph_attrs = sprintf('rankdir=%s tooltip="%s" %s', rankdir, graph_name, graph_attrs),
      node_attrs = sprintf('margin=0 fontcolor = "#444444" %s', node_attrs),
      nodes_df = g_list$nodes,
      edges_df = g_list$edges,
      edge_attrs = c('color = "#555555"', "arrowsize = 1", edge_attrs)
    )
  class(graph) <- c("datamodelr_graph", class(graph))

  # re-create dot code for data model
  # (DiagrammeR does not support yet the HTML labels and clusters (v.0.8))
  graph$dot_code <- dot_graph(graph, columnArrows)

  graph
}

bdm_render_graph <- function(graph, width = NULL, height = NULL) {
  if (!requireNamespace("DiagrammeR", quietly = TRUE)) {
    stop("DiagrammeR package needed for this function to work. Please install it.",
      call. = FALSE
    )
  }

  if (is.null(graph$dot_code)) {
    graph$dot_code <- dot_graph(graph)
  }

  DiagrammeR::grViz(graph$dot_code, allow_subst = FALSE, width, height)
}

bdm_create_graph_list <- function(
                                  data_model,
                                  view_type = "all",
                                  focus = NULL,
                                  col_attr = "column",
                                  columnArrows = FALSE,
                                  legacy = FALSE) {

  # hidden tables

  if (!is.null(focus) && is.list(focus)) {
    if (!is.null(focus[["tables"]])) {
      data_model$tables <- data_model$tables[data_model$tables$table %in% focus$tables, ]
      data_model$columns <- data_model$columns[data_model$columns$table %in% focus$tables, ]
      if (is.null(focus[["external_ref"]]) || !focus[["external_ref"]]) {
        data_model$references <- data_model$references[
          data_model$references$table %in% focus$tables &
            data_model$references$ref %in% focus$tables,
        ]
      }
    }
  } else {
    # hide tables with display == "hide" attribute
    if (is.null(data_model$tables$display)) data_model$tables$display <- NA
    data_model$tables$display[is.na(data_model$tables$display)] <- "show"
    hidden_tables <- data_model$tables[data_model$tables$display == "hide", "table"]
    if (!is.null(hidden_tables)) {
      data_model$tables <- data_model$tables[!data_model$tables$table %in% hidden_tables, ]
      data_model$columns <- data_model$columns[!data_model$columns$table %in% hidden_tables, ]
      data_model$references <- data_model$references[
        !data_model$references$table %in% hidden_tables &
          !data_model$references$ref %in% hidden_tables,
      ]
    }
  }

  # remove hidden columns
  # data_model$columns <-
  #  data_model$columns[is.na(data_model$columns$display) | data_model$columns$display != "hide", ]

  tables <- split(data_model$columns, data_model$columns$table)

  switch(view_type,
    all = {},

    keys_only = {
      tables <- lapply(tables, function(tab) {
        tab[tab[["key"]] > 0 | !is.na(tab[, "ref"]), ]
      })
    },

    title_only = {
      tables <- lapply(tables, function(tab) {
        tab[0L, ]
      })
    }
  )
  g_labels <-
    sapply(names(tables), function(x) {
      if (legacy) {
        dot_html_label_2(
          tables[[x]],
          title = x,
          palette_id = data_model$tables[data_model$tables$table == x, "display"],
          col_attr = col_attr,
          columnArrows = columnArrows
        )
      } else {
        dot_html_label(
          tables[[x]],
          title = x,
          palette_id = data_model$tables[data_model$tables$table == x, "display"],
          col_attr = col_attr,
          columnArrows = columnArrows
        )
      }
    })

  nodes <-
    data.frame(
      nodes = names(tables),
      label = g_labels,
      shape = "plaintext",
      type = "upper",
      segment = data_model$tables[order(data_model$tables$table), "segment"],

      stringsAsFactors = FALSE
    )


  if (!is.null(data_model$references)) {
    edges <-
      with(
        data_model$references[data_model$references$ref_col_num == 1, ],
        data.frame(
          from = table,
          to = ref,
          fromCol = column,
          toCol = ref_col,
          stringsAsFactors = FALSE
        )
      )
  } else {
    edges <- NULL
  }

  ret <-
    list(nodes = nodes, edges = edges)

  ret
}

dot_graph <- function(graph, columnArrows = FALSE) {
  graph_type <- "digraph"

  dot_attr <- paste0(
    sprintf("graph [%s]\n\n", paste(graph$graph_attrs, collapse = ", ")),
    sprintf("node [%s]\n\n", paste(graph$node_attrs, collapse = ", ")),
    sprintf("edge [%s]\n\n", paste(graph$edge_attrs, collapse = ", "))
  )
  segments <- unique(graph$nodes_df$segment)
  segments <- segments[!is.na(segments)]
  segments <- stats::setNames(1:(length(segments)), segments)

  dot_nodes <- sapply(seq_len(nrow(graph$nodes_df)), function(n) {
    node <- graph$nodes_df[n, ]
    dot_node <- sprintf("  '%s' [label = %s, shape = '%s'] \n", node$nodes, node$label, node$shape)
    if (!is.na(node[["segment"]])) {
      dot_node <- sprintf(
        "subgraph cluster_%s {\nlabel='%s'\ncolor=\"#DDDDDD\"\n%s\n}\n",
        segments[node[["segment"]]],
        node[["segment"]],
        dot_node
      )
    }
    dot_node
  })

  dot_seg_nodes <- paste(dot_nodes, collapse = "\n")
  dot_edges <- ""
  if (columnArrows) {
    dot_edges <- paste(
      sprintf(
        "'%s':'%s'->'%s':'%s'",
        graph$edges_df$from,
        graph$edges_df$fromCol,
        graph$edges_df$to,
        graph$edges_df$toCol
      ),
      collapse = "\n"
    )
  } else {
    dot_edges <- paste(
      sprintf("'%s'->'%s'", graph$edges_df$from, graph$edges_df$to),
      collapse = "\n"
    )
  }
  ret <- sprintf(
    "#data_model\n%s {\n%s\n%s\n%s\n}",
    graph_type,
    dot_attr,
    dot_seg_nodes,
    dot_edges
  )
  ret
}

html_table <- function(x, ...) html_tag(x, tag = "TABLE", ident = 1, ...)
html_tr <- function(x, ...) html_tag(x, tag = "TR", ident = 2, ...)
html_td <- function(x, ...) html_tag(x, tag = "TD", ident = 3, nl = FALSE, ...)
html_font <- function(x, ...) html_tag(x, tag = "FONT", ident = 0, nl = FALSE, ...)

html_tag <- function(x, tag, ident = 0, nl = TRUE, atrs = NULL, collapse = "") {
  if (length(x) > 1 && !is.null(collapse)) {
    x <- paste(x, collapse = collapse)
  }
  space <- paste(rep("  ", ident), collapse = "")
  atrs <- paste(sprintf('%s="%s"', names(atrs), atrs), collapse = " ")
  if (nchar(atrs) > 0) atrs <- paste0(" ", atrs)

  htext <-
    if (nl) {
      sprintf("%s<%s%s>\n%s%s</%s>\n", space, tag, atrs, x, space, tag)
    } else {
      sprintf("%s<%s%s>%s</%s>\n", space, tag, atrs, x, tag)
    }
  paste(htext, collapse = "")
}

to_html_table <- function(x,
                          title = "Table",
                          attr_table,
                          attr_header,
                          attr_font,
                          attr_td = NULL,
                          trans = NULL,
                          cols = names(x)) {
  html_table(atrs = attr_table, c(
    # header
    html_tr(
      html_td(
        html_font(title, atrs = attr_font),
        atrs = attr_header,
        collapse = NULL
      )
    ),
    # rows
    sapply(seq_len(nrow(x)), function(r) {
      html_tr(c(
        # cells
        sapply(cols, function(col_name) {
          value <- x[r, col_name]
          if (!is_null(trans)) value <- trans(col_name, x[r, ], value)
          html_td(value, if (is.null(attr_td)) NULL else attr_td(col_name, x[r, ], value))
        })
      ))
    })
  ))
}

dot_html_label <- function(x, title, palette_id = "default", col_attr = c("column"),
                           columnArrows = FALSE) {
  cols <- c("ref", col_attr)
  if (is.null(palette_id) || palette_id == "show") {
    palette_id <- "default"
  }
  # currently we always have a border around the tables
  border <- 1
  # test if palette_id is valid: either datamodelr or hexcode (converted in `dm_set_colors()` from colorname)
  if (palette_id == "default") {
    col <- list(
      line_color = "#555555",
      header_bgcolor = "#EFEBDD",
      header_font = "#000000",
      bgcolor = "#FFFFFF"
    )
  } else {
    header_bgcol_rgb <- col2rgb(palette_id)[, 1]
    bodycol_rgb <- as.integer(header_bgcol_rgb + (255 - header_bgcol_rgb) * 0.8)
    bodycol <- rgb(bodycol_rgb[1], bodycol_rgb[2], bodycol_rgb[3], maxColorValue = 255)
    # if header background too dark, use white font color
    header_font <- if (is_dark_color(header_bgcol_rgb)) "#FFFFFF" else "#000000"
    line_color_rgb <- as.integer(header_bgcol_rgb / 1.5)
    line_color <- rgb(line_color_rgb[1], line_color_rgb[2], line_color_rgb[3], maxColorValue = 255)

    col <- list(
      line_color = line_color,
      header_bgcolor = palette_id,
      header_font = header_font,
      bgcolor = bodycol
    )
  }

  attr_table <- list(
    ALIGN = "LEFT", BORDER = border, CELLBORDER = 0, CELLSPACING = 0
  )
  # border color
  if (border) {
    attr_table[["COLOR"]] <- col[["line_color"]]
  }
  attr_header <- list(
    COLSPAN = length(cols) - columnArrows, BGCOLOR = col[["header_bgcolor"]], BORDER = 0
  )
  attr_font <- list()
  attr_font <- list(COLOR = col[["header_font"]])

  attr_td <- function(col_name, row_values, value) {
    ret <- list(ALIGN = "LEFT", BGCOLOR = col[["bgcolor"]])
    if (col_name == "column" && columnArrows) {
      key <- row_values[["key"]]
      reference <- row_values[["ref"]]
      if (!is.na(reference) || key) {
        ret$PORT <- row_values[["column"]]
      }
    }
    ret
  }

  # value presentation transformation
  trans <- function(col_name, row_values, value) {
    if (col_name == "ref") {
      value <- ifelse(is.na(value), "", "~")
      if (columnArrows) {
        value <- NULL
      }
    }
    if (col_name == "column" && row_values[["key"]]) {
      value <- sprintf("<U>%s</U>", value)
    }
    if (!is.null(value) && is.na(value)) {
      value <- ""
    }
    return(value)
  }

  ret <- to_html_table(x,
    title = title,
    attr_table = attr_table,
    attr_header = attr_header,
    attr_font = attr_font,
    attr_td = attr_td,
    cols = cols,
    trans = trans
  )

  ret <- sprintf("<%s>", trimws(ret))

  ret
}
