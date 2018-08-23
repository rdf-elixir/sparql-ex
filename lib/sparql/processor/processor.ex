defmodule SPARQL.Processor do

  alias SPARQL.{Query, Algebra}

  def query(data, query_string) when is_binary(query_string) do
    with %Query{} = query <- Query.new(query_string) do
      query(data, query)
    end
  end

  def query(data, %Query{expr: expr, base: base}) do
    Algebra.Expression.evaluate(expr, data, execution_context(base))
  end

  defp execution_context(base) do
    %{
      base: base,
      time: DateTime.utc_now(),
    }
  end

end
