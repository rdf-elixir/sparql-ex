defmodule SPARQL.Query.Result.CSV.Decoder do
  @moduledoc false

  use SPARQL.Query.Result.Format.Decoder

  alias NimbleCSV.RFC4180, as: CSV


  def decode(content, _opts \\ []) do
    try do
      with [header | rows] <- CSV.parse_string(content, headers: false),
           {:ok, header}   <- valid_header(header)
      do
        {:ok, %ResultSet{variables: header, results: decode_results(rows, header)}}
      else
        []    -> {:ok, %ResultSet{}}
        error -> error
      end
    rescue
      error in [NimbleCSV.ParseError] ->
      {:error, error}
    end
  end

  defp valid_header(header) do
    normalized_header = Enum.map(header, &String.trim/1)
    if Enum.any?(normalized_header, fn variable -> variable == "" end) do
      {:error, "invalid header variable: ''"}
    else
      {:ok, normalized_header}
    end
  end

  defp decode_results(results, header) do
    Enum.map(results, &(decode_result(&1, header)))
  end

  defp decode_result(result, header) do
    %Result{bindings:
       header
       |> Enum.zip(result)
       |> Enum.map(&decode_value/1)
       |> Map.new
    }
  end

  defp decode_value({variable, "_:" <> label}),
    do: {variable, RDF.BlankNode.new(label)}

  defp decode_value({variable, ("http://" <> _str) = iri}),
    do: {variable, RDF.IRI.new(iri)}

  defp decode_value({variable, ""}),
    do: {variable, nil}

  defp decode_value({variable, value}),
    do: {variable, RDF.Literal.new(value)}

end
