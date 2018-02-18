defmodule SPARQL.Query.Result.JSON.Decoder do
  @moduledoc false

  use SPARQL.Query.Result.Format.Decoder


  def decode(content, _opts \\ []) do
    with {:ok, object} <- Jason.decode(content) do
      {:ok, decode_results(object)}
    end
  end

  defp decode_results(%{"boolean" => boolean}) do
    %ResultSet{results: boolean}
  end

  defp decode_results(%{"head" => %{"vars" => variables}} = object) do
    %ResultSet{Map.delete(object, "head") |> decode_results() |
      variables: variables
    }
  end

  defp decode_results(%{"results" => %{"bindings" => bindings}}) do
    %ResultSet{results: Enum.map(bindings, &decode_result/1)}
  end

  defp decode_results(_) do
    %ResultSet{}
  end

  defp decode_result(result) do
    %Result{bindings:
      Enum.reduce(result, %{}, fn {variable, value}, query_result ->
        Map.put(query_result, variable, decode_value(value))
      end)
    }
  end

  defp decode_value(%{"type" => "uri", "value" => value}),
    do: RDF.IRI.new(value)

  defp decode_value(%{"type" => "literal", "value" => value}),
    do: RDF.Literal.new(value)

  defp decode_value(%{"type" => "literal", "value" => value, "xml:lang" => language}),
    do: RDF.Literal.new(value, language: language)

  defp decode_value(%{"type" => type, "value" => value, "datatype" => datatype})
    when type in ~w[literal typed-literal],
    do: RDF.Literal.new(value, datatype: datatype)

  defp decode_value(%{"type" => "bnode", "value" => value}),
    do: RDF.BlankNode.new(value)

  defp decode_value(value),
    do: raise "Invalid query solution: #{inspect value}"

end
