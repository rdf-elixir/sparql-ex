defmodule SPARQL.W3C.TestSuite.OptionalFilterTest do
  @moduledoc """
  The W3C SPARQL 1.0 algebra test cases for an optional graph pattern edge case.

  see <https://www.w3.org/TR/sparql11-query/#convertGraphPattern>

  <https://www.w3.org/2001/sw/DataAccess/tests/data-r2/optional-filter/>
  """

  use SPARQL.W3C.TestSuite.Case, async: false

  @test_suite {"1.0", "optional-filter"}
  @manifest_graph TestSuite.manifest_graph(@test_suite)

  TestSuite.test_cases(@test_suite, MF.QueryEvaluationTest)
  |> Enum.each(fn test_case ->
       if test_case.subject |> to_string() |> String.ends_with?("dawg-optional-filter-005-simplified"),
         do: @tag skip: "This test contradicts dawg-optional-filter-005-not-simplified which uses the same query on the same data but has a different result - not really sure what is expected here"

       @tag test_case: test_case
       test TestSuite.test_title(test_case), %{test_case: test_case} do
         assert_query_evaluation_case_result(test_case, @manifest_graph)
       end
     end)
end
