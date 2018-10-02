#' Get URLs for Open Crime Database files
#'
#' URLs are either obtained from the OSF API or, if a cached version exists,
#' from the cache.
#'
#' @export
#'
#' @import digest
get_file_urls <- function () {

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

    message("Using cached URLs to get data from server. These URLs rarely ",
            "change and this is almost certainly safe.", appendLF = TRUE)

  } else {

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
#' @export
#'
#' @import httr
#' @import tibble
#' @import purrr
#' @import stringr
fetch_file_urls <- function () {

  # create an empty tibble in which to store the result
  values <- tibble::tibble(type = character(), year = character(),
                           file_url = character())

  # specify the URL of the API end point
  page_url <- paste0("https://api.osf.io/v2/nodes/zyaqn/files/osfstorage/",
                     "5b2ceceed65eaa0011d95f95/?format=json")

  # fetch paginated results until there are none left, at which point page_url
  # will be NULL
  while (!is.null(page_url)) {

    # get a page of JSON results from the server, throwing an error if the
    # HTTP status suggests a problem
    json <- httr::GET(page_url) %>%
      httr::stop_for_status() %>%
      httr::content(as = "parsed", type = "application/json")

    # extract the data as a tibble
    result <- purrr::map_df(json$data, function (x) {

      # parse the file name into type and year
      file_name <- stringr::str_split(x$attributes$name, "\\.",
                                      simplify = TRUE) %>%
        purrr::pluck(1) %>% stringr::str_split("_", simplify = TRUE)

      # return a list of data for this file
      list(type = file_name[4], year = file_name[5],
           file_url = x$links$download)

    })

    # combine the new data with any existing data
    values <- rbind(values, result)

    # update the URL to the next page (or NULL if this is the last page)
    page_url <- json$links[["next"]]

  }

  # convert year from character to integer
  values$year <- as.integer(values$year)

  # return tibble of links
  values

}
