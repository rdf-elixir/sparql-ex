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

  @doc """
  The list of all support `SPARQL.Query.Result.Format`s.
  """
  def result_formats, do: @result_formats

  @doc """
  Returns the `SPARQL.Query.Result.Format` with the given name.

  Returns `nil` if no `SPARQL.Query.Result.Format` with the given name exists.
  """
  def result_format(name),
    do: @result_format_by_name[name]

  @doc """
  Returns the `SPARQL.Query.Result.Format` with the given media type.

  Returns `nil` if no `SPARQL.Query.Result.Format` for the given media type exists.
  """
  def result_format_by_media_type(media_type),
    do: @result_format_by_media_type[media_type]

  @doc """
  Returns the `SPARQL.Query.Result.Format` with the given file extension.

  Returns `nil` if no `SPARQL.Query.Result.Format` for the given file extension exists.
  """
  def result_format_by_extension(extension),
    do: @result_format_by_extension[extension]


  @doc """
  Alias for `SPARQL.Query.new/1`.
  """
  defdelegate query(query), to: SPARQL.Query, as: :new

  @doc """
  Alias for `SPARQL.Query.new/2`.
  """
  defdelegate query(query, opts), to: SPARQL.Query, as: :new

  @doc """
  Alias for `SPARQL.Processor.query/2`.
  """
  defdelegate execute_query(data, query), to: SPARQL.Processor, as: :query

  @doc """
  Alias for `SPARQL.Processor.query/3`.
  """
  defdelegate execute_query(data, query, options), to: SPARQL.Processor, as: :query

end
