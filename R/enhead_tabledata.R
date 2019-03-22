
#' Enhead tabledata
#'
#' This is a utility function that reshapes the data using unpivotr functions (which are specified in the head dataframes)
#' @param header_data cells representing headers
#' @param direction orietations of heades with respect to value cells.
#' @param values centre components of the table, representing values
#'
#' @export


enhead_tabledata <- function(header_data, direction, values = tabledata) {
  unpivotr::enhead(
    data_cells = values,
    header_cells = header_data,
    direction = direction
  )
}
