defmodule SPARQL.Query.Result.XML.Decoder do
  @moduledoc false

  use SPARQL.Query.Result.Format.Decoder

  import SweetXml


  def decode(content, _opts \\ []) do
    try do
      with doc = parse(content, namespace_conformant: true),
           %Result{} = result_set <- decode_doc(doc)
      do
        {:ok, result_set}
      end
    catch
      # TODO: We still get an error logged. How do get rid of that in a less intrusive way? See https://github.com/kbrw/sweet_xml/issues/48 and https://elixirforum.com/t/rescuing-from-an-erlang-error/1132
      :exit, error ->
        {:error, "XML parser error: #{inspect error}"}
    end
  end

  defp decode_doc(doc) do
    with {:ok, results} <- decode_results(doc) do
      %Result{
        variables: decode_variables(doc),
        results: results
      }
    end
  end

  defp decode_variables(doc) do
    case xpath(doc, ~x"//sparql/head/variable/@name"sl) do
      []        -> nil
      variables -> variables
    end
  end

  defp decode_results(doc) do
    cond do
      (results = xpath(doc, ~x"//sparql/results/result"l)) != [] ->
        decode_select_results(results)
      (result = xpath(doc, ~x"//sparql/boolean/text()"s)) != "" ->
        decode_ask_result(result)
      true ->
        {:ok, []}
    end
  end

  defp decode_ask_result("true"),  do: {:ok, true}
  defp decode_ask_result("false"), do: {:ok, false}
  defp decode_ask_result(invalid), do: {:error, "invalid boolean: #{inspect invalid}"}

  defp decode_select_results(result_nodes) do
    {:ok, Enum.map(result_nodes, &decode_result/1)}
  end

  defp decode_result(result_node) do
    result_node
    |> xpath(~x"./binding"l)
    |> Enum.map(&decode_binding/1)
    |> Map.new()
  end

  defp decode_binding(binding_node) do
    {
      (binding_node |> xpath(~x"./@name"s)),
      (binding_node |> xpath(~x"./*") |> decode_value())
    }
  end

  defp decode_value(node) when elem(node, 1) == :uri,
    do: node |> xpath(~x"./text()"s) |> RDF.IRI.new()

  defp decode_value(node) when elem(node, 1) == :literal do
    cond do
      (language = xpath(node, ~x"./@xml:lang"s)) != "" ->
        node |> xpath(~x"./text()"s) |> RDF.Literal.new(language: language)
      (datatype = xpath(node, ~x"./@datatype"s)) ==
          "http://www.w3.org/1999/02/22-rdf-syntax-ns#XMLLiteral" ->
        node |> xpath(~x"*") |> node_to_xml() |> RDF.Literal.new(datatype: datatype)
      (datatype = xpath(node, ~x"./@datatype"s)) != "" ->
        node |> xpath(~x"./text()"s) |> RDF.Literal.new(datatype: datatype)
      true ->
        node |> xpath(~x"./text()"s) |> RDF.Literal.new()
    end
  end

  defp decode_value(node) when elem(node, 1) == :bnode,
    do: node |> xpath(~x"./text()"s) |> RDF.BlankNode.new()

  defp decode_value(value),
    do: raise "Invalid query result: #{inspect value}"

  # TODO: This is quite hacky! Is there a better solution? - https://github.com/kbrw/sweet_xml/issues/58
  # TODO: Remove this when https://github.com/kbrw/sweet_xml/pull/45 gets merged
  defp node_to_xml(node) do
    [node]
    |> :xmerl.export(:xmerl_xml)
    |> List.flatten()
    |> List.to_string()
    |> String.replace_leading(~s[<?xml version="1.0"?>], "")
  end
end
