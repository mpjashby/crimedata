context("Test function to get crime data")

test_that("return value of get_crime_data is a tibble or SF object", {
  expect_is(get_crime_data(), "tbl_df")
  expect_is(get_crime_data(output = "sf"), "sf")
})

test_that("incorrect arguments produce errors", {

  # Arguments of the wrong type
  expect_error(get_crime_data(type = "blah"))
  expect_error(get_crime_data(years = 2019.5))
  expect_error(get_crime_data(quiet = "blah"))

  # Arguments of the wrong length
  expect_error(get_crime_data(type = character(0)))
  expect_error(get_crime_data(years = integer(0)))
  expect_error(get_crime_data(quiet = logical(0)))

  # Argument specifying non-existent data
  expect_error(
    get_crime_data(years = 1990:1995),
    "One or more of the requested years"
  )
  expect_error(
    get_crime_data(cities = "non-existant city"),
    "Data is not available for one or more of the specified cities"
  )

  # Data for Virginia Beach are only available from 2013 onwards
  expect_error(
    get_crime_data(cities = "Virginia Beach", years = 2007),
    "The Crime Open Database does not contain data for any"
  )
})

test_that("partially missing data produce warnings", {
  # 2012 is not present in the data but 2013 is, so this should produce a
  # warning rather than an error
  expect_warning(
    get_crime_data(cities = "Virginia Beach", years = 2012:2013),
    "Data are not available for crimes in"
  )
})

test_that("quiet execution does not return any messages", {
  # Testing for an NA message allows testing for the absence of a message, as
  # per https://stackoverflow.com/q/10826365/8222654
  expect_message(get_crime_data(years = 2019, quiet = TRUE), NA)
})

test_that("data cache works as expected", {

  # get data, which should then be cached
  get_crime_data(cities = "Detroit")

  # request data again and check if it is retrieved from the cache
  expect_message(
    get_crime_data(cities = "Detroit"),
    "Loading cached data"
  )

  # request data again, forcing download from server
  expect_message(
    get_crime_data(cities = "Detroit", cache = FALSE),
    "Deleting cached data"
  )
})
