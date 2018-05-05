# Change Log

All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/) and
[Keep a CHANGELOG](http://keepachangelog.com).


## Unreleased

### Added

- SPARQL algebra representation and evaluation of queries against RDF data structures


### Changed

- renamed the `SPARQL.Query.ResultSet` struct to `SPARQL.Query.Result`
- removed the previous `SPARQL.Query.Result` struct for single solutions; these 
  are now represented as simple maps


[Compare v0.1.0...HEAD](https://github.com/marcelotto/sparql-ex/compare/v0.1.0...HEAD)



## v0.1.0 - 2018-03-19

Initial release
