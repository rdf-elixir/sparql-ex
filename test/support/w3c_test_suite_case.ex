defmodule SPARQL.W3C.TestSuite.Case do
  use ExUnit.CaseTemplate

  using do
    quote do
      ExUnit.Case.register_attribute __ENV__, :test_case

      alias SPARQL.W3C.TestSuite
      alias TestSuite.NS.MF

      import SPARQL.W3C.TestSuite.Case

    end
  end

  alias SPARQL.W3C.TestSuite

  def assert_query_evaluation_case_result(test_case, manifest_graph) do
    query = TestSuite.test_input_query(test_case, manifest_graph)
    data  = TestSuite.test_input_data(test_case, manifest_graph)
    expected_result =
      test_case
      |> TestSuite.test_result_file_path(manifest_graph)
      |> read_result()

    assert %SPARQL.Query.Result{} = actual_result =
             SPARQL.Processor.query(data, query)

    assert Multiset.new(actual_result.variables) ==
             Multiset.new(expected_result.variables)
    assert Multiset.new(actual_result.results) ==
             Multiset.new(expected_result.results)
  end

  defp read_result(file) do
    file
    |> File.read!()
    |> decode_result(Path.extname(file))
  end

  defp decode_result(content, ".srx"), do: SPARQL.Query.Result.XML.decode!(content)
  defp decode_result(content, ".ttl"), do: SPARQL.Query.Result.Turtle.decode!(content)

end
