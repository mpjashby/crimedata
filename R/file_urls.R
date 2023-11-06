#' Get URLs for Open Crime Database files
#'
#' URLs are either obtained from the OSF API or, if a cached version exists,
#' from the cache.
#'
#' @param cache Should the result be cached and then re-used if the function is
#'   called again with the same arguments?
#' @param quiet Should messages and warnings relating to data availability be
#'   suppressed?
#'
#' @noRd
#'
get_file_urls <- function(cache = TRUE, quiet = FALSE) {

  # Check inputs
  if (!rlang::is_logical(cache, n = 1))
    rlang::abort("`cache` must be `TRUE` or `FALSE`")
  if (!rlang::is_logical(quiet, n = 1))
    rlang::abort("`quiet` must be `TRUE` or `FALSE`")

  # set path for cache file
  cache_file <- paste0(tempdir(), "/crimedata_urls_",
                       digest::digest("crimedata"), ".Rds")

  # check if cached data exist and are less than 24 hours old
  if (
    file.exists(cache_file)
    & file.mtime(cache_file) > Sys.time() - 60 * 60 * 24
    & cache == TRUE
  ) {

    # get URLs from cache
    urls <- readRDS(cache_file)

    if (quiet == FALSE) {
      rlang::inform(c(
        "Using cached URLs to get data from server.",
        "i" = "These URLs rarely change and this is almost certainly safe."
      ))
    }

  } else {

    if (quiet == FALSE) {
      rlang::inform(c(
        "Downloading list of URLs for data files.",
        "i" = "This takes a few seconds but is only done once per session."
      ))
    }

    # get URLs from server
    urls <- fetch_file_urls()

    # save URLs to cache
    saveRDS(urls, cache_file)

  }

  # return URLs
  urls

}

#' Generate a tibble of URLs for data files
#'
#' Fetch the URLs of crime data files from the Crime Open Database server,
#' together with the type of data in the file and the year the data is for.
#'
#' @return a tibble with four columns: `data_type`, `city`, `year` and
#'   `file_url`
#'
#' @noRd
#'
fetch_file_urls <- function() {

  # Download file details
  files <- osfr::osf_ls_files(
    osfr::osf_retrieve_node("https://osf.io/zyaqn"),
    path = "Data for R package",
    n_max = Inf
  )

  # Extract file-name components
  components <- stringr::str_match(
    files$name,
    "^crime_open_database_(core|extended|sample)_(.+)_(\\d+).Rds$"
  )

  # Add components
  files$data_type <- components[, 2]
  files$city <- stringr::str_to_title(
    stringr::str_replace_all(components[, 3], "_", " ")
  )
  files$city <- ifelse(files$city == "All", "All cities", files$city)
  files$year <- as.integer(components[, 4])

  # return tibble of links
  files[order(files$data_type, files$city, files$year), ]

}


#' List Data Available in the Open Crime Database
#'
#' Get a tibble showing what years of crime data are available from which cities
#' in the Open Crime Database.
#'
#' @param quiet Should messages and warnings relating to data availability and
#'   processing be suppressed?
#'
#' @return A tibble
#'
#' @examples
#' \donttest{
#' list_crime_data()
#' }
#'
#' @export
#'
list_crime_data <- function(quiet = FALSE) {

  # Get DF of URLs
  urls <- get_file_urls(quiet = quiet)

  # Calculate first and last years of data for each city
  first_last_years <- cbind(
    stats::aggregate(year ~ city, data = urls, FUN = min),
    stats::aggregate(year ~ city, data = urls, FUN = max)
  )[, c(1, 2, 4)]

  # Format those years into a character value
  first_last_years$years <- paste(
    first_last_years$year,
    "to",
    first_last_years$year.1
  )

  # Return result
  first_last_years[, c("city", "years")]

}
