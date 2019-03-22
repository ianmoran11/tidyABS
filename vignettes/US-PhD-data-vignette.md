
<!-- README.md is generated from README.Rmd. Please edit that file -->

## Tidying excel sheets from The Survey of Earned Doctorates

Here are a couple of examples using tidyABS on a non-ABS excel
table.

#### Table 12. Doctorate recipients, by major field of study: Selected years, 1987â€“2017

##### Minimal code

Here’s a mininal example.

``` r
tidyABS_example("PhD_major-field.xlsx") %>%
  process_sheet(path = ., sheets = 1, manual_value_references = "B6:O50") %>%
  change_direction("row_group_01", "WNW") %>%
  change_direction("row_group_02", "WNW") %>%
  assemble_table_components() %>%
  str()
#> Classes 'tbl_df', 'tbl' and 'data.frame':    630 obs. of  9 variables:
#>  $ row         : int  6 6 6 6 6 6 6 6 6 6 ...
#>  $ col         : int  2 3 4 5 6 7 8 9 10 11 ...
#>  $ comment     : chr  NA NA NA NA ...
#>  $ value       : chr  "32365" "100" "38886" "100" ...
#>  $ col_group_01: chr  "1987" "1987" "1992" "1992" ...
#>  $ col_group_02: chr  "Number" "Percent" "Number" "Percent" ...
#>  $ row_group_01: chr  "All fields" "All fields" "All fields" "All fields" ...
#>  $ row_group_02: chr  NA NA NA NA ...
#>  $ row_group_03: chr  NA NA NA NA ...
```

##### Step-through

First, read in the sheet, specifying table corners.

``` r
phd_field_df_components <-
  tidyABS_example("PhD_major-field.xlsx") %>%
  process_sheet(path = ., sheets = 1, manual_value_references = "B6:O50")
```

Check the orietation of cells and make
corrections.

``` r
phd_field_df_components %>% plot_table_components()
```

![](vignettes/US-PhD-data-vignette_files/figure-gfm/unnamed-chunk-4-1.png)<!-- -->

``` r

phd_field_df_components <-
  phd_field_df_components %>%
  change_direction("row_group_01", "WNW") %>%
  change_direction("row_group_02", "WNW")
```

Check the structure of the table implied by `phd_field_df_components`
against the original excel table. If tidyABS has not identified row and
column names correctly, the output below will not line up with the
original excel table.

``` r
phd_field_df_components %>% reconstruct_table() 
#> # A tibble: 45 x 17
#>    row_group_01 row_group_02 row_group_03 `1987_Number` `1987_Percent`
#>    <chr>        <chr>        <chr>                <dbl>          <dbl>
#>  1 All fields   <NA>         <NA>                 32365          100  
#>  2 All fields   Life scienc~ <NA>                  5783           17.9
#>  3 All fields   Life scienc~ Agricultura~          1144            3.5
#>  4 All fields   Life scienc~ Biological ~          3839           11.9
#>  5 All fields   Life scienc~ Health scie~           800            2.5
#>  6 All fields   Physical sc~ <NA>                  3811           11.8
#>  7 All fields   Physical sc~ Chemistry             1975            6.1
#>  8 All fields   Physical sc~ Geosciences~           599            1.9
#>  9 All fields   Physical sc~ Physics and~          1237            3.8
#> 10 All fields   Mathematics~ <NA>                  1189            3.7
#> # ... with 35 more rows, and 12 more variables: `1992_Number` <dbl>,
#> #   `1992_Percent` <dbl>, `1997_Number` <dbl>, `1997_Percent` <dbl>,
#> #   `2002_Number` <dbl>, `2002_Percent` <dbl>, `2007_Number` <dbl>,
#> #   `2007_Percent` <dbl>, `2012_Number` <dbl>, `2012_Percent` <dbl>,
#> #   `2017_Number` <dbl>, `2017_Percent` <dbl>
```

Using `View()` is useful
here:

![](vignettes/US-PhD-data-vignette_files/figure-gfm/unnamed-chunk-6-1.png)<!-- -->

Assemble.

``` r
phd_field_df <-
  phd_field_df_components %>%
  assemble_table_components()

phd_field_df %>% glimpse()
#> Observations: 630
#> Variables: 9
#> $ row          <int> 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 7, 7, 7...
#> $ col          <int> 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 2...
#> $ comment      <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, N...
#> $ value        <chr> "32365", "100", "38886", "100", "42539", "100", "...
#> $ col_group_01 <chr> "1987", "1987", "1992", "1992", "1997", "1997", "...
#> $ col_group_02 <chr> "Number", "Percent", "Number", "Percent", "Number...
#> $ row_group_01 <chr> "All fields", "All fields", "All fields", "All fi...
#> $ row_group_02 <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, N...
#> $ row_group_03 <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, N...
```

#### Table 22. Doctorate recipients, by subfield of study, citizenship status, ethnicity, and race: 2017

##### Minimal code

Here’s a mininal
example.

