defmodule SPARQL.Algebra.AlternativeGraphPatternTest do
  use SPARQL.Test.Case

  import SPARQL.Language.Decoder, only: [decode: 1]

  test "group consisting of a union of two basic graph patterns" do
    query = """
      PREFIX : <http://example.com/>
      SELECT *
      WHERE { { ?s :p1 ?v1 } UNION {?s :p2 ?v2 } }
      """
    assert {:ok, %SPARQL.Query{
             expr: %SPARQL.Algebra.Union{
               expr1: %SPARQL.Algebra.BGP{triples: [{"s", %IRI{value: "http://example.com/p1"}, "v1"}]},
               expr2: %SPARQL.Algebra.BGP{triples: [{"s", %IRI{value: "http://example.com/p2"}, "v2"}]}
             }
           }} = decode(query)
  end

  test "group consisting of a union of a union and a basic graph pattern" do
    query = """
      PREFIX : <http://example.com/>
      SELECT *
      WHERE { { ?s :p1 ?v1 } UNION {?s :p2 ?v2 } UNION {?s :p3 ?v3 } }
      """
    assert {:ok, %SPARQL.Query{
             expr: %SPARQL.Algebra.Union{
               expr1: %SPARQL.Algebra.Union{
                 expr1: %SPARQL.Algebra.BGP{triples: [{"s", %IRI{value: "http://example.com/p1"}, "v1"}]},
                 expr2: %SPARQL.Algebra.BGP{triples: [{"s", %IRI{value: "http://example.com/p2"}, "v2"}]}
               },
               expr2: %SPARQL.Algebra.BGP{triples: [{"s", %IRI{value: "http://example.com/p3"}, "v3"}]}
             }
           }} = decode(query)
  end

  test "group consisting of a union graph pattern and an optional graph pattern" do
    query = """
      PREFIX : <http://example.com/>
      SELECT *
      WHERE { {?s :p1 ?v1} UNION {?s :p2 ?v2} OPTIONAL {?s :p3 ?v3} }
      """
    assert {:ok, %SPARQL.Query{
             expr: %SPARQL.Algebra.LeftJoin{
               expr1: %SPARQL.Algebra.Union{
                 expr1: %SPARQL.Algebra.BGP{triples: [{"s", %IRI{value: "http://example.com/p1"}, "v1"}]},
                 expr2: %SPARQL.Algebra.BGP{triples: [{"s", %IRI{value: "http://example.com/p2"}, "v2"}]}
               },
               expr2: %SPARQL.Algebra.BGP{triples: [{"s", %IRI{value: "http://example.com/p3"}, "v3"}]},
               filters: [%Literal{literal: %XSD.Boolean{value: true}}]
             }
           }} = decode(query)
  end

  test "group consisting of a union of two basic graph patterns with filters" do
    query = """
      PREFIX : <http://example.com/>
      SELECT *
      WHERE { { ?s :p1 ?v1 } UNION {?s :p2 ?v2 FILTER(?v2<3)} }
      """
    n3 = XSD.integer(3)
    assert {:ok, %SPARQL.Query{
             expr: %SPARQL.Algebra.Union{
               expr1: %SPARQL.Algebra.BGP{triples: [{"s", %IRI{value: "http://example.com/p1"}, "v1"}]},
               expr2: %SPARQL.Algebra.Filter{
                 filters: [
                   %SPARQL.Algebra.FunctionCall.Builtin{
                     name: :<,
                     arguments: ["v2", ^n3]
                   }
                 ], expr: %SPARQL.Algebra.BGP{triples: [{"s", %IRI{value: "http://example.com/p2"}, "v2"}]}
               }
             }
           }} = decode(query)
  end

  test "empty UNION graph pattern" do
    query = """
      PREFIX : <http://example.com/>
      SELECT *
      WHERE { {} UNION {} }
      """
    assert {:ok, %SPARQL.Query{
             expr: %SPARQL.Algebra.Union{
               expr1: %SPARQL.Algebra.BGP{triples: []},
               expr2: %SPARQL.Algebra.BGP{triples: []}
             }
           }} = decode(query)
  end
end
