
#' Convert an adress to row/col tibble
#'
#' Convert an adress reference to a tibble identifying row and col
#'
#' @param cell_ref Cell reference in address format - e.g. "A1"
#'
#' @export


cell_ref_2_df <- function(cell_ref) {
  column_index <-
    data_frame(LETTERS) %>%
    mutate(LETTERS2 = rep(tibble(LETTERS), 26)) %>%
    unnest() %>%
    mutate(columns = paste0(LETTERS, LETTERS2)) %>%
    pull(columns) %>%
    c(LETTERS, .)

  which(str_extract(cell_ref, "[A-Z]{1,5}") == column_index) -> column
  str_extract(cell_ref, "[0-9]{1,5}") -> row

  data_frame(column = column, row = row)
}
