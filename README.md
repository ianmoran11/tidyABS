
<!-- README.md is generated from README.Rmd. Please edit that file -->

## Overview

The tidyABS package converts ABS excel tables to tidy data frames. It
uses rules-of-thumb to determine the structure of excel tables, however
it sometimes requires pointers from the user.

*Note: tidyABS works with .xlsx files only.*

## Installation

The tidyABS package is not available on CRAN. It can be installed from
github with the following script:

``` r
# install.packages("devtools")
devtools::install_github("ianmoran11/tidyABS")
```

## Usage

``` r
library(tidyABS)
library(tidyverse)
```

Below is a short demonstration that tidies a table from the Australian
Industry publication (catalogue 8155.0).

``` r

tidy_aus_industry_df <-
  tidyABS_example("australian-industry.xlsx") %>%
  process_ABS_sheet(sheets = "Table_1") %>%
  assemble_table_components()

tidy_aus_industry_df %>% str()
#> Classes 'tbl_df', 'tbl' and 'data.frame':    1816 obs. of  8 variables:
#>  $ row         : int  8 8 8 8 8 8 8 8 9 9 ...
#>  $ col         : int  2 3 4 5 6 7 8 9 2 3 ...
#>  $ comment     : chr  NA NA NA NA ...
#>  $ value       : chr  "485" "5843" "54410" "57577" ...
#>  $ col_group_01: chr  "Employment at end of June" "Wages and salaries" "Sales and service income" "Total income" ...
#>  $ col_group_02: chr  "'000" "$m" "$m" "$m" ...
#>  $ row_group_01: chr  "2006–07" "2006–07" "2006–07" "2006–07" ...
#>  $ row_group_02: chr  "AGRICULTURE, FORESTRY AND FISHING" "AGRICULTURE, FORESTRY AND FISHING" "AGRICULTURE, FORESTRY AND FISHING" "AGRICULTURE, FORESTRY AND FISHING" ...
```

### Examples

The tidyABS package contains several example files. Use the helper
`tidyABS_example()` function with no arguments to list these files:

``` r
tidyABS_example()
#> [1] "australian-industry.xlsx"                            
#> [2] "consumer-price-index.xlsx"                           
#> [3] "environmental-economic-accounts.xlsx"                
#> [4] "PhD_ subfield-citizenship-status-ethnicity-race.xlsx"
#> [5] "PhD_major-field.xlsx"
```

#### Example 1: Australian Industry

![](README-unnamed-chunk-7-1.png)<!-- -->

Above is the first sheet of an excel workbook from the Australian
Industry publication. We can retrieve the path of this file using the
`tidyABS_example` function:

``` r
ai_path <- tidyABS_example("australian-industry.xlsx")
```

To process the sheet above, we pass the workbook file path to the
`process_ABS_sheet` function and identify the sheet we’d like to tidy.

``` r
ai_processed <- process_ABS_sheet(path = ai_path, sheets = "Table_1")

ai_processed %>% str(1)
#> List of 3
#>  $ col_groups:Classes 'tbl_df', 'tbl' and 'data.frame':  2 obs. of  10 variables:
#>  $ row_groups:Classes 'tbl_df', 'tbl' and 'data.frame':  2 obs. of  11 variables:
#>  $ tabledata :Classes 'tbl_df', 'tbl' and 'data.frame':  1816 obs. of  4 variables:
```

This produces a list of three data frames. They store the location and
format information of row names (`row_groups`), column names
(`col_groups`) and table data (`tabledata`).

We can inspect the row and column names in `ai_processed` using the
`inspect_table_components` function.

