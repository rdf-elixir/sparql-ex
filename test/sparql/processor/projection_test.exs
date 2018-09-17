defmodule SPARQL.Processor.ProjectionTest do
  use SPARQL.Test.Case

  import SPARQL.Processor, only: [query: 2]

  @example_graph Graph.new([
      {EX.s1, EX.p1, EX.o1},
      {EX.s1, EX.p2, EX.o2},
      {EX.s3, EX.p3, EX.o2}
    ])

  test "single variable" do
    assert query(@example_graph, "SELECT ?o WHERE { <#{EX.s1}> ?p ?o }") ==
      %Query.Result{
        variables: ~w[o],
        results: [
          %{"o" => ~I<http://example.org/o1>},
          %{"o" => ~I<http://example.org/o2>}
        ]}
  end

  test "projected expression" do
    assert query(@example_graph, "SELECT ?o (str(?p) AS ?ps) WHERE { <#{EX.s1}> ?p ?o }") ==
      %Query.Result{
        variables: ~w[o ps],
        results: [
          %{"o" => ~I<http://example.org/o1>, "ps" => ~L"http://example.org/p1"},
          %{"o" => ~I<http://example.org/o2>, "ps" => ~L"http://example.org/p2"}
        ]}
  end

  test "projected expressions over earlier projected expressions" do
    assert query(@example_graph, """
      SELECT ?o (str(?p) AS ?ps) (ucase(?ps) AS ?psu)
      WHERE { <#{EX.s1}> ?p ?o }
      """) ==
      %Query.Result{
        variables: ~w[o ps psu],
        results: [
          %{"o" => ~I<http://example.org/o1>, "ps" => ~L"http://example.org/p1", "psu" => ~L"HTTP://EXAMPLE.ORG/P1"},
          %{"o" => ~I<http://example.org/o2>, "ps" => ~L"http://example.org/p2", "psu" => ~L"HTTP://EXAMPLE.ORG/P2"}
        ]}
  end

  test "projected expression with errors" do
    assert query(@example_graph, "SELECT ?o (ucase(?p) AS ?ps) WHERE { <#{EX.s1}> ?p ?o }") ==
      %Query.Result{
        variables: ~w[o ps],
        results: [
          %{"o" => ~I<http://example.org/o1>},
          %{"o" => ~I<http://example.org/o2>}
        ]}
  end

end
