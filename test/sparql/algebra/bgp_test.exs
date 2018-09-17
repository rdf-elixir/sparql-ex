defmodule SPARQL.Algebra.BGPTest do
  use SPARQL.Test.Case

  import SPARQL.Language.Decoder, only: [decode: 1]

  test "empty bgp" do
    query = "SELECT * WHERE {}"

    assert {:ok, %SPARQL.Query{expr:
           %SPARQL.Algebra.BGP{triples: []}}} = decode(query)
  end

  test "a single bgp with a single triple" do
    query = """
      PREFIX foaf: <http://xmlns.com/foaf/0.1/>
      SELECT * WHERE { ?person foaf:name ?name }
      """

    assert {:ok, %SPARQL.Query{expr:
        %SPARQL.Algebra.BGP{
          triples: [{"person", ~I<http://xmlns.com/foaf/0.1/name>, "name"}]
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

    assert {:ok, %SPARQL.Query{expr:
        %SPARQL.Algebra.BGP{
          triples: [
            {"person", ~I<http://xmlns.com/foaf/0.1/name>,  "name"},
            {"person", ~I<http://xmlns.com/foaf/0.1/knows>, "other"},
            {"person", ~I<http://xmlns.com/foaf/0.1/knows>, "friend"},
            {"other",  ~I<http://xmlns.com/foaf/0.1/knows>, "friend"},
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
    assert {:ok, %SPARQL.Query{expr:
        %SPARQL.Algebra.BGP{
          triples: [
            {%RDF.BlankNode{} = bnode, ~I<http://xmlns.com/foaf/0.1/mbox>,  "email"},
            {%RDF.BlankNode{} = bnode, ~I<http://xmlns.com/foaf/0.1/knows>, "other"},
            {%RDF.BlankNode{} = bnode, ~I<http://xmlns.com/foaf/0.1/knows>, "friend"},
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
    assert {:ok, %SPARQL.Query{expr:
        %SPARQL.Algebra.BGP{
          triples: [
            {%RDF.BlankNode{} = bnode, ~I<http://xmlns.com/foaf/0.1/mbox>,  "email"},
            {%RDF.BlankNode{} = bnode, ~I<http://xmlns.com/foaf/0.1/knows>, "other"},
            {%RDF.BlankNode{} = bnode, ~I<http://xmlns.com/foaf/0.1/knows>, "friend"},
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
    assert {:ok, %SPARQL.Query{expr:
        %SPARQL.Algebra.BGP{
          triples: [
            {"s", "p", %RDF.BlankNode{} = bnode},
            {%RDF.BlankNode{} = bnode, ~I<http://xmlns.com/foaf/0.1/mbox>,  "email"},
            {%RDF.BlankNode{} = bnode, ~I<http://xmlns.com/foaf/0.1/knows>, "other"},
            {%RDF.BlankNode{} = bnode, ~I<http://xmlns.com/foaf/0.1/knows>, "friend"},
          ]
        }
      }} = decode(query)
  end

end
