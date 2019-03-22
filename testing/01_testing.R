library(devtools)
library(tidyverse)
devtools::install()
library(tidyABS)



tidyABS_example("australian-industry.xlsx") %>%
  process_ABS_sheet(sheets = "Table_1") %>%
  reconstruct_table()

