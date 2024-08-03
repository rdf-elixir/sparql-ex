defmodule SPARQL.Query.Result.JSON.Decoder do
  @moduledoc false

  use SPARQL.Query.Result.Format.Decoder


  def decode(content, _opts \\ []) do
    try do
      with {:ok, object} <- Jason.decode(content) do
        {:ok, decode_results(object)}
      end
    rescue
      error ->
        {:error, Exception.message(error)}
    end
  end

  defp decode_results(%{"boolean" => boolean}) when is_boolean(boolean),
    do: %Result{results: boolean}

  defp decode_results(%{"boolean" => invalid}),
    do: raise "invalid boolean: #{inspect invalid}"

  defp decode_results(%{"head" => %{"vars" => variables}} = object) do
    %Result{Map.delete(object, "head") |> decode_results() |
      variables: variables
    }
  end

  defp decode_results(%{"results" => %{"bindings" => bindings}}) do
    %Result{results: Enum.map(bindings, &decode_solution/1)}
  end

  defp decode_results(_), do: %Result{}


  defp decode_solution(bindings) do
    Enum.reduce(bindings, %{}, fn {variable, value}, query_result ->
      Map.put(query_result, variable, decode_value(value))
    end)
  end

  defp decode_value(%{"type" => "uri", "value" => value}),
    do: RDF.IRI.new(value)

  defp decode_value(%{"type" => "literal", "value" => value, "xml:lang" => language}),
    do: RDF.Literal.new(value, language: language)

  defp decode_value(%{"type" => type, "value" => value, "datatype" => datatype})
       when type in ~w[literal typed-literal],
       do: RDF.Literal.new(value, datatype: datatype)

  defp decode_value(%{"type" => "literal", "value" => value}),
    do: RDF.Literal.new(value)

  defp decode_value(%{"type" => "bnode", "value" => value}),
    do: RDF.BlankNode.new(value)

  defp decode_value(%{"type" => "triple", "value" => value}) do
    # the spo-fallbacks are for some non-spec-compliant implementations out there (like GraphDB)
    {
      decode_value(value["subject"] || value["s"] || raise("'subject' missing in triple value: #{value}")),
      decode_value(value["predicate"] || value["p"] || raise("'predicate' missing in triple value: #{value}")),
      decode_value(value["object"] || value["o"] || raise("'object' missing in triple value: #{value}"))
    }
  end

  defp decode_value(value),
    do: raise "invalid query solution: #{inspect value}"

end
