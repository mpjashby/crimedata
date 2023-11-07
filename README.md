crimedata
================

<!-- badges: start -->

[![CRAN
status](https://www.r-pkg.org/badges/version/crimedata)](https://CRAN.R-project.org/package=crimedata)
[![Lifecycle:
stable](https://img.shields.io/badge/lifecycle-stable-brightgreen.svg)](https://lifecycle.r-lib.org/articles/stages.html#stable)
<!-- badges: end -->

The goal of crimedata is to access police-recorded crime data from large
US cities using the [Crime Open Database](https://osf.io/zyaqn/) (CODE),
a service that provides these data in a convenient format for analysis.
All the data are available to use for free as long as you acknowledge
the source of the data.

The function `get_crime_data()` returns a
[tidy](https://CRAN.R-project.org/package=tidyr) data
[tibble](https://CRAN.R-project.org/package=tibble) or [simple features
(SF) object](https://CRAN.R-project.org/package=sf) of crime data with
each row representing a single crime. The data provided for each offense
includes the offense type, approximate offense location and date/time.
More fields are available for some records, depending on what data have
been released by each city. For most cities, data are available from
2010 onward, with some available back to 2007. Use `list_crime_data()`
to see which years are available for which cities.

More detail about what data are available, how they were constructed and
the meanings of the different categories can be found on the [CODE
project website](https://osf.io/zyaqn/). Further detail is available in
the paper [Studying Crime and Place with the Crime Open
Database](https://doi.org/10.1163/24523666-00401007).

## Installation

You can install the crimedata package with:

``` r
install.packages("crimedata")
```

You can install the latest development version of the crimedata package
from GitHub with:

``` r
# install.packages("remotes")
remotes::install_github("mpjashby/crimedata")
```

## Examples

Data can be downloaded by year and by city. By default (i.e. if no
arguments are specified) a 1% sample of data for all cities for the most
recent available year is returned.

``` r
library(crimedata)

crime_data <- get_crime_data()
```

The data are in a tidy format, so can be quickly manipulated using
[dplyr](https://CRAN.R-project.org/package=dplyr) verbs. For example, to
analyze two years of personal robberies in Chicago and Detroit, you can
run:

``` r
suppressPackageStartupMessages(library(tidyverse))

personal_robberies <- get_crime_data(
  years = 2009:2010, 
  cities = c("Chicago", "Detroit"), 
  type = "core",
  quiet = TRUE
) %>% 
  filter(offense_type == "personal robbery")
```

You can alternatively get a [simple features
(SF)](https://r-spatial.github.io/sf/articles/sf1.html) point object
with the correct co-ordinates and co-ordinate reference system (CRS)
specified by setting the argument `output = "sf"`. This can be used, for
example, to quickly plot the data.

``` r
suppressPackageStartupMessages(library(lubridate))

get_crime_data(
  cities = "Fort Worth", 
  years = 2014:2017, 
  type = "core",
  quiet = TRUE,
  output = "sf"
) %>% 
  filter(offense_group == "homicide offenses") %>% 
  mutate(offense_year = year(date_single)) %>% 
  ggplot() + 
  geom_sf() +
  facet_wrap(vars(offense_year), nrow = 1)
#> Warning: Unknown columns: `location_type`
```

<div class="figure">

<img src="man/figures/README-crimedata_sf_example-1.png" alt="plot of chunk crimedata_sf_example" width="100%" />
<p class="caption">
plot of chunk crimedata_sf_example
</p>

</div>

## Included data

The package includes two datasets. `homicides15` contains records of
1,922 recorded homicides in nine US cities in 2015. `nycvehiclethefts`
contains records of 35,746 thefts of motor vehicles in New York City
from 2014 to 2017. These may be particularly useful for teaching
purposes.
