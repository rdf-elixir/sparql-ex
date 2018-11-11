defmodule SPARQL.W3C.TestSuite.ConstructTest do
  @moduledoc """
  The W3C SPARQL 1.0 cast test cases for CONSTRUCT.

  <https://www.w3.org/2001/sw/DataAccess/tests/data-r2/construct/>
  """

  use SPARQL.W3C.TestSuite.Case, async: false

  @test_suite {"1.0", "construct"}
  @manifest_graph TestSuite.manifest_graph(@test_suite)

  TestSuite.test_cases(@test_suite, MF.QueryEvaluationTest)
  |> Enum.each(fn test_case ->
       ["construct-1", "construct-2", "construct-3", "construct-4"]
       |> Enum.each(fn test_subject ->
            if test_case.subject |> to_string() |> String.ends_with?(test_subject),
              do: @tag skip: "the result is correct, but the bnode names are different; we need to do a isomorphism comparison here"
          end)

       @tag test_case: test_case
       test TestSuite.test_title(test_case), %{test_case: test_case} do
         assert_query_evaluation_case_result(test_case, @manifest_graph)
       end
     end)
end
