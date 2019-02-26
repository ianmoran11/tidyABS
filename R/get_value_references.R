#' Get table references
#'
#' Identifies rectangle of numeric cells in table.
#'
#' @param sheet sheet object read in by `tidyxl::xlsx_cells`
#' @param manual_value_references sheet object read in by `tidyxl::xlsx_cells`
#'
#' @export

get_value_references <- function(sheet, manual_value_references) {

  # Automatic producedure
  if (is.null(manual_value_references)) {
    sheet %>%
      filter(!is.na(numeric)) %>%
      summarise(
        min_row = min(row), max_row = max(row),
        min_col = min(col), max_col = max(col)
      )
  } else {
    # Use manual values
    cell_ref_df <-
      manual_value_references %>%
      map_df(cell_ref_2_df)

    data_frame(
      min_col = as.integer(min(cell_ref_df$column)),
      max_col = as.integer(max(cell_ref_df$column)),
      min_row = as.integer(min(cell_ref_df$row)),
      max_row = as.integer(max(cell_ref_df$row))
    )
  }
}
