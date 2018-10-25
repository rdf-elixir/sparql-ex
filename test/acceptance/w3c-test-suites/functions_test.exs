defmodule SPARQL.W3C.TestSuite.FunctionsTest do
  @moduledoc """
  The W3C SPARQL 1.1 test cases for builtin functions.

  <http://w3c.github.io/rdf-tests/sparql11/data-sparql11/functions/index.html>
  """

  use SPARQL.W3C.TestSuite.Case, async: false

  @test_suite {"1.1", "functions"}
  @manifest_graph TestSuite.manifest_graph(@test_suite)

  TestSuite.test_cases(@test_suite, MF.QueryEvaluationTest)
  |> Enum.each(fn test_case ->
       [
         "plus-1",
         "plus-2",
         "bnode01",
       ]
       |> Enum.each(fn test_subject ->
         if test_case.subject |> to_string() |> String.ends_with?(test_subject),
            do: @tag skip: "TODO: the result is correct, but the bnode names are different"
       end)

      [
         "strlang03",
         "strdt03"
       ]
       |> Enum.each(fn test_subject ->
            if test_case.subject |> to_string() |> String.ends_with?(test_subject),
              do: @tag skip: "TODO: Differentiate simple literals from string literals?"
          end)

       [
         "in01",
         "in02",
         "now01",
         "rand01",
       ]
       |> Enum.each(fn test_subject ->
            if test_case.subject |> to_string() |> String.ends_with?(test_subject),
              do: @tag skip: "TODO: ASK query form"
          end)

       @tag test_case: test_case
       test TestSuite.test_title(test_case), %{test_case: test_case} do
         assert_query_evaluation_case_result(test_case, @manifest_graph)
       end
     end)
end
