#' Get URLs for Open Crime Database files
#'
#' URLs are either obtained from the OSF API or, if a cached version exists,
#' from the cache.
#'
#' @param quiet Should messages and warnings relating to data availability be
#'   suppressed?
#'
#' @import digest
get_file_urls <- function (quiet = FALSE) {

  # set path for cache file
  cache_file <- paste0(tempdir(), "/crimedata_urls_",
                       digest::digest("crimedata"), ".Rds")

  # check if cached data exist and are less than 24 hours old
  if (
    file.exists(cache_file)
    & file.mtime(cache_file) > Sys.time() - 60 * 60 * 24
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
#' @return a tibble with three columns: type, year and file_url
#'
fetch_file_urls <- function () {

  # Create an empty data frame in which to store the result
  values <- data.frame(
    type = character(),
    year = character(),
    file_url = character()
  )

  # specify the URL of the API end point
  page_url <- "https://api.osf.io/v2/nodes/zyaqn/files/osfstorage/5bbde32b7cb18100193c778a/?format=json"

  # fetch paginated results until there are none left, at which point page_url
  # will be NULL
  while (!is.null(page_url)) {

    # get a page of JSON results from the server, throwing an error if the
    # HTTP status suggests a problem
    json <- httr::GET(page_url) %>%
      httr::stop_for_status() %>%
      httr::content(as = "parsed", type = "application/json")

    # extract the data as a tibble
    result <- purrr::map_dfr(json$data, function (x) {

      # parse the file name into type and year
      file_name <- stringr::str_match(
        x$attributes$name,
        paste0("^crime_open_database_(core|extended|sample)_(.+)_(\\d+).Rds$")
      ) %>%
        as.character()

      # extract city_name
      city_name <- stringr::str_to_title(
        stringr::str_replace_all(file_name[3], "_", " ")
      )
      if (city_name == "All") {
        city_name <- "all cities"
      }

      # return a list of data for this file
      list(
        data_type = file_name[2],
        city = city_name,
        year = file_name[4],
        file_url = x$links$download
      )

    })

    # combine the new data with any existing data
    values <- rbind(values, result)

    # update the URL to the next page (or NULL if this is the last page)
    page_url <- json$links[["next"]]

  }

  # convert year from character to integer
  values$year <- as.integer(values$year)

  # return tibble of links
  dplyr::arrange(values, .data$data_type, .data$city, .data$year)

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
#' @import dplyr
list_crime_data <- function (quiet = FALSE) {

  dplyr::select(
    dplyr::mutate(
      dplyr::summarise(
        dplyr::group_by(get_file_urls(quiet = quiet), .data$city),
        year_min = min(.data$year),
        year_max = max(.data$year)
      ),
      years = paste(.data$year_min, "to", .data$year_max)
    ),
    .data$city, .data$years
  )

}
