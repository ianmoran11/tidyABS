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



  print("x")


  col_df <-
    sheet %>%
    filter(!is_blank) %>%
    filter(col <= value_ref$max_col) %>%
    filter(col >= value_ref$min_col) %>%
    filter(row < value_ref$min_row) %>%
    mutate(row_temp = row) %>%
    mutate(indent = local_format_id %>%
             map_int(possibly({
               ~ formats$local$alignment[["indent"]][[.x]]              }, 0)) %>%
             unlist()) %>%
    mutate(bold = local_format_id %>%
             map_lgl(possibly({
               ~ formats$local$font[["bold"]][[.x]]},F)) %>%
             unlist()) %>%
    mutate(italic = local_format_id %>%
             map_lgl(possibly({~ formats$local$font[["italic"]][[.x]]},F)) %>%
             unlist()) %>%
    group_by(row_temp, indent, bold, italic) %>%
    mutate(merged = ifelse(sum(merged,na.rm = TRUE ) == length(merged),T,F)) %>%
    filter(merged != T ) %>%
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
