defmodule SPARQL.W3C.TestSuite.ExprBuiltinTest do
  @moduledoc """
  The W3C SPARQL 1.0 expression test cases for builtins.

  <https://www.w3.org/2001/sw/DataAccess/tests/data-r2/expr-builtin/>
  """

  use SPARQL.W3C.TestSuite.Case, async: false

  @test_suite {"1.0", "expr-builtin"}
  @manifest_graph TestSuite.manifest_graph(@test_suite)

  TestSuite.test_cases(@test_suite, MF.QueryEvaluationTest)
  |> Enum.filter(fn test_case ->
    # In SPARQL 1.1 datatype() of language tagged string returns a result
    not (test_case.subject |> to_string() |> String.ends_with?("dawg-datatype-2"))
  end)
  |> Enum.each(fn test_case ->
       [
         "sameTerm-eq",
         "isBlank-1",
       ]
       |> Enum.each(fn test_subject ->
            if test_case.subject |> to_string() |> String.ends_with?(test_subject),
              do: @tag skip: "TODO: the result is correct, but the bnode names are different"
          end)

       @tag test_case: test_case
       test TestSuite.test_title(test_case), %{test_case: test_case} do
         assert_query_evaluation_case_result(test_case, @manifest_graph)
       end
     end)
end
