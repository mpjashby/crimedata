#' Get data from the Open Crime Database
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
#' Compressed data files are approximately 40MB per year for the core data and
#' 70MB per year for the extended data, so consider requesting fewer years of
#' data (or use type = "sample") for exploratory analysis.
#'
#' @param years A single number or vector of numbers specifying the years for
#'   which data should be retrieved. If NULL (the default), data for all
#'   available years will be returned.
#' @param type Either "sample" (the default), "core" or "extended".
#' @param cache Should the result be cached and then re-used if the function is
#'   called again with the same arguments?
#'
#' @return A tibble containing data from the Open Crime Database.
#' @export
#'
#' @examples
#' # Retrieve data for specific years
#' get_crime_data(years = 2011:2015, type = "sample")
#'
#' @import digest
#' @import dplyr
#' @import readr
#' @import purrr
get_crime_data <- function (years = NULL, type = "sample", cache = TRUE) {

  # check for errors
  stopifnot(type %in% c("core", "extended", "sample"))
  stopifnot(is.integer(as.integer(years)) | is.null(years))

  # get tibble of available data
  urls <- get_file_urls()

  # if years are not specified, use all available years
  if (is.null(years)) {
    years <- unique(urls$year)
  }

  # make sure years is of type integer, since there is a difference between the
  # hashed values of the same numbers stored as numeric and stored as integer,
  # which makes a difference when specifying the cache file name
  years <- as.integer(years)

  # check if all specified years are available
  if (!all(years %in% urls$year)) {
    stop("One or more of the specified years does not correspond to a year of ",
         "data available in the Open Crime Database. For details of available ",
         "data, see <https://osf.io/zyaqn/>. Data for the current year are ",
         "not available because the database is updated annually.")
  }

  # digest() produces an MD5 hash of the type and years of data requested, so
  # that repeated calls to this function with the same arguments results in data
  # being retrieved from the cache, while calls with different arguments results
  # in fresh data being downloaded
  hash <- digest::digest(c(type, years))
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

    crime_data <- readRDS(cache_files[1])

    message("Returning cached data from previous request in this session. To ",
            "refresh data, call get_crime_data() with cache = FALSE.",
            appendLF = TRUE)

  } else {

    # fetch data
    # purrr::transpose() converts each row of the urls tibble into a list, which
    # can then by processed by purrr::map_df()
    crime_data <- urls[urls[["type"]] == type & urls[["year"]] %in% years, ] %>%
      purrr::transpose(.names = paste0(.$type, .$year)) %>%
      purrr::map(function (x) {

        # report progress
        message("Reading ", x[["type"]], " data for ", x[["year"]], " from ",
                x[["file_url"]], appendLF = TRUE)

        # set name for temporary file
        temp_file <- tempfile(pattern = "code_data_", fileext = ".csv.gz")

        # download remote file
        httr::GET(x[["file_url"]]) %>%
          httr::content(as = "raw") %>%
          writeBin(temp_file)

        # read file
        this_crime_data <- readr::read_csv(
          temp_file,
          progress = TRUE,
          col_types = readr::cols(
            .default = col_character(),
            uid = col_integer(),
            date_single = col_datetime(format = ""),
            date_start = col_datetime(format = ""),
            date_end = col_datetime(format = ""),
            longitude = col_double(),
            latitude = col_double(),
            fips_state = col_integer(),
            block_group = col_integer(),
            block = col_integer()
          ))

        # remove temporary file
        file.remove(temp_file)

        # return data from file
        this_crime_data

      }) %>%
        purrr::reduce(rbind)

    # store data in cache
    saveRDS(crime_data, cache_file)

  }

  # return data
  crime_data

}
