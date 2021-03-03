#' Read/write a local dm from/to files
#'
#' @description
#' `r lifecycle::badge("experimental")`
#'
#' Store a local `dm` in a file or directory and retrieve it later.
#'
#' @inheritParams dm_add_pk
#' @param csv_directory For `dm_write_csv()`: The path to a non-existent or empty
#' directory to write the `csv`-files defining the `dm` to.
#'
#' For `dm_read_csv()`: The path to the directory containing the `dm` as `csv-files`.
#' @details `dm_write_csv()`: write a `dm` to a collection of `csv`-files to a non-existent or empty directory.
#'
#' @return `read`-family: A `dm` object.
#'
#' `write`-family: The path to the file/directory containing the stored `dm`, invisibly.
#'
#' @rdname dm-read-write
#' @export
#' @examples
#' dm_write_csv(dm_nycflights13(), "nyc_dm_as_csv")
dm_write_csv <- function(dm, csv_directory) {
  if (dir.exists(csv_directory) && length(list.files(csv_directory)) > 0) {
    abort_dir_not_empty()
  }
  tryCatch(
    dm_write_csv_impl(dm, csv_directory, zip = FALSE),
    error = function(e) {
      # remove directory in case it was created but there was an error
      try(unlink(csv_directory, recursive = TRUE))
      # keep error message and class though
      abort(conditionMessage(e), .subclass = class(e))
    }
  )
}

#' @details `dm_read_csv()`: read a `dm` from a directory created using `dm_write_csv()`.
#' @rdname dm-read-write
#' @export
#' @examples
#' dm_read_csv("nyc_dm_as_csv")
dm_read_csv <- function(csv_directory) {
  file_list <- list.files(csv_directory)
  special_files <- c(
    "___info_file_dm.csv",
    "___coltypes_file_dm.csv",
    "___pk_file_dm.csv",
    "___fk_file_dm.csv"
  )
  if (!all(special_files %in% file_list)) {
    abort_files_or_sheets_missing(setdiff(special_files, intersect(file_list, special_files)), csv_directory)
  }

  def_base <- readr::read_csv(
    file.path(csv_directory, "___info_file_dm.csv"),
    col_types = "ccc"
  )
  table_names <- def_base$table
  col_class_info <- readr::read_csv(
    file.path(csv_directory, "___coltypes_file_dm.csv"),
    col_types = "ccc"
  ) %>%
    mutate(readr_class = readr_translate(class)) %>%
    group_by(table) %>%
    summarize(readr_class = paste0(readr_class, collapse = ""))
  # sort column classes according to column def_base$table
  col_class_sorted <- col_class_info$readr_class[order(match(col_class_info$table, table_names))]

  pk_info <- readr::read_csv(
    file.path(csv_directory, "___pk_file_dm.csv"),
    col_types = "cc"
  )

  fk_info <- readr::read_csv(
    file.path(csv_directory, "___fk_file_dm.csv"),
    col_types = "ccci"
  )

  table_files <- setdiff(
    list.files(csv_directory),
    c("___info_file_dm.csv", "___pk_file_dm.csv", "___fk_file_dm.csv", "___coltypes_file_dm.csv")
  )
  # sort table_files according to column def_base$table
  table_files_sorted <- table_files[order(match(table_files, paste0(table_names, ".csv")))]

  table_tibble <- map2(
    file.path(csv_directory, table_files_sorted),
    col_class_sorted,
    ~ readr::read_csv(file = .x, col_types = .y)
  ) %>%
    set_names(table_names) %>%
    enframe(name = "table", value = "data") %>%
    # empty subset is necessary because
    # https://www.tidyverse.org/blog/2018/12/readr-1-3-1/#tibble-subclass
    mutate(data = map(data, `[`))

  make_dm(def_base, table_names, table_tibble, pk_info, fk_info)
}

