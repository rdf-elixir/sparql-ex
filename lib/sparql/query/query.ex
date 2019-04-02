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

  The `default_prefixes` option, allows to set additional default prefixes above
  the `SPARQL.Query.standard_prefixes/0` and the configured
  `SPARQL.Query.default_prefixes/0`. The special value `:none` will disable all
  default prefixes.
  """
  def new(query, options \\ [])

  def new(%Query{} = query, _options), do: query
  def new(query, options) when is_binary(query), do: translate(query, options)


  @doc """
  Creates a `SPARQL.Query` struct from a SPARQL language string.

  The `default_prefixes` option, allows to set additional default prefixes above
  the `SPARQL.Query.standard_prefixes/0` and the configured
  `SPARQL.Query.default_prefixes/0`. The special value `:none` will disable all
  default prefixes.
  """
  def translate(string, options \\ []) do
    with prefixes = (
           options
           |> Keyword.get(:default_prefixes)
           |> prefixes()
           |> encode_prefixes()
         ),
         {:ok, query} <-
           SPARQL.Language.Decoder.decode(prefixes <> "\n" <> string, options)
    do
      query
    end
  end

  defp prefixes(nil),      do: RDF.default_prefixes()
  defp prefixes(prefixes), do: RDF.PrefixMap.new(prefixes)

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
