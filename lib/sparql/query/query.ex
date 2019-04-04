defmodule SPARQL.Query do
  @moduledoc """
  A structure for SPARQL queries.
  """

  defstruct [
    :base,
    :prefixes,
    :form,

    :expr,

    :query_string, # This might be only temporary until we have a functionally complete SPARQL language decoder and encoder
  ]

  alias __MODULE__

  @type t :: module

  @type forms :: :select | :construct | :describe | :ask


  @doc """
  Creates a `SPARQL.Query` struct.

  See `translate/2` for more information about default prefixes, all of which
  applies also to this function.
  """
  def new(query, options \\ [])

  def new(%Query{} = query, _options), do: query
  def new(query, options) when is_binary(query), do: translate(query, options)


  @doc """
  Creates a `SPARQL.Query` struct from a SPARQL language string.

  By default the configured `RDF.default_prefixes/0` will be automatically
  defined for the query, so that you can use these prefixes without having them
  defined manually in your query.
  You can overwrite these default prefixes and define another set of prefixes
  with the `default_prefixes` option.
  If you don't want to use default prefixes for the given query you
  can pass `nil` or an empty map for the `default_prefixes` option.

  If you don't want to use default prefixes at all, just don't configure any and
  set the `rdf` configuration flag `use_standard_prefixes` to `false`.
  See the [API documentation of RDF.ex](https://hexdocs.pm/rdf/RDF.html) for
  for more information about `RDF.default_prefixes/0` and `RDF.standard_prefixes/0`
  and how to configure them.
  """
  def translate(string, options \\ []) do
    with prefixes = (
           options
           |> Keyword.get(:default_prefixes, :default_prefixes)
           |> prefixes()
           |> encode_prefixes()
         ),
         {:ok, query} <-
           SPARQL.Language.Decoder.decode(prefixes <> "\n" <> string, options)
    do
      query
    end
  end

  defp prefixes(nil),               do: RDF.PrefixMap.new()
  defp prefixes(:default_prefixes), do: RDF.default_prefixes()
  defp prefixes(prefixes),          do: RDF.PrefixMap.new(prefixes)

  defp encode_prefixes(prefixes) do
    prefixes
    |> Stream.map(fn {prefix, iri} ->
         "PREFIX #{to_string(prefix)}: <#{to_string(iri)}>"
       end)
    |> Enum.join("\n")
  end

  defimpl String.Chars do
    def to_string(query) do
      query.query_string
    end
  end
end