``` r
inspect_table_components(ai_processed)
#> $col_groups
#> $col_groups[[1]]
#> [1] "Employment at end of June"                                 
#> [2] "Wages and salaries"                                        
#> [3] "Sales and service income"                                  
#> [4] "Total income"                                              
#> [5] "Total expenses"                                            
#> [6] "Operating profit before tax"                               
#> [7] "Earnings before interest tax depreciation and amortisation"
#> [8] "Industry value added"                                      
#> 
#> $col_groups[[2]]
#> [1] "'000" "$m"  
#> 
#> 
#> $row_groups
#> $row_groups[[1]]
#>  [1] "2006–07" "2007–08" "2008–09" "2009–10" "2010–11" "2011–12" "2012–13"
#>  [8] "2013–14" "2014–15" "2015–16" "2016–17"
#> 
#> $row_groups[[2]]
#>  [1] "AGRICULTURE, FORESTRY AND FISHING"              
#>  [2] "MINING"                                         
#>  [3] "MANUFACTURING"                                  
#>  [4] "ELECTRICITY, GAS, WATER AND WASTE SERVICES"     
#>  [5] "CONSTRUCTION"                                   
#>  [6] "WHOLESALE TRADE"                                
#>  [7] "RETAIL TRADE"                                   
#>  [8] "ACCOMMODATION AND FOOD SERVICES"                
#>  [9] "TRANSPORT, POSTAL AND WAREHOUSING"              
#> [10] "INFORMATION MEDIA AND TELECOMMUNICATIONS"       
#> [11] "RENTAL, HIRING AND REAL ESTATE SERVICES"        
#> [12] "PROFESSIONAL, SCIENTIFIC AND TECHNICAL SERVICES"
#> [13] "ADMINISTRATIVE AND SUPPORT SERVICES"            
#> [14] "PUBLIC ADMINISTRATION AND SAFETY (PRIVATE)"     
#> [15] "EDUCATION AND TRAINING (PRIVATE)"               
#> [16] "HEALTH CARE AND SOCIAL ASSISTANCE (PRIVATE)"    
#> [17] "ARTS AND RECREATION SERVICES"                   
#> [18] "OTHER SERVICES"                                 
#> [19] "TOTAL SELECTED INDUSTRIES"                      
#> 
#> 
#> $tabledata
#> list()
```

