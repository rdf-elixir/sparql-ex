defmodule SPARQL.Language.DecoderTest do
  use ExUnit.Case

  import RDF.Sigils

  doctest SPARQL.Language

  import SPARQL.Language.Decoder, only: [decode: 1]


  test "prologue" do
    query = """
      BASE <http://exmaple.com/ns>
      PREFIX foaf: <http://xmlns.com/foaf/0.1/>
      SELECT * WHERE { ?s a ?class }
      """

    assert {:ok, %SPARQL.Query{
              base: ~I<http://exmaple.com/ns>,
              prefixes: %{"foaf" => ~I<http://xmlns.com/foaf/0.1/>},
            }} = decode(query)
  end

  describe "query form" do
    test "SELECT" do
      assert {:ok, %SPARQL.Query{form: :select}} = decode("SELECT * WHERE { ?s a ?class }")
    end

    test "ASK" do
      assert {:ok, %SPARQL.Query{form: :ask}} = decode("ASK { ?s a ?class }")
    end

    test "true and false are case-insensitive" do
      assert {:ok, %SPARQL.Query{}} = decode("SELECT * WHERE { ?s a TRUE }")
    end
  end

  describe "invalid query" do
    test "when using unknown prefixes" do
      assert_raise RuntimeError, ~r/^unknown prefix/,
                   fn -> decode("SELECT * WHERE { ?s a unknown:Foo }") end

      # TODO: We actually want the following behaviour, but this requires a larger refactoring
      #       of the algebra translation to use ok and error tuples consistently
      # assert {:error, %SPARQL.Query{}} = decode("SELECT * WHERE { ?s a unknown:Foo }")
    end

  end
end
