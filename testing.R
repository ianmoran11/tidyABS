devtools::document()
devtools::install()
13
library(tidyABS)
library(tidyverse)
library(magrittr)

rm(list = ls())

process_sheet(tidyABS_example("australian-industry.xlsx"), sheets = "Table_1",table_range = "A5:E234",strict_merging = T) %>%
  assemble_table_components()

  table_components <-
  "C:/Users/Ian/Downloads/frank_ermis__11178__Enron Pricing Report.xlsx" %>%

df_list <-
  c("G25:J34","Q14:T23","L25:O34","Q25:T34","G36:J45","L36:O45","Q36:T45","G47:J56","L47:O56","Q47:T56") %>%
    map( ~ process_sheet(table_range = .x, sheets = "Report",row_groups_present = F,ignore_indenting = T,numeric_values = T,
    path = "C:/Users/Ian/Downloads/frank_ermis__11178__Enron Pricing Report.xlsx") %>%
      assemble_table_components)

  "C:/Users/Ian/Downloads/frank_ermis__11178__Enron Pricing Report.xlsx" %>%
    process_sheet(sheets = "Report",table_range = "G25:J34",row_groups_present = F,ignore_indenting = T,numeric_values = F) %>%
    plot_table_components()


  "C:/Users/Ian/Downloads/frank_ermis__11178__Enron Pricing Report.xlsx" %>%
    process_sheet(sheets = "Report",table_range = "G25:J34",row_groups_present = F,ignore_indenting = T,numeric_values = F,strict_merging = F) %>%
    assemble_table_components() %>% View
b
  table_components %>% View




  table_components %>%
    gather(group,  label, -row, -col,-value, -comment) %>%
  ggplot(aes(
    x = col, y = -row, fill = group,
    label = ifelse(type != "data", paste(
      str_extract(group, "[0-9]{1,2}"),
      paste0(ifelse(type != "data", paste0("(", direction, ")"), ""))
    ), "")
  )) +
    geom_tile() +
    geom_text(size = 3) +
    # xlim(limits = c(.5,10)) +
    # ylim(limits = c(-30,-.5)) +
    theme_minimal() +
    labs(fill = "Cell Type", y = "Row", x = "Column")


  table_components %>% reconstruct_table()

  table_components %>% assemble_table_components() %>%
    mutate(col_group_03  = coalesce(col_group_03,col_group_04,col_group_05)) %>%
    filter(col_group_02    == "Fixed Price") %>%
              select(row,value,col_group_01,col_group_03) %>%
    mutate(value  = as.numeric(value)) %>%
    spread(col_group_03 ,value) %>%
    mutate(diiference = OFFER - BID) %>%
    ggplot(aes(x =diiference )) + geom_point() + geom_abline(intercept = 0, slope =1) +
    theme_ipsum()

  library(hrbrthemes)

  ?geom_abline


    spread(col_group_03, value)



col_groups <- bind_rows(table_component_data)

tabledata <- table_components$tabledata

map2(col_groups$data, col_groups$direction, ~ enhead_tabledata(header_data = .x, direction = .y, values = tabledata)) %>%
  reduce(full_join)

library(tidyxl)

"C:/Users/Ian/Downloads/frank_ermis__11178__Enron Pricing Report.xlsx" %>% xlsx_cells()

    "C:/Users/Ian/Downloads/frank_ermis__11178__Enron Pricing Report.xlsx" %>%
    process_sheet(sheets = "Report",table_range = "G25:J34",row_groups_present = F) %>%
    tidyABS::inspect_table_components()

