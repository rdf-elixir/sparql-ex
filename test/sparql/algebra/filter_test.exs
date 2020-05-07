defmodule SPARQL.Algebra.FilterTest do
  use SPARQL.Test.Case

  import SPARQL.Language.Decoder, only: [decode: 1]


  test "single filter at the end of a graph pattern" do
    query = """
      PREFIX ex: <http://example.org/>
      SELECT ?s ?cost WHERE {
        ?s ex:cost ?cost .
        FILTER (?cost < 10)
      }
      """
    n10 = XSD.integer(10)
    assert {:ok, %SPARQL.Query{
        expr: %SPARQL.Algebra.Project{
          vars: ~w[s cost],
          expr: %SPARQL.Algebra.Filter{
            filters: [
              %SPARQL.Algebra.FunctionCall.Builtin{
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

  test "single filter at the beginning of a graph pattern" do
    query = """
    PREFIX ex: <http://example.org/>
    SELECT ?s ?cost WHERE {
      FILTER (?cost < 10)
      ?s ex:cost ?cost .
    }
    """
    n10 = XSD.integer(10)
    assert {:ok, %SPARQL.Query{
             expr: %SPARQL.Algebra.Project{
               vars: ~w[s cost],
               expr: %SPARQL.Algebra.Filter{
                 filters: [
                   %SPARQL.Algebra.FunctionCall.Builtin{
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
              %SPARQL.Algebra.FunctionCall.Builtin{
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

  test "single filter with extension function" do
    query = """
    PREFIX foaf: <http://xmlns.com/foaf/0.1/>
    PREFIX ex: <http://example.com/>
    SELECT ?person ?name WHERE {
      ?person foaf:name ?name
      FILTER(ex:fun(?name, "foo", "i"))
    }
    """
    assert {:ok, %SPARQL.Query{
             expr: %SPARQL.Algebra.Project{
               vars: ~w[person name],
               expr: %SPARQL.Algebra.Filter{
                 filters: [
                   %SPARQL.Algebra.FunctionCall.Extension{
                     name: ~I<http://example.com/fun>,
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
              %SPARQL.Algebra.FunctionCall.Builtin{
                name: :=,
                arguments: [
                  %SPARQL.Algebra.FunctionCall.Builtin{
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
