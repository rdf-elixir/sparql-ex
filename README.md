# SPARQL.ex

[![Travis](https://img.shields.io/travis/marcelotto/sparql-ex.svg?style=flat-square)](https://travis-ci.org/marcelotto/sparql-ex)
[![Hex.pm](https://img.shields.io/hexpm/v/sparql.svg?style=flat-square)](https://hex.pm/packages/sparql)


An implementation of the [SPARQL] standards for Elixir.

It allows to execute SPARQL queries against [RDF.ex] data structures. With the separate [SPARQL.Client] package SPARQL queries can be executed against SPARQL protocol endpoints.



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
    - [ ] Negation via `NOT EXIST`
    - [ ] Negation via `MINUS`
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
- [x] SPARQL 1.1 Protocol (currently client-only; in a separate package: [sparql_client](https://github.com/marcelotto/sparql_client))
- [ ] SPARQL 1.1 Graph Store HTTP Protocol
- [ ] SPARQL 1.1 Service Description
- [ ] SPARQL 1.1 Federated Query
- [ ] SPARQL 1.1 Entailment Regimes

Other features on the roadmap:

- [ ] parallelization of the query execution
- [ ] query DSL



## Installation

The [SPARQL.ex] Hex package can be installed as usual, by adding `sparql` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:sparql, "~> 0.2"}]
end
```



## Usage

### Executing queries

Let's say we have an RDF.ex graph like this:

```elixir
graph = RDF.Turtle.read_string! """
  @prefix foaf:  <http://xmlns.com/foaf/0.1/> .
  
  _:a  foaf:name   "Johnny Lee Outlaw" .
  _:a  foaf:mbox   <mailto:jlow@example.com> .
  _:b  foaf:name   "Peter Goodguy" .
  _:b  foaf:mbox   <mailto:peter@example.org> .
  _:c  foaf:mbox   <mailto:carol@example.org> .
  """
```


We can execute the following SPARQL query:

```elixir
query = """
  PREFIX foaf:   <http://xmlns.com/foaf/0.1/>
  SELECT ?name ?mbox
  WHERE
    { ?x foaf:name ?name .
      ?x foaf:mbox ?mbox }
  """
```

like this:

```elixir
SPARQL.execute_query(graph, query)
```

This will return a `SPARQL.Query.Result` struct which contains the results under the `results` field as a list of maps with the bindings of the solutions.

```elixir
%SPARQL.Query.Result{
  results: [
    %{"mbox" => ~I<mailto:peter@example.org>, "name" => ~L"Peter Goodguy"},
    %{"mbox" => ~I<mailto:jlow@example.com>, "name" => ~L"Johnny Lee Outlaw"}
  ],
  variables: ["name", "mbox"]
}
```

The list of results for a single variable can be fetched with the `SPARQL.Query.Result.get/2` function.

```elixir
SPARQL.execute_query(graph, query) 
|> SPARQL.Query.Result.get(:mbox)
```

If `SPARQL.execute_query/2` is used to execute a `CONSTRUCT` query, it will return an `RDF.Graph`:

```elixir
iex> SPARQL.execute_query graph, """
...>  PREFIX foaf:   <http://xmlns.com/foaf/0.1/>
...>  PREFIX schema: <http://schema.org/>
...>  CONSTRUCT   
...>    { ?x schema:name ?name ;
...>         schema:email ?mbox }
...>  WHERE
...>    { ?x foaf:name ?name ;
...>         foaf:mbox ?mbox }
...>  """
#RDF.Graph{name: nil
     ~B<b0>
         ~I<http://schema.org/email>
             ~I<mailto:peter@example.org>
         ~I<http://schema.org/name>
             ~L"Peter Goodguy" 
     ~B<b1>
         ~I<http://schema.org/email>
             ~I<mailto:jlow@example.com>
         ~I<http://schema.org/name>
             ~L"Johnny Lee Outlaw"}
```

The `SPARQL.execute_query/2` function converts a given query string implicitly to a `SPARQL.Query` struct. If you intend to execute the query multiple times it's better to do this step on your own with the `SPARQL.query/1` function and pass the interpreted query directly to `SPARQL.execute_query/2`, in order to not parse the query on every execution.

```elixir
query = SPARQL.query """
  PREFIX foaf: <http://xmlns.com/foaf/0.1/>
  SELECT ?name ?mbox
  WHERE
    { ?x foaf:name ?name .
      ?x foaf:mbox ?mbox }
  """

SPARQL.execute_query(graph, query)
```

By default the following prefixes are defined before every query:

```sparql
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
```

You can define further application-wide default prefixes via the `default_prefixes` configuration parameter and providing a map of prefixes to IRIs:

```elixir
config :sparql,
  default_prefixes: %{
    ex: "http://example.com/ns/"
  }
```

Further query-specific prefixes can be defined with the `default_prefixes` option on the `SPARQL.query/1` function which also expects a prefixes map. By using the `default_prefixes` option with the value `none`, the standard application-configured will not be used for a query.


### Defining extension functions

The SPARQL query language has a specified way for the introduction of custom [extension functions](https://www.w3.org/TR/sparql11-query/#extensionFunctions). An extension function for a function with the name `http://example.com/fun` can be defined in SPARQL.ex like this:

```elixir
defmodule ExampleFunction do
  use SPARQL.ExtensionFunction, name: "http://example.com/fun"

  def call(distinct, arguments, _, execution) do
    # your implementation
  end
end
```

The name of the module is arbitrary and has no further meaning. The first argument `distinct` is a boolean flag telling, if the function was called with the `DISTINCT` keyword, which is syntactically allowed in custom aggregate function calls only. The `arguments` argument is the list of already evaluated RDF terms with which the extension function was called in the SPARQL query. The ignored third argument contains the currently evaluated solution and some other internal information and shouldn't be relied upon. Since the arguments are already evaluated against the current solution, this shouldn't be necessary anyway. The `execution` argument is a map with some global query execution context information. In particular:

- `base`: the base IRI
- `time`: the query execution time
- `bnode_generator`: the name of the `RDF.BlankNode.Generator` (see [RDF.ex documentation](http://hexdocs.pm/rdf)) used to generate unique blank nodes consistently


## Getting help

- [Documentation](http://hexdocs.pm/sparql)
- [Tutorial about SPARQL.ex and SPARQL.Client by Tony Hammond](https://medium.com/@tonyhammond/querying-rdf-with-elixir-2378b39d65cc)
- [Google Group](https://groups.google.com/d/forum/rdfex)


## Contributing

see [CONTRIBUTING](CONTRIBUTING.md) for details.


## License and Copyright

(c) 2018 Marcel Otto. MIT Licensed, see [LICENSE](LICENSE.md) for details.


[SPARQL]:               http://www.w3.org/TR/sparql11-overview/
[SPARQL.ex]:            https://hex.pm/packages/sparql
[SPARQL.Client]:        https://hex.pm/packages/sparql_client
[RDF.ex]:               https://hex.pm/packages/rdf
