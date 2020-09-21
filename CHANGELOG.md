# Change Log

All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/) and
[Keep a CHANGELOG](http://keepachangelog.com).


## v0.3.6 - 2020-09-21

### Fixed

- The JSON query result decoder didn't recognize the datatype of literals when the JSON
  value object was `"type" : "literal"`. Only for those with `"typed-literal"` the `"datatype"` 
  field was interpreted.    
- Not all IRI values in CSV results were recognized as IRIs. Values starting with the most
  common URI schemes (http/https, urn, ftp, file, ldap, mailto, geo, data) are now recognized 
  correctly. 

[Compare v0.3.5...v0.3.6](https://github.com/rdf-elixir/sparql-ex/compare/v0.3.5...v0.3.6)



## v0.3.5 - 2020-06-01

### Changed

- Upgrade to RDF.ex 0.8. With that Elixir versions < 1.8 are no longer supported.
- the SPARQL extension function registry is now implemented with the ProtocolEx library,
  improving the performance of queries using SPARQL extension functions (including the 
  builtin casting functions); unfortunately this means the `SPARQL.ExtensionFunction.Registry.get_all/0`
  function to get all registered extension functions can no longer be supported 

[Compare v0.3.4...v0.3.5](https://github.com/rdf-elixir/sparql-ex/compare/v0.3.4...v0.3.5)



## v0.3.4 - 2019-12-14

- Upgrade to RDF.ex 0.7

[Compare v0.3.3...v0.3.4](https://github.com/rdf-elixir/sparql-ex/compare/v0.3.3...v0.3.4)



## v0.3.3 - 2019-10-25

### Fixed

- a bug in the BGP processing algorithm lead to wrong solutions when one triple 
  pattern in a BGP had no solutions 


[Compare v0.3.2...v0.3.3](https://github.com/rdf-elixir/sparql-ex/compare/v0.3.2...v0.3.3)



## v0.3.2 - 2019-09-08

### Added

- `no_extension_detection_in_releases_warning` configuration which disables the  
  warning that not all extension functions may be detected in a release with the
  runtime system in interactive mode

### Fixed

- Raise an error when the query uses an unknown prefix instead of producing an 
  invalid query


[Compare v0.3.1...v0.3.2](https://github.com/rdf-elixir/sparql-ex/compare/v0.3.1...v0.3.2)



## v0.3.1 - 2019-07-15

### Changed

- Use the new `RDF.Literal.matches?/3` function from RDF.ex 0.6.1 for the `REGEX` function
- with the fix from RDF.ex 0.6.1 XSD boolean with uppercase letters in the boolean
  lexical values are no longer valid

### Fixed

- the `true` and `false` keywords from the SPARQL language are case-insensitive
- the new `RDF.Literal.matches?/3` function also fixes some Unicode escaping
  issues in regular expressions


[Compare v0.3.0...v0.3.1](https://github.com/rdf-elixir/sparql-ex/compare/v0.3.0...v0.3.1)



## v0.3.0 - 2019-04-06

### Changed

- Replace the prefix management of SPARQL.ex with the new prefix management 
  capabilities of RDF.ex 0.6
- Use the query prefixes as the prefixes of CONSTRUCTed graphs


[Compare v0.2.9...v0.3.0](https://github.com/rdf-elixir/sparql-ex/compare/v0.2.9...v0.3.0)



## v0.2.9 - 2019-03-06

### Fixed

- the application failed to start in OTP releases (#2)


[Compare v0.2.8...v0.2.9](https://github.com/rdf-elixir/sparql-ex/compare/v0.2.8...v0.2.9)



## v0.2.8 - 2019-02-16

### Added

- Support for negations with `MINUS`


[Compare v0.2.7...v0.2.8](https://github.com/rdf-elixir/sparql-ex/compare/v0.2.7...v0.2.8)



## v0.2.7 - 2018-11-11

### Added

- Support of the `CONSTRUCT` query form

### Fixed

- various fixes on comparisons between `RDF.DateTime`s and `RDF.Date`s  


[Compare v0.2.6...v0.2.7](https://github.com/rdf-elixir/sparql-ex/compare/v0.2.6...v0.2.7)



## v0.2.6 - 2018-10-30

### Added

- Support for alternative graph patterns with `UNION`
- Support for assigning to variables with `BIND`


### Changed

- `REDUCED` no longer removes duplicates without projection (for performance reasons)


### Fixed

- `DISTINCT` did not work without projection


[Compare v0.2.5...v0.2.6](https://github.com/rdf-elixir/sparql-ex/compare/v0.2.5...v0.2.6)



## v0.2.5 - 2018-10-21

### Added

- Support for optional graph patterns via `OPTIONAL`
- Support for the `bound` function

### Fixed

- errors during evaluation of function arguments were handled incorrectly, 
  which led in particular to wrong behaviour of the `COALESCE` function
- `SPARQL.Query.Result.get/2` failed when the given variable was not in the results


[Compare v0.2.4...v0.2.5](https://github.com/rdf-elixir/sparql-ex/compare/v0.2.4...v0.2.5)



## v0.2.4 - 2018-10-06

### Added

- Support for group graph patterns, i.e. nested graph patterns and `FILTER`s in
  the middle of a graph patterns (which splits up a graph pattern)
- `SPARQL.Query.Result.get/2` as a short way for getting the solutions of a 
  single variable

### Fixed

- `FILTER` expressions at the beginning of a graph pattern


[Compare v0.2.3...v0.2.4](https://github.com/rdf-elixir/sparql-ex/compare/v0.2.3...v0.2.4)



## v0.2.3 - 2018-09-23

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

[Compare v0.2.2...v0.2.3](https://github.com/rdf-elixir/sparql-ex/compare/v0.2.2...v0.2.3)



## v0.2.2 - 2018-09-22

### Added

- application-wide and query-specific ways to define default prefixes 

### Fixed

- bug in the lexer grammar which caused a scanner error on lowercase `distinct`

[Compare v0.2.1...v0.2.2](https://github.com/rdf-elixir/sparql-ex/compare/v0.2.1...v0.2.2)



## v0.2.1 - 2018-09-17

### Fixed

- generated Erlang output files of Leex and Yecc are excluded from Hex package, 
  which caused issues using the SPARQL.ex Hex package on OTP < 21
  (because the package was released with OTP 21)

[Compare v0.2.0...v0.2.1](https://github.com/rdf-elixir/sparql-ex/compare/v0.2.0...v0.2.1)



## v0.2.0 - 2018-09-17

### Added

- SPARQL Query engine for executing queries against RDF.ex graphs 
  (not complete yet; see Current state section in README)

### Changed

- Elixir versions < 1.6 are no longer supported
- renamed the `SPARQL.Query.ResultSet` struct to `SPARQL.Query.Result`
- removed the previous `SPARQL.Query.Result` struct for single solutions; these 
  are now represented as simple maps


[Compare v0.1.0...v0.2.0](https://github.com/rdf-elixir/sparql-ex/compare/v0.1.0...v0.2.0)



## v0.1.0 - 2018-03-19

Initial release
