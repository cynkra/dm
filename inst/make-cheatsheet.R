temp_folder <- withr::local_tempdir()
input <- knitr::current_input(dir = TRUE)
input_dir <- dirname(input)
final_dir <- file.path(input_dir, "cheatsheet")
withr::with_dir(
  temp_folder, {
    html_path <- withr::local_tempfile(fileext = ".html")
    rmd_path <- withr::local_tempfile(fileext = ".rmd")

    original <- brio::read_lines(input)
    # remove the part reading this very script to avoid an infinite loop :-s
    brio::write_lines(original[-c((length(original)-4):length(original))], rmd_path)

    withr::with_envvar(
      new = list("CHEATSHEET" = "blabla"), {
        rmarkdown::render(
          rmd_path,
          output_format = rmarkdown::html_document(
            self_contained = FALSE,
            section_divs = FALSE
          ),
          output_file = html_path
        )
      }
    )

    html <- xml2::read_html(html_path)
    title <- xml2::xml_find_first(html, ".//h1") |> xml2::xml_text()
    subtitle <- xml2::xml_find_first(html, ".//blockquote/p") |> xml2::xml_text()

    # figures ----------

    img <- xml2::xml_find_all(html, ".//img")
    fix_src <- function(img) {
      if (grepl("shiny.png", xml2::xml_attr(img, "src"))) {
        xml2::xml_attr(img, "src") <- "cheatsheet-figures/shiny.png"
      } else {
        xml2::xml_attr(img, "src") <- sub(
          ".*man/figures/cheatsheet",
          "cheatsheet-figures",
          xml2::xml_attr(img, "src")
        )
      }
    }
    purrr::walk(img, fix_src)

    # content ---------
    find_col <- function(col) {

      xml2::xml_find_first(
        html,
        sprintf(
          "//div[@class='%s']",
          col
        )
      ) |>
        xml2::xml_contents() |>
        as.character() |>
        paste0(collapse = "\n")
    }
    col11 <- find_col("page1col1")
    col12 <- find_col("page1col2")
    col13 <- find_col("page1col3")
    col21 <- find_col("page2col1")
    col22 <- find_col("page2col2")
    col23 <- find_col("page2col3")

    # deps ------------
    bs_theme <- bslib::bs_theme(
      `font-size-base` = ".6rem",
      `h2-font-size` = "1rem",
      `h3-font-size` = ".8rem",
      `h4-font-size` = ".8rem",
      `headings-color` = "#6366f1",
      `primary` = "#6366f1"
    )

    deps <- bslib::bs_theme_dependencies(bs_theme)
    deps <- lapply(deps, htmltools::copyDependencyToDir, file.path("cheatsheet", "deps"))
    deps <- lapply(deps, htmltools::makeDependencyRelative, getwd())
    deps <- htmltools::renderDependencies(deps, srcType = "file")

    # css -------
    css <- system.file("cheatsheet.css", package = "dm")
    file.copy(css, "cheatsheet.css")

    # logo -------
    fs::dir_copy(file.path(input_dir, "cheatsheet-figures"), "cheatsheet-figures")
    logo <- file.path(input_dir, "cheatsheet-figures", "logo.svg")
    dir.create("cheatsheet")
    file.copy(logo, file.path("cheatsheet", "logo.svg"))
    file.copy(logo, "logo.svg")
    file.copy(
      file.path(input_dir, "logo.png"),
      "logo.png"
    )

    # render --------------
    template <- paste0(brio::read_lines(system.file("cheatsheet-template.html", package = "dm")), collapse = "")
    rendered <- whisker::whisker.render(template)
    brio::write_lines(rendered, "cheatsheet-printable.html")
    fs::dir_copy(getwd(), final_dir)
  }
)
