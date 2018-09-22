defmodule SPARQL.QueryTest do
  use ExUnit.Case
  doctest SPARQL.Query

  defmodule Test.NS do
    use RDF.Vocabulary.Namespace

    defvocab EX,
             base_iri: "http://www.example.com/ns/",
             terms: ~w[Foo bar]
  end

  describe "default_prefixes/1" do
    test "standard prefixes when given nil" do
      assert SPARQL.Query.default_prefixes(nil) == SPARQL.Query.standard_prefixes()
    end

    test "standard prefixes can be overwritten" do
      assert SPARQL.Query.default_prefixes(%{rdf: "http://example.com"}) ==
             SPARQL.Query.standard_prefixes() |> Map.put(:rdf, "http://example.com")
    end

    test "standard prefixes can be removed" do
      assert SPARQL.Query.default_prefixes(%{rdf: nil}) ==
             SPARQL.Query.standard_prefixes() |> Map.delete(:rdf)
    end

    test "can be passed a list of RDF.Vocabulary.Namespaces" do
      assert SPARQL.Query.default_prefixes([RDF.NS.OWL, Test.NS.EX]) ==
             SPARQL.Query.standard_prefixes()
             |> Map.put(:owl, to_string(RDF.NS.OWL.__base_iri__()))
             |> Map.put(:ex,  to_string(Test.NS.EX.__base_iri__()))
    end
  end

end
