
#' Get indent of cells
#'
#' This function returns the level of indenting of a specified cell.
#'
#' @param local_format_id the local_format_id provided by `tidyxl::xlsx_cells`
#' @param formats sheet object read in by `tidyxl::xlsx_formats`
#'
#' @export


get_indent <- function(local_format_id, formats) {
  formats$local$alignment[["indent"]][[local_format_id]]
}
