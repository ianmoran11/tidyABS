
#' Fill in blanks
#'
#' This function ensures that merged cells are unmerged.
#'
#' @param sheet sheet object read in by `tidyxl::xlsx_cells`
#'
#' @export


fill_in_blanks <- function(sheet) {

  # Define blank cells
  blank_df <-
    sheet %>%
    filter(data_type == "blank")

  # Filter out blank cells - use this to check neighbours of blank cells
  joiner <- sheet %>% select(-character_formatted) %>% filter(!is_blank)

  # Check each cells agains the column to the left
  inserter <-
    blank_df %>%
    mutate(col_old = col, col = col - 1) %>%
    mutate(address_old = address) %>%
    select(sheet, row, col, col_old, local_format_id,address_old) %>%
    left_join(joiner) %>%
    mutate(address = address_old) %>%
    select(-address_old) %>%
    mutate(col = col_old) %>%
    select(-col_old) %>%
    filter(!is_blank) %>%
    mutate(row_col = paste0(row, "_", col))

  # Join sheet with inserter
  sheet <-
    sheet %>%
    mutate(row_col = paste0(row, "_", col)) %>%
    filter(!row_col %in% inserter$row_col) %>%
    bind_rows(inserter) %>%
    arrange(row, col)

  # Remove duplicates
  sheet %>% group_by(row, col) %>% top_n(1) %>% ungroup()

}

#' Get table references
#'
#' Identifies rectangle of numeric cells in table.
#'
#' @param sheet sheet object read in by `tidyxl::xlsx_cells`
#' @param manual_value_references sheet object read in by `tidyxl::xlsx_cells`
#'
#' @export



get_value_references <- function(sheet, manual_value_references) {

 # Automatic producedure
  if (is.null(manual_value_references)) {
    sheet %>%
      filter(!is.na(numeric)) %>%
      summarise(
        min_row = min(row), max_row = max(row),
        min_col = min(col), max_col = max(col)
      )
  } else {
 # Use manual values
    cell_ref_df <-
      manual_value_references %>%
      map_df(cell_ref_2_df)

    data_frame(
      min_col = as.integer(min(cell_ref_df$column)),
      max_col = as.integer(max(cell_ref_df$column)),
      min_row = as.integer(min(cell_ref_df$row)),
      max_row = as.integer(max(cell_ref_df$row))
    )
  }
}


#' Convert an adress to row/col tibble
#'
#' Convert an adress reference to a tibble identifying row and col
#'
#' @param cell_ref Cell reference in address format - e.g. "A1"
#'
#' @export


cell_ref_2_df <- function(cell_ref) {
  column_index <-
    data_frame(LETTERS) %>%
    mutate(LETTERS2 = rep(tibble(LETTERS), 26)) %>%
    unnest() %>%
    mutate(columns = paste0(LETTERS, LETTERS2)) %>%
    pull(columns) %>%
    c(LETTERS, .)

  which(str_extract(cell_ref, "[A-Z]{1,5}") == column_index) -> column
  str_extract(cell_ref, "[0-9]{1,5}") -> row

  data_frame(column = column, row = row)
}


#' Get indent of cells
#'
#' Return the level of indenting of a specified cell.
#'
#' @param local_format_id the local_format_id provided by `tidyxl::xlsx_cells`
#' @param formats sheet object read in by `tidyxl::xlsx_formats`
#'
#' @export


get_indent <- function(local_format_id, formats) {
  formats$local$alignment[["indent"]][[local_format_id]]
}


#' Get table references
#'
#' This function:
#'          1. Identifies which cells are likely to be headers
#'          2. groups them according to their indenting, bold and italic formatting
#'          3. Specifies the unpivotr function specifying the direction of the header w.r.t. table data
#' @param sheet sheet object read in by `tidyxl::xlsx_cells`
#' @param value_ref data frame representing corners of numeric cells in excel sheet
#' @param formats format object read in by `tidyxl::xlsx_cells`
#'
#' @export


