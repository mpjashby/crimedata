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
get_file_urls <- function (cache = TRUE, quiet = FALSE) {

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
fetch_file_urls <- function () {

  # Retrieve data types separtely because there seems to be some undocumented
  # limit on the number of files returned by each API call, even with pagination
  urls <- c(
    "https://api.osf.io/v2/nodes/zyaqn/files/osfstorage/5bbde32b7cb18100193c778a/?filter[name]=core",
    "https://api.osf.io/v2/nodes/zyaqn/files/osfstorage/5bbde32b7cb18100193c778a/?filter[name]=extended",
    "https://api.osf.io/v2/nodes/zyaqn/files/osfstorage/5bbde32b7cb18100193c778a/?filter[name]=sample"
  )

  json_values <- purrr::map(urls, function (x) {

    page_url <- x

    # Create an empty list to store result
    values <- list()

    while (!is.null(page_url)) {

      # Get JSON data
      json <- httr::content(
        httr::stop_for_status(httr::GET(page_url)),
        as = "parsed",
        type = "application/json"
      )

      # Update the URL to the next page (or NULL if this is the last page)
      page_url <- json$links[["next"]]

      # Add results to existing object
      values <- c(values, json$data)

    }

    # Return list of JSON objects
    values

  })

  values <- purrr::map_dfr(json_values, function (x) {

    purrr::map_dfr(x, function (y) {

      # Parse the file name into type and year
      file_name <- as.character(stringr::str_match(
        y$attributes$name,
        "^crime_open_database_(core|extended|sample)_(.+)_(\\d+).Rds$"
      ))

      # Extract city_name
      city_name <- stringr::str_to_title(
        stringr::str_replace_all(file_name[3], "_", " ")
      )
      if (city_name == "All") {
        city_name <- "All cities"
      }

      # Return a list of data for this file
      list(
        data_type = file_name[2],
        city = city_name,
        year = file_name[4],
        file_url = y$links$download
      )

    })

  })

  # convert year from character to integer
  values$year <- as.integer(values$year)

  # return tibble of links
  values[order(values$data_type, values$city, values$year), ]

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
#' @export
#'
list_crime_data <- function (quiet = FALSE) {

  # Get DF of URLs
  urls <- get_file_urls(quiet = quiet)

  # Calculate first and last years of data for each city
  first_last_years <- cbind(
    stats::aggregate(year ~ city, data = urls, FUN = min),
    stats::aggregate(year ~ city, data = urls, FUN = max)
  )[, c(1, 2, 4)]

  # Format those years into a character value
  first_last_years$years = paste(
    first_last_years$year,
    "to",
    first_last_years$year.1
  )

  # Return result
  first_last_years[, c("city", "years")]

}
