defmodule SPARQL.W3C.TestSuite.RegexTest do
  @moduledoc """
  The W3C SPARQL 1.0 regex test cases.

  <https://www.w3.org/2001/sw/DataAccess/tests/data-r2/regex/>
  """

  use ExUnit.Case, async: false
  ExUnit.Case.register_attribute __ENV__, :test_case

  alias SPARQL.W3C.TestSuite
  alias TestSuite.NS.MF

  @test_suite {"1.0", "regex"}
  @manifest_graph TestSuite.manifest_graph(@test_suite)

  TestSuite.test_cases(@test_suite, MF.QueryEvaluationTest)
  |> Enum.each(fn test_case ->
       @tag test_case: test_case
       test TestSuite.test_title(test_case), %{test_case: test_case} do
         query = TestSuite.test_input_query(test_case, @manifest_graph)
         data  = TestSuite.test_input_data(test_case, @manifest_graph)
         expected_result =
           TestSuite.test_result_file_path(test_case, @manifest_graph)
           |> File.read!()
           |> SPARQL.Query.Result.Turtle.decode!()

         assert %SPARQL.Query.Result{} = actual_result =
                  SPARQL.Processor.query(data, query)

         assert Multiset.new(actual_result.variables) ==
                Multiset.new(expected_result.variables)
         assert Multiset.new(actual_result.results) ==
                Multiset.new(expected_result.results)
       end
     end)
end
