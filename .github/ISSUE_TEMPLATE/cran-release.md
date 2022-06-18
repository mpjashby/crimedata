---
name: CRAN release
about: Checklist of actions in preparation for submission to CRAN
title: ''
labels: release
assignees: mpjashby

---

These checks should be run **in this order** before submitting to CRAN. If any of these tests finds further work is needed on the package, start the checklist again from scratch.

- [ ] `urlchecker::url_check()`
- [ ]  `devtools::document()`
- [ ] `pkgdown::build_site()`
- [ ] `devtools::spell_check()`
- [ ] `devtools::check()`
- [ ] `devtoolls::check_rhub()`
- [ ] `devtools::check_win_devel()`
- [ ] update `NEWS.md`
- [ ] update `DESCRIPTION`, including incrementing version number
- [ ] update `cran-comments.md`
- [ ] push any uncommitted files

Finally, to submit to CRAN run `devtools::release()`.
