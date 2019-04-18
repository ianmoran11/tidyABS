
#' Change direction
#' The function changes the direction associated with a header_label/row_group in a processed_sheet - the output of `process_sheet`.
#' @param processed_sheet returned by process_sheet
#' @param group row_group name / header_label name
#' @param new_direction unpivotr compass direction
#' @param header_labels format object read in by `tidyxl::xlsx_cells`
#' @param added_row_groups format object read in by `tidyxl::xlsx_cells`
#'
#' @examples
#'
#'  \donttest{tidyABS_example("environmental-economic-accounts.xlsx") %>%  process_sheet( sheets = "Table 6.1") %>% change_direction("row_group_01", "WNW") }
#'
#'
#'
#'
#'
#' @export





change_direction <- function(processed_sheet, group, new_direction) {
  processed_sheet$header_labels <-
    processed_sheet$header_labels %>%
    mutate(direction = ifelse(!!sym(names(.)[1]) == group, new_direction, direction))

  processed_sheet$row_groups <-
    processed_sheet$row_groups %>%
    mutate(direction = ifelse(!!sym(names(.)[1]) == group, new_direction, direction))

  processed_sheet
}
