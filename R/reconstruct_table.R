#' reconstruct_table
#'
#' This function reconstructs the table components from `process_sheet` to structure of oringinal excel file.
#'
#' @param table_components object returned by `process_sheet`
#'
#' @examples
#'
#'  \donttest{tidyABS_example("australian-industry.xlsx") %>% process_sheet(sheets = "Table_1") %>% reconstruct_table() }
#'
#'
#'
#'
#'
#' @export



reconstruct_table <-
  function(table_components){

    #!#!#!# Use xltabr here

    table_components %>%
      assemble_table_components() %>%
      mutate_at(.vars = vars(matches("row_")),
                .funs = funs( ifelse(is.na(.),
                                     NA,
                                     paste(str_pad(as.character(row),width = 5,pad = "0"),
                                           .,
                                           sep = "_")))) %>%
      mutate( cols = paste3(str_pad(as.character(col),width = 5,pad = "0"), !!!syms(names(.)[str_detect(names(.),"col_")]), sep = "_")) %>%
      select(-row,-col,-comment) %>%
      select(-matches("col_"))  %>%
      mutate(value = as.numeric(value)) %>%
      spread(cols,value) %>%
      select(everything(), sort(names(.)[str_detect(names(.),"^[0-9]{5}")])) %>%
      set_names(str_remove(names(.),"^[0-9]{5}_")) %>%
      arrange(!!!syms(names(.)[str_detect(names(.),"row_")])) %>%
      mutate_at(.vars = vars(matches("row_")),.funs = funs( ifelse(is.na(.), NA, str_remove_all(.,"[0-9]{5}_"))))

  }

#' paste3
#'
#' Removes NAs from paste. Taken from https://stackoverflow.com/users/1855677/42 stackoverflow answer.
#'
#' @param table_components object returned by `process_ABS_sheet`
#'
#' @export

paste3 <- function(...,sep=", ") {
  L <- list(...)
  L <- lapply(L,function(x) {x[is.na(x)] <- ""; x})
  ret <-gsub(paste0("(^",sep,"|",sep,"$)"),"",
             gsub(paste0(sep,sep),sep,
                  do.call(paste,c(L,list(sep=sep)))))
  is.na(ret) <- ret==""
  ret
}


