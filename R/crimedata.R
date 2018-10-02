#' crimedata: a package for accessing US city crime data
#'
#' Access incident-level crime data from the Open Crime Database
#'
#' @section Crime Open Database:
#'
#' The Crime Open Database (CODE) is a service that makes it convenient to use
#' crime data from multiple US cities in research on crime. All the data are
#' available to use for free as long as you acknowledge the source of the data.
#'
#' For more about CODE data, see \url{https://osf.io/zyaqn/}.
#'
#' @section Accessing the data:
#'
#' To access CODE data, call \code{\link{get_crime_data}}. Data are returned as
#' a 'tidy' tibble with each row corresponding to one recorded crime.
#'
#' @docType package
#' @name crimedata
NULL

## quiets concerns of R CMD check re: the .'s that appear in pipelines
# code from:
# https://github.com/STAT545-UBC/Discussion/issues/451#issuecomment-264598618
if(getRversion() >= "2.15.1")  utils::globalVariables(c("."))
