

#' check_low_col_names
#'
#' This is a utility function that checks whether merging of a row label is leading to dupplicates in col and row labels.
#' @param col_groups groups cells identified as referring to the same category.


check_low_col_names <- function(col_groups) {
  uniqueness_test <- col_groups$data %>% map(3) %>% map_lgl(function(x) length(unique(x)) == 1 & length(x) > 1)

  col_groups[!uniqueness_test, ]
}
