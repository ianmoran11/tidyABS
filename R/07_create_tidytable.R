
#' create_tidytable
#'
#' This is a utility function that reshapes the data using unpivotr functions (which are specified in the head dataframes)
#' @param header_labels output of `process_sheet`
#' @param row_groups output of `process_sheet`
#' @param meta_df output of `process_sheet`
#' @param tabledata output of `process_sheet`
#'


create_tidytable <- function(header_labels, row_groups, meta_df, tabledata) {
  bind_rows(header_labels, row_groups, meta_df) -> header_labels


  tabledata <- tabledata %>%
    group_by(row, col, comment) %>%
    nest() %>%
    mutate(value = data %>% map_chr(~ .x[[1, 1]])) %>%
    select(-data)

  map2(header_labels$data, header_labels$direction, ~ enhead_tabledata(header_data = .x, direction = .y, values = tabledata)) %>%
    reduce(full_join)
}



