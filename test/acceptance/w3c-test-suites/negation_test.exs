defmodule SPARQL.W3C.TestSuite.NegationTest do
  @moduledoc """
  The W3C SPARQL 1.1 negation test cases.

  <http://w3c.github.io/rdf-tests/sparql11/data-sparql11/negation/index.html>
  """

  use SPARQL.W3C.TestSuite.Case, async: false

  @test_suite {"1.1", "negation"}
  @manifest_graph TestSuite.manifest_graph(@test_suite)

  TestSuite.test_cases(@test_suite, MF.QueryEvaluationTest)
  |> Enum.each(fn test_case ->
       [
         "subset-by-exclusion-nex-1",
         "temporal-proximity-by-exclusion-nex-1",
         "exists-01",
         "exists-02",
         "subset-01",
         "subset-02",
         "subset-03",
         "subset-03",
         "set-equals-1",
       ]
       |> Enum.each(fn test_subject ->
         if test_case.subject |> to_string() |> String.ends_with?(test_subject),
            do: @tag skip: "TODO: EXISTS"
       end)

       @tag test_case: test_case
       test TestSuite.test_title(test_case), %{test_case: test_case} do
         assert_query_evaluation_case_result(test_case, @manifest_graph)
       end
     end)
end
