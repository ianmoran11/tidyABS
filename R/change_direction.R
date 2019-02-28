
#' Change direction
#' Changes the direction associated with a col_group/row_group in a `process_ABS_sheet`
#' @param processed_ABS_sheet returned by process_ABS_sheet
#' @param group row_group name / col_group name
#' @param new_direction unpivotr compass direction
#' @param col_groups format object read in by `tidyxl::xlsx_cells`
#' @param added_row_groups format object read in by `tidyxl::xlsx_cells`
#'
#' @export



change_direction <- function(processed_ABS_sheet, group, new_direction) {
  processed_ABS_sheet$col_groups <-
    processed_ABS_sheet$col_groups %>%
    mutate(direction = ifelse(!!sym(names(.)[1]) == group, new_direction, direction))

  processed_ABS_sheet$row_groups <-
    processed_ABS_sheet$row_groups %>%
    mutate(direction = ifelse(!!sym(names(.)[1]) == group, new_direction, direction))

  processed_ABS_sheet
}
