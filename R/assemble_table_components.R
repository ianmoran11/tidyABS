
#' assemble_table_components
#'
#' Reshapes the data using unpivotr functions (which are specified in the head dataframes)
#' @param table_componsents
#'
#' @export

assemble_table_components <- function(table_componsents) {

  if(length(table_componsents) == 4){

    bind_rows(table_componsents[1:3]) -> col_groups


    tabledata <- table_componsents[[4]] %>%
      group_by(row, col, comment) %>%
      nest() %>%
      mutate(value = data %>% map_chr(~ .x[[1, 1]])) %>%
      select(-data)

    map2(col_groups$data, col_groups$direction, ~ enhead_tabledata(header_data = .x, direction = .y, values = tabledata)) %>%
      reduce(full_join)

  }else{


    bind_rows(table_componsents[1:2]) -> col_groups


    tabledata <- table_componsents[[3]] %>%
      group_by(row, col, comment) %>%
      nest() %>%
      mutate(value = data %>% map_chr(~ .x[[1, 1]])) %>%
      select(-data)

    map2(col_groups$data, col_groups$direction, ~ enhead_tabledata(header_data = .x, direction = .y, values = tabledata)) %>%
      reduce(full_join)


  }


}
