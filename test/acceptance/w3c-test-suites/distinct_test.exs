defmodule SPARQL.W3C.TestSuite.DistinctTest do
  @moduledoc """
  The W3C SPARQL 1.0 cast test cases for DISTINCT.

  <https://www.w3.org/2001/sw/DataAccess/tests/data-r2/distinct/>
  """

  use SPARQL.W3C.TestSuite.Case, async: false

  @test_suite {"1.0", "distinct"}
  @manifest_graph TestSuite.manifest_graph(@test_suite)

  TestSuite.test_cases(@test_suite, MF.QueryEvaluationTest)
  |> Enum.each(fn test_case ->
       ["distinct-3", "no-distinct-3"]
       |> Enum.each(fn test_subject ->
            if test_case.subject |> to_string() |> String.ends_with?(test_subject),
              do: @tag skip: "the result is correct, but the bnode names are different; we need to do a isomorphism comparison here"
          end)

       ["distinct-2"]
       |> Enum.each(fn test_subject ->
            if test_case.subject |> to_string() |> String.ends_with?(test_subject),
              do: @tag skip: "TODO: Differentiate simple literals from string literals?"
          end)

       ["distinct-9", "no-distinct-9"]
       |> Enum.each(fn test_subject ->
            if test_case.subject |> to_string() |> String.ends_with?(test_subject),
              do: @tag skip: "TODO: bnode-isomorphism-problem and rdf1.0-string semantics problem"
          end)

       @tag test_case: test_case
       test TestSuite.test_title(test_case), %{test_case: test_case} do
         assert_query_evaluation_case_result(test_case, @manifest_graph)
       end
     end)
end
