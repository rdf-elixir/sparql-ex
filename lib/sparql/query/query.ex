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
  """
  def new(query, options \\ %{})

  def new(%Query{} = query, _options), do: query
  def new(query, options) when is_binary(query), do: translate(query, options)


  @doc """
  Creates a `SPARQL.Query` struct from a SPARQL language string.
  """
  def translate(string, options \\ %{}) do
    with {:ok, query} <- SPARQL.Language.Decoder.decode(string, options) do
      query
    end
  end

end
