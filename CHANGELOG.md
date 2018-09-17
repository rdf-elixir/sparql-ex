# Change Log

All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/) and
[Keep a CHANGELOG](http://keepachangelog.com).


## 0.2.1 - 2018-09-17

### Fixed

- generated Erlang output files of Leex and Yecc are excluded from Hex package, 
  which caused issues using the SPARQL.ex Hex package on OTP < 21
  (because the package was released with OTP 21)

[Compare v0.2.0...v0.2.1](https://github.com/marcelotto/rdf-ex/compare/v0.2.0...v0.2.1)



## 0.2.0 - 2018-09-17

### Added

- SPARQL Query engine for executing queries against RDF.ex graphs 
  (not complete yet; see Current state section in README)

### Changed

- Elixir versions < 1.6 are no longer supported
- renamed the `SPARQL.Query.ResultSet` struct to `SPARQL.Query.Result`
- removed the previous `SPARQL.Query.Result` struct for single solutions; these 
  are now represented as simple maps


[Compare v0.1.0...v0.2.0](https://github.com/marcelotto/sparql-ex/compare/v0.1.0...v0.2.0)



## v0.1.0 - 2018-03-19

Initial release
