defmodule SPARQL.Query.Result.CSV.Decoder do
  @moduledoc false

  use SPARQL.Query.Result.Format.Decoder

  alias NimbleCSV.RFC4180, as: CSV


  def decode(content, _opts \\ []) do
    try do
      with [header | rows] <- CSV.parse_string(content, skip_headers: false),
           {:ok, header}   <- valid_header(header)
      do
        {:ok, %Result{variables: header, results: decode_solutions(rows, header)}}
      else
        []    -> {:ok, %Result{}}
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

  defp decode_solutions(solutions, header) do
    Enum.map(solutions, &(decode_solution(&1, header)))
  end

  defp decode_solution(solution, header) do
     header
     |> Enum.zip(solution)
     |> Enum.map(&decode_value/1)
     |> Map.new
  end

  defp decode_value({variable, "_:" <> label}),
    do: {variable, RDF.BlankNode.new(label)}

  # before starting to add all of the official IANA-registered URI schemes here we should
  # consider alternatives, like
  # - using an external URI parser lib for this (will make the CSV result parsing considerably slower)
  # - allow the user to provide a list of additional regexes of what should be recognized as IRIs
  ~w[
    urn:
    http://
    https://
    ftp://
    file:/
    ldap://
    mailto:
    geo:
    data:
  ]
  |> Enum.each(fn scheme ->
    defp decode_value({variable, (unquote(scheme) <> _str) = iri}),
      do: {variable, RDF.IRI.new(iri)}
  end)

  defp decode_value({variable, ""}),
    do: {variable, nil}

  defp decode_value({variable, value}),
    do: {variable, RDF.Literal.new(value)}

end
