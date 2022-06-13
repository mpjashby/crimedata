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
block_geoid_to <- function (geoid, to, name = FALSE) {

  # Check inputs
  if (!rlang::is_character(as.character(geoid)))
    rlang::abort("`geoid` must be a character vector.")
  if (any(stringr::str_length(as.character(geoid)) != 15))
    rlang::abort("Values in `geoid` must be 15 characters long.")
  rlang::arg_match(
    to,
    values = c("state", "county", "tract", "block group", "blockgroup")
  )
  if (!rlang::is_logical(name, n = 1))
    rlang::abort("`name` must be one of `TRUE` or `FALSE`")

  # Complain about requesting names for geographies that don't have them
  if (name == TRUE & !to %in% c("state", "county"))
    rlang::abort("Names are only available for states and counties.")

  if (name == TRUE) {

    if (to == "county") {

      values <- paste0(
        county_names$name[
          match(stringr::str_sub(geoid, 0, 5), county_names$geoid)
        ],
        ", ",
        county_names$state[
          match(stringr::str_sub(geoid, 0, 5), county_names$geoid)
        ]
      )

    } else if (to == "state") {

      values <- state_names$name[
        match(stringr::str_sub(geoid, 0, 2), state_names$geoid)
      ]

    }

  } else {

    # Identify how many characters of `geoid` to keep
    output_length <- ifelse(
      to == "state",
      2,
      ifelse(
        to == "county",
        5,
        ifelse(
          to == "tract",
          11,
          ifelse(to %in% c("block group", "blockgroup"), 12, NA_real_)
        )
      )
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
