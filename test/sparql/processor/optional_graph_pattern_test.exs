defmodule SPARQL.Processor.OptionalGraphPatternTest do
  use SPARQL.Test.Case

  import SPARQL.Processor, only: [query: 2]

  @example_graph Graph.new([
    {EX.s1, EX.p1, EX.o1},
    {EX.s1, EX.p2, EX.o2},
    {EX.s3, EX.p3, EX.o2}
  ])

  test "basic example" do
    graph = RDF.Turtle.read_string! """
      @prefix foaf:       <http://xmlns.com/foaf/0.1/> .
      @prefix rdf:        <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .

      _:a  rdf:type        foaf:Person .
      _:a  foaf:name       "Alice" .
      _:a  foaf:mbox       <mailto:alice@example.com> .
      _:a  foaf:mbox       <mailto:alice@work.example> .

      _:b  rdf:type        foaf:Person .
      _:b  foaf:name       "Bob" .
      """
    assert query(graph, """
           PREFIX foaf: <http://xmlns.com/foaf/0.1/>
           SELECT ?name ?mbox
           WHERE  { ?x foaf:name  ?name .
                    OPTIONAL { ?x  foaf:mbox  ?mbox }
                  }
           """) ==
             %Query.Result{
               variables: ~w[name mbox],
               results: [
                 %{
                   "name" => ~L"Alice",
                   "mbox" => ~I<mailto:alice@work.example>,
                 },
                 %{
                   "name" => ~L"Alice",
                   "mbox" => ~I<mailto:alice@example.com>,
                 },
                 %{
                   "name" => ~L"Bob"
                 },
               ]}
  end

  test "basic example with filter" do
    graph = RDF.Turtle.read_string! """
      @prefix dc:   <http://purl.org/dc/elements/1.1/> .
      @prefix :     <http://example.org/book/> .
      @prefix ns:   <http://example.org/ns#> .

      :book1  dc:title  "SPARQL Tutorial" .
      :book1  ns:price  42 .
      :book2  dc:title  "The Semantic Web" .
      :book2  ns:price  23 .
      """
    assert query(graph, """
           PREFIX  dc:  <http://purl.org/dc/elements/1.1/>
           PREFIX  ns:  <http://example.org/ns#>
           SELECT  ?title ?price
           WHERE   { ?x dc:title ?title .
                     OPTIONAL { ?x ns:price ?price . FILTER (?price < 30) }
                   }
           """) ==
             %Query.Result{
               variables: ~w[title price],
               results: [
                 %{
                   "title" => ~L"The Semantic Web",
                   "price" => XSD.integer(23),
                 },
                 %{
                   "title" => ~L"SPARQL Tutorial",
                 },
               ]}
  end


  test "basic example with multiple optional graph patterns" do
    graph = RDF.Turtle.read_string! """
      @prefix foaf:       <http://xmlns.com/foaf/0.1/> .

      _:a  foaf:name       "Alice" .
      _:a  foaf:homepage   <http://work.example.org/alice/> .

      _:b  foaf:name       "Bob" .
      _:b  foaf:mbox       <mailto:bob@work.example> .
      """
    assert query(graph, """
           PREFIX foaf: <http://xmlns.com/foaf/0.1/>
           SELECT ?name ?mbox ?hpage
           WHERE  { ?x foaf:name  ?name .
                    OPTIONAL { ?x foaf:mbox ?mbox } .
                    OPTIONAL { ?x foaf:homepage ?hpage }
                  }
           """) ==
             %Query.Result{
               variables: ~w[name mbox hpage],
               results: [
                 %{
                   "name" => ~L"Alice",
                   "hpage" => ~I<http://work.example.org/alice/>,
                 },
                 %{
                   "name" => ~L"Bob",
                   "mbox" => ~I<mailto:bob@work.example>,
                 },
               ]}
  end

  test "no solutions in the non-optional part" do
    assert query(@example_graph, """
           SELECT *
           WHERE {
             <#{EX.s}> ?p ?o .
             OPTIONAL {<#{EX.s1}> <#{EX.p1}> ?o .}
           }
           """) ==
             %Query.Result{
               variables: ~w[o p],
               results: []
             }
  end

  test "no solutions in the optional part" do
    assert query(@example_graph, """
           SELECT *
           WHERE {
             <#{EX.s1}> ?p ?o .
             OPTIONAL {?s <#{EX.p1}> ?o . ?s <#{EX.p3}> ?o .}
           }
           """) ==
             %Query.Result{
               variables: ~w[o p s],
               results: [
                 %{
                   "p"  => ~I<http://example.org/p1>,
                   "o"  => ~I<http://example.org/o1>,
                 },
                 %{
                   "p"  => ~I<http://example.org/p2>,
                   "o"  => ~I<http://example.org/o2>,
                 },
               ]
             }
  end

  test "multiple solutions for the optional part" do
    assert query(@example_graph, """
           SELECT *
           WHERE {
             <#{EX.s1}> <#{EX.p2}> ?o .
             OPTIONAL {?s ?p ?o .}
           }
           """) ==
             %Query.Result{
               variables: ~w[o p s],
               results: [
                 %{
                   "s"  => ~I<http://example.org/s1>,
                   "p"  => ~I<http://example.org/p2>,
                   "o"  => ~I<http://example.org/o2>,
                 },
                 %{
                   "s"  => ~I<http://example.org/s3>,
                   "p"  => ~I<http://example.org/p3>,
                   "o"  => ~I<http://example.org/o2>,
                 },
               ]
             }
  end

  test "independent triple patterns lead to cross-products" do
    assert query(@example_graph, """
           SELECT *
           WHERE {
             <#{EX.s1}> ?p1 ?o .
             OPTIONAL {?s ?p2 <#{EX.o2}>.}
           }
           """) ==
             %Query.Result{
               variables: ~w[o p1 p2 s],
               results: [
                 %{
                   "p1" => ~I<http://example.org/p2>,
                   "o"  => ~I<http://example.org/o2>,
                   "s"  => ~I<http://example.org/s1>,
                   "p2" => ~I<http://example.org/p2>,
                 },
                 %{
                   "p1" => ~I<http://example.org/p2>,
                   "o"  => ~I<http://example.org/o2>,
                   "s"  => ~I<http://example.org/s3>,
                   "p2" => ~I<http://example.org/p3>,
                 },
                 %{
                   "p1" => ~I<http://example.org/p1>,
                   "o"  => ~I<http://example.org/o1>,
                   "s"  => ~I<http://example.org/s1>,
                   "p2" => ~I<http://example.org/p2>,
                 },
                 %{
                   "p1" => ~I<http://example.org/p1>,
                   "o"  => ~I<http://example.org/o1>,
                   "s"  => ~I<http://example.org/s3>,
                   "p2" => ~I<http://example.org/p3>,
                 },
               ]
             }
  end

end
