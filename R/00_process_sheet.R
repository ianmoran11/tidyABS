#' get tidyABS components
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

process_sheet <-
  function(path, sheets, table_range = NULL, manual_value_references = NULL, row_groups_present = TRUE, header_labels_present = TRUE,
           added_row_groups = NULL, keep_meta_data = FALSE, ignore_bolding = FALSE, ignore_indenting = FALSE,  ignore_italics = FALSE,
           numeric_values = FALSE,strict_merging = TRUE) {


      if (!is.null(manual_value_references)) {
        if (!tidyxl::is_range(manual_value_references)) {
          stop("manual_value_references must be a range")
        }
      }

    sheet <- tidyxl::xlsx_cells(path = path, sheets = sheets)
    formats <- tidyxl::xlsx_formats(path)


    if (!is.null(table_range)) {

      cell_ref_df <- as_tibble(cellranger::as.cell_limits(table_range))

      table_range_df <-
      cell_ref_df[,1:2] %>%
        set_names(c("min","max")) %>%
        mutate(dimension = c("row","col")) %>%
        gather(key, value, -dimension) %>%
        unite(label, key, dimension, sep = "_") %>%
        spread(label, value )

      sheet <-
      sheet %>%
        filter(row >= table_range_df$min_row[1],
               row <= table_range_df$max_row[1],
               col >= table_range_df$min_col[1],
               col <= table_range_df$max_col[1])


      }



    continue <- TRUE

    while (continue) {
      sheet_original <- sheet
      sheet <- sheet %>% unmerge_cells(strict_merging = strict_merging)

      continue <- !identical(sheet_original, sheet)
    }



    manual_value_references_temp <- manual_value_references
    value_ref <- sheet %>% get_value_references(manual_value_references = manual_value_references_temp)


    added_row_groups_temp <- added_row_groups

    if(header_labels_present){
      header_labels <- get_header_labels(sheet = sheet, value_ref = value_ref, formats = formats, ignore_bolding = FALSE, ignore_indenting = FALSE,  ignore_italics = FALSE)
      unique_cols <- header_labels$data %>% map(3) %>% map(unique)
    }


    if(row_groups_present){
      row_groups <- get_row_groups(
        sheet = sheet, value_ref = value_ref,
        formats = formats, header_labels = header_labels, added_row_groups = added_row_groups_temp,
        ignore_bolding = ignore_bolding, ignore_indenting = ignore_indenting,  ignore_italics = ignore_italics)

      unique_rows <- row_groups$data %>% map(3) %>% map(unique)
    }


    if(keep_meta_data){
      meta_df <- get_meta_df(sheet = sheet, value_ref = value_ref, formats = formats, header_labels = header_labels)
      unique_meta <- meta_df$data %>% map(3) %>% map(unique)
    }


    tabledata <- get_tabledata(sheet = sheet, value_ref = value_ref,numeric_values = numeric_values)

    # Remove meta data /col group duplicates



    if(( !exists("meta_df")) & header_labels_present == TRUE ){

      keep_meta_data <-  FALSE

    }else if(header_labels_present == TRUE){

      joint_col <-
        full_join(
          tibble(values = unique_cols) %>%
            mutate(header_label = row_number()) %>%
            unnest(),
          tibble(values = unique_meta) %>%
            mutate(meta_group = row_number()) %>%
            unnest()
        )

      cols_to_keep <-
        joint_col %>%
        group_by(header_label) %>%
        filter(!is.na(header_label)) %>%
        summarise(keep = 1 != sum(!is.na(meta_group) / length(meta_group), na.rm = TRUE)) %>%
        pull(keep)

      header_labels <- header_labels[cols_to_keep, ]

    }


    component_list <- list()
    if(header_labels_present){component_list <- component_list %>% append(list(header_labels = header_labels))}
    if(row_groups_present){component_list <- component_list %>% append(list(row_groups = row_groups))}
    if(keep_meta_data){component_list <- component_list %>% append(list(meta_df = meta_df))}

    component_list <- component_list %>% append(list(tabledata = tabledata))


    component_list

  }
