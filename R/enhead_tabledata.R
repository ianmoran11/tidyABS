
#' Enhead tabledata
#'
#' Reshapes the data using unpivotr functions (which are specified in the head dataframes)
#' @param header_data path to .xlsx file
#' @param direction sheet nominated for tidying
#' @param values sheet nominated for tidying
#'
#' @export


enhead_tabledata <- function(header_data, direction, values = tabledata) {
  unpivotr::enhead(
    data_cells = values,
    header_cells = header_data,
    direction = direction
  )
}
