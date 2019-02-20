
#' Fill in blanks
#'
#' This function ensures that merged cells are unmerged.
#'
#' @param sheet sheet object read in by `tidyxl::xlsx_cells`


fill_in_blanks <- function(sheet){

  # Define blank cells
  blank_df <-
    sheet %>%
    filter(data_type == "blank")

  joiner <- sheet %>% select(-character_formatted) %>% filter(!is_blank)

  inserter <-
    blank_df %>%
      mutate(col_old = col, col = col -1  ) %>%
      select(sheet,row,col,col_old,local_format_id ) %>%
      left_join(joiner) %>%
      mutate(col = col_old) %>% select(-col_old) %>%
      filter(!is_blank) %>%
      mutate(row_col = paste0(row,"_",col))

  sheet <-
    sheet %>%
      mutate(row_col = paste0(row,"_",col)) %>%
      filter(!row_col %in% inserter$row_col) %>%
      bind_rows(inserter) %>% arrange(row,col)

  sheet %>% group_by(row,col) %>% top_n(1) %>% ungroup()

}

#' Get table references
#'
#' Identify which cells are the numeric table cells by finding the corners
#'
#' @param sheet sheet object read in by `tidyxl::xlsx_cells`

get_value_references <- function(sheet){


  sheet %>%
    filter(!is.na(numeric)) %>%
    summarise(
      min_row = min(row), max_row = max(row),
      min_col = min(col), max_col = max(col))
}


get_indent <- function(local_format_id, formats){

  formats$local$alignment[["indent"]][[local_format_id]]
}


#' Get table references
#'
#' This function:
#'          1. Identifies which cells are likely to be headers
#'          2. groups them according to their indenting, bold and italic formatting
#'          3. Specifies the unpivotr function specifying the direction of the header w.r.t. table data
#' @param sheet sheet object read in by `tidyxl::xlsx_cells`
#' @param value_ref data frame representing corners of numeric cells in excel sheet
#' @param formats format object read in by `tidyxl::xlsx_cells`


get_col_groups <- function(sheet, value_ref,formats){


col_df <-
  sheet %>%
    filter(!is_blank) %>%
    filter(col <= value_ref$max_col) %>%
    filter(col >= value_ref$min_col) %>%
    filter(row < value_ref$min_row ) %>%
    mutate(row_temp = row) %>%
    mutate(indent = local_format_id %>%
             map_dbl(possibly({~ formats$local$alignment[["indent"]][[.x]]},0)) %>%
             unlist) %>%
    mutate(bold = local_format_id %>%
             map(~ formats$local$font[["bold"]][[.x]]) %>%
             unlist) %>%
    mutate(italic = local_format_id %>%
             map(~ formats$local$font[["italic"]][[.x]]) %>%
             unlist) %>%
    group_by(row_temp,indent,bold,italic) %>%
    nest() %>% ungroup() %>%
    mutate(row_no_name =  row_temp - min(row_temp) + 1) %>%
    mutate(col_group = paste0("col_group_",str_pad(row_number(),2,side = "left","0"))) %>%
    mutate(data=map2(data,col_group,
                     function(data,col_group){

                       temp_df <- data %>% select(row,col,character)
                       temp_df[[col_group]] <- temp_df$character
                       temp_df %>%  select(-character)})) %>%
    mutate(direction = "N") %>%
    dplyr::select(col_group,direction,data,indent,bold,italic)

  col_df %>%
    mutate(data_summary =data %>%
             map(~ .x %>% summarise(min_col = min(col,na.rm = T),max_col = max(col,na.rm = T),
                                    min_row = min(row,na.rm = T),max_row = max(row,na.rm = T)) )) %>%
    unnest(data_summary)

}


#' Get Rowname DF
#'
#' This function:
#'          1. Identifies which cells are likely to be row names
#'          2. groups them according to their indenting, bold and italic formatting
#'          3. Specifies the unpivotr function specifying the direction of the header w.r.t. table data
#' @param sheet sheet object read in by `tidyxl::xlsx_cells`
#' @param value_ref data frame representing corners of numeric cells in excel sheet
#' @param formats format object read in by `tidyxl::xlsx_cells`
#' @param col_groups format object read in by `tidyxl::xlsx_cells`


