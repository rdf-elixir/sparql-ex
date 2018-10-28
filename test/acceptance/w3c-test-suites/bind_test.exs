defmodule SPARQL.W3C.TestSuite.BindTest do
  @moduledoc """
  The W3C SPARQL 1.1 test cases for BIND.

  <http://w3c.github.io/rdf-tests/sparql11/data-sparql11/bind/index.html>
  """

  use SPARQL.W3C.TestSuite.Case, async: false

  @test_suite {"1.1", "bind"}
  @manifest_graph TestSuite.manifest_graph(@test_suite)

  TestSuite.test_cases(@test_suite, MF.QueryEvaluationTest)
  |> Enum.each(fn test_case ->
       @tag test_case: test_case
       test TestSuite.test_title(test_case), %{test_case: test_case} do
         assert_query_evaluation_case_result(test_case, @manifest_graph)
       end
     end)
end
