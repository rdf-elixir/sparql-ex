defmodule SPARQL.Algebra.TranslationTest do
  use ExUnit.Case

  import RDF.Sigils

  import SPARQL.Language.Decoder, only: [decode: 1]


  test "IRI" do
    query = "SELECT * WHERE { ?s <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> ?class }"

    assert {:ok, %SPARQL.Query{expr:
        %SPARQL.Algebra.BGP{
          triples: [{:s?, ~I<http://www.w3.org/1999/02/22-rdf-syntax-ns#type>, :class?}]
        }}} = decode(query)
  end

  @tag skip: "TODO"
  test "relative IRI"

  test "a" do
    query = "SELECT * WHERE { ?s a ?class }"

    assert {:ok, %SPARQL.Query{expr:
        %SPARQL.Algebra.BGP{
          triples: [{:s?, ~I<http://www.w3.org/1999/02/22-rdf-syntax-ns#type>, :class?}]
        }}} = decode(query)
  end

  test "blank node" do
    query = "SELECT * WHERE { _:foo ?p ?o }"

    assert {:ok, %SPARQL.Query{expr:
        %SPARQL.Algebra.BGP{
          triples: [{~B"foo", :p?, :o?}]
        }}} = decode(query)
  end

  test "abbreviated blank node" do
    query = "SELECT * WHERE { [] ?p ?o }"

    assert {:ok, %SPARQL.Query{expr:
        %SPARQL.Algebra.BGP{
          triples: [{%RDF.BlankNode{}, :p?, :o?}]
        }}} = decode(query)
  end


  describe "literals" do
    test "integer" do
      query = ~s[SELECT * WHERE { ?s ?p 42 }]

      int = RDF.Integer.new(42)
      assert {:ok, %SPARQL.Query{expr:
          %SPARQL.Algebra.BGP{
            triples: [{:s?, :p?, ^int}]
          }}} = decode(query)
    end

    test "plain literal" do
      query = ~s[SELECT * WHERE { ?s ?p "foo" }]

      assert {:ok, %SPARQL.Query{expr:
          %SPARQL.Algebra.BGP{
            triples: [{:s?, :p?, ~L"foo"}]
          }}} = decode(query)
    end

    test "typed literal" do
      query = ~s[SELECT * WHERE { ?s ?p "foo"^^<http://www.w3.org/2001/XMLSchema#token> }]

      literal = RDF.literal("foo", datatype: "http://www.w3.org/2001/XMLSchema#token")
      assert {:ok, %SPARQL.Query{expr:
          %SPARQL.Algebra.BGP{
            triples: [{:s?, :p?, ^literal}]
          }}} = decode(query)
    end

    test "language tagged literal" do
      query = ~s[SELECT * WHERE { ?s ?p "foo"@en }]

      assert {:ok, %SPARQL.Query{expr:
          %SPARQL.Algebra.BGP{
            triples: [{:s?, :p?, ~L"foo"en}]
          }}} = decode(query)
    end
  end

  describe "collection" do
    @rdf_first RDF.first()
    @rdf_rest  RDF.rest()
    @rdf_nil   RDF.nil()

    test "simple" do
      one = RDF.Integer.new(1)

      query = "SELECT * WHERE { ?s ?p (1 ?second ?third) }"
      assert {:ok, %SPARQL.Query{expr:
          %SPARQL.Algebra.BGP{
            triples: [
              {:s?, :p?, %RDF.BlankNode{} = first_node},
              {%RDF.BlankNode{} = first_node , @rdf_first, ^one},
              {%RDF.BlankNode{} = first_node , @rdf_rest, second_node},
              {%RDF.BlankNode{} = second_node, @rdf_first, :second?},
              {%RDF.BlankNode{} = second_node, @rdf_rest, third_node},
              {%RDF.BlankNode{} = third_node , @rdf_first, :third?},
              {%RDF.BlankNode{} = third_node , @rdf_rest, @rdf_nil},
            ]
          }}} = decode(query)

      query = "SELECT * WHERE { (1 ?second ?third) ?p ?o }"
      assert {:ok, %SPARQL.Query{expr:
          %SPARQL.Algebra.BGP{
            triples: [
              {%RDF.BlankNode{} = first_node , @rdf_first, ^one},
              {%RDF.BlankNode{} = first_node , @rdf_rest, second_node},
              {%RDF.BlankNode{} = second_node, @rdf_first, :second?},
              {%RDF.BlankNode{} = second_node, @rdf_rest, third_node},
              {%RDF.BlankNode{} = third_node , @rdf_first, :third?},
              {%RDF.BlankNode{} = third_node , @rdf_rest, @rdf_nil},
              {%RDF.BlankNode{} = first_node, :p?, :o?,},
            ]
          }}} = decode(query)
    end

    test "nested collection" do
      one = RDF.Integer.new(1)

      query = "SELECT * WHERE { ?s ?p (?one (1 ?two) [?foo ?bar]) }"

      assert {:ok, %SPARQL.Query{expr:
          %SPARQL.Algebra.BGP{
            triples: [
              {:s?, :p?, %RDF.BlankNode{} = first_node},
              {%RDF.BlankNode{} = first_node , @rdf_first, :one?},
              {%RDF.BlankNode{} = first_node , @rdf_rest, second_node},
              {%RDF.BlankNode{} = second_node, @rdf_first, first_nested_node},
              {%RDF.BlankNode{} = first_nested_node , @rdf_first, ^one},
              {%RDF.BlankNode{} = first_nested_node , @rdf_rest, second_nested_node},
              {%RDF.BlankNode{} = second_nested_node, @rdf_first, :two?},
              {%RDF.BlankNode{} = second_nested_node, @rdf_rest, @rdf_nil},
              {%RDF.BlankNode{} = second_node, @rdf_rest, third_node},
              {%RDF.BlankNode{} = third_node , @rdf_first, %RDF.BlankNode{} = description_node},
              {%RDF.BlankNode{} = description_node , :foo?, :bar?},
              {%RDF.BlankNode{} = third_node , @rdf_rest, @rdf_nil},
            ]
          }}} = decode(query)
    end

    test "'()' for nil" do
      query = "SELECT * WHERE { () ?p ?o }"

      assert {:ok, %SPARQL.Query{expr:
          %SPARQL.Algebra.BGP{
            triples: [{~I<http://www.w3.org/1999/02/22-rdf-syntax-ns#nil>, :p?, :o?}]
          }}} = decode(query)

      query = "SELECT * WHERE { ?s ?p () }"

      assert {:ok, %SPARQL.Query{expr:
          %SPARQL.Algebra.BGP{
            triples: [{:s?, :p?, ~I<http://www.w3.org/1999/02/22-rdf-syntax-ns#nil>}]
          }}} = decode(query)
    end

  end

end
