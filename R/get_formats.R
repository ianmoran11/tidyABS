
#' Get formats
#' Produces the  tidyABS table components, which store information on column groups, row groups and tabledata.
#' @param path path to .xlsx file
#' @param sheets sheet nominated for tidying
#'
#' @examples
#'
#'  \donttest{tidyABS_example("australian-industry.xlsx") %>% process_sheet(sheets = "Table_1")  }
#'
#'
#'
#' @export

get_indenting <- function(format_id,sheet_format){
  sheet_format$local$alignment[["indent"]][[format_id]]
}

get_indenting_vec <- function(format_id_vec,sheet_format){
  format_id_vec %>% map_dbl(possibly(get_indenting,NA_real_),sheet_format = sheet_format)
}


get_bolding <- function(format_id,sheet_format){
  sheet_format$local$font[["bold"]][[format_id]]
}

get_bolding_vec <- function(format_id_vec,sheet_format){
  format_id_vec %>% map_dbl(possibly(get_bolding,NA_real_),sheet_format = sheet_format)
}

get_italics <- function(format_id,sheet_format){
  sheet_format$local$font[["italic"]][[format_id]]
}

get_italics_vec <- function(format_id_vec,sheet_format){
  format_id_vec %>% map_dbl(possibly(get_italics,NA_real_),sheet_format = sheet_format)
}

