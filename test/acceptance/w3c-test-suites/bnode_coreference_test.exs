defmodule SPARQL.W3C.TestSuite.BnodeCoreferenceTest do
  @moduledoc """
  The W3C SPARQL 1.0 test cases on bnode co-reference.

  <https://www.w3.org/2001/sw/DataAccess/tests/data-r2/bnode-coreference/>
  """

  use SPARQL.W3C.TestSuite.Case, async: false

  @test_suite {"1.0", "bnode-coreference"}
  @manifest_graph TestSuite.manifest_graph(@test_suite)

  TestSuite.test_cases(@test_suite, MF.QueryEvaluationTest)
  |> Enum.each(fn test_case ->
       if test_case.subject |> to_string() |> String.ends_with?("dawg-bnode-coref-001") do
         @tag skip: "the result is correct, but the bnode names are different; we need to do a isomorphism comparison here"
       end

       @tag test_case: test_case
       test TestSuite.test_title(test_case), %{test_case: test_case} do
         assert_query_evaluation_case_result(test_case, @manifest_graph)
       end
     end)

end
