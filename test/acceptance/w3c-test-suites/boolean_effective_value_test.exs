defmodule SPARQL.W3C.TestSuite.BooleanEffectiveValueTest do
  @moduledoc """
  The W3C SPARQL 1.0 test cases for boolean expressions.

  <https://www.w3.org/2001/sw/DataAccess/tests/data-r2/boolean-effective-value/>
  """

  use SPARQL.W3C.TestSuite.Case, async: false

  @test_suite {"1.0", "boolean-effective-value"}
  @manifest_graph TestSuite.manifest_graph(@test_suite)

  TestSuite.test_cases(@test_suite, MF.QueryEvaluationTest)
  |> Enum.each(fn test_case ->
       @tag test_case: test_case
       test TestSuite.test_title(test_case), %{test_case: test_case} do
         assert_query_evaluation_case_result(test_case, @manifest_graph)
       end
     end)
end