get_row_groups <- function(sheet,value_ref,col_groups,formats){

  ## Used for debugging
  # sheet <- sheet
  # value_ref <- value_ref
  # formats <- formats
  # col_groups <- col_groups

  row_name_df <-
  sheet %>%
    filter(!is_blank,
           row <= value_ref$max_row,
           row > max(col_groups$max_row),
           col < value_ref$min_col ) %>%
    mutate(col_temp = col ) %>%
    mutate(indent = local_format_id %>%
             map(~ formats$local$alignment[["indent"]][[.x]]) %>%
             unlist) %>%
    mutate(bold = local_format_id %>%
             map(~ formats$local$font[["bold"]][[.x]]) %>%
             unlist) %>%
    mutate(italic = local_format_id %>%
             map(~ formats$local$font[["italic"]][[.x]]) %>%
             unlist) %>%
    group_by(col_temp,indent,bold,italic) %>% nest() %>% ungroup() %>%
    arrange(col_temp,indent,italic,bold) %>%
    mutate(row_group = paste0("row_group_",str_pad(row_number(),2,side = "left","0"))) %>%
    mutate(data=map2(data,row_group,
                     function(data,row_group){

                       temp_df <- data %>% select(row,col,character)
                       temp_df[[row_group]] <- temp_df$character
                       temp_df %>%  select(-character)}))


row_name_df <-
  row_name_df %>%  mutate(row_sum = map_dbl(data,~get_row_sum(data = .x,sheet = sheet) ))


row_name_df %>% mutate(direction = ifelse(row_sum == 0,"NNW","W")) %>%
  dplyr::select(row_group,direction,data,indent,bold,italic) %>%
  mutate(data_summary =data %>%
           map(~ .x %>% summarise(min_col = min(col,na.rm = T),max_col = max(col,na.rm = T),
                                  min_row = min(row,na.rm = T),max_row = max(row,na.rm = T)) )) %>%
  unnest(data_summary)



}



#' Get row sum
#'
#' This function is used to identify whether rows have a Wester or NNW orientation to data
#' @param x  a row_name_df object
#' @param sheet  a row_name_df object

get_row_sum <- function(data,sheet){

  data %>%
    mutate(row_sum_values = map_dbl(row,
                                    function(x){summarise(filter(sheet,row == x ),filled = sum(numeric, na.rm = T))$filled})) %>%
    summarise(row_sum_values =  sum(row_sum_values, na.rm = T)) %>% pull(row_sum_values)
}


#' get metadata df
#'
#' This function:
#'          1. Identifies which cells are likely to to contains meta data (in top right corner)
#'          2. groups them according to their indenting, bold and italic formatting
#'          3. Specifies the unpivotr function specifying the direction of the header w.r.t. table data
#' @param sheet sheet object read in by `tidyxl::xlsx_cells`
#' @param value_ref data frame representing corners of numeric cells in excel sheet
#' @param formats format object read in by `tidyxl::xlsx_cells`
#' @param col_groups format object read in by `tidyxl::xlsx_cells`


