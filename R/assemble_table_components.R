
#' assemble_table_components
#'
#' Reshapes the table components to create a tidy data frame.
#' @param table_components produced by `process_sheet`
#'
#' @examples
#'
#'  \donttest{tidyABS_example("australian-industry.xlsx") %>% process_sheet(sheets = "Table_1") %>% assemble_table_components()  }
#'
#'
#'
#' @export

assemble_table_components <- function(table_components) {


  table_component_data <-  list()

  if(table_components %$% exists("row_groups")){table_component_data <- table_component_data %>% append(list(table_components$row_groups))}
  if(table_components %$% exists("col_groups")){table_component_data <- table_component_data %>% append(list(table_components$col_groups))}
  if(table_components %$% exists("meta_df")){table_component_data <- table_component_data %>% append(list(table_components$meta_df))}

  col_groups <- bind_rows(table_component_data)

  tabledata <- table_components$tabledata

  map2(col_groups$data, col_groups$direction, ~ enhead_tabledata(header_data = .x, direction = .y, values = tabledata)) %>%
    reduce(full_join)


}
