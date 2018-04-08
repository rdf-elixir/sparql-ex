defmodule SPARQL.Algebra.TranslationTest do
  use ExUnit.Case

  import RDF.Sigils

  import SPARQL.Language.Decoder, only: [decode: 1]

  @rdf_first RDF.first()
  @rdf_rest  RDF.rest()
  @rdf_nil   RDF.nil()

  describe "RDF model" do
    test "with IRI" do
      query = "SELECT * WHERE { ?s <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> ?class }"

      assert {:ok, %SPARQL.Query{expression:
          %SPARQL.Algebra.BGP{
            triples: [{:s?, ~I<http://www.w3.org/1999/02/22-rdf-syntax-ns#type>, :class?}]
          }}} = decode(query)
    end

    @tag skip: "TODO"
    test "with relative IRI"

    test "with a" do
      query = "SELECT * WHERE { ?s a ?class }"

      assert {:ok, %SPARQL.Query{expression:
          %SPARQL.Algebra.BGP{
            triples: [{:s?, ~I<http://www.w3.org/1999/02/22-rdf-syntax-ns#type>, :class?}]
          }}} = decode(query)
    end

    test "with integer literal" do
      query = ~s[SELECT * WHERE { ?s ?p 42 }]

      int = RDF.Integer.new(42)
      assert {:ok, %SPARQL.Query{expression:
          %SPARQL.Algebra.BGP{
            triples: [{:s?, :p?, ^int}]
          }}} = decode(query)
    end

    test "with plain literal" do
      query = ~s[SELECT * WHERE { ?s ?p "foo" }]

      assert {:ok, %SPARQL.Query{expression:
          %SPARQL.Algebra.BGP{
            triples: [{:s?, :p?, ~L"foo"}]
          }}} = decode(query)
    end

    test "with typed literal" do
      query = ~s[SELECT * WHERE { ?s ?p "foo"^^<http://www.w3.org/2001/XMLSchema#token> }]

      literal = RDF.literal("foo", datatype: "http://www.w3.org/2001/XMLSchema#token")
      assert {:ok, %SPARQL.Query{expression:
          %SPARQL.Algebra.BGP{
            triples: [{:s?, :p?, ^literal}]
          }}} = decode(query)
    end

    test "with language tagged literal" do
      query = ~s[SELECT * WHERE { ?s ?p "foo"@en }]

      assert {:ok, %SPARQL.Query{expression:
          %SPARQL.Algebra.BGP{
            triples: [{:s?, :p?, ~L"foo"en}]
          }}} = decode(query)
    end

    test "with blank node" do
      query = "SELECT * WHERE { _:foo ?p ?o }"

      assert {:ok, %SPARQL.Query{expression:
          %SPARQL.Algebra.BGP{
            triples: [{~B"foo", :p?, :o?}]
          }}} = decode(query)
    end

    test "with abbreviated blank node" do
      query = "SELECT * WHERE { [] ?p ?o }"

      assert {:ok, %SPARQL.Query{expression:
          %SPARQL.Algebra.BGP{
            triples: [{%RDF.BlankNode{}, :p?, :o?}]
          }}} = decode(query)
    end

    test "with '()' for nil" do
      query = "SELECT * WHERE { () ?p ?o }"

      assert {:ok, %SPARQL.Query{expression:
          %SPARQL.Algebra.BGP{
            triples: [{~I<http://www.w3.org/1999/02/22-rdf-syntax-ns#nil>, :p?, :o?}]
          }}} = decode(query)

      query = "SELECT * WHERE { ?s ?p () }"

      assert {:ok, %SPARQL.Query{expression:
          %SPARQL.Algebra.BGP{
            triples: [{:s?, :p?, ~I<http://www.w3.org/1999/02/22-rdf-syntax-ns#nil>}]
          }}} = decode(query)
    end

    test "with list" do
      one = RDF.Integer.new(1)

      query = "SELECT * WHERE { ?s ?p (1 ?second ?third) }"
      assert {:ok, %SPARQL.Query{expression:
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
      assert {:ok, %SPARQL.Query{expression:
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

    test "with nested list" do
      one = RDF.Integer.new(1)

      query = "SELECT * WHERE { ?s ?p (?one (1 ?two) [?foo ?bar]) }"

      assert {:ok, %SPARQL.Query{expression:
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
  end


  describe "SELECT query" do
    test "a single bgp with a single triple" do
      query = """
        PREFIX foaf: <http://xmlns.com/foaf/0.1/>
        SELECT * WHERE { ?person foaf:name ?name }
        """

      assert {:ok, %SPARQL.Query{expression:
          %SPARQL.Algebra.BGP{
            triples: [{:person?, ~I<http://xmlns.com/foaf/0.1/name>, :name?}]
          }
        }} = decode(query)
    end

    test "a single bgp with a multiple triples" do
      query = """
        PREFIX foaf: <http://xmlns.com/foaf/0.1/>
        SELECT *
        WHERE {
          ?person foaf:name ?name ;
                  foaf:knows ?other, ?friend .
          ?other foaf:knows ?friend .
        }
        """

      assert {:ok, %SPARQL.Query{expression:
          %SPARQL.Algebra.BGP{
            triples: [
              {:person?, ~I<http://xmlns.com/foaf/0.1/name>,  :name?},
              {:person?, ~I<http://xmlns.com/foaf/0.1/knows>, :other?},
              {:person?, ~I<http://xmlns.com/foaf/0.1/knows>, :friend?},
              {:other?,  ~I<http://xmlns.com/foaf/0.1/knows>, :friend?},
            ]
          }
        }} = decode(query)
    end

    test "a single bgp with a blank node property list at subject position" do
      query = """
        PREFIX foaf: <http://xmlns.com/foaf/0.1/>
        SELECT *
        WHERE {
          [ foaf:mbox ?email ] foaf:knows ?other, ?friend .
        }
        """
      assert {:ok, %SPARQL.Query{expression:
          %SPARQL.Algebra.BGP{
            triples: [
              {%RDF.BlankNode{} = bnode, ~I<http://xmlns.com/foaf/0.1/mbox>,  :email?},
              {%RDF.BlankNode{} = bnode, ~I<http://xmlns.com/foaf/0.1/knows>, :other?},
              {%RDF.BlankNode{} = bnode, ~I<http://xmlns.com/foaf/0.1/knows>, :friend?},
            ]
          }
        }} = decode(query)

      query = """
        PREFIX foaf: <http://xmlns.com/foaf/0.1/>
        SELECT *
        WHERE {
          [ foaf:mbox ?email ; foaf:knows ?other, ?friend ] .
        }
        """
      assert {:ok, %SPARQL.Query{expression:
          %SPARQL.Algebra.BGP{
            triples: [
              {%RDF.BlankNode{} = bnode, ~I<http://xmlns.com/foaf/0.1/mbox>,  :email?},
              {%RDF.BlankNode{} = bnode, ~I<http://xmlns.com/foaf/0.1/knows>, :other?},
              {%RDF.BlankNode{} = bnode, ~I<http://xmlns.com/foaf/0.1/knows>, :friend?},
            ]
          }
        }} = decode(query)
    end

    test "a single bgp with a blank node property list at object position" do
      query = """
        PREFIX foaf: <http://xmlns.com/foaf/0.1/>
        SELECT *
        WHERE {
          ?s ?p [ foaf:mbox ?email ; foaf:knows ?other, ?friend ] .
        }
        """
      assert {:ok, %SPARQL.Query{expression:
          %SPARQL.Algebra.BGP{
            triples: [
              {:s?, :p?, %RDF.BlankNode{} = bnode},
              {%RDF.BlankNode{} = bnode, ~I<http://xmlns.com/foaf/0.1/mbox>,  :email?},
              {%RDF.BlankNode{} = bnode, ~I<http://xmlns.com/foaf/0.1/knows>, :other?},
              {%RDF.BlankNode{} = bnode, ~I<http://xmlns.com/foaf/0.1/knows>, :friend?},
            ]
          }
        }} = decode(query)
    end

  end

end
