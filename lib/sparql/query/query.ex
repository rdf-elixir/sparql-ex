defmodule SPARQL.Query do
  @moduledoc """
  A structure for SPARQL queries.
  """

  defstruct [
    :base,
    :prefixes,
    :form,

    :expr,

    :query_string, # This is only temporary until we have a functionally complete SPARQL language decoder and encoder
  ]

  alias __MODULE__

  @type t :: module

  @type forms :: :select | :construct | :describe | :ask


  @doc """
  Creates a `SPARQL.Query` struct.
  """
  def new(query)

  def new(%Query{} = query), do: query
  def new(query) when is_binary(query), do: translate(query)


  @doc """
  Creates a `SPARQL.Query` struct from a SPARQL language string.

  In the first version we just use the decoder for validation and determination
  of the query form.
  """
  def translate(string) do
    with {:ok, query} <- SPARQL.Language.Decoder.decode(string) do
      query
    end
  end

end