We can also visualize how these groups are spatially layed out in the
spreadsheet and how tidyABS will relate them to table values with the
function `plot_table_components`. Row names directly to the left of
their data points should be labelled “W”, and column names directly
above should be labelled “N”. (See the
[unpivotr](https://github.com/nacnudus/unpivotr) package for more
information.)

``` r
plot_table_components(ai_processed) +
  ylim(-30, 0)
```

![](README-unnamed-chunk-11-1.png)<!-- -->

Finally, we can assembly the components into a tidy data frame using
`assemble_table_components`.

``` r
assemble_table_components(ai_processed) %>%
  glimpse()
#> Observations: 1,816
#> Variables: 8
#> $ row          <int> 8, 8, 8, 8, 8, 8, 8, 8, 9, 9, 9, 9, 9, 9, 9, 9, 1...
#> $ col          <int> 2, 3, 4, 5, 6, 7, 8, 9, 2, 3, 4, 5, 6, 7, 8, 9, 2...
#> $ comment      <chr> NA, NA, NA, NA, NA, "estimate has a relative stan...
#> $ value        <chr> "485", "5843", "54410", "57577", "52046", "5461",...
#> $ col_group_01 <chr> "Employment at end of June", "Wages and salaries"...
#> $ col_group_02 <chr> "'000", "$m", "$m", "$m", "$m", "$m", "$m", "$m",...
#> $ row_group_01 <chr> "2006–07", "2006–07", "2006–07", "2006–07", "2006...
#> $ row_group_02 <chr> "AGRICULTURE, FORESTRY AND FISHING", "AGRICULTURE...
```

### Example 2: Environmental-Economic Accounts

![](README-unnamed-chunk-13-1.png)<!-- -->

Here’s an example that requires some manual work, the
Environmental-Economic Accounts. Let’s retrieve the path of our example
workbook and proces `Table 6.1`:

``` r
eea_path <- tidyABS_example("environmental-economic-accounts.xlsx")

eea_processed <- process_ABS_sheet(path = eea_path, sheets = "Table 6.1")
```

On visual inspection, we can see `row_group_01` has been given a “W”
orientation to the data, not “WNW”.

``` r
plot_table_components(eea_processed)
```

![](README-unnamed-chunk-15-1.png)<!-- -->

Luckily, we can fix this with the `change_direction` function.

``` r
eea_processed <-
  eea_processed %>%
  change_direction("row_group_01", "WNW")
```

Plotting the table confirms the direction has been corrected.

``` r
plot_table_components(eea_processed)
```

![](README-unnamed-chunk-17-1.png)<!-- -->

Finally, we can assemble the components into a tidy dataframe using
`assemble_table_components`.

``` r
assemble_table_components(eea_processed) %>%
  glimpse()
#> Observations: 156
#> Variables: 8
#> $ row          <int> 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 8, 8, 8, 8...
#> $ col          <int> 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 2, 3,...
#> $ comment      <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, N...
#> $ value        <chr> "13532", "14352", "14075", "14658", "15085", "155...
#> $ col_group_01 <chr> "2003–04", "2004–05", "2005–06", "2006–07", "2007...
#> $ row_group_01 <chr> "Energy Taxes ", "Energy Taxes ", "Energy Taxes "...
#> $ row_group_02 <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, N...
#> $ row_group_03 <chr> "Crude oil and LPG", "Crude oil and LPG", "Crude ...
```

### Example 3: Consumer Price Index (time series)

![](README-unnamed-chunk-19-1.png)<!-- -->

Time series data require the user to manually identify the inner table
cells. This is because some of the column names are numberic — for
example, collection month.

I recommend using the
[`readABS`](https://github.com/MattCowgill/readabs) package for this. It
was created for importing ABS time series data and does not require
manual identifcation of table cells.

That said, here’s how you would process this table with `tidyABS`.

``` r
cpi_path <- tidyABS_example("consumer-price-index.xlsx")
```

We need to identify the inner table cells using the
`manual_value_references` argument.This argument takes a vector of
addresses, identifying the inner corners of the table.

``` r
cpi_processed <-
  process_ABS_sheet(
    path = cpi_path, sheets = "Data1",
    manual_value_references = "B11:AB292"
  )
```

Here is the resulting data frame.

``` r
assemble_table_components(cpi_processed) %>%
  glimpse()
#> Observations: 7,185
#> Variables: 15
#> $ row          <int> 11, 11, 11, 11, 11, 11, 11, 11, 12, 12, 12, 12, 1...
#> $ col          <int> 2, 3, 4, 5, 6, 7, 9, 10, 2, 3, 4, 5, 6, 7, 9, 10,...
#> $ comment      <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, N...
#> $ value        <chr> "3.7", "3.8", "3.7", "3.8", "3.7", "3.8", "3.9", ...
#> $ col_group_01 <chr> "Index Numbers ;  All groups CPI ;  Sydney ;", "I...
#> $ col_group_02 <chr> "Index Numbers", "Index Numbers", "Index Numbers"...
#> $ col_group_03 <chr> "Original", "Original", "Original", "Original", "...
#> $ col_group_04 <chr> "INDEX", "INDEX", "INDEX", "INDEX", "INDEX", "IND...
#> $ col_group_05 <chr> "Quarter", "Quarter", "Quarter", "Quarter", "Quar...
#> $ col_group_06 <chr> "3", "3", "3", "3", "3", "3", "3", "3", "3", "3",...
#> $ col_group_07 <chr> "1948-09-01", "1948-09-01", "1948-09-01", "1948-0...
#> $ col_group_08 <chr> "2018-12-01", "2018-12-01", "2018-12-01", "2018-1...
#> $ col_group_09 <chr> "282", "282", "282", "282", "282", "282", "282", ...
#> $ col_group_10 <chr> "A2325806K", "A2325811C", "A2325816R", "A2325821J...
#> $ row_group_01 <chr> "1948-09-01", "1948-09-01", "1948-09-01", "1948-0...
```
