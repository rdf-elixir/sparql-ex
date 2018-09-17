defmodule SPARQL.Processor do
  @moduledoc """
  Context module for the SPARQL processor executing SPARQL queries and updates.
  """

  alias SPARQL.{Query, Algebra}

  @doc """
  Executes a `SPARQL.Query` or string with a SPARQL string against a `RDF.Data` structure.
  """
  def query(data, query)

  def query(data, query_string) when is_binary(query_string) do
    with %Query{} = query <- Query.new(query_string) do
      query(data, query)
    end
  end

  def query(data, %Query{expr: expr, base: base}) do
    {:ok, generator} = RDF.BlankNode.Generator.start_link(RDF.BlankNode.Increment, prefix: "b")
    try do
      Algebra.Expression.evaluate(expr, data, execution_context(base, generator))
      |> Query.Result.remove_identity()
    after
      RDF.BlankNode.Generator.stop(generator)
    end
  end

  defp execution_context(base, generator) do
    %{
      base: base,
      time: DateTime.utc_now(),
      bnode_generator: generator
    }
  end

end
