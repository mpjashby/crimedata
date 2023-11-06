## R CMD check results

0 errors | 1 warnings | 1 notes

This version deals with a CRAN check error resulting from an API being down, so that the relevant functions now degrade gracefully.

The 1 warning is for a possibly invalid URL <https://orcid.org/0000-0003-4201-9239> that is actually valid.

The 1 note is for a possibly invalid URL https://doi.org/10.1163/24523666-00401007 that produces a 404 error when checked by RHub but resolves as expected in the browser.
