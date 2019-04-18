#' Get header groups
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


get_header_labels <- function(sheet, value_ref, formats, ignore_bolding = FALSE, ignore_indenting = FALSE,  ignore_italics = FALSE) {


  # Get header cells
  header_df <-
    sheet %>%
    filter(!is_blank) %>%
    filter(col <= value_ref$max_col) %>%
    filter(col >= value_ref$min_col) %>%
    filter(row < value_ref$min_row) %>%
    mutate(row_temp = row)


  if(nrow(header_df) == 0){
    stop("No header groups have been detected. If you haven't already, try using the 'manual_value_references` argument")
  }



  # Get format information
  header_df <-
    header_df %>%
    mutate(bold = ifelse(ignore_bolding, NA,local_format_id %>% get_bolding_vec(sheet_format = formats))) %>%
    mutate(indent = ifelse(ignore_indenting, NA,local_format_id %>% get_indenting_vec(sheet_format = formats))) %>%
    mutate(italic = ifelse(ignore_italics, NA,local_format_id %>% get_italics_vec(sheet_format = formats)))


  # Nest header groups
  header_df <-
    header_df %>%
    group_by(row_temp, indent, bold, italic) %>%
    mutate(merged = ifelse(sum(merged, na.rm = TRUE) == length(merged), T, F)) %>%
    filter(merged != T) %>%
    nest() %>%
    ungroup()

  # Name header groups
  header_df <-
    header_df %>%
      mutate(row_no_name = row_temp - min(row_temp) + 1) %>%
      mutate(header_label = paste0("header_label_", str_pad(row_number(), 2, side = "left", "0")))

      # Create and name headers
    header_df <-
    header_df %>%
    mutate(data = map2(
      data, header_label,
      function(data, header_label) {
        temp_df <- data %>%
          mutate(value = coalesce(
            as.character(numeric),
            as.character(character),
            as.character(logical),
            as.character(date)
          )) %>%
          select(row, col, value)
        temp_df[[header_label]] <- temp_df$value
        temp_df %>% select(-value)
      }
    ))

  # Set direction
  header_df <-
    header_df %>%
    mutate(direction = "N") %>%
    dplyr::select(header_label, direction, data, indent, bold, italic)


  # Add information to output df
  header_df %>%
    mutate(data_summary = data %>%
      map(~ .x %>% summarise(
        min_col = min(col, na.rm = T), max_col = max(col, na.rm = T),
        min_row = min(row, na.rm = T), max_row = max(row, na.rm = T)
      ))) %>%
    unnest(data_summary) # %>%
  # check_low_header_names
}
