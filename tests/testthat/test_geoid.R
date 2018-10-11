context("Test lookup for census GEOIDs")

test_that("return value of block_geoid_to is a character vector", {
  expect_is(block_geoid_to("360810443021005", to = "state"), "character")
})

test_that("return values are correct", {
  expect_equal(block_geoid_to("360810443021005", to = "state"), "36")
  expect_equal(block_geoid_to("360810443021005", to = "state", name = TRUE),
               "New York")
  expect_equal(block_geoid_to("360810443021005", to = "county"), "36081")
  expect_equal(block_geoid_to("360810443021005", to = "county", name = TRUE),
               "Queens County, NY")
  expect_equal(block_geoid_to("360810443021005", to = "tract"), "36081044302")
  expect_equal(block_geoid_to("360810443021005", to = "block group"),
               "360810443021")
  expect_equal(block_geoid_to("360810443021005", to = "blockgroup"),
               "360810443021")
  expect_equal(block_geoid_to_state("360810443021005"), "New York")
  expect_equal(block_geoid_to_state("360810443021005", name = FALSE), "36")
  expect_equal(block_geoid_to_county("360810443021005"), "Queens County, NY")
  expect_equal(block_geoid_to_county("360810443021005", name = FALSE), "36081")
  expect_equal(block_geoid_to_tract("360810443021005"), "36081044302")
  expect_equal(block_geoid_to_block_group("360810443021005"), "360810443021")
})

test_that("requests to return names for tracts and block groups give errors", {
  expect_error(block_geoid_to("360810443021005", to = "tract", name = TRUE))
  expect_error(block_geoid_to("360810443021005", to = "block group",
                              name = TRUE))
  expect_error(block_geoid_to("360810443021005", to = "blockgroup",
                              name = TRUE))
})