#' @inheritParams dm_write_csv
#' @param zip_file_path
#' For `dm_write_zip`: The file path to the `zip`-file to write; defaults to `dm.zip`.
#'
#' For `dm_read_zip`: The file path to the `zip`-file to read the `dm` from.
#' @param overwrite Logical, default: `FALSE`. In case the file already exists, should it be overwritten?
#' @details `dm_write_zip()`: write a `dm` to a `zip`-file containing a collection of `csv`-files.
#' @rdname dm-read-write
#' @export
#' @examples
#' dm_write_zip(dm_nycflights13())
dm_write_zip <- function(dm, zip_file_path = "dm.zip", overwrite = FALSE) {
  if (file.exists(zip_file_path)) {
    if (overwrite) {
      message(glue::glue("Overwriting file {tick(zip_file_path)}."))
    } else{
      abort_file_exists(zip_file_path)
    }
  }

  csv_directory <- file.path(tempdir(), basename(tempfile(pattern = "dm_zip_")))
  dm_write_csv_impl(dm, csv_directory, zip = TRUE)

  withr::defer(try(unlink(csv_directory, recursive = TRUE)))

  csv_files <- list.files(csv_directory)
  # compress the file ("-j" junks the path to the file)

  zip(
    zipfile = zip_file_path,
    files = file.path(csv_directory, csv_files),
    flags = "-j -q"
  )
  message(glue::glue("Written `dm` as zip-file {tick(zip_file_path)}."))
  invisible(zip_file_path)
}

#' @details `dm_read_zip()`: read a `dm` from a `zip`-file created using `dm_write_zip()`.
#' @rdname dm-read-write
#' @export
#' @examples
#' dm_read_zip("dm.zip")
dm_read_zip <- function(zip_file_path) {
  # FIXME: nicer way for randomized path-name?
  unzip_directory <- file.path(tempdir(), basename(tempfile(pattern = "dm_unzip_")))
  withr::defer(unlink(unzip_directory, recursive = TRUE))
  utils::unzip(zip_file_path, exdir = unzip_directory)

  dm_read_csv(unzip_directory)
}

#' @inheritParams dm_write_zip
#' @param xlsx_file_path
#' For `dm_write_xlsx()`: The file path to the `xlsx`-file to write; defaults to `dm.xlsx`.
#'
#' For `dm_read_xlsx()`: The file path to the `xlsx`-file to read the `dm` from.
#' @details `dm_write_xlsx()`: write a `dm` to an `xlsx`-file containing several tables defining the `dm`.
#' @rdname dm-read-write
#' @export
#' @examples
#' dm_write_xlsx(dm_nycflights13())
dm_write_xlsx <- function(dm, xlsx_file_path = "dm.xlsx", overwrite = FALSE) {

  if (file.exists(xlsx_file_path)) {
    if (overwrite) {
      message(glue::glue("Overwriting file {tick(xlsx_file_path)}."))
    } else{
      abort_file_exists(xlsx_file_path)
    }
  }

  xlsx_tables <- prepare_tables(dm)

  xl_sheet_list <- c(
    dm_get_tables_impl(dm),
    list(
      "___info_dm" = xlsx_tables$info_tibble,
      "___coltypes_dm" = xlsx_tables$col_class_tibble,
      "___pk_dm" = xlsx_tables$pk_tibble,
      "___fk_dm" = xlsx_tables$fk_tibble
      )
    )

  writexl::write_xlsx(xl_sheet_list, path = xlsx_file_path)
  message(
    glue::glue("Written `dm` as xlsx-file {tick(xlsx_file_path)}.")
  )
  invisible(xlsx_file_path)
}

