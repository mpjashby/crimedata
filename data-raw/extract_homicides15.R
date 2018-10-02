# download data and extract homicides for 2015

homicides15 <- crimedata::get_crime_data(years = 2015, type = "core") %>%
  dplyr::filter(offense_group == "homicide offenses") %>%
  dplyr::select(-local_row_id, -case_number, -offense_group, -offense_against,
                -date_start, -date_end)

devtools::use_data(homicides15, overwrite = TRUE)
