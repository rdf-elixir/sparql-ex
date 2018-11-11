defmodule SPARQL.Algebra.ConstructTest do
  use SPARQL.Test.Case

  import SPARQL.Language.Decoder, only: [decode: 1]

  test "simple example" do
    query = """
      PREFIX foaf:  <http://xmlns.com/foaf/0.1/>
      PREFIX vcard: <http://www.w3.org/2001/vcard-rdf/3.0#>
      CONSTRUCT   { <http://example.org/person#Alice> vcard:FN ?name }
      WHERE       { ?x foaf:name ?name }
      """
    assert {:ok,
             %SPARQL.Query{form: :construct,
               expr: %SPARQL.Algebra.Construct{
                 template: [{
                   %RDF.IRI{value: "http://example.org/person#Alice"},
                   %RDF.IRI{value: "http://www.w3.org/2001/vcard-rdf/3.0#FN"},
                   "name"
                 }],
                 query: %SPARQL.Algebra.BGP{
                   triples: [{"x", ~I<http://xmlns.com/foaf/0.1/name>, "name"}]
                 }
               },
             }
           } = decode(query)
  end

end
