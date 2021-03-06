% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/plot_table_components.R
\name{plot_table_components}
\alias{plot_table_components}
\title{Plot table components}
\usage{
plot_table_components(processed_sheet)
}
\arguments{
\item{processed_sheet}{returned by \code{process_sheet}}
}
\description{
This function plots the excel sheet, highlighting the relationship between headers and table values.
}
\examples{

 \donttest{tidyABS_example("australian-industry.xlsx") \%>\% process_sheet(sheets = "Table_1") \%>\% plot_table_components() }


}