get_meta_df <- function(sheet,value_ref,col_groups,formats){

  ## Used for debugging
  # sheet <- master_df_01$sheet[[100]]
  # value_ref <- master_df_01$value_ref[[100]]
  # formats <- master_df_01$formats[[100]]
  # col_groups <- master_df_01$col_groups[[100]]

  sheet %>%
    filter(!is_blank,
           row <= max(col_groups$max_row),
           col < value_ref$min_col ) %>%
    mutate(col_temp = col ) %>%
    mutate(row_temp = row ) %>%
    mutate(indent = local_format_id %>%
             map(~ formats$local$alignment[["indent"]][[.x]]) %>%
             unlist) %>%
    mutate(bold = local_format_id %>%
             map(~ formats$local$font[["bold"]][[.x]]) %>%
             unlist) %>%
    mutate(italic = local_format_id %>%
             map(~ formats$local$font[["italic"]][[.x]]) %>%
             unlist) %>%
    group_by(col_temp, row_temp,indent,bold,italic) %>% nest() %>% ungroup() %>%
    mutate(col_no_name =  col_temp - min(col_temp) + 1) %>%
    mutate(row_no_name =  row_temp - min(row_temp) + 1) %>%
    mutate(header_name = paste0("row_",str_pad(row_no_name,2,"left","0"),
                                "_col_",str_pad(col_no_name,2,"left","0"),
                                "_in",indent,
                                "_b", as.integer(bold),
                                "_it", as.integer(italic))) %>%
    mutate(meta_data = paste0("meta_data_",str_pad(row_number(),2,side = "left","0"))) %>%
    mutate(data=map2(data,meta_data,
                     function(data,meta_data){

                       temp_df <- data %>% select(row,col,character)
                       temp_df[[meta_data]] <- temp_df$character
                       temp_df %>%  select(-character)})) %>%
    mutate(direction = "WNW") %>%
    dplyr::select(meta_data,direction,data,indent,bold,italic) %>%
    mutate(data_summary =data %>%
             map(~ .x %>% summarise(min_col = min(col,na.rm = T),max_col = max(col,na.rm = T),
                                    min_row = min(row,na.rm = T),max_row = max(row,na.rm = T)) )) %>%
    unnest(data_summary)
}





#' get_tabledata
#'
#' Extracts the numeric data from the table.
#' @param sheet sheet object read in by `tidyxl::xlsx_cells`
#' @param value_ref data frame representing corners of numeric cells in excel sheet

get_tabledata <- function(sheet,value_ref){

  sheet %>%
    filter(!is_blank,
           row <= value_ref$max_row,
           row >= value_ref$min_row,
           col <= value_ref$max_col,
           col >= value_ref$min_col ) %>%
    mutate(value = coalesce(as.character(numeric),as.character(character),as.character(logical),as.character(date))) %>%
    select(row,col,value,comment)
}


#' create_tidytable
#'
#' Reshapes the data using unpivotr functions (which are specified in the head dataframes)
#' @param col_groups
#' @param row_groups
#' @param meta_df
#' @param tabledata


create_tidytable <- function(col_groups,row_groups,meta_df,tabledata){

  bind_rows(col_groups,row_groups,meta_df) -> col_groups


  tabledata <- tabledata %>% group_by(row,col,comment) %>% nest() %>%
    mutate(value  = data %>% map_chr(~ .x[[1,1]])) %>% select(-data)

  map2(col_groups$data,col_groups$direction, ~ enhead_tabledata(header_data= .x,direction = .y, values = tabledata)) %>%
    reduce(full_join)

}


#' Enhead tabledata
#'
#' Reshapes the data using unpivotr functions (which are specified in the head dataframes)
#' @param header_data path to .xlsx file
#' @param direction sheet nominated for tidying
#' @param values sheet nominated for tidying
#'
#' @export


enhead_tabledata <-  function(header_data, direction,values = tabledata){
  unpivotr::enhead(data_cells = values,
                   header_cells =  header_data,
                   direction =direction)
}


#' get tidy table
#'
#' Reshapes the data using unpivotr functions (which are specified in the head dataframes)
#' @param path path to .xlsx file
#' @param sheets sheet nominated for tidying
#'
#' @export

tidy_ABS_sheet <- function(path,sheets ){

  sheet <-  tidyxl::xlsx_cells(path = path,sheets = sheets)
  formats <-  tidyxl::xlsx_formats(path)


  sheet <-
  sheet %>%
    fill_in_blanks %>% fill_in_blanks %>% fill_in_blanks %>%
    fill_in_blanks %>% fill_in_blanks %>% fill_in_blanks %>%
    fill_in_blanks %>% fill_in_blanks %>% fill_in_blanks %>%
    fill_in_blanks %>% fill_in_blanks %>% fill_in_blanks %>%
    fill_in_blanks %>% fill_in_blanks %>% fill_in_blanks


  value_ref <- sheet %>% get_value_references()

  col_groups <- get_col_groups(sheet = sheet,value_ref = value_ref,formats =formats  )
  row_groups <- get_row_groups(sheet = sheet,value_ref = value_ref,formats =formats,col_groups = col_groups)
  meta_df <- get_meta_df(sheet = sheet,value_ref = value_ref,formats =formats,col_groups = col_groups)
  tabledata <- get_tabledata(sheet = sheet, value_ref = value_ref)


  create_tidytable(col_groups =col_groups,meta_df = meta_df,row_groups =row_groups,tabledata =   tabledata)

}




