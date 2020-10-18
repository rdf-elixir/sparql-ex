<img src="sparql-logo.png" align="right" />

# SPARQL.ex

[![CI](https://github.com/rdf-elixir/sparql-ex/workflows/CI/badge.svg?branch=master)](https://github.com/rdf-elixir/sparql-ex/actions?query=branch%3Amaster+workflow%3ACI)
[![Hex.pm](https://img.shields.io/hexpm/v/sparql.svg?style=flat-square)](https://hex.pm/packages/sparql)


An implementation of the [SPARQL] standards for Elixir.

It allows to execute SPARQL queries against [RDF.ex] data structures. With the separate [SPARQL.Client] package SPARQL queries can be executed against SPARQL protocol endpoints.

The API documentation can be found [here](https://hexdocs.pm/sparql/). For a guide and more information about SPARQL.ex and it's related projects, go to <https://rdf-elixir.dev>.


## Current state

Note: **The [SPARQL.Client] supports the full SPARQL 1.1 query language**. The missing query language features in the following list are just not yet supported **by the query engine** executing queries against RDF.ex data structures.

- [ ] SPARQL 1.1 Query Language
    - [x] Basic Graph Pattern matching
    - [x] Group Graph Pattern matching
    - [x] Optional Graph Pattern matching via `OPTIONAL`
    - [x] Alternative Graph Pattern matching via `UNION`
    - [ ] Pattern matching on Named Graphs via `FROM` and `GRAPH`
    - [ ] Solution sequence modification
        - [x] Projection with the `SELECT` clause
        - [x] Assignments to variables in the `SELECT` clause
        - [x] `DISTINCT`
        - [x] `REDUCED`
        - [ ] `ORDER BY`
        - [ ] `OFFSET`
        - [ ] `LIMIT`
    - [x] Restriction of solutions via `FILTER`
    - [x] All builtin functions specified in SPARQL 1.0 and 1.1
    - [x] Ability to define extension functions
    - [x] All XPath constructor functions as specified in the SPARQL 1.1 spec
    - [x] Assignments via `BIND`
    - [x] Negation via `MINUS`
    - [ ] Negation via `NOT EXIST`
    - [ ] Inline Data via `VALUES`
    - [ ] Aggregates via `GROUP BY` and `HAVING`
    - [ ] Subqueries
    - [ ] Property Paths
    - [ ] `ASK` query form
    - [ ] `DESCRIBE` query form
    - [x] `CONSTRUCT` query form
- [ ] SPARQL 1.1 Update
- [x] SPARQL Query Results XML Format
- [x] SPARQL 1.1 Query Results JSON Format
- [x] SPARQL 1.1 Query Results CSV and TSV Formats
- [x] SPARQL 1.1 Protocol (currently client-only; in a separate package: [sparql_client](https://github.com/rdf-elixir/sparql_client))
- [ ] SPARQL 1.1 Graph Store HTTP Protocol
- [ ] SPARQL 1.1 Service Description
- [ ] SPARQL 1.1 Federated Query
- [ ] SPARQL 1.1 Entailment Regimes

Other features on the roadmap:

- [ ] parallelization of the query execution
- [ ] query DSL



## Contributing

see [CONTRIBUTING](CONTRIBUTING.md) for details.


## Consulting and Partnership

If you need help with your Elixir and Linked Data projects, just contact <info@cokron.com> or visit <https://www.cokron.com/kontakt>


## License and Copyright

(c) 2018-2020 Marcel Otto. MIT Licensed, see [LICENSE](LICENSE.md) for details.


[SPARQL]:               http://www.w3.org/TR/sparql11-overview/
[SPARQL.ex]:            https://hex.pm/packages/sparql
[SPARQL.Client]:        https://hex.pm/packages/sparql_client
[RDF.ex]:               https://hex.pm/packages/rdf
