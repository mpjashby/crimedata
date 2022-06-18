#' Homicides in nine cities in 2015
#'
#' Dataset containing records of homicides in nine large US cities in 2015,
#' obtained from the \href{https://osf.io/zyaqn/}{Crime Open Database}.
#'
#' More details of the data format are available on the
#' \href{https://osf.io/zyaqn/wiki/home/}{Crime Open Database website}.
#' Variables marked * are only available for some of the
#' data, due to limitations in the data published by some cities.
#'
#' The variables in this dataset mirror those obtained by calling
#' \code{get_crime_data(type = "core")}, except that some fields have been
#' removed because they are redundant (e.g. if they have the same value for all
#' rows in this dataset).
#'
#' @format A tibble with 1,922 rows and 15 variables:
#' \describe{
#'   \item{uid}{an integer unique identifier for the offense}
#'   \item{city_name}{name of the city in which the crime occurred}
#'   \item{offense_code}{offense code, modified from the FBI NIBRS offense code}
#'   \item{offense_type}{offense type name}
#'   \item{date_single}{date (and, in most cases, time) of the offense}
#'   \item{address}{approximate address of the offense*}
#'   \item{longitude}{approximate longitude}
#'   \item{latitude}{approximate latitude}
#'   \item{location_type}{type of location*}
#'   \item{location_category}{category of location type*}
#'   \item{fips_state}{two-digit FIPS state code (possibly with leading zero)}
#'   \item{fips_county}{three-digit FIPS county code (possibly with leading
#'     zero)}
#'   \item{tract}{six-digit code for 2016 census tract}
#'   \item{block_group}{one-digit code for 2016 census block group}
#'   \item{block}{four-digit code for 2016 census block}
#' }
#'
#' @source \url{https://osf.io/zyaqn/}
"homicides15"

#' Thefts of motor vehicles 2014 to 2017
#'
#' Dataset containing records of thefts of motor vehicles in New York City from
#' 2014 to 2017, obtained from the
#' \href{https://osf.io/zyaqn/}{Crime Open Database}.
#'
#' More details of the data format are available on the
#' \href{https://osf.io/zyaqn/wiki/home/}{Crime Open Database website}.
#' Variables marked * are only available for some of the
#' data, due to limitations in the data published by some cities.
#'
#' The variables in this dataset mirror those obtained by calling
#' \code{get_crime_data(type = "core")}, except that some fields have been
#' removed because they are redundant (e.g. if they have the same value for all
#' rows in this dataset).
#'
#' @format A tibble with 35,746 rows and 13 variables:
#' \describe{
#'   \item{uid}{an integer unique identifier for the offense}
#'   \item{date_single}{date (and, in most cases, time) half-way between the
#'     first and last possible dates at which the offense could have occurred}
#'   \item{date_start}{first possible date (and, in most cases, time) at which
#'     the offense could have occurred}
#'   \item{date_send}{last possible date (and, in most cases, time) at which the
#'     offense could have occurred}
#'   \item{longitude}{approximate longitude}
#'   \item{latitude}{approximate latitude}
#'   \item{location_type}{type of location*}
#'   \item{location_category}{category of location type*}
#'   \item{fips_state}{two-digit FIPS state code (possibly with leading zero)}
#'   \item{fips_county}{three-digit FIPS county code (possibly with leading
#'     zero)}
#'   \item{tract}{six-digit code for 2016 census tract}
#'   \item{block_group}{one-digit code for 2016 census block group}
#'   \item{block}{four-digit code for 2016 census block}
#' }
#'
#' @source \url{https://osf.io/zyaqn/}
"nycvehiclethefts"
