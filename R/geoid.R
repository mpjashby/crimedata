#' Convert Census Block GEOIDs
#'
#' Convert the GEOID of a 2016 US Census block to the name or GEOID for the
#' corresponding state, county, tract or block group.
#'
#' For details of the format of US Census GEOIDs, see
#' \url{https://www.census.gov/geo/reference/geoidentifiers.html}.
#'
#' @param geoid A character vector of 15-digit US Census block GEOIDs.
#' @param to One of "state", "county", "tract", "block group" or (as an alias)
#'   "blockgroup".
#' @param name Should the function return the state/county name rather than FIPS
#'   code?
#'
#' @return A character vector of GEOIDs or names.
#' @export
#'
#' @examples
#' block_geoid_to("360810443021005", to = "county", name = TRUE)
#'
#' @import dplyr
#' @import stringr
block_geoid_to <- function (geoid, to, name = FALSE) {

  # check inputs
  stopifnot(is.character(as.character(geoid)) |
              all(stringr::str_length(as.character(geoid)) == 15))
  stopifnot(is.character(to) | to %in% c("state", "county", "tract",
                                         "block group", "blockgroup"))
  stopifnot(is.logical(name))

  # complain about requesting names for geographies that don't have them
  if (name == TRUE &
      to %in% c("tract", "block group", "blockgroup")) {
    stop("Names are only available for states and counties.")
  }

  if (name == TRUE) {
    if (to == "county") {

      values <- paste0(county_names$name[match(stringr::str_sub(geoid, 0, 5),
                                               county_names$geoid)],
                       ", ",
                       county_names$state[match(stringr::str_sub(geoid, 0, 5),
                                                county_names$geoid)])

    } else if (to == "state") {

      values <- state_names$name[match(stringr::str_sub(geoid, 0, 2),
                                       state_names$geoid)]

    }

  } else {
    # identify how many characters of the geoid to keep
    output_length <- dplyr::case_when(
      to == "state" ~ 2,
      to == "county" ~ 5,
      to == "tract" ~ 11,
      to %in% c("block group", "blockgroup") ~ 12
    )

    # extract required number of digits
    values <- stringr::str_sub(geoid, 0, output_length)

  }

  # return result
  values

}

#' @rdname block_geoid_to
block_geoid_to_state <- function(geoid, name = TRUE) {

  block_geoid_to(geoid, to = "state", name = name)

}

#' @rdname block_geoid_to
block_geoid_to_county <- function(geoid, name = TRUE) {

  block_geoid_to(geoid, to = "county", name = name)

}

#' @rdname block_geoid_to
block_geoid_to_tract <- function(geoid) {

  block_geoid_to(geoid, to = "tract", name = FALSE)

}

#' @rdname block_geoid_to
block_geoid_to_block_group <- function(geoid) {

  block_geoid_to(geoid, to = "block group", name = FALSE)

}
