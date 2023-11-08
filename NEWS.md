# crimedata 0.3.5

* Changed how DOI is specified in CITATION file.


# crimedata 0.3.4

* Changed how ORCID is included in package DESCRIPTION file.


# crimedata 0.3.3

* Re-written tests and docs to ensure no errors/warnings are produced during
  automatic testing if API is not available (#13).
* Suppressed progress bars automatically when running non-interactively (#14).
* Removed unnecessary dependency `httr`.


# crimedata 0.3.2

* Update how package-level documentation is signposted for CRAN (#11).


# crimedata 0.3.1

* Fixed an error with downloading some data for 2020 that was caused by a 
  change in the OSF API used to query the data.


# crimedata 0.3.0

* Errors, warnings and messages are now generated using `rlang` to make them
  easier to read.
* The `cities` argument to `get_crime_data()` is now case insensitive.
* Removed dependencies on `magrittr`, `readr` and `tibble`.
* Updated author contact details.


# crimedata 0.2.0

* Added option of returning crime data as an sf object instead of a tibble.
* Categorical variables are now returned as factors and date variables as POSIX
  variables.
* Added vignette introducing the package.
* Fixed a warning generated when requesting data from multiple named cities.


# crimedata 0.1.0

* Added a `NEWS.md` file to track changes to the package.
