defmodule SPARQL.Algebra.FilterTest do
  use SPARQL.Test.Case

  import SPARQL.Language.Decoder, only: [decode: 1]


  test "single filter" do
    query = """
      PREFIX ex: <http://example.org/>
      SELECT ?s ?cost WHERE {
        ?s ex:cost ?cost .
        FILTER (?cost < 10)
      }
      """
    n10 = RDF.integer(10)
    assert {:ok, %SPARQL.Query{
        expr: %SPARQL.Algebra.Project{
          vars: ~w[s cost],
          expr: %SPARQL.Algebra.Filter{
            filters: [
              %SPARQL.Algebra.FunctionCall{
                name: :<,
                arguments: ["cost", ^n10]
              }
            ],
            expr: %SPARQL.Algebra.BGP{
                triples: [{"s", ~I<http://example.org/cost>, "cost"}]
              }
            }
          }
      }} = decode(query)
  end

  test "single filter with function" do
    query = """
      PREFIX foaf: <http://xmlns.com/foaf/0.1/>
      SELECT ?person ?name WHERE {
        ?person foaf:name ?name
        FILTER(regex(?name, "foo", "i"))
      }
      """
    assert {:ok, %SPARQL.Query{
        expr: %SPARQL.Algebra.Project{
          vars: ~w[person name],
          expr: %SPARQL.Algebra.Filter{
            filters: [
              %SPARQL.Algebra.FunctionCall{
                name: :REGEX,
                arguments: ["name", ~L"foo", ~L"i"]
              }
            ],
            expr: %SPARQL.Algebra.BGP{
                triples: [{"person", ~I<http://xmlns.com/foaf/0.1/name>, "name"}]
              }
            }
          }
      }} = decode(query)
  end

  test "nested function call" do
    query = """
      PREFIX foaf: <http://xmlns.com/foaf/0.1/>
      SELECT ?person ?name WHERE {
        ?person foaf:name ?name
        FILTER (UCASE(?name) = "foo")
      }
      """
    assert {:ok, %SPARQL.Query{
        expr: %SPARQL.Algebra.Project{
          vars: ~w[person name],
          expr: %SPARQL.Algebra.Filter{
            filters: [
              %SPARQL.Algebra.FunctionCall{
                name: :=,
                arguments: [
                  %SPARQL.Algebra.FunctionCall{
                    name: :UCASE,
                    arguments: ["name"]
                  },
                  ~L"foo"
                ]
              }
            ],
            expr: %SPARQL.Algebra.BGP{
                triples: [{"person", ~I<http://xmlns.com/foaf/0.1/name>, "name"}]
              }
            }
          }
      }} = decode(query)
  end

end
