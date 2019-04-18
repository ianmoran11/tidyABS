
#' Inspect table components
#'
#' This function produces the various tidyABS components.
#' @param process_sheet path to .xlsx file
#'
#' @examples
#'
#'  \donttest{tidyABS_example("australian-industry.xlsx") %>% process_sheet(sheets = "Table_1") %>% inspect_table_components() }
#'
#' @export

inspect_table_components <- function(processed_sheet) {
  processed_sheet %>% map(~ .x$data %>% map(~ .x %>% pull(3) %>% unique()))
}


