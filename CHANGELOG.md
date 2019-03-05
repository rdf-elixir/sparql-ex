# Change Log

All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/) and
[Keep a CHANGELOG](http://keepachangelog.com).


## 0.2.9 - 2019-03-06

### Fixed

- the application failed to start in OTP releases (#2)


[Compare v0.2.8...v0.2.9](https://github.com/marcelotto/sparql-ex/compare/v0.2.8...v0.2.9)



## 0.2.8 - 2019-02-16

### Added

- Support for negations with `MINUS`


[Compare v0.2.7...v0.2.8](https://github.com/marcelotto/sparql-ex/compare/v0.2.7...v0.2.8)



## 0.2.7 - 2018-11-11

### Added

- Support of the `CONSTRUCT` query form

### Fixed

- various fixes on comparisons between `RDF.DateTime`s and `RDF.Date`s  


[Compare v0.2.6...v0.2.7](https://github.com/marcelotto/sparql-ex/compare/v0.2.6...v0.2.7)



## 0.2.6 - 2018-10-30

### Added

- Support for alternative graph patterns with `UNION`
- Support for assigning to variables with `BIND`


### Changed

- `REDUCED` no longer removes duplicates without projection (for performance reasons)


### Fixed

- `DISTINCT` did not work without projection


[Compare v0.2.5...v0.2.6](https://github.com/marcelotto/sparql-ex/compare/v0.2.5...v0.2.6)



## 0.2.5 - 2018-10-21

### Added

- Support for optional graph patterns via `OPTIONAL`
- Support for the `bound` function

### Fixed

- errors during evaluation of function arguments were handled incorrectly, 
  which led in particular to wrong behaviour of the `COALESCE` function
- `SPARQL.Query.Result.get/2` failed when the given variable was not in the results


[Compare v0.2.4...v0.2.5](https://github.com/marcelotto/sparql-ex/compare/v0.2.4...v0.2.5)



## 0.2.4 - 2018-10-06

### Added

- Support for group graph patterns, i.e. nested graph patterns and `FILTER`s in
  the middle of a graph patterns (which splits up a graph pattern)
- `SPARQL.Query.Result.get/2` as a short way for getting the solutions of a 
  single variable

### Fixed

- `FILTER` expressions at the beginning of a graph pattern


[Compare v0.2.3...v0.2.4](https://github.com/marcelotto/sparql-ex/compare/v0.2.3...v0.2.4)



## 0.2.3 - 2018-09-23

### Added

- evaluation of `DISTINCT` and `REDUCED` (the later having the semantics as 
  `DISTINCT`, i.e. no optimizations right now)
- implementation of `String.Chars` protocol on `SPARQL.Query`

### Changed

- various refinements of default prefixes
	- renamed the query-specific default prefixes option from `prefixes` to `default_prefixes`
	- setting `none` on the `default_prefixes` option, removes the standard application-wide
	  configured default prefixes
	- `SPARQL.Processor.query` (and the `SPARQL.execute_query` alias) pass options
	  down `SPARQL.Query.new/2`, so it can also used with `default_prefixes`

[Compare v0.2.2...v0.2.3](https://github.com/marcelotto/sparql-ex/compare/v0.2.2...v0.2.3)



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
