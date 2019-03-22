library(devtools)
library(tidyverse)
devtools::document()
devtools::install()


library(tidyABS)



tidyABS_example("australian-industry.xlsx") %>%
  process_sheet(sheets = "Table_1",manual_value_references = "A1") %>%
  reconstruct_table()

tidyABS_example("australian-industry.xlsx")

cellranger::as.cell_addr_v("A1:A3")

cellranger::as.cell_limits("A1:A5") %>% as_tibble()

