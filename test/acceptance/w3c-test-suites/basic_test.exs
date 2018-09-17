defmodule SPARQL.W3C.TestSuite.BasicTest do
  @moduledoc """
  The W3C SPARQL 1.0 Basic test cases.

  <https://www.w3.org/2001/sw/DataAccess/tests/data-r2/basic/>
  """

  use SPARQL.W3C.TestSuite.Case, async: false

  @test_suite {"1.0", "basic"}
  @manifest_graph TestSuite.manifest_graph(@test_suite)

  TestSuite.test_cases(@test_suite, MF.QueryEvaluationTest)
  |> Enum.filter(fn test_case ->
       # Decimal format changed in SPARQL 1.1
       not (test_case.subject |> to_string() |> String.ends_with?("term-6")) and
       not (test_case.subject |> to_string() |> String.ends_with?("term-7"))
     end)
  |> Enum.each(fn test_case ->
       @tag test_case: test_case
       test TestSuite.test_title(test_case), %{test_case: test_case} do
         assert_query_evaluation_case_result(test_case, @manifest_graph)
       end
     end)

end
