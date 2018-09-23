# Change Log

All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/) and
[Keep a CHANGELOG](http://keepachangelog.com).


## Unreleased

### Added

- evaluation of `DISTINCT`

### Changed

- various refinements of default prefixes
	- renamed the query-specific default prefixes option from `prefixes` to `default_prefixes`
	- setting `none` on the `default_prefixes` option, removes the standard application-wide
	  configured default prefixes
	- `SPARQL.Processor.query` (and the `SPARQL.execute_query` alias) pass options
	  down `SPARQL.Query.new/2`, so it can also used with `default_prefixes`

[Compare v0.2.2...HEAD](https://github.com/marcelotto/sparql-ex/compare/v0.2.2...HEAD)



## 0.2.2 - 2018-09-22

### Added

- application-wide and query-specific ways to define default prefixes 

### Fixed

- bug in the lexer grammar which caused a scanner error on lowercase `distinct`

[Compare v0.2.1...v0.2.2](https://github.com/marcelotto/sparql-ex/compare/v0.2.1...v0.2.2)



## 0.2.1 - 2018-09-17

### Fixed

- generated Erlang output files of Leex and Yecc are excluded from Hex package, 
  which caused issues using the SPARQL.ex Hex package on OTP < 21
  (because the package was released with OTP 21)

[Compare v0.2.0...v0.2.1](https://github.com/marcelotto/sparql-ex/compare/v0.2.0...v0.2.1)



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