get_col_groups <- function(sheet, value_ref, formats) {
  col_df <-
    sheet %>%
    filter(!is_blank) %>%
    filter(col <= value_ref$max_col) %>%
    filter(col >= value_ref$min_col) %>%
    filter(row < value_ref$min_row) %>%
    mutate(row_temp = row) %>%
    mutate(indent = local_format_id %>%
      map_dbl(possibly({
        ~ formats$local$alignment[["indent"]][[.x]]
      }, 0)) %>%
      unlist()) %>%
    mutate(bold = local_format_id %>%
      map(~ formats$local$font[["bold"]][[.x]]) %>%
      unlist()) %>%
    mutate(italic = local_format_id %>%
      map(~ formats$local$font[["italic"]][[.x]]) %>%
      unlist()) %>%
    group_by(row_temp, indent, bold, italic) %>%
    nest() %>%
    ungroup() %>%
    mutate(row_no_name = row_temp - min(row_temp) + 1) %>%
    mutate(col_group = paste0("col_group_", str_pad(row_number(), 2, side = "left", "0"))) %>%
    mutate(data = map2(
      data, col_group,
      function(data, col_group) {
        temp_df <- data %>%
          mutate(value = coalesce(
            as.character(numeric),
            as.character(character),
            as.character(logical),
            as.character(date)
          )) %>%
          select(row, col, value)
        temp_df[[col_group]] <- temp_df$value
        temp_df %>% select(-value)
      }
    )) %>%
    mutate(direction = "N") %>%
    dplyr::select(col_group, direction, data, indent, bold, italic)

  col_df %>%
    mutate(data_summary = data %>%
      map(~ .x %>% summarise(
        min_col = min(col, na.rm = T), max_col = max(col, na.rm = T),
        min_row = min(row, na.rm = T), max_row = max(row, na.rm = T)
      ))) %>%
    unnest(data_summary) # %>%
  # check_low_col_names
}


#' Get Rowname DF
#'
#' This function:
#'          1. Identifies which cells are likely to be row names
#'          2. groups them according to their indenting, bold and italic formatting
#'          3. Specifies the unpivotr function specifying the direction of the header w.r.t. table data
#' @param sheet sheet object read in by `tidyxl::xlsx_cells`
#' @param value_ref data frame representing corners of numeric cells in excel sheet
#' @param formats format object read in by `tidyxl::xlsx_cells`
#' @param col_groups format object read in by `tidyxl::xlsx_cells`
#' @param added_row_groups format object read in by `tidyxl::xlsx_cells`
#'
#' @export


get_row_groups <- function(sheet, value_ref, col_groups, formats, added_row_groups) {

  ## Used for debugging
  # sheet <- sheet
  # value_ref <- value_ref
  # formats <- formats
  # col_groups <- col_groups

  row_name_df <-
    sheet %>%
    filter(
      !is_blank,
      row <= value_ref$max_row,
      row > max(col_groups$max_row),
      col < value_ref$min_col
    ) %>%
    mutate(col_temp = col) %>%
    mutate(indent = local_format_id %>%
      map(~ formats$local$alignment[["indent"]][[.x]]) %>%
      unlist()) %>%
    mutate(bold = local_format_id %>%
      map(~ formats$local$font[["bold"]][[.x]]) %>%
      unlist()) %>%
    mutate(italic = local_format_id %>%
      map(~ formats$local$font[["italic"]][[.x]]) %>%
      unlist())


  if (!is.null(added_row_groups)) {
    added_row_df <-
      tibble(address = added_row_groups) %>%
      mutate(added_group_no = row_number()) %>%
      unnest()

    row_name_df <-
      row_name_df %>%
      left_join(added_row_df)
  } else {
    row_name_df <-
      row_name_df %>%
      mutate(added_group_no = NA)
  }


  row_name_df <-
    row_name_df %>%
    group_by(col_temp, indent, bold, italic, added_group_no) %>%
    nest() %>%
    ungroup() %>%
    arrange(col_temp, indent, italic, bold) %>%
    mutate(row_group = paste0("row_group_", str_pad(row_number(), 2, side = "left", "0"))) %>%
    mutate(data = map2(
      data, row_group,
      function(data, row_group) {
        temp_df <- data %>%
          mutate(value = coalesce(
            as.character(numeric),
            as.character(character),
            as.character(logical),
            as.character(date)
          )) %>%
          select(row, col, value)

        temp_df[[row_group]] <- temp_df$value

        temp_df %>% select(-value)
      }
    ))


  row_name_df <-
    row_name_df %>%
    mutate(row_sum = map_dbl(data, ~ get_row_sum(data = .x, sheet = sheet)))


  row_name_df %>%
    mutate(direction = ifelse(row_sum == 0, "NNW", "W")) %>%
    dplyr::select(row_group, direction, data, indent, bold, italic, added_group_no) %>%
    mutate(data_summary = data %>%
      map(~ .x %>% summarise(
        min_col = min(col, na.rm = T), max_col = max(col, na.rm = T),
        min_row = min(row, na.rm = T), max_row = max(row, na.rm = T)
      ))) %>%
    unnest(data_summary)
}



