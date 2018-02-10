defmodule SPARQL do
  @moduledoc """
  An implementation of the [SPARQL](http://www.w3.org/TR/sparql11-overview/) standard for Elixir.
  """

  @result_formats [
    SPARQL.Query.Result.JSON,
  ]

  @result_formats_by_name        @result_formats |> Enum.map(&{&1.name, &1}) |> Map.new
  @result_format_by_content_type @result_formats |> Enum.map(&{&1.content_type, &1}) |> Map.new
  @result_format_by_extension    @result_formats |> Enum.map(&{&1.extension, &1}) |> Map.new

  def result_formats, do: @result_formats

  def result_format(name),                         do: @result_formats_by_name[name]
  def result_format_by_content_type(content_type), do: @result_formats_by_content_type[content_type]
  def result_format_by_extension(extension),       do: @result_formats_by_extension[extension]

end
