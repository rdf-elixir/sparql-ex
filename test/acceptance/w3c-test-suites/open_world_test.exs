defmodule SPARQL.W3C.TestSuite.OpenWorldTest do
  @moduledoc """
  The W3C SPARQL 1.0 algebra open-world test cases.

  <https://www.w3.org/2001/sw/DataAccess/tests/data-r2/open-world/>
  """

  use SPARQL.W3C.TestSuite.Case, async: false

  @test_suite {"1.0", "open-world"}
  @manifest_graph TestSuite.manifest_graph(@test_suite)

  TestSuite.test_cases(@test_suite, MF.QueryEvaluationTest)
  |> Enum.each(fn test_case ->
       [
         "open-eq-07",
       ]
       |> Enum.each(fn test_subject ->
            if test_case.subject |> to_string() |> String.ends_with?(test_subject),
              do: @tag skip: "the result is correct, but the bnode names are different; we need to do a isomorphism comparison here"
          end)

       [
         "open-eq-06",
       ]
       |> Enum.each(fn test_subject ->
         if test_case.subject |> to_string() |> String.ends_with?(test_subject),
            do: @tag skip: "This requires the unequal operator to fail on any unknown datatype - https://lists.w3.org/Archives/Public/public-sparql-dev/2018OctDec/0010.html"
       end)

       [
         "open-eq-08",
         "open-eq-10",
         "open-eq-11",
         "open-eq-12",
       ]
       |> Enum.each(fn test_subject ->
         if test_case.subject |> to_string() |> String.ends_with?(test_subject),
            do: @tag skip: "https://lists.w3.org/Archives/Public/public-sparql-dev/2018OctDec/0008.html"
       end)

       @tag test_case: test_case
       test TestSuite.test_title(test_case), %{test_case: test_case} do
         assert_query_evaluation_case_result(test_case, @manifest_graph)
       end
     end)
end
