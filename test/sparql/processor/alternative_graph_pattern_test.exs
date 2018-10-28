defmodule SPARQL.Processor.AlternativeGraphPatternTest do
  use SPARQL.Test.Case

  import SPARQL.Processor, only: [query: 2]

  @w3c_example_graph RDF.Turtle.read_string! """
    @prefix dc10:  <http://purl.org/dc/elements/1.0/> .
    @prefix dc11:  <http://purl.org/dc/elements/1.1/> .

    _:a  dc10:title     "SPARQL Query Language Tutorial" .
    _:a  dc10:creator   "Alice" .

    _:b  dc11:title     "SPARQL Protocol Tutorial" .
    _:b  dc11:creator   "Bob" .

    _:c  dc10:title     "SPARQL" .
    _:c  dc11:title     "SPARQL (updated)" .
    """

  @example_graph Graph.new([
    {EX.s1, EX.p1, EX.o1},
    {EX.s1, EX.p2, EX.o2},
    {EX.s3, EX.p3, EX.o2}
  ])

  test "basic example" do
    assert query(@w3c_example_graph, """
           PREFIX dc10:  <http://purl.org/dc/elements/1.0/>
           PREFIX dc11:  <http://purl.org/dc/elements/1.1/>

           SELECT ?title
           WHERE  { { ?book dc10:title  ?title } UNION { ?book dc11:title  ?title } }
           """) ==
             %Query.Result{
               variables: ~w[title],
               results: [
                 %{
                   "title" => ~L"SPARQL",
                 },
                 %{
                   "title" => ~L"SPARQL Query Language Tutorial",
                 },
                 %{
                   "title" => ~L"SPARQL (updated)",
                 },
                 %{
                   "title" => ~L"SPARQL Protocol Tutorial",
                 },
               ]}
  end

  test "basic example with multiple triple patterns in the alternatives" do
    assert query(@w3c_example_graph, """
           PREFIX dc10:  <http://purl.org/dc/elements/1.0/>
           PREFIX dc11:  <http://purl.org/dc/elements/1.1/>

           SELECT ?title ?author
           WHERE  { { ?book dc10:title ?title .  ?book dc10:creator ?author }
                    UNION
                    { ?book dc11:title ?title .  ?book dc11:creator ?author }
                  }
           """) ==
             %Query.Result{
               variables: ~w[title author],
               results: [
                 %{
                   "title"  => ~L"SPARQL Query Language Tutorial",
                   "author" => ~L"Alice",
                 },
                 %{
                   "title"  => ~L"SPARQL Protocol Tutorial",
                   "author" => ~L"Bob",
                 },
               ]}
  end

  test "no solutions in the alternatives" do
    assert query(@example_graph, """
           SELECT *
           WHERE {
             {<#{EX.s1}> <#{EX.p1}> ?o .}
             UNION
             {<#{EX.s1}> <#{EX.p3}> ?o .}
           }
           """) ==
             %Query.Result{
               variables: ~w[o],
               results: [
                 %{
                   "o"  => ~I<http://example.org/o1>,
                 },
               ]
             }

    assert query(@example_graph, """
           SELECT *
           WHERE {
             {<#{EX.s1}> <#{EX.p3}> ?o .}
             UNION
             {<#{EX.s1}> <#{EX.p1}> ?o .}
           }
           """) ==
             %Query.Result{
               variables: ~w[o],
               results: [
                 %{
                   "o"  => ~I<http://example.org/o1>,
                 },
               ]
             }

    assert query(@example_graph, """
           SELECT *
           WHERE {
             {<#{EX.s4}> <#{EX.p1}> ?o .}
             UNION
             {<#{EX.s4}> <#{EX.p2}> ?o .}
           }
           """) ==
             %Query.Result{
               variables: ~w[o],
               results: []
             }
  end

end
