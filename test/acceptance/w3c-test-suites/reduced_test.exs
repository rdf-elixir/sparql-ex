defmodule SPARQL.W3C.TestSuite.ReducedTest do
  @moduledoc """
  The W3C SPARQL 1.0 cast test cases for REDUCED.

  <https://www.w3.org/2001/sw/DataAccess/tests/data-r2/reduced/>
  """

  use SPARQL.W3C.TestSuite.Case, async: false

  @test_suite {"1.0", "reduced"}
  @manifest_graph TestSuite.manifest_graph(@test_suite)

  TestSuite.test_cases(@test_suite, MF.QueryEvaluationTest)
  |> Enum.each(fn test_case ->
       ["reduced-2"]
       |> Enum.each(fn test_subject ->
            if test_case.subject |> to_string() |> String.ends_with?(test_subject),
              do: @tag skip: "TODO: Differentiate simple literals from string literals?"
          end)

       @tag test_case: test_case
       test TestSuite.test_title(test_case), %{test_case: test_case} do
         assert_query_evaluation_case_result(test_case, @manifest_graph)
       end
     end)
end
