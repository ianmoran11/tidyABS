
#' Inspect table components
#'
#' This function produces the various tidyABS components.
#' @param process_sheet path to .xlsx file
#'
#' @export

inspect_table_components <- function(processed_sheet) {
  processed_sheet %>% map(~ .x$data %>% map(~ .x %>% pull(3) %>% unique()))
}
