defmodule SPARQL.Algebra.RDFValueTest do
  use SPARQL.Test.Case

  import SPARQL.Language.Decoder, only: [decode: 1, decode: 2]


  test "IRI" do
    query = "SELECT * WHERE { ?s <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> ?class }"

    assert {:ok, %SPARQL.Query{expr:
        %SPARQL.Algebra.BGP{
          triples: [{"s", ~I<http://www.w3.org/1999/02/22-rdf-syntax-ns#type>, "class"}]
        }}} = decode(query)
  end

  describe "relative IRI" do
    test "with base given as an option" do
      query = "SELECT * WHERE { <x> <p> ?v }"

      assert {:ok, %SPARQL.Query{expr:
          %SPARQL.Algebra.BGP{
            triples: [{~I<http://example.org/x/x>, ~I<http://example.org/x/p>, "v"}]
          }}} = decode(query, base: "http://example.org/x/")
    end

    test "with base given in the query" do
      query = """
      BASE <http://example.org/x/>
      SELECT * WHERE { <x> <p> ?v }
      """

      assert {:ok, %SPARQL.Query{expr:
          %SPARQL.Algebra.BGP{
            triples: [{~I<http://example.org/x/x>, ~I<http://example.org/x/p>, "v"}]
          }}} = decode(query)
    end

    test "base in the query overwrites a base given as an option" do
      query = """
      BASE <http://example.org/x/>
      SELECT * WHERE { <x> <p> ?v }
      """

      assert {:ok, %SPARQL.Query{expr:
          %SPARQL.Algebra.BGP{
            triples: [{~I<http://example.org/x/x>, ~I<http://example.org/x/p>, "v"}]
          }}} = decode(query, base: "http://example.org/y/")
    end

    test "relative IRI in prefix" do
      query = """
      BASE <http://example.org/x/>
      PREFIX : <>
      SELECT * WHERE { :x ?p ?v }
      """

      assert {:ok, %SPARQL.Query{expr:
          %SPARQL.Algebra.BGP{
            triples: [{~I<http://example.org/x/x>, "p", "v"}]
          }}} = decode(query)
    end
  end

  test "a" do
    query = "SELECT * WHERE { ?s a ?class }"

    assert {:ok, %SPARQL.Query{expr:
        %SPARQL.Algebra.BGP{
          triples: [{"s", ~I<http://www.w3.org/1999/02/22-rdf-syntax-ns#type>, "class"}]
        }}} = decode(query)
  end

  test "blank node" do
    query = "SELECT * WHERE { _:foo ?p ?o }"

    assert {:ok, %SPARQL.Query{expr:
        %SPARQL.Algebra.BGP{
          triples: [{~B"foo", "p", "o"}]
        }}} = decode(query)
  end

  test "abbreviated blank node" do
    query = "SELECT * WHERE { [] ?p ?o }"

    assert {:ok, %SPARQL.Query{expr:
        %SPARQL.Algebra.BGP{
          triples: [{%BlankNode{}, "p", "o"}]
        }}} = decode(query)
  end


  describe "literals" do
    test "integer" do
      query = ~s[SELECT * WHERE { ?s ?p 42 }]

      int = XSD.integer(42)
      assert {:ok, %SPARQL.Query{expr:
          %SPARQL.Algebra.BGP{
            triples: [{"s", "p", ^int}]
          }}} = decode(query)
    end

    test "plain literal" do
      query = ~s[SELECT * WHERE { ?s ?p "foo" }]

      assert {:ok, %SPARQL.Query{expr:
          %SPARQL.Algebra.BGP{
            triples: [{"s", "p", ~L"foo"}]
          }}} = decode(query)
    end

    test "typed literal" do
      query = ~s[SELECT * WHERE { ?s ?p "foo"^^<http://www.w3.org/2001/XMLSchema#token> }]

      literal = RDF.literal("foo", datatype: "http://www.w3.org/2001/XMLSchema#token")
      assert {:ok, %SPARQL.Query{expr:
          %SPARQL.Algebra.BGP{
            triples: [{"s", "p", ^literal}]
          }}} = decode(query)
    end

    test "typed literal with prefixed type" do
      query = """
      PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
      SELECT * WHERE { ?s ?p "foo"^^xsd:token }
      """

      literal = RDF.literal("foo", datatype: "http://www.w3.org/2001/XMLSchema#token")
      assert {:ok, %SPARQL.Query{expr:
          %SPARQL.Algebra.BGP{
            triples: [{"s", "p", ^literal}]
          }}} = decode(query)
    end

    test "language tagged literal" do
      query = ~s[SELECT * WHERE { ?s ?p "foo"@en }]

      assert {:ok, %SPARQL.Query{expr:
          %SPARQL.Algebra.BGP{
            triples: [{"s", "p", ~L"foo"en}]
          }}} = decode(query)
    end
  end

  describe "collection" do
    @rdf_first RDF.first()
    @rdf_rest  RDF.rest()
    @rdf_nil   RDF.nil()

    test "simple" do
      one = XSD.integer(1)

      query = "SELECT * WHERE { ?s ?p (1 ?second ?third) }"
      assert {:ok, %SPARQL.Query{expr:
          %SPARQL.Algebra.BGP{
            triples: [
              {"s", "p", %BlankNode{} = first_node},
              {%BlankNode{} = first_node , @rdf_first, ^one},
              {%BlankNode{} = first_node , @rdf_rest, second_node},
              {%BlankNode{} = second_node, @rdf_first, "second"},
              {%BlankNode{} = second_node, @rdf_rest, third_node},
              {%BlankNode{} = third_node , @rdf_first, "third"},
              {%BlankNode{} = third_node , @rdf_rest, @rdf_nil},
            ]
          }}} = decode(query)

      query = "SELECT * WHERE { (1 ?second ?third) ?p ?o }"
      assert {:ok, %SPARQL.Query{expr:
          %SPARQL.Algebra.BGP{
            triples: [
              {%BlankNode{} = first_node , @rdf_first, ^one},
              {%BlankNode{} = first_node , @rdf_rest, second_node},
              {%BlankNode{} = second_node, @rdf_first, "second"},
              {%BlankNode{} = second_node, @rdf_rest, third_node},
              {%BlankNode{} = third_node , @rdf_first, "third"},
              {%BlankNode{} = third_node , @rdf_rest, @rdf_nil},
              {%BlankNode{} = first_node, "p", "o",},
            ]
          }}} = decode(query)
    end

    test "nested collection" do
      one = XSD.integer(1)

      query = "SELECT * WHERE { ?s ?p (?one (1 ?two) [?foo ?bar]) }"

      assert {:ok, %SPARQL.Query{expr:
          %SPARQL.Algebra.BGP{
            triples: [
              {"s", "p", %BlankNode{} = first_node},
              {%BlankNode{} = first_node , @rdf_first, "one"},
              {%BlankNode{} = first_node , @rdf_rest, second_node},
              {%BlankNode{} = second_node, @rdf_first, first_nested_node},
              {%BlankNode{} = first_nested_node , @rdf_first, ^one},
              {%BlankNode{} = first_nested_node , @rdf_rest, second_nested_node},
              {%BlankNode{} = second_nested_node, @rdf_first, "two"},
              {%BlankNode{} = second_nested_node, @rdf_rest, @rdf_nil},
              {%BlankNode{} = second_node, @rdf_rest, third_node},
              {%BlankNode{} = third_node , @rdf_first, %BlankNode{} = description_node},
              {%BlankNode{} = description_node , "foo", "bar"},
              {%BlankNode{} = third_node , @rdf_rest, @rdf_nil},
            ]
          }}} = decode(query)
    end

    test "'()' for nil" do
      query = "SELECT * WHERE { () ?p ?o }"

      assert {:ok, %SPARQL.Query{expr:
          %SPARQL.Algebra.BGP{
            triples: [{~I<http://www.w3.org/1999/02/22-rdf-syntax-ns#nil>, "p", "o"}]
          }}} = decode(query)

      query = "SELECT * WHERE { ?s ?p () }"

      assert {:ok, %SPARQL.Query{expr:
          %SPARQL.Algebra.BGP{
            triples: [{"s", "p", ~I<http://www.w3.org/1999/02/22-rdf-syntax-ns#nil>}]
          }}} = decode(query)
    end

  end

end
