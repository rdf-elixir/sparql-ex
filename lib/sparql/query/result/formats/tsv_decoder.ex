NimbleCSV.define(TSV, separator: "\t", escape: "\0", reserved: [])

defmodule SPARQL.Query.Result.TSV.Decoder do
  @moduledoc false

  use SPARQL.Query.Result.Format.Decoder


  def decode(content, _opts \\ []) do
    try do
      with [header | rows] <- TSV.parse_string(content, skip_headers: false),
           {:ok, header}   <- decode_header(header)
      do
        {:ok, %Result{variables: header, results: decode_results(rows, header)}}
      else
        []    -> {:ok, %Result{}}
        error -> error
      end
    rescue
      error in [NimbleCSV.ParseError] ->
        {:error, error}
      error ->
        {:error, error.message}
    end
  end

  defp decode_header(header) do
    with decoded_header when is_list(decoded_header) <-
          header
          |> Enum.map(&String.trim/1)
          |> do_decode_header()
          |> Enum.reverse()
    do
      {:ok, decoded_header}
    end
  end

  defp do_decode_header(header, acc \\ [])
  defp do_decode_header(["?" <> variable | rest], acc),
    do: do_decode_header(rest, [variable | acc])
  defp do_decode_header([], acc),
    do: acc
  defp do_decode_header([invalid | _], _),
    do: raise "invalid header variable: '#{invalid}'"


  defp decode_results(results, header) do
    Enum.map(results, &(decode_result(&1, header)))
  end

  defp decode_result(result, header) do
     header
     |> Enum.zip(result)
     |> Enum.map(&decode_value/1)
     |> Map.new
  end

  defp decode_value({variable, value}) do
    with {:ok, tokens, _} <- RDF.Turtle.Decoder.tokenize(value) do
      {variable, do_decode_value(tokens)}
    else
      {:error, {_, :turtle_lexer, error}, _} ->
        error
        |> Tuple.to_list()
        |> Enum.map(&to_string/1)
        |> Enum.join(" ")
        |> raise
    end
  end

  # TODO: This should rely completely on the Turtle parser (not the interal token structure of the lexer)
  defp do_decode_value(tokens)

  defp do_decode_value([{:iriref, _, iri}]),
    do: RDF.IRI.new(iri)

  defp do_decode_value([{:blank_node_label, _, bnode}]),
    do: RDF.BlankNode.new(bnode)

  defp do_decode_value([{:integer, _, integer}]),
    do: integer

  defp do_decode_value([{:decimal, _, decimal}]),
    do: decimal

  defp do_decode_value([{:double, _, double}]),
    do: double

  defp do_decode_value([{:boolean, _, boolean}]),
    do: RDF.XSD.Boolean.new(boolean)

  defp do_decode_value([{:string_literal_quote, _, literal}]),
    do: RDF.Literal.new(literal)

  defp do_decode_value([{:string_literal_quote, _, literal}, {:"^^", _}, {:iriref, _, datatype}]),
    do: RDF.Literal.new(literal, datatype: datatype)

  defp do_decode_value([{:string_literal_quote, _, literal}, {:langtag, _, language}]),
    do: RDF.Literal.new(literal, language: language)

  defp do_decode_value([]),
    do: nil

end
