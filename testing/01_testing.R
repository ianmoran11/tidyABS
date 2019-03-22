library(devtools)
library(tidyverse)
devtools::install()
13
library(tidyABS)



tidyABS_example("australian-industry.xlsx") %>%
  process_sheet(sheets = "Table_1") %>%
  reconstruct_table() %>% View

tidyABS_example("australian-industry.xlsx")

cellranger::as.cell_addr_v("A1:A3")

cellranger::as.cell_limits("A1:A5") %>% as_tibble()

