context("Test of functions in file_urls.R")

test_that("return value of get_file_urls is a tibble", {
  skip_if_offline()
  expect_is(get_file_urls(), "tbl_df")
})

test_that("type column of return value contains only valid values", {
  skip_if_offline()
  expect_is(get_file_urls()[["data_type"]], "character")
  expect_match(get_file_urls()[["data_type"]], "(core|extended|sample)")
})

test_that("year column of return value contains only valid integer years", {
  skip_if_offline()
  expect_is(get_file_urls()[["year"]], "integer")
  expect_gte(min(get_file_urls()[["year"]]), as.integer(2000))
  expect_lt(max(get_file_urls()[["year"]]),
            as.integer(format(Sys.Date(), "%Y")))
})

test_that("return value of list_crime_data is a tibble", {
  skip_if_offline()
  expect_is(list_crime_data(), "data.frame")
})
