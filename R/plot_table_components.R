
#' Plot table components
#'
#' This function plots the excel sheet, highlighting the relationship between headers and table values.
#' @param processed_sheet returned by `process_sheet`
#'
#' @examples
#'
#'  \donttest{tidyABS_example("australian-industry.xlsx") %>% process_sheet(sheets = "Table_1") %>% plot_table_components() }
#'
#'
#' @export


plot_table_components <- function(processed_sheet) {



  processed_sheet_headers <-
    processed_sheet[1:(length(processed_sheet) -1)]

    temp <-
      processed_sheet_headers %>%
      map(~ .x %>% dplyr::select(type = 1, direction, data)) %>%
      bind_rows() %>%
      unnest()

    value_cols <- names(temp)[str_detect(names(temp), "^col_|^row_|^meta_")]

    temp_01 <-
      temp %>%
      mutate(value = coalesce(!!!syms(value_cols))) %>%
      select(type, direction, row, col, value) %>%
      bind_rows(processed_sheet[[length(processed_sheet)]] %>% mutate(type = "data"))


  # expression(symbol('\256'))

  temp_01 %>%
    ggplot(aes(
      x = col, y = -row, fill = str_to_title(str_replace_all(type, "_", " ")),
      label = ifelse(type != "data", paste(
        str_extract(type, "[0-9]{1,2}"),
        paste0(ifelse(type != "data", paste0("(", direction, ")"), ""))
      ), "")
    )) +
    geom_tile() +
    geom_text(size = 3) +
    # xlim(limits = c(.5,10)) +
    # ylim(limits = c(-30,-.5)) +
    theme_minimal() +
    labs(fill = "Cell Type", y = "Row", x = "Column")
}
