defmodule SPARQL.Language do
  @moduledoc """
  An implementation of the SPARQL 1.1 query language.

  see <https://www.w3.org/TR/sparql11-query/>
  """

  alias SPARQL.Query
  alias SPARQL.Language.Decoder


  @file_extension "rq"
  @media_type     "application/sparql-query"

  def file_extension, do: @file_extension
  def media_type,     do: @media_type


  def parse(string, opts \\ [])

  def parse(string, opts),
    do: Decoder.decode(string, opts)

end