#' @details `dm_read_xlsx()`: read a `dm` from an `xlsx`-file created using `dm_write_xlsx()`.
#' @rdname dm-read-write
#' @export
#' @examples
#' dm_read_xlsx("dm.xlsx")
dm_read_xlsx <- function(xlsx_file_path) {
  sheet_list <- readxl::excel_sheets(xlsx_file_path)
  special_sheets <- c(
    "___info_dm",
    "___coltypes_dm",
    "___pk_dm",
    "___fk_dm"
  )
  if (!all(special_sheets %in% sheet_list)) {
    abort_files_or_sheets_missing(
      setdiff(special_sheets, intersect(sheet_list[1:3], special_sheets)),
      xlsx_file_path,
      csv = FALSE
    )
  }

  def_base <- readxl::read_xlsx(
    xlsx_file_path,
    sheet = "___info_dm",
    col_types = "text"
  )
  table_names <- def_base$table

  col_class_info <- readxl::read_xlsx(
    xlsx_file_path,
    sheet = "___coltypes_dm",
    col_types = "text"
  ) %>%
    group_by(table) %>%
    summarize(column = list(column), class = list(class))
  # FIXME: use it wisely

  pk_info <- readxl::read_xlsx(
      xlsx_file_path,
      sheet = "___pk_dm",
    col_types = "text"
  )

  fk_info <- readxl::read_xlsx(
    xlsx_file_path,
    sheet = "___fk_dm",
    col_types = c("text", "text", "text", "numeric")
  )

  table_sheets <- setdiff(
    sheet_list,
    c("___info_dm", "___pk_dm", "___fk_dm", "___coltypes_dm")
  )
  # sort table_files according to column def_base$table
  table_sheets_sorted <- table_sheets[order(match(table_sheets, table_names))]

  table_tibble <- map(
    table_sheets_sorted,
    readxl::read_xlsx, path = xlsx_file_path
  ) %>%
    set_names(table_names) %>%
    enframe(name = "table", value = "data")

  # since reading from xlsx via `readxl::read_xlsx()` does e.g. not support reading as integer
  # we reclass the columns in retrospect:
  table_tibble_reclassed <- left_join(table_tibble, col_class_info, by = "table") %>%
    select(-table) %>%
    pmap(function(data, column, class) {
      reduce2(column, class, function(data, column, class) {
      mutate(data, !!column := get(paste0("as.", class))(!!sym(column)))
    }, .init = data)
    }) %>%
    set_names(table_names) %>%
    enframe(name = "table", value = "data")

  make_dm(def_base, table_names, table_tibble_reclassed, pk_info, fk_info)
}

make_dm <- function(def_base, table_names, table_tibble, pk_info, fk_info) {

  pk_tibble <- pk_info %>%
    group_by(table) %>%
    mutate(pks = list(tibble(column = list(pk_col)))) %>%
    ungroup() %>%
    select(-pk_col)

  fk_tibble <- fk_info %>%
    group_by(child_table, key_nr) %>%
    summarize(fks = list(
      tibble(
        table = unique(parent_table),
        column = list(fk_col)
      )
    ), .groups = "drop_last"
    ) %>%
    summarize(
      fks = list(bind_rows(fks)),
      .groups = "drop"
    )

  zoom <- new_zoom()
  col_tracker_zoom <- new_col_tracker_zoom()
  filter_tibble <-
    tibble(
      table = table_names,
      filters = vctrs::list_of(new_filter())
    )

  def_base %>%
    left_join(table_tibble, by = "table") %>%
    relocate(data, .after = "table") %>%
    left_join(pk_tibble, by = "table") %>%
    mutate(pks = map(pks, ~ if (is_null(.x)) {new_pk()} else {.x})) %>%
    mutate(pks = vctrs::as_list_of(pks)) %>%
    left_join(fk_tibble, by = c("table" = "child_table")) %>%
    mutate(fks = map(fks, ~ if (is_null(.x)) {new_fk()} else {.x})) %>%
    mutate(fks = vctrs::as_list_of(fks)) %>%
    left_join(filter_tibble, by = "table") %>%
    left_join(zoom, by = "table") %>%
    left_join(col_tracker_zoom, by = "table") %>%
    new_dm3()
}

