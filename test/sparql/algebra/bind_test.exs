defmodule SPARQL.Algebra.BindTest do
  use SPARQL.Test.Case

  import SPARQL.Language.Decoder, only: [decode: 1]

  test "group graph pattern with a single BIND alias at the end" do
    query = """
      PREFIX ex: <http://example.org/>
      SELECT * WHERE {
        ?s ex:cost ?cost .
        BIND (?cost AS ?my_cost)
      }
      """
    assert {:ok,
             %SPARQL.Query{
               expr: %SPARQL.Algebra.Extend{
                 var: "my_cost",
                 expr: "cost",
                 child_expr: %SPARQL.Algebra.BGP{
                   triples: [{"s", ~I<http://example.org/cost>, "cost"}]
                 }
               }
           }} = decode(query)
  end

  test "group graph pattern with a single BIND of a function call result at the end" do
    n2 = XSD.integer(2)
    [
      """
      PREFIX : <http://example.com/>
      SELECT *
      WHERE  { ?s :p ?v . {} BIND (2*?v AS ?v2) }
      """,
      """
      PREFIX : <http://example.com/>
      SELECT *
      WHERE  { ?s :p ?v . BIND (2*?v AS ?v2) }
      """
    ]
    |> Enum.each(fn query ->
         assert {:ok,
                  %SPARQL.Query{
                    expr: %SPARQL.Algebra.Extend{
                      var: "v2",
                      expr: %SPARQL.Algebra.FunctionCall.Builtin{
                        name: :*,
                        arguments: [^n2, "v"],
                      },
                      child_expr: %SPARQL.Algebra.BGP{triples: [{"s", %IRI{value: "http://example.com/p"}, "v"}]},
                    }
                  }} = decode(query)
       end)
  end

  test "group graph pattern with a single BIND of a function call result" do
    query = """
      PREFIX : <http://example.com/>
      SELECT *
      WHERE  { ?s :p ?v . BIND (2*?v AS ?v2) ?s :p1 ?v2 }
      """
    n2 = XSD.integer(2)
    assert {:ok,
             %SPARQL.Query{
               expr: %SPARQL.Algebra.Join{
                 expr1: %SPARQL.Algebra.Extend{
                   var: "v2",
                   expr: %SPARQL.Algebra.FunctionCall.Builtin{
                     name: :*,
                     arguments: [^n2, "v"],
                   },
                   child_expr: %SPARQL.Algebra.BGP{triples: [{"s", %IRI{value: "http://example.com/p"}, "v"}]},
                 },
                 expr2: %SPARQL.Algebra.BGP{triples: [{"s", %IRI{value: "http://example.com/p1"}, "v2"}]}
               }
           }} = decode(query)
  end

  test "optional graph pattern with a single BIND of a function call result" do
    query = """
      PREFIX : <http://example.com/>
      SELECT *
      WHERE  { ?s :p ?v OPTIONAL { ?s :p1 ?v2 . BIND (2*?v AS ?v2) } }
      """
    n2 = XSD.integer(2)
    assert {:ok,
             %SPARQL.Query{
               expr: %SPARQL.Algebra.LeftJoin{
                 expr1: %SPARQL.Algebra.BGP{triples: [{"s", %IRI{value: "http://example.com/p"}, "v"}]},
                 expr2: %SPARQL.Algebra.Extend{
                   var: "v2",
                   expr: %SPARQL.Algebra.FunctionCall.Builtin{
                     name: :*,
                     arguments: [^n2, "v"],
                   },
                   child_expr: %SPARQL.Algebra.BGP{triples: [{"s", %IRI{value: "http://example.com/p1"}, "v2"}]},
                 },
                 filters: [%Literal{literal: %XSD.Boolean{value: true}}]
               }
             }} = decode(query)
  end

  @tag skip: "TODO"
  test "the variable assigned in a BIND clause must not be already in-use within the immediately preceding TriplesBlock within a GroupGraphPattern" do
    query = """
      PREFIX : <http://example.com/>
      SELECT *
      WHERE  { ?s :p ?v . BIND (2*?v AS ?s) }
      """
    assert {:error, "variable ?s already used"} = decode(query)

  end

end
