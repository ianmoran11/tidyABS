
#' Inspect table components
#'
#' Produces the various tidyABS compentents
#' @param abs_sheet_processed path to .xlsx file
#'
#' @export

inspect_table_components <- function(abs_sheet_processed) {
  abs_sheet_processed %>% map(~ .x$data %>% map(~ .x %>% pull(3) %>% unique()))
}