prepare_tables <- function(dm) {
  check_param_class(dm, "dm")
  check_not_zoomed(dm, -3)
  check_no_filter(dm, -3)
  if (is_empty(dm)) {abort_empty_dm()}

  if (is_db(dm_get_src(dm))) {
    abort_only_for_local_src(dm_get_src(dm))
  }

  info_tibble <- dm_get_def(dm) %>% select(table, segment, display)

  col_class_tibble <- dm_col_class(dm)
  if ("list" %in% col_class_tibble$class) {
    tbl_col_list <- filter(col_class_tibble, class == "list")
    abort_no_list(tbl_col_list$table, tbl_col_list$column)
  }
  if ("datetime" %in% col_class_tibble$class |
      "POSIXct" %in% col_class_tibble$class |
      "POSIXlt" %in% col_class_tibble$class) {
    tbl_dt_list <- filter(
      col_class_tibble,
      class == "datetime" |
        class == "POSIXct" |
        class == "POSIXlt"
    )
    message(
      glue::glue(
        "Columns containing datetimes need to be converted to TZ `UTC` to avoid errors, consider checking columns:\n",
        "{paste0('Table: ', tick(tbl_dt_list$table), ', column: ', tick(tbl_dt_list$column), collapse = '\n')}"
      )
    )
  }

  # FIXME: might need to revisit for compound keys
  pk_tibble <- dm_get_all_pks_impl(dm)

  # not using dm_get_all_fks_impl(), because it will break with introduction of compound keys
  # FIXME: might need to revisit for compound keys
  fk_tibble <- dm_get_def(dm) %>%
    select("child_table" = table, fks) %>%
    unnest(fks) %>%
    rename(parent_table = table, fk_col = column) %>%
    # key number is needed in case of compound keys
    # FIXME: referenced column of PK then needs to be given too
    mutate(key_nr = row_number()) %>%
    unnest(fk_col)

  list(
    info_tibble = info_tibble,
    col_class_tibble = col_class_tibble,
    pk_tibble = pk_tibble,
    fk_tibble = fk_tibble
  )
}

dm_write_csv_impl <- function(dm, csv_directory, zip) {
  csv_tables <- prepare_tables(dm)

  if (!dir.exists(csv_directory)) {
    dir.create(csv_directory)
  }

  csv_info_filename <- file.path(csv_directory, "___info_file_dm.csv")
  csv_coltypes_filename <- file.path(csv_directory, "___coltypes_file_dm.csv")
  csv_pk_filename <- file.path(csv_directory, "___pk_file_dm.csv")
  csv_fk_filename <- file.path(csv_directory, "___fk_file_dm.csv")
  csv_table_filenames <- file.path(csv_directory, paste0(src_tbls(dm), ".csv"))

  readr::write_csv(csv_tables$info_tibble, csv_info_filename)
  readr::write_csv(csv_tables$col_class_tibble, csv_coltypes_filename)
  readr::write_csv(csv_tables$pk_tibble, csv_pk_filename)
  readr::write_csv(csv_tables$fk_tibble, csv_fk_filename)

  walk2(dm_get_tables_impl(dm), csv_table_filenames, readr::write_csv)
  if (!zip) {
    message(
      glue::glue("Written `dm` as collection of csv-files to directory {tick(csv_directory)}.")
    )
  }
  invisible(csv_directory)
}

dm_col_class <- function(dm) {
  tables <- dm_get_tables_impl(dm)
  map(dm_get_tables_impl(dm), colnames) %>%
    imap_dfr(function(col, table) {tibble(table = table, column = col)}) %>%
    mutate(class = map2_chr(
      table,
      column,
      function(table, column) {
        tables[[table]] %>%
          pull(column) %>%
          class() %>%
          pluck(1)}
      )
    )
}

readr_translate <- function(r_class) {
  translation_tibble <- tribble(
    ~r_class, ~readr_code,
    "logical", "l",
    "integer", "i",
    "double", "d",
    "numeric", "d",
    "character", "c",
    "Date", "D",
    "time", "t",
    "datetime", "T",
    "POSIXlt", "T",
    "POSIXct", "T",
    "number", "n"
    )
  map_chr(r_class, ~ filter(translation_tibble, r_class == .x) %>% pull(readr_code))
}
