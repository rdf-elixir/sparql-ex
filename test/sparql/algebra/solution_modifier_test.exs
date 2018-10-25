defmodule SPARQL.Algebra.SolutionModifierTest do
  use SPARQL.Test.Case

  import SPARQL.Language.Decoder, only: [decode: 1]


  test "simple projected variables" do
    query = """
      PREFIX foaf: <http://xmlns.com/foaf/0.1/>
      SELECT ?person ?name WHERE { ?person foaf:name ?name }
      """

    assert {:ok, %SPARQL.Query{expr:
        %SPARQL.Algebra.Project{
          vars: ~w[person name],
          expr: %SPARQL.Algebra.BGP{
              triples: [{"person", ~I<http://xmlns.com/foaf/0.1/name>, "name"}]
            }
          }
      }} = decode(query)
  end

  test "projected expressions" do
    query = """
      PREFIX ns: <http://example.org/ns#>
      SELECT ?product (?p - ?discount AS ?price) WHERE {
        ?product ns:price ?p .
        ?product ns:discount ?discount .
      }
      """

    assert {:ok, %SPARQL.Query{expr:
           %SPARQL.Algebra.Project{
             vars: ~w[product price],
             expr: %SPARQL.Algebra.Extend{
               child_expr: %SPARQL.Algebra.BGP{
                   triples: [
                     {"product", ~I<http://example.org/ns#price>, "p"},
                     {"product", ~I<http://example.org/ns#discount>, "discount"}
                   ]},
               var: "price",
               expr: %SPARQL.Algebra.FunctionCall.Builtin{
                       arguments: ["p", "discount"],
                       name: :-
                     }
             }
           }
      }} = decode(query)
  end

  test "projected expressions over earlier projected expressions" do
    query = """
    PREFIX ns: <http://example.org/ns#>
    SELECT ?product (?p - ?discount AS ?p2) (?p2 - ?discount2 AS ?price) WHERE {
      ?product ns:price ?p .
      ?product ns:discount ?discount .
      ?product ns:discount2 ?discount2 .
    }
    """

    assert {:ok, %SPARQL.Query{expr:
           %SPARQL.Algebra.Project{
             vars: ~w[product p2 price],
             expr: %SPARQL.Algebra.Extend{
               child_expr: %SPARQL.Algebra.Extend{
                 child_expr: %SPARQL.Algebra.BGP{
                   triples: [
                     {"product", ~I<http://example.org/ns#price>, "p"},
                     {"product", ~I<http://example.org/ns#discount>, "discount"},
                     {"product", ~I<http://example.org/ns#discount2>, "discount2"}
                   ]},
                 var: "p2",
                 expr: %SPARQL.Algebra.FunctionCall.Builtin{
                   arguments: ["p", "discount"],
                   name: :-
                 }
               },
               var: "price",
               expr: %SPARQL.Algebra.FunctionCall.Builtin{
                 arguments: ["p2", "discount2"],
                 name: :-
               }
             }
           }
      }} = decode(query)
  end

  test "error is raised when variable name of a projected expression is already used in the pattern" do
    query = """
      PREFIX ns: <http://example.org/ns#>
      SELECT ?product (?price - ?discount AS ?price) WHERE {
        ?product ns:price ?price .
        ?product ns:discount ?discount .
      }
      """

    assert {:error, "variable ?price already used"} = decode(query)
  end

  test "error is raised when variable name of a projected expression is already used for another projected expression" do
    query = """
      PREFIX ns: <http://example.org/ns#>
      SELECT ?product (?p - ?discount AS ?price) (?p - ?discount AS ?price) WHERE {
        ?product ns:price ?p .
        ?product ns:discount ?discount .
      }
      """

    assert {:error, "variable ?price used for multiple expressions"} = decode(query)
  end

  test "DISTINCT with *" do
    query = """
      PREFIX foaf: <http://xmlns.com/foaf/0.1/>
      SELECT DISTINCT * WHERE { ?person foaf:name ?name }
      """

    assert {:ok, %SPARQL.Query{expr:
        %SPARQL.Algebra.Distinct{expr:
          %SPARQL.Algebra.BGP{
            triples: [{"person", ~I<http://xmlns.com/foaf/0.1/name>, "name"}]
          }
        }
      }} = decode(query)
  end

  test "DISTINCT with projected variables" do
    query = """
      PREFIX foaf: <http://xmlns.com/foaf/0.1/>
      SELECT DISTINCT ?person ?name WHERE { ?person foaf:name ?name }
      """

    assert {:ok, %SPARQL.Query{expr:
        %SPARQL.Algebra.Distinct{expr:
          %SPARQL.Algebra.Project{
            vars: ~w[person name],
            expr: %SPARQL.Algebra.BGP{
                triples: [{"person", ~I<http://xmlns.com/foaf/0.1/name>, "name"}]
              }
            }
          }
      }} = decode(query)
  end

  test "REDUCED with *" do
    query = """
      PREFIX foaf: <http://xmlns.com/foaf/0.1/>
      SELECT REDUCED * WHERE { ?person foaf:name ?name }
      """

    assert {:ok, %SPARQL.Query{expr:
        %SPARQL.Algebra.Reduced{expr:
          %SPARQL.Algebra.BGP{
            triples: [{"person", ~I<http://xmlns.com/foaf/0.1/name>, "name"}]
          }
        }
      }} = decode(query)
  end

  test "REDUCED with projected variables" do
    query = """
      PREFIX foaf: <http://xmlns.com/foaf/0.1/>
      SELECT REDUCED ?person ?name WHERE { ?person foaf:name ?name }
      """

    assert {:ok, %SPARQL.Query{expr:
        %SPARQL.Algebra.Reduced{expr:
          %SPARQL.Algebra.Project{
            vars: ~w[person name],
            expr: %SPARQL.Algebra.BGP{
                triples: [{"person", ~I<http://xmlns.com/foaf/0.1/name>, "name"}]
              }
            }
          }
      }} = decode(query)
  end

end
