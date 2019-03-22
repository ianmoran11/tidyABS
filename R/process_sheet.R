#' get tidyABS components
#'
#' Produces the  tidyABS table components, which store information on column groups, row groups and tabledata.
#' @param path path to .xlsx file
#' @param sheets sheet nominated for tidying
#'
#' @examples
#'
#'  \donttest{tidyABS_example("australian-industry.xlsx") %>% process_sheet(sheets = "Table_1")  }
#'
#'
#'
#' @export

process_sheet <-
  function(path, sheets, manual_value_references = NULL, added_row_groups = NULL, keep_meta_data = FALSE) {

    sheet <- tidyxl::xlsx_cells(path = path, sheets = sheets)
    formats <- tidyxl::xlsx_formats(path)

    continue <- TRUE

    while (continue) {
      sheet_original <- sheet
      sheet <- sheet %>% fill_in_blanks()

      continue <- !identical(sheet_original, sheet)
    }



    manual_value_references_temp <- manual_value_references
    value_ref <- sheet %>% get_value_references(manual_value_references = manual_value_references_temp)


    added_row_groups_temp <- added_row_groups
    col_groups <- get_col_groups(sheet = sheet, value_ref = value_ref, formats = formats)
    row_groups <- get_row_groups(
      sheet = sheet, value_ref = value_ref,
      formats = formats, col_groups = col_groups, added_row_groups = added_row_groups_temp
    )


    meta_df <- get_meta_df(sheet = sheet, value_ref = value_ref, formats = formats, col_groups = col_groups)
    tabledata <- get_tabledata(sheet = sheet, value_ref = value_ref)



    unique_cols <- col_groups$data %>% map(3) %>% map(unique)
    unique_meta <- meta_df$data %>% map(3) %>% map(unique)
    unique_rows <- row_groups$data %>% map(3) %>% map(unique)


    # Remove meta data /col group duplicates
    joint_col <-
      full_join(
        tibble(values = unique_cols) %>%
          mutate(col_group = row_number()) %>%
          unnest(),
        tibble(values = unique_meta) %>%
          mutate(meta_group = row_number()) %>%
          unnest()
      )

    cols_to_keep <-
      joint_col %>%
      group_by(col_group) %>%
      filter(!is.na(col_group)) %>%
      summarise(keep = 1 != sum(!is.na(meta_group) / length(meta_group), na.rm = TRUE)) %>%
      pull(keep)


    col_groups <- col_groups[cols_to_keep, ]

    if (keep_meta_data == FALSE) {
      list(col_groups = col_groups, row_groups = row_groups, tabledata = tabledata)
    } else {
      list(col_groups = col_groups, row_groups = row_groups, meta_df = meta_df, tabledata = tabledata)
    }
  }
