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
           |> default_prefixes()
           |> encode_prefixes()
         ),
         {:ok, query} <-
           SPARQL.Language.Decoder.decode(prefixes <> "\n" <> string, options)
    do
      query
    end
  end

  @standard_prefixes %{
    xsd: to_string(RDF.NS.XSD.__base_iri__),
    rdf: to_string(RDF.__base_iri__),
    rdfs: to_string(RDF.NS.RDFS.__base_iri__)
  }

  @doc """
  The map of standard prefixes that is available on every query.

  ```elixir
  #{inspect(@standard_prefixes, pretty: true)}
  ```

  """
  def standard_prefixes(), do: @standard_prefixes


  @doc """
  A user-defined map of prefixes that is available on every query.

  By default the `standard_prefixes/0` are assumed to be available on every query.

  Additional default prefixes can be defined via the `default_prefixes` configuration.

  For example:

      config :sparql,
        default_prefixes: %{
          ex: "http://example.com/"
        }

  The `default_prefixes` take precedence over the `standard_prefixes/0` and can
  be overwritten.

  """
  @default_prefixes Application.get_env(:sparql, :default_prefixes, %{})
  def default_prefixes() do
    @standard_prefixes
    |> Map.merge(@default_prefixes)
    |> remove_nil_prefixes()
  end

  def default_prefixes(nil), do: default_prefixes()

  def default_prefixes(:none), do: nil

  def default_prefixes(prefixes) when is_map(prefixes) do
    default_prefixes()
    |> Map.merge(prefixes)
    |> remove_nil_prefixes()
  end

  def default_prefixes(vocabs) when is_list(vocabs) do
    vocabs
    |> Stream.map(fn vocab ->
         {prefix_of_vocab(vocab), to_string(vocab.__base_iri__)}
       end)
    |> Map.new()
    |> default_prefixes()
  end

  defp prefix_of_vocab(vocab) do
    vocab
    |> Module.split()
    |> List.last()
    |> String.downcase()
    |> String.to_atom()
  end

  defp encode_prefixes(nil), do: ""

  defp encode_prefixes(prefixes) do
    prefixes
    |> Stream.map(fn {prefix, iri} ->
         "PREFIX #{to_string(prefix)}: <#{to_string(iri)}>"
       end)
    |> Enum.join("\n")
  end

  defp remove_nil_prefixes(prefixes) do
    prefixes
    |> Stream.filter(fn {_, iri} -> iri end)
    |> Map.new()
  end

end
