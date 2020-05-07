defmodule SPARQL.Processor.FilterTest do
  use SPARQL.Test.Case

  import SPARQL.Processor, only: [query: 2]

  @example_graph_with_literals Graph.new([
      {EX.s1, EX.p1, 1},
      {EX.s1, EX.p2, 2},
      {EX.s3, EX.p3, "3"},
      {EX.s4, EX.p4, true},
      {EX.s5, EX.p4, false},
      {EX.s6, EX.p3, "Foo"},
      {EX.s6, EX.p3, ""},
      {EX.s7, EX.p3, XSD.date("2010-01-01")},
    ])

  test "simple comparison" do
    assert query(@example_graph_with_literals, """
      SELECT ?s
      WHERE {
        ?s ?p ?o
        FILTER(?o = 1)
      }
      """) ==
      %Query.Result{
        variables: ~w[s],
        results: [%{"s" => ~I<http://example.org/s1>}]}
  end

  test "with a boolean constant" do
    assert query(@example_graph_with_literals, """
      SELECT ?s
      WHERE {
        ?s ?p ?o
        FILTER(false)
      }
      """) ==
        %Query.Result{
          variables: ~w[s],
          results: []}

    assert query(@example_graph_with_literals, """
      SELECT ?s
      WHERE {
        ?s ?p ?o
        FILTER(true)
      }
      """) ==
        %Query.Result{
          variables: ~w[s],
          results: [
            %{"s" => ~I<http://example.org/s7>},
            %{"s" => ~I<http://example.org/s6>},
            %{"s" => ~I<http://example.org/s6>},
            %{"s" => ~I<http://example.org/s5>},
            %{"s" => ~I<http://example.org/s4>},
            %{"s" => ~I<http://example.org/s3>},
            %{"s" => ~I<http://example.org/s1>},
            %{"s" => ~I<http://example.org/s1>},
          ]
        }
  end

  test "!" do
    assert query(@example_graph_with_literals, """
      SELECT ?s
      WHERE {
        ?s ?p ?o
        FILTER(!?o)
      }
      """) ==
      %Query.Result{
        variables: ~w[s],
        results: [
          %{"s" => ~I<http://example.org/s6>},
          %{"s" => ~I<http://example.org/s5>},
        ]
      }

    assert query(@example_graph_with_literals, """
      SELECT ?s
      WHERE {
        ?s ?p ?o
        FILTER(!(!?o))
      }
      """) ==
      %Query.Result{
        variables: ~w[s],
        results: [
          %{"s" => ~I<http://example.org/s6>},
          %{"s" => ~I<http://example.org/s4>},
          %{"s" => ~I<http://example.org/s3>},
          %{"s" => ~I<http://example.org/s1>},
          %{"s" => ~I<http://example.org/s1>},
        ]
      }
  end

  test "multiple filters" do
    assert query(@example_graph_with_literals, """
      SELECT ?p
      WHERE {
        ?s ?p ?o
        FILTER(?s = <#{EX.s1}>)
        FILTER(?o = 1)
      }
      """) ==
      %Query.Result{
        variables: ~w[p],
        results: [%{"p" => ~I<http://example.org/p1>}]}
  end

  test "nested function calls" do
    assert query(@example_graph_with_literals, """
      SELECT ?s
      WHERE {
        ?s ?p ?o
        FILTER(ucase(str(?o)) = "FOO")
      }
      """) ==
      %Query.Result{
        variables: ~w[s],
        results: [%{"s" => ~I<http://example.org/s6>}]}
  end

  test "extension function calls" do
    assert query(@example_graph_with_literals, """
      PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
      SELECT ?s
      WHERE {
        ?s ?p ?o
        FILTER(xsd:integer(?o) = 3)
      }
      """) ==
        %Query.Result{
          variables: ~w[s],
          results: [%{"s" => ~I<http://example.org/s3>}]}
  end

  test "non-existing extension function calls" do
    assert query(@example_graph_with_literals, """
      PREFIX ex: <http://example.com/>
      SELECT ?s
      WHERE {
        ?s ?p ?o
        FILTER(ex:foo(?o) = 3)
      }
      """) ==
        %Query.Result{
          variables: ~w[s],
          results: []}
  end

end
