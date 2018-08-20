defmodule SPARQL.Algebra.Extend do
  defstruct [:p, :var, :expr]

  alias SPARQL.Algebra.Expression

  def result_set(%SPARQL.Query.Result{} = result, var, expr, data) do
    %SPARQL.Query.Result{
      variables: result.variables,
      results: Enum.map(result.results, fn bindings ->
                 Map.put(bindings, var,
                   Expression.evaluate(expr, %{solution: bindings, data: data}))
               end)
    }
  end

  defimpl SPARQL.Algebra.Expression do
    def evaluate(extend, data) do
      Expression.evaluate(extend.p, data)
      |> SPARQL.Algebra.Extend.result_set(extend.var, extend.expr, data)
    end

    def variables(extend) do
      Expression.variables(extend.p)
    end
  end
end
