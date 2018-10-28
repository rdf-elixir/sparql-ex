defmodule SPARQL.Processor.SolutionModifiersTest do
  use SPARQL.Test.Case

  import SPARQL.Processor, only: [query: 2]

  @example_graph Graph.new([
    {EX.s1, EX.p1, EX.o1},
    {EX.s1, EX.p2, EX.o2},
    {EX.s2, EX.p3, EX.o2},
    {EX.s3, EX.p3, EX.o2}
  ])

  describe "DISTINCT" do
    test "with projection" do
      assert query(@example_graph, "SELECT DISTINCT ?o WHERE { ?s <#{EX.p3}> ?o }") ==
        %Query.Result{
          variables: ~w[o],
          results: [
            %{
              "o" => ~I<http://example.org/o2>,
            }
          ]
        }
    end

    test "without projection" do
      assert query(@example_graph, """
        SELECT DISTINCT *
        WHERE {
          { <#{EX.s2}> <#{EX.p3}> ?o }
          UNION
          { <#{EX.s3}> <#{EX.p3}> ?o }
        }
        """) ==
        %Query.Result{
          variables: ~w[o],
          results: [
            %{
              "o" => ~I<http://example.org/o2>,
            }
          ]
        }
    end
  end

  describe "REDUCED" do
    test "with projection" do
      assert query(@example_graph, "SELECT REDUCED ?o WHERE { ?s <#{EX.p3}> ?o }") ==
               %Query.Result{
                 variables: ~w[o],
                 results: [
                   %{
                     "o" => ~I<http://example.org/o2>,
                   }
                 ]
               }
    end

    test "without projection" do
      assert query(@example_graph, """
             SELECT REDUCED *
             WHERE {
               { <#{EX.s2}> <#{EX.p3}> ?o }
               UNION
               { <#{EX.s3}> <#{EX.p3}> ?o }
             }
             """) ==
               %Query.Result{
                 variables: ~w[o],
                 results: [
                   %{
                     "o" => ~I<http://example.org/o2>,
                   },
                   %{
                     "o" => ~I<http://example.org/o2>,
                   }
                 ]
               }
    end
  end

end
