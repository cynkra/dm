dm_write_zip <- function(dm, zip_file_path = "dm.zip") {
  check_param_class(dm, "dm")
  check_not_zoomed(dm)
  check_no_filter(dm)

  if (is_db(dm_get_src(dm))) {
    abort_only_for_local_src(dm_get_src(dm))
  }

  csv_info_filename <- file.path(tempdir(), "___info_file_dm.csv")
  csv_coltypes_filename <- file.path(tempdir(), "___coltypes_file_dm.csv")
  csv_pk_filename <- file.path(tempdir(), "___pk_file_dm.csv")
  csv_fk_filename <- file.path(tempdir(), "___fk_file_dm.csv")
  csv_table_filenames <- file.path(tempdir(), paste0(src_tbls(dm), ".csv"))

  info_tibble <- dm_get_def(dm) %>% select(table, segment, display)

  col_class_tibble <- dm_col_class(dm)

  pk_tibble <- dm_get_all_pks_impl(dm) %>%
    unnest(pk_col)

  # not using dm_get_all_fks_impl(), because it will break with introduction of compound keys
  fk_tibble <- dm_get_def(dm) %>%
    select("child_table" = table, fks) %>%
    unnest(fks) %>%
    rename(parent_table = table, fk_col = column) %>%
    # key number is needed in case of compound keys
    # FIXME: referenced column of PK then needs to be given too
    mutate(key_nr = row_number()) %>%
    unnest(fk_col)

  withr::defer({
    try(file.remove(csv_info_filename))
    try(file.remove(csv_coltypes_filename))
    try(file.remove(csv_pk_filename))
    try(file.remove(csv_fk_filename))
    walk(csv_table_filenames, ~ try(file.remove(.x)))
  })

  readr::write_csv(info_tibble, csv_info_filename)
  readr::write_csv(col_class_tibble, csv_coltypes_filename)
  readr::write_csv(pk_tibble, csv_pk_filename)
  readr::write_csv(fk_tibble, csv_fk_filename)

  walk2(dm_get_tables_impl(dm), csv_table_filenames, readr::write_csv)

  # compress the file ("-j" junks the path to the file)
  zip(zipfile = zip_file_path, files = c(
    csv_info_filename,
    csv_coltypes_filename,
    csv_table_filenames,
    csv_pk_filename,
    csv_fk_filename),
    flags = "-j -q"
  )
  message(glue::glue("Written `dm` as zip-file {tick(zip_file_path)}."))
  invisible(zip_file_path)
}

dm_read_zip <- function(zip_file_path) {
  # FIXME: nicer way for randomized path-name?
  unzip_directory <- file.path(tempdir(), basename(tempfile(pattern = "dm_unzip_")))
  withr::defer(unlink(unzip_directory, recursive = TRUE))
  utils::unzip("dm.zip", exdir = unzip_directory)

  # FIXME: abort if special files do not exist

  def_base <- readr::read_csv(
    file.path(unzip_directory, "___info_file_dm.csv"),
    col_types = "ccc"
  )
  table_names <- def_base$table
  col_class_info <- readr::read_csv(
    file.path(unzip_directory, "___coltypes_file_dm.csv"),
    col_types = "ccc"
  ) %>%
    mutate(readr_class = readr_translate(class)) %>%
    group_by(table) %>%
    summarize(readr_class = paste0(readr_class, collapse = ""))
  # sort column classes according to column def_base$table
  col_class_sorted <- col_class_info$readr_class[order(match(col_class_info$table, table_names))]

  pk_info <- readr::read_csv(
    file.path(unzip_directory, "___pk_file_dm.csv"),
    col_types = "cc"
  )

  fk_info <- readr::read_csv(
    file.path(unzip_directory, "___fk_file_dm.csv"),
    col_types = "ccci"
  )

  table_files <- setdiff(
    list.files(unzip_directory),
    c("___info_file_dm.csv", "___pk_file_dm.csv", "___fk_file_dm.csv", "___coltypes_file_dm.csv")
  )
  # sort table_files according to column def_base$table
  table_files_sorted <- table_files[order(match(table_files, paste0(table_names, ".csv")))]

  # guessing column types
  # FIXME: column-types could actually also be stored in another file; is it necessary?
  table_tibble <- map2(
    file.path(unzip_directory, table_files_sorted),
    col_class_sorted,
    ~ readr::read_csv(file = .x, col_types = .y)
  ) %>%
    set_names(table_names) %>%
    enframe(name = "table", value = "data") %>%
    # empty subset is necessary because
    # https://www.tidyverse.org/blog/2018/12/readr-1-3-1/#tibble-subclass
    mutate(data = map(data, `[`))

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

dm_col_class <- function(dm) {
  tables <- dm_get_tables_impl(dm)
  map(dm_get_tables_impl(dm), colnames) %>%
    imap_dfr(function(col, table) {tibble(table = table, column = col)}) %>%
    mutate(class = map2_chr(
      table,
      column,
      function(table, column) {tables[[table]] %>% pull(column) %>% class()})
    )
}

readr_translate <- function(r_class) {
  translation_tibble <- tribble(
    ~r_class, ~readr_code,
    "logical", "l",
    "integer", "i",
    "double", "d",
    "character", "c",
    "date", "D",
    "time", "t",
    "datetime", "T",
    "number", "n"
    )
  map_chr(r_class, ~ filter(translation_tibble, r_class == .x) %>% pull(readr_code))
}