#' Get row sum
#'
#' This function is used to identify whether rows have a Wester or NNW orientation to data
#' @param data  a row_name_df object
#' @param sheet  a row_name_df object
#'
#' @export

get_row_sum <- function(data, sheet) {
  data %>%
    mutate(row_sum_values = map_dbl(
      row,
      function(x) {
        summarise(filter(sheet, row == x), filled = sum(numeric, na.rm = T))$filled
      }
    )) %>%
    summarise(row_sum_values = sum(row_sum_values, na.rm = T)) %>%
    pull(row_sum_values)
}


#' get metadata df
#'
#' This function:
#'          1. Identifies which cells are likely to to contains meta data (in top right corner)
#'          2. groups them according to their indenting, bold and italic formatting
#'          3. Specifies the unpivotr function specifying the direction of the header w.r.t. table data
#' @param sheet sheet object read in by `tidyxl::xlsx_cells`
#' @param value_ref data frame representing corners of numeric cells in excel sheet
#' @param formats format object read in by `tidyxl::xlsx_cells`
#' @param col_groups format object read in by `tidyxl::xlsx_cells`
#'
#' @export


get_meta_df <- function(sheet, value_ref, col_groups, formats) {

  ## Used for debugging
  # sheet <- master_df_01$sheet[[100]]
  # value_ref <- master_df_01$value_ref[[100]]
  # formats <- master_df_01$formats[[100]]
  # col_groups <- master_df_01$col_groups[[100]]

  sheet %>%
    filter(
      !is_blank,
      row <= max(col_groups$max_row),
      col < value_ref$min_col
    ) %>%
    mutate(col_temp = col) %>%
    mutate(row_temp = row) %>%
    mutate(indent = local_format_id %>%
      map(~ formats$local$alignment[["indent"]][[.x]]) %>%
      unlist()) %>%
    mutate(bold = local_format_id %>%
      map(~ formats$local$font[["bold"]][[.x]]) %>%
      unlist()) %>%
    mutate(italic = local_format_id %>%
      map(~ formats$local$font[["italic"]][[.x]]) %>%
      unlist()) %>%
    group_by(col_temp, row_temp, indent, bold, italic) %>%
    nest() %>%
    ungroup() %>%
    mutate(col_no_name = col_temp - min(col_temp) + 1) %>%
    mutate(row_no_name = row_temp - min(row_temp) + 1) %>%
    mutate(header_name = paste0(
      "row_", str_pad(row_no_name, 2, "left", "0"),
      "_col_", str_pad(col_no_name, 2, "left", "0"),
      "_in", indent,
      "_b", as.integer(bold),
      "_it", as.integer(italic)
    )) %>%
    mutate(meta_data = paste0("meta_data_", str_pad(row_number(), 2, side = "left", "0"))) %>%
    mutate(data = map2(
      data, meta_data,
      function(data, meta_data) {
        temp_df <- data %>% select(row, col, character)
        temp_df[[meta_data]] <- temp_df$character
        temp_df %>% select(-character)
      }
    )) %>%
    mutate(direction = "WNW") %>%
    dplyr::select(meta_data, direction, data, indent, bold, italic) %>%
    mutate(data_summary = data %>%
      map(~ .x %>% summarise(
        min_col = min(col, na.rm = T), max_col = max(col, na.rm = T),
        min_row = min(row, na.rm = T), max_row = max(row, na.rm = T)
      ))) %>%
    unnest(data_summary)
}





#' get_tabledata
#'
#' Extracts the numeric data from the table.
#' @param sheet sheet object read in by `tidyxl::xlsx_cells`
#' @param value_ref data frame representing corners of numeric cells in excel sheet
#'
#' @export


get_tabledata <- function(sheet, value_ref) {
  sheet %>%
    filter(
      !is_blank,
      row <= value_ref$max_row,
      row >= value_ref$min_row,
      col <= value_ref$max_col,
      col >= value_ref$min_col
    ) %>%
    mutate(value = coalesce(as.character(numeric), as.character(character), as.character(logical), as.character(date))) %>%
    select(row, col, value, comment)
}


#' create_tidytable
#'
#' Reshapes the data using unpivotr functions (which are specified in the head dataframes)
#' @param col_groups
#' @param row_groups
#' @param meta_df
#' @param tabledata
#'
#' @export


create_tidytable <- function(col_groups, row_groups, meta_df, tabledata) {
  bind_rows(col_groups, row_groups, meta_df) -> col_groups


  tabledata <- tabledata %>%
    group_by(row, col, comment) %>%
    nest() %>%
    mutate(value = data %>% map_chr(~ .x[[1, 1]])) %>%
    select(-data)

  map2(col_groups$data, col_groups$direction, ~ enhead_tabledata(header_data = .x, direction = .y, values = tabledata)) %>%
    reduce(full_join)
}


