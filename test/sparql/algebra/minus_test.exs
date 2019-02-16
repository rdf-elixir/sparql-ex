defmodule SPARQL.Algebra.MinusTest do
  use SPARQL.Test.Case

  import SPARQL.Language.Decoder, only: [decode: 1]

  test "simple example" do
    query = """
      PREFIX : <http://example.com/>
      SELECT *
      WHERE { ?s :p ?v . MINUS {?s :p1 ?v2 } }
      """
    assert {:ok, %SPARQL.Query{
             expr: %SPARQL.Algebra.Minus{
               expr1: %SPARQL.Algebra.BGP{triples: [{"s", %RDF.IRI{value: "http://example.com/p"}, "v"}]},
               expr2: %SPARQL.Algebra.BGP{triples: [{"s", %RDF.IRI{value: "http://example.com/p1"}, "v2"}]}
             }
           }} = decode(query)
  end

  test "empty groups" do
    query = """
      PREFIX : <http://example.com/>
      SELECT *
      WHERE { {} MINUS {} }
      """
    assert {:ok, %SPARQL.Query{
             expr: %SPARQL.Algebra.Minus{
               expr1: %SPARQL.Algebra.BGP{triples: []},
               expr2: %SPARQL.Algebra.BGP{triples: []}
             }
           }} = decode(query)
  end
end
