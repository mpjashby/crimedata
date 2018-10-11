context("Test function to get crime data")

test_that("return value of get_crime_data is a tibble", {
  expect_is(get_crime_data(), "tbl_df")
})
