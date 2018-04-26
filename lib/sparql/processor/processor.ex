defmodule SPARQL.Processor do

  alias SPARQL.{Query, Algebra}

  def query(data, query_string) when is_binary(query_string) do
    with %Query{} = query <- Query.new(query_string) do
      query(data, query)
    end
  end

  def query(data, %Query{expr: expr} = query) do
    SPARQL.Algebra.Expression.evaluate(expr, data)
  end

end
