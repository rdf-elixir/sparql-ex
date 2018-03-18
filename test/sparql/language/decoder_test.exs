defmodule SPARQL.Language.DecoderTest do
  use ExUnit.Case

  import RDF.Sigils

  doctest SPARQL.Language

  alias SPARQL.Query

  import SPARQL.Language.Decoder, only: [decode: 1]
  import SPARQL.QueryFactory


  test "prologue" do
    {query, expected_result} =
      prologue("""
        BASE <http://exmaple.com/ns>
        PREFIX foaf: <http://xmlns.com/foaf/0.1/>
        """)

    assert decode(query) == {:ok,
              %Query{expected_result |
                base: ~I<http://exmaple.com/ns>,
                prefixes: %{"foaf" => ~I<http://xmlns.com/foaf/0.1/>},
              }
            }
  end

  describe "SELECT query" do

    test "with simple variables" do
      with {query, expected_result} = select_query(
                "SELECT ?name WHERE { ?x foaf:name ?name }",
                foaf: "http://xmlns.com/foaf/0.1/") do
        assert decode(query) == {:ok, expected_result}
      end
    end

    test "with Turtle shortcuts" do
      with {query, expected_result} =
            select_query("""
            SELECT ?name ?mbox
            WHERE {
              ?x
                foaf:name ?name ;
                foaf:mbox ?mbox .
            }
            """, foaf: "http://xmlns.com/foaf/0.1/") do
        assert decode(query) == {:ok, expected_result}
      end
    end

  end

end