#' Enhead tabledata
#'
#' Reshapes the data using unpivotr functions (which are specified in the head dataframes)
#' @param header_data path to .xlsx file
#' @param direction sheet nominated for tidying
#' @param values sheet nominated for tidying
#'
#' @export


enhead_tabledata <- function(header_data, direction, values = tabledata) {
  unpivotr::enhead(
    data_cells = values,
    header_cells = header_data,
    direction = direction
  )
}


#' get tidy table
#'
#' Reshapes the data using unpivotr functions (which are specified in the head dataframes)
#' @param path path to .xlsx file
#' @param sheets sheet nominated for tidying
#'
#' @export

tidy_ABS_sheet <- function(path, sheets, manual_value_references = NULL) {
  precessed_sheet <- process_ABS_sheet(path, sheets, manual_value_references = NULL)


  assemble_table_components(precessed_sheet)
}

#' get tidyABS components
#'
#' Produces the various tidyABS compentents
#' @param path path to .xlsx file
#' @param sheets sheet nominated for tidying
#'
#' @export

process_ABS_sheet <-
  function(path, sheets, manual_value_references = NULL, added_row_groups = NULL) {
    sheet <- tidyxl::xlsx_cells(path = path, sheets = sheets)
    formats <- tidyxl::xlsx_formats(path)

    continue <- TRUE

    while(continue){

      sheet_original <- sheet
      sheet <- sheet %>% fill_in_blanks()

      continue <- !identical(sheet_original,sheet)



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



    list(col_groups = col_groups, row_groups = row_groups, meta_df = meta_df, tabledata = tabledata)
  }


#' Plot table components
#'
#' Produces the various tidyABS compentents
#' @param abs_sheet_processed path to .xlsx file
#'
#' @export


plot_table_components <- function(abs_sheet_processed) {
  temp <-
    abs_sheet_processed %>%
    .[1:3] %>%
    map(~ .x %>% dplyr::select(type = 1, direction, data)) %>%
    bind_rows() %>%
    unnest()

  value_cols <- names(temp)[str_detect(names(temp), "^col_|^row_|^meta_")]

  temp_01 <-
    temp %>%
    mutate(value = coalesce(!!!syms(value_cols))) %>%
    select(type, direction, row, col, value) %>%
    bind_rows(abs_sheet_processed[[4]] %>% mutate(type = "data"))

  # expression(symbol('\256'))

  temp_01 %>%
    ggplot(aes(
      x = col, y = -row, fill = str_to_title(str_replace_all(type, "_", " ")),
      label = ifelse(type != "data", paste(
        str_extract(type, "[0-9]{1,2}"),
        paste0(ifelse(type != "data", paste0("(", direction, ")"), ""))
      ), "")
    )) +
    geom_tile() +
    geom_text(size = 3) +
    # xlim(limits = c(.5,10)) +
    # ylim(limits = c(-30,-.5)) +
    theme_minimal() +
    labs(fill = "Cell Type", y = "Row", x = "Column")
}

#' Inspect table components
#'
#' Produces the various tidyABS compentents
#' @param abs_sheet_processed path to .xlsx file
#'
#' @export

inspect_table_components <- function(abs_sheet_processed) {
  abs_sheet_processed %>% map(~ .x$data %>% map(~ .x %>% pull(3) %>% unique()))
}




#' assemble_table_components
#'
#' Reshapes the data using unpivotr functions (which are specified in the head dataframes)
#' @param table_componsents
#'
#' @export

assemble_table_components <- function(table_componsents) {
  bind_rows(table_componsents[1:3]) -> col_groups


  tabledata <- table_componsents[[4]] %>%
    group_by(row, col, comment) %>%
    nest() %>%
    mutate(value = data %>% map_chr(~ .x[[1, 1]])) %>%
    select(-data)

  map2(col_groups$data, col_groups$direction, ~ enhead_tabledata(header_data = .x, direction = .y, values = tabledata)) %>%
    reduce(full_join)
}



#' check_low_col_names
#'
#' Checks whether merging of a row label is leading to dupplicates in col and row labels.
#' @param table_componsents
#'
#' @export
#'

check_low_col_names <- function(col_groups) {
  uniqueness_test <- col_groups$data %>% map(3) %>% map_lgl(function(x) length(unique(x)) == 1 & length(x) > 1)

  col_groups[!uniqueness_test, ]
}
