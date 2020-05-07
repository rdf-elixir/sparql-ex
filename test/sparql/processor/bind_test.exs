defmodule SPARQL.Processor.BindTest do
  use SPARQL.Test.Case

  import SPARQL.Processor, only: [query: 2]

  test "example from the W3C spec" do
    assert RDF.Turtle.read_string!("""
             @prefix dc:   <http://purl.org/dc/elements/1.1/> .
             @prefix :     <http://example.org/book/> .
             @prefix ns:   <http://example.org/ns#> .

             :book1  dc:title     "SPARQL Tutorial" .
             :book1  ns:price     42 .
             :book1  ns:discount  0.2 .

             :book2  dc:title     "The Semantic Web" .
             :book2  ns:price     23 .
             :book2  ns:discount  0.25 .
             """)
            |> query(
                 """
                 PREFIX  dc:  <http://purl.org/dc/elements/1.1/>
                 PREFIX  ns:  <http://example.org/ns#>

                 SELECT  ?title ?price
                 {  ?x ns:price ?p .
                    ?x ns:discount ?discount
                    BIND (?p*(1-?discount) AS ?price)
                    FILTER(?price < 20)
                    ?x dc:title ?title .
                 }
                 """) ==
                  %Query.Result{
                    variables: ~w[title price],
                    results: [
                      %{
                        "title" => ~L<The Semantic Web>,
                        "price" => XSD.decimal(17.25)
                      }
                    ]
                  }
  end
end
