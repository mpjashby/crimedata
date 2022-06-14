# download data and extract thefts of motor vehicles in NYC

nycvehiclethefts <- crimedata::get_crime_data(years = 2014:2017,
                                              cities = "New York",
                                              type = "core") %>%
  dplyr::filter(offense_group == "motor vehicle theft") %>%
  dplyr::select(-offense_code, -offense_type, -offense_group, -offense_against,
                -city_name) %>%
  dplyr::glimpse()

devtools::use_data(nycvehiclethefts, overwrite = TRUE)
