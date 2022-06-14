# create tibbles of 2016 state and county census codes and names for looking up
# names from geoids

library("magrittr")



# STATES

# download remote file

state_names <- readr::read_delim(paste0("https://www2.census.gov/geo/docs/",
                                        "reference/state.txt"), delim = "|") %>%
  dplyr::select(geoid = STATE, name = STATE_NAME, abbr = STUSAB)



# COUNTIES

# set name for temporary file
temp_file <- tempfile(fileext = ".zip")

# download remote file
httr::GET(paste0("http://www2.census.gov/geo/docs/maps-data/data/gazetteer/",
                 "2016_Gazetteer/2016_Gaz_counties_national.zip")) %>%
  httr::content(as = "raw") %>%
  writeBin(temp_file)

# unzip file
unzip(temp_file, exdir = tempdir())

# read file
county_names <- readr::read_tsv(paste0(tempdir(),
                                       "/2016_Gaz_counties_national.txt")) %>%
  dplyr::select(geoid = GEOID, name = NAME, state = USPS)



# add data to package
devtools::use_data(state_names, county_names, overwrite = TRUE, internal = TRUE)
