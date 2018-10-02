# download data and extract thefts of motor vehicles in NYC

nycvehiclethefts <- crimedata::get_crime_data(years = 2014:2017,
                                              type = "core") %>%
  dplyr::filter(offense_group == "motor vehicle theft",
                city_name == "New York") %>%
  dplyr::select(-local_row_id, -case_number, -offense_code, -offense_type,
                -offense_group, -offense_against, -city_name, -address) %>%
  dplyr::glimpse()

devtools::use_data(nycvehiclethefts, overwrite = TRUE)