``` r
tidyABS_example("PhD_ subfield-citizenship-status-ethnicity-race.xlsx") %>%
  process_sheet(path = ., sheets = 1, manual_value_references = "B7:L277") %>%
  change_direction("row_group_01", "WNW") %>%
  change_direction("row_group_02", "WNW") %>%
  change_direction("row_group_03", "WNW") %>%
  change_direction("row_group_04", "WNW") %>%
  assemble_table_components() %>%
  glimpse()
#> Observations: 2,981
#> Variables: 12
#> $ row          <int> 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 8, 8, 8, 8, 8, 8...
#> $ col          <int> 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 2, 3, 4, 5, 6...
#> $ comment      <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, N...
#> $ value        <chr> "54664", "16323", "35791", "2540", "109", "3502",...
#> $ col_group_01 <chr> "All doctorate recipientsa", "Temporary visa hold...
#> $ col_group_02 <chr> NA, NA, "Total", "Hispanic or Latino", "Not Hispa...
#> $ col_group_03 <chr> NA, NA, NA, NA, "American Indian or Alaska Native...
#> $ row_group_01 <chr> "All fields", "All fields", "All fields", "All fi...
#> $ row_group_02 <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, "Life...
#> $ row_group_03 <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, N...
#> $ row_group_04 <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, N...
#> $ row_group_05 <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, N...
```

##### Step-through

First, read in the sheet, specifying table corners.

``` r
phd_background_components <-
  tidyABS_example("PhD_ subfield-citizenship-status-ethnicity-race.xlsx") %>%
  process_sheet(path = ., sheets = 1, manual_value_references = "B7:L277")
```

Check the orietation of cells and make
corrections.

``` r
phd_background_components %>% plot_table_components() + ylim(-30, 0)
```

![](vignettes/US-PhD-data-vignette_files/figure-gfm/unnamed-chunk-10-1.png)<!-- -->

``` r

phd_background_components <-
  phd_background_components %>%
  change_direction("row_group_01", "WNW") %>%
  change_direction("row_group_02", "WNW") %>%
  change_direction("row_group_03", "WNW") %>% 
  change_direction("row_group_04", "WNW")
```

Check the structure of the table implied by `phd_field_df_components`
against the original excel table. If tidyABS has not identified row and
column names correctly, the output below will not line up with the
original excel table.

``` r
phd_background_components %>% reconstruct_table()  
#> # A tibble: 271 x 16
#>    row_group_01 row_group_02 row_group_03 row_group_04 row_group_05
#>    <chr>        <chr>        <chr>        <chr>        <chr>       
#>  1 All fields   <NA>         <NA>         <NA>         <NA>        
#>  2 All fields   Life scienc~ <NA>         <NA>         <NA>        
#>  3 All fields   Life scienc~ "Agricultur~ <NA>         <NA>        
#>  4 All fields   Life scienc~ "Agricultur~ Agricultura~ <NA>        
#>  5 All fields   Life scienc~ "Agricultur~ Agronomy, h~ <NA>        
#>  6 All fields   Life scienc~ "Agricultur~ Animal nutr~ <NA>        
#>  7 All fields   Life scienc~ "Agricultur~ Animal scie~ <NA>        
#>  8 All fields   Life scienc~ "Agricultur~ Environment~ <NA>        
#>  9 All fields   Life scienc~ "Agricultur~ Fishing and~ <NA>        
#> 10 All fields   Life scienc~ "Agricultur~ Food scienc~ <NA>        
#> # ... with 261 more rows, and 11 more variables: `All doctorate
#> #   recipientsa` <dbl>, `Temporary visa holders` <dbl>, `U.S. citizens and
#> #   permanent residents_Total` <dbl>, `U.S. citizens and permanent
#> #   residents_Hispanic or Latino` <dbl>, `U.S. citizens and permanent
#> #   residents_Not Hispanic or Latino_American Indian or Alaska
#> #   Native` <dbl>, `U.S. citizens and permanent residents_Not Hispanic or
#> #   Latino_Asian` <dbl>, `U.S. citizens and permanent residents_Not
#> #   Hispanic or Latino_Black or African American` <dbl>, `U.S. citizens
#> #   and permanent residents_Not Hispanic or Latino_White` <dbl>, `U.S.
#> #   citizens and permanent residents_Not Hispanic or Latino_More than one
#> #   race` <dbl>, `U.S. citizens and permanent residents_Not Hispanic or
#> #   Latino_Other race or race not reported` <dbl>, `U.S. citizens and
#> #   permanent residents_Ethnicity not reported` <dbl>
```

Using `View()` is useful
here:

![](vignettes/US-PhD-data-vignette_files/figure-gfm/unnamed-chunk-12-1.png)<!-- -->

Assemble.

``` r
phd_background_df <-
  phd_background_components %>%
  assemble_table_components()


phd_background_df %>% glimpse()
#> Observations: 2,981
#> Variables: 12
#> $ row          <int> 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 8, 8, 8, 8, 8, 8...
#> $ col          <int> 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 2, 3, 4, 5, 6...
#> $ comment      <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, N...
#> $ value        <chr> "54664", "16323", "35791", "2540", "109", "3502",...
#> $ col_group_01 <chr> "All doctorate recipientsa", "Temporary visa hold...
#> $ col_group_02 <chr> NA, NA, "Total", "Hispanic or Latino", "Not Hispa...
#> $ col_group_03 <chr> NA, NA, NA, NA, "American Indian or Alaska Native...
#> $ row_group_01 <chr> "All fields", "All fields", "All fields", "All fi...
#> $ row_group_02 <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, "Life...
#> $ row_group_03 <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, N...
#> $ row_group_04 <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, N...
#> $ row_group_05 <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, N...
```
