defmodule SPARQL.Processor.GroupGraphPatternTest do
  use SPARQL.Test.Case

  import SPARQL.Processor, only: [query: 2]

  @example_graph Graph.new([
    {EX.s1, EX.p1, EX.o1},
    {EX.s1, EX.p2, EX.o2},
    {EX.s3, EX.p3, EX.o2}
  ])

  test "two groups with connected triple patterns with a match" do
    assert query(@example_graph, """
           SELECT *
           WHERE {
             { <#{EX.s1}> ?p ?o . }
             { <#{EX.s3}> ?p2 ?o . }
           }
           """) ==
             %Query.Result{
               variables: ~w[o p p2],
               results: [
                 %{
                   "p"  => ~I<http://example.org/p2>,
                   "p2" => ~I<http://example.org/p3>,
                   "o"  => ~I<http://example.org/o2>,
                 },
               ]}

    assert query(
             Graph.new([
               {EX.s1, EX.p1, EX.o1},
               {EX.s3, EX.p2, EX.o2},
               {EX.s3, EX.p3, EX.o1}
             ]),
             """
             SELECT *
             WHERE {
               {<#{EX.s1}> <#{EX.p1}> ?o .}
               {<#{EX.s3}> ?p ?o .}
             }
             """) ==
             %Query.Result{
               variables: ~w[o p],
               results: [
                 %{
                   "p"  => ~I<http://example.org/p3>,
                   "o"  => ~I<http://example.org/o1>,
                 },
               ]}
  end

  test "a triple pattern with dependent variables from separate triple patterns" do
    assert query(
             Graph.new([
               {EX.s1, EX.p1, EX.o1},
               {EX.s2, EX.p2, EX.o2},
               {EX.s3, EX.p2, EX.o1}
             ]),
             """
             SELECT *
             WHERE {
               {<#{EX.s1}> <#{EX.p1}> ?o .}
               {<#{EX.s2}> ?p <#{EX.o2}>  .}
               {?s ?p ?o .}
             }
             """) ==
             %Query.Result{
               variables: ~w[o p s],
               results: [
                 %{
                   "s"  => ~I<http://example.org/s3>,
                   "p"  => ~I<http://example.org/p2>,
                   "o"  => ~I<http://example.org/o1>,
                 },
               ]}
  end

  test "multiple triple patterns with a constant unmatched triple has no solutions" do
    assert query(@example_graph, """
           SELECT *
           WHERE {
             {<#{EX.s1}> ?p ?o .}
             {<#{EX.s}> <#{EX.p}> <#{EX.o}> .}
           }
           """) ==
             %Query.Result{
               variables: ~w[o p],
               results: []
             }
  end

  test "independent triple patterns lead to cross-products" do
    assert query(@example_graph, """
           SELECT *
           WHERE {
             {<#{EX.s1}> ?p1 ?o .}
             {?s ?p2 <#{EX.o2}>.}
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

  test "with blank nodes" do
    assert query(@example_graph, """
           SELECT *
           WHERE {
             {<#{EX.s1}> ?p _:o .}
             {<#{EX.s3}> ?p2 _:o .}
           }
           """) ==
             %Query.Result{
               variables: ~w[p p2],
               results: [
                 %{
                   "p"  => ~I<http://example.org/p2>,
                   "p2" => ~I<http://example.org/p3>,
                 },
                 %{
                   "p"  => ~I<http://example.org/p1>,
                   "p2" => ~I<http://example.org/p3>,
                 },
               ]}
  end

  test "cross-product with blank nodes" do
    assert query(@example_graph, """
           SELECT *
           WHERE {
             {<#{EX.s1}> ?p1 ?o .}
             {_:s ?p2 <#{EX.o2}>.}
           }
           """) ==
             %Query.Result{
               variables: ~w[o p1 p2],
               results: [
                 %{
                   "p1" => ~I<http://example.org/p2>,
                   "o"  => ~I<http://example.org/o2>,
                   "p2" => ~I<http://example.org/p2>,
                 },
                 %{
                   "p1" => ~I<http://example.org/p2>,
                   "o"  => ~I<http://example.org/o2>,
                   "p2" => ~I<http://example.org/p3>,
                 },
                 %{
                   "p1" => ~I<http://example.org/p1>,
                   "o"  => ~I<http://example.org/o1>,
                   "p2" => ~I<http://example.org/p2>,
                 },
                 %{
                   "p1" => ~I<http://example.org/p1>,
                   "o"  => ~I<http://example.org/o1>,
                   "p2" => ~I<http://example.org/p3>,
                 },
               ]
             }
  end

end
