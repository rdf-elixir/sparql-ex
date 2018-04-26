defmodule SPARQL.W3C.TestSuite.BasicTest do
  @moduledoc """
  The W3C SPARQL 1.0 Basic test cases.

  <https://www.w3.org/2001/sw/DataAccess/tests/data-r2/basic/>
  """

  use ExUnit.Case, async: false
  ExUnit.Case.register_attribute __ENV__, :test_case

  alias SPARQL.W3C.TestSuite
  alias TestSuite.NS.MF

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

       [
        "list-2",
        "list-3",
        "list-4",
       ]
       |> Enum.each(fn test_subject ->
            if test_case.subject |> to_string() |> String.ends_with?(test_subject),
              do: @tag skip: "TODO: proper treatment of blank nodes"
          end)

       test TestSuite.test_title(test_case), %{test_case: test_case} do
         query = TestSuite.test_input_query(test_case, @manifest_graph)
         data  = TestSuite.test_input_data(test_case, @manifest_graph)
         expected_result =
           TestSuite.test_result_file_path(test_case, @manifest_graph)
           |> File.read!()
           |> SPARQL.Query.Result.XML.decode!()

         assert %SPARQL.Query.ResultSet{} = actual_result =
                  SPARQL.Processor.query(data, query)

         assert Multiset.new(actual_result.variables) ==
                Multiset.new(expected_result.variables)
         assert Multiset.new(actual_result.results) ==
                Multiset.new(expected_result.results)
       end
     end)

end
