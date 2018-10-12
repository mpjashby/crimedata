# crimedata

The goal of crimedata is to access police-recorded crime data from large US 
cities using the [Open Crime Database](https://osf.io/zyaqn/) (CODE), a service 
that provides these data in a convenient format for analysis. All the data are 
available to use for free as long as you acknowledge the source of the data.

The function `get_crime_data()` returns a [tidy](https://CRAN.R-project.org/package=tidyr) 
data [tibble](https://CRAN.R-project.org/package=tibble)
of crime data with each row representing a single crime. The data provided for
each offense includes the offense type, approximate offense location and 
date/time. More fields are available for some records, depending on what data
have been released by each city. For most cities, data are available from 2010
onwards, with some available back to 2007. Use `list_crime_data()` to see which
years are available for which cities.

More detail about what data are available, how they were constructed and the
meanings of the different categories can be found on the [CODE project 
website](https://osf.io/zyaqn/). Further detail is available in a [pre-print
data paper](https://doi.org/10.31235/osf.io/9y7qz).


## Installation

You can install crimedata from github with:

``` r
# install.packages("devtools")
devtools::install_github("mpjashby/crimedata")
```


## Examples

Data can be downloaded by year and by city. By default (i.e. if no arguments are
specified) a 1% sample of data for all cities for the most recent available year 
is returned.

``` r
library(crimedata)

crime_data <- get_crime_data()
```

The data are in a tidy format, so can be quickly manipulated using 
[dplyr](https://CRAN.R-project.org/package=dplyr) verbs. For example, to analyse 
two years of personal robberies in Chicago and Detroit, you can run:

``` r
chicago_robberies <- get_crime_data(
  years = 2009:2010, 
  cities = c("Chicago", "Detroit"), 
  type = "core"
) %>% 
  filter(offense_type == "personal robbery")
```


## Included data

The package includes two datasets. `homicides15` contains records of 1,922 
recorded homicides in nine US cities in 2015. `nycvehiclethefts` contains 
records of 35,746 thefts of motor vehicles in New York City from 2014 to 2017.
These may be particularly useful for teaching purposes.


[![Travis-CI Build Status](https://travis-ci.org/mpjashby/crimedata.svg?branch=master)](https://travis-ci.org/mpjashby/crimedata)
