
# Set up package ---------------------------------------------

setwd("C:/Users/Ian/Data/r-projects/tidyABS")

library(usethis)

create_package(path = "C:/Users/Ian/Data/r-projects/tidyABS")

use_mit_license("Ian Moran")

use_revdep()

use_readme_md()

use_news_md()

use_test("my-test")

use_git()

#------------------------------------------------------------
# Add Data and packages -------------------------------------

use_data()

usethis::use_package("tidyxl", type = "Imports")
usethis::use_package("unpivotr", type = "Imports")
usethis::use_package("magrittr", type = "Imports")
usethis::use_package("dplyr", type = "Imports")
usethis::use_package("purrr", type = "Imports")
usethis::use_package("stringi", type = "Imports")
usethis::use_package("forcats", type = "Imports")
usethis::use_package("tidyverse", type = "Imports")
usethis::use_package("cellranger", type = "Imports")

devtools::install()

