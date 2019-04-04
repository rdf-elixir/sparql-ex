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
    query_form = TestSuite.test_query_form(test_case)
    result =
      test_case
      |> TestSuite.test_result_file_path(manifest_graph)
      |> read_result(query_form)
    assert_query_evaluation_case_result(query_form, query, data, result)
  end

  defp assert_query_evaluation_case_result(:select, query, data, expected_result) do
    assert %SPARQL.Query.Result{} = actual_result =
             SPARQL.Processor.query(data, query)

    assert Multiset.equal? Multiset.new(actual_result.variables),
                           Multiset.new(expected_result.variables)
    assert Multiset.equal? Multiset.new(actual_result.results),
                           Multiset.new(expected_result.results)
  end

  defp assert_query_evaluation_case_result(:construct, query, data, expected_result) do
    assert %RDF.Graph{} = actual_result = SPARQL.Processor.query(data, query)
    assert RDF.Graph.equal?(actual_result, expected_result)
  end

  defp read_result(file, query_form) do
    file
    |> File.read!()
    |> decode_result(Path.extname(file), query_form)
  end

  defp decode_result(content, ".srx", :select), do: SPARQL.Query.Result.XML.decode!(content)
  defp decode_result(content, ".ttl", :select), do: SPARQL.Query.Result.Turtle.decode!(content)

  defp decode_result(content, ".ttl", :construct), do: RDF.Turtle.read_string!(content)

end
