#' Get Data from the Open Crime Database
#'
#' Retrieves data from the Open Crime Database for the specified years.
#'
#' By default this function returns a 1% sample of the 'core' data. This is the
#' default to minimise accidentally requesting large files over a network.
#'
#' Seting type = "core" retrieves the core fields (e.g. the type, co-ordinates
#' and date/time of each offense) for each offense.
#' The data retrieved by setting type = "extended" includes all available fields
#' provided by the police department in each city. The extended data fields have
#' not been harmonized across cities, so will require further cleaning before
#' most types of analysis.
#'
#' Requesting all data may lead to problems with memory capacity. Consider
#' downloading smaller quantities of data (e.g. using type = "sample") for
#' exploratory analysis.
#'
#' @param years A single integer or vector of integers specifying the years for
#'   which data should be retrieved. If NULL (the default), data for the most
#'   recent year will be returned.
#' @param cities A character vector of city names for which data should be
#'   retrieved. If NULL (the default), data for all available cities will be
#'   returned.
#' @param type Either "sample" (the default), "core" or "extended".
#' @param cache Should the result be cached and then re-used if the function is
#'   called again with the same arguments?
#' @param quiet Should messages and warnings relating to data availability and
#'   processing be suppressed?
#'
#' @return A tibble containing data from the Open Crime Database.
#' @export
#'
#' @examples
#' \dontrun{
#' # Retrieve a 1% sample of data for specific years and cities
#' get_crime_data(years = 2016:2017, cities = c("Tucson", "Virginia Beach"))
#' }
#'
#' @import digest
#' @import dplyr
#' @import readr
#' @import purrr
get_crime_data <- function (years = NULL, cities = NULL, type = "sample",
                            cache = TRUE, quiet = FALSE) {

  # check for errors
  stopifnot(type %in% c("core", "extended", "sample"))
  stopifnot(is.character(cities) | is.null(cities))
  stopifnot(is.integer(as.integer(years)) | is.null(years))
  stopifnot(is.logical(quiet))

  # get tibble of available data
  urls <- get_file_urls(quiet = quiet)

  # if years are not specified, use the most recent available year
  if (is.null(years)) {
    years <- max(urls$year)
  }

  # if cities are not specified, use all available cities
  if (is.null(cities)) {
    cities <- "all cities"
  }

  # make sure years is of type integer, since there is a difference between the
  # hashed values of the same numbers stored as numeric and stored as integer,
  # which makes a difference when specifying the cache file name
  years <- as.integer(years)

  # check if all specified years are available
  if (!all(years %in% unique(urls$year))) {
    stop("One or more of the specified years does not correspond to a year of ",
         "data available in the Open Crime Database. For details of available ",
         "data, see <https://osf.io/zyaqn/>. Data for the current year are ",
         "not available because the database is updated annually.")
  }

  # check if all specified cities are available
  if (cities != "all" & !all(cities %in% unique(urls$city))) {
    stop("One or more of the specified cities does not correspond to a city ",
         "for which data are available in the Open Crime Database. Check your ",
         "spelling or for details of available data, see ",
         "<https://osf.io/zyaqn/>.")
  }

  # digest() produces an MD5 hash of the type and years of data requested, so
  # that repeated calls to this function with the same arguments results in data
  # being retrieved from the cache, while calls with different arguments results
  # in fresh data being downloaded
  hash <- digest::digest(c(type, years, cities))
  cache_file <- tempfile(
    pattern = paste0("crimedata_", hash, "_"),
    fileext = ".Rds"
  )
  cache_files <- dir(tempdir(), pattern = hash, full.names = TRUE)

  # delete cached data if cache = FALSE
  if (cache == FALSE & length(cache_files) > 0) {

    lapply(cache_files, file.remove)

  }

  # check if requested data are available in cache
  if (cache == TRUE & length(cache_files) > 0) {

    if (quiet == FALSE) {
      message("Loading cached data from previous request in this session. To ",
              "download data again, call get_crime_data() with cache = FALSE.",
              appendLF = TRUE)
    }

    crime_data <- readRDS(cache_files[1])

  } else {

    # extract URLs for requested data
    urls <- urls[urls$data_type == type & urls$year %in% years &
                   urls$city %in% cities, ]

    # check if specified combination of years and cities is available
    if (nrow(urls) == 0) {

      stop("The Crime Open Database does not contain data for any of the ",
           "specified years for the specified cities.")

    } else {

      throw_away <- expand.grid(year = years, city = cities) %>%
        apply(1, function (x) {
          if (nrow(urls[urls$year == x[[1]] & urls$city == x[[2]], ]) == 0 &
              quiet == FALSE) {
            warning("Data are not available for crimes in ", x[[2]], " in ",
                    x[[1]], call. = FALSE, immediate. = TRUE,
                    noBreaks. = TRUE)
          }
        })

      rm(throw_away)

    }

    # fetch data
    # purrr::transpose() converts each row of the urls tibble into a list, which
    # can then by processed by purrr::map()
    crime_data <- urls %>%
      purrr::transpose(.names = paste0(.$data_type, .$city, .$year)) %>%
    purrr::map(function (x) {

      # report progress
      if (quiet == FALSE) {
        message("Downloading ", x[["data_type"]], " data for ", x[["city"]],
                " in ", x[["year"]], appendLF = TRUE)
      }

      # set name for temporary file
      temp_file <- tempfile(pattern = "code_data_", fileext = ".Rds")

      # download remote file
      httr::GET(x[["file_url"]], progress(type = "down")) %>%
        httr::content(as = "raw") %>%
        writeBin(temp_file)

      # read file
      this_crime_data <- readRDS(temp_file)

      # remove temporary file
      file.remove(temp_file)

      # return data from file
      this_crime_data

    }) %>%
      dplyr::bind_rows() %>%
      dplyr::arrange(.data$uid)

    # store data in cache
    saveRDS(crime_data, cache_file)

  }

  # return data
  crime_data

}
