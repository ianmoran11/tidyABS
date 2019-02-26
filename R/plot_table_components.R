
#' Plot table components
#'
#' Produces the various tidyABS compentents
#' @param abs_sheet_processed path to .xlsx file
#'
#' @export


plot_table_components <- function(abs_sheet_processed) {

  if(length(abs_sheet_processed) == 4){

    temp <-
      abs_sheet_processed %>%
      .[1:3] %>%
      map(~ .x %>% dplyr::select(type = 1, direction, data)) %>%
      bind_rows() %>%
      unnest()

    value_cols <- names(temp)[str_detect(names(temp), "^col_|^row_|^meta_")]

    temp_01 <-
      temp %>%
      mutate(value = coalesce(!!!syms(value_cols))) %>%
      select(type, direction, row, col, value) %>%
      bind_rows(abs_sheet_processed[[4]] %>% mutate(type = "data"))

  }else{


    temp <-
      abs_sheet_processed %>%
      .[1:2] %>%
      map(~ .x %>% dplyr::select(type = 1, direction, data)) %>%
      bind_rows() %>%
      unnest()

    value_cols <- names(temp)[str_detect(names(temp), "^col_|^row_|^meta_")]

    temp_01 <-
      temp %>%
      mutate(value = coalesce(!!!syms(value_cols))) %>%
      select(type, direction, row, col, value) %>%
      bind_rows(abs_sheet_processed[[3]] %>% mutate(type = "data"))


  }


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
