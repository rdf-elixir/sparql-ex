defmodule SPARQL do
  @moduledoc """
  An implementation of the [SPARQL](http://www.w3.org/TR/sparql11-overview/) standard for Elixir.
  """

  @result_formats [
    SPARQL.Query.Result.JSON,
    SPARQL.Query.Result.XML,
    SPARQL.Query.Result.TSV,
    SPARQL.Query.Result.CSV
  ]

  @result_format_by_name       @result_formats |> Enum.map(&{&1.name, &1}) |> Map.new
  @result_format_by_media_type @result_formats |> Enum.map(&{&1.media_type, &1}) |> Map.new
  @result_format_by_extension  @result_formats |> Enum.map(&{&1.extension, &1}) |> Map.new

  def result_formats, do: @result_formats

  def result_format(name),                     do: @result_format_by_name[name]
  def result_format_by_media_type(media_type), do: @result_format_by_media_type[media_type]
  def result_format_by_extension(extension),   do: @result_format_by_extension[extension]


  defdelegate query(query), to: SPARQL.Query, as: :new

  defdelegate execute_query(data, query), to: SPARQL.Processor, as: :query

end