#' get tidyABS components
#'
#' Produces the various tidyABS compentents
#' @param path path to .xlsx file
#' @param sheets sheet nominated for tidying
#'
#' @export

process_ABS_sheet <- function(path,sheets ){

  sheet <-  tidyxl::xlsx_cells(path = path,sheets = sheets)
  formats <-  tidyxl::xlsx_formats(path)


  sheet <-
    sheet %>%
    fill_in_blanks %>% fill_in_blanks %>% fill_in_blanks %>%
    fill_in_blanks %>% fill_in_blanks %>% fill_in_blanks %>%
    fill_in_blanks %>% fill_in_blanks %>% fill_in_blanks %>%
    fill_in_blanks %>% fill_in_blanks %>% fill_in_blanks %>%
    fill_in_blanks %>% fill_in_blanks %>% fill_in_blanks


  value_ref <- sheet %>% get_value_references()

  col_groups <- get_col_groups(sheet = sheet,value_ref = value_ref,formats =formats  )
  row_groups <- get_row_groups(sheet = sheet,value_ref = value_ref,formats =formats,col_groups = col_groups)
  meta_df <- get_meta_df(sheet = sheet,value_ref = value_ref,formats =formats,col_groups = col_groups)
  tabledata <- get_tabledata(sheet = sheet, value_ref = value_ref)

  list(col_groups= col_groups,row_groups=row_groups,meta_df=meta_df,tabledata=tabledata )



}


#' Plot table components
#'
#' Produces the various tidyABS compentents
#' @param abs_sheet_processed path to .xlsx file
#'
#' @export


plot_table_components <- function(abs_sheet_processed){
  temp <-
    abs_sheet_processed %>% .[1:3]  %>%
    map( ~ .x %>% dplyr::select(type = 1,direction,data)) %>%
    bind_rows() %>% unnest()

  value_cols <- names(temp)[str_detect(names(temp),"^col_|^row_|^meta_")]

  temp_01 <-
    temp %>%
    mutate(value = coalesce(!!!syms(value_cols))) %>%
    select(type,direction,row,col,value) %>%
    bind_rows(abs_sheet_processed[[4]] %>% mutate(type = "data"))

  temp_01 %>%
    ggplot(aes(x = col, y = -row, fill = str_to_title(str_replace_all(type,"_"," ")),
               label = paste0(ifelse(type!="data",paste0("(",direction,")"),"")))) +
    geom_tile() +
    geom_text(size = 3) +
    xlim(limits = c(.5,10)) +
    ylim(limits = c(-30,-.5)) +
    theme_minimal() +
    labs(fill="Cell Type", y = "Row", x = "Column")
}

#' Inspect table components
#'
#' Produces the various tidyABS compentents
#' @param abs_sheet_processed path to .xlsx file
#'
#' @export

inspect_table_components <-   function(abs_sheet_processed){
  abs_sheet_processed %>% map(~.x$data  %>% map(~ .x %>% pull(3) %>% unique))
}




#' assemble_table_components
#'
#' Reshapes the data using unpivotr functions (which are specified in the head dataframes)
#' @param table_componsents
#'
#' @export

assemble_table_components <- function(table_componsents){

  bind_rows(table_componsents[1:3]) -> col_groups


  tabledata <- table_componsents[[4]] %>% group_by(row,col,comment) %>% nest() %>%
    mutate(value  = data %>% map_chr(~ .x[[1,1]])) %>% select(-data)

  map2(col_groups$data,col_groups$direction, ~ enhead_tabledata(header_data= .x,direction = .y, values = tabledata)) %>%
    reduce(full_join)

}
