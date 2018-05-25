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

  @tag skip: "TODO when we have SPARQL expressions as algebra expressions available"
  test "projected expressions"


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
