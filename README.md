# SPARQL.ex

[![Travis](https://img.shields.io/travis/marcelotto/sparql-ex.svg?style=flat-square)](https://travis-ci.org/marcelotto/sparql-ex)
[![Hex.pm](https://img.shields.io/hexpm/v/sparql.svg?style=flat-square)](https://hex.pm/packages/sparql)


An implementation of the [SPARQL] standards for Elixir.

Currently, this package is not very useful on its own. It contains just the necessary parts to make the [SPARQL.Client] work. You'll find more useful information [there](https://github.com/marcelotto/sparql_client).

## Current state

- [x] SPARQL 1.1 Query Language (in progress; currently just the language parser)
- [ ] SPARQL 1.1 Update
- [x] SPARQL Query Results XML Format
- [x] SPARQL 1.1 Query Results JSON Format
- [x] SPARQL 1.1 Query Results CSV and TSV Formats
- [x] SPARQL 1.1 Protocol (in a separate package: [sparql_client](https://github.com/marcelotto/sparql_client))
- [ ] SPARQL 1.1 Graph Store HTTP Protocol
- [ ] SPARQL 1.1 Service Description
- [ ] SPARQL 1.1 Federated Query
- [ ] SPARQL 1.1 Entailment Regimes

## Installation

The [SPARQL.ex] Hex package can be installed as usual, by adding `sparql` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:sparql, "~> 0.1"}]
end
```

## Getting help

- [Documentation](http://hexdocs.pm/sparql)
- [Google Group](https://groups.google.com/d/forum/rdfex)


## Contributing

see [CONTRIBUTING](CONTRIBUTING.md) for details.


## License and Copyright

(c) 2018 Marcel Otto. MIT Licensed, see [LICENSE](LICENSE.md) for details.


[SPARQL]:               http://www.w3.org/TR/sparql11-overview/
[SPARQL.ex]:            https://hex.pm/packages/sparql
[SPARQL.Client]:        https://hex.pm/packages/sparql_client
[RDF.ex]:               https://hex.pm/packages/rdf
