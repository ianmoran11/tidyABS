

#' Get path to tidyABS example
#' tidyABS comes bundled with some example files in its `inst/extdata`
#' directory. This function make them easy to access.
#' This function has been copied from the readxl package.
#'
#' @param path Name of file. If `NULL`, the example files will be listed.
#' @export
#' @examples
#' readxl_example()
#' readxl_example("datasets.xlsx")
#'

tidyABS_example <- function(path = NULL) {
  if (is.null(path)) {
    dir(system.file("extdata", package = "tidyABS"))
  } else {
    system.file("extdata", path, package = "tidyABS", mustWork = TRUE)
  }
}
