defmodule SPARQL.Algebra.Extend do
  defstruct [:p, :var, :expr]

  alias SPARQL.Algebra.Expression

  def result_set(%SPARQL.Query.Result{} = result, var, expr, data, execution) do
    %SPARQL.Query.Result{
      variables: result.variables,
      results:
        Enum.map(result.results, fn bindings ->
          with eval_result when eval_result != :error <-
                 Expression.evaluate(expr, %{solution: bindings, data: data}, execution)
          do
            Map.put(bindings, var, eval_result)
          else
            _ -> bindings
          end
        end)
    }
  end

  defimpl Expression do
    def evaluate(extend, data, execution) do
      Expression.evaluate(extend.p, data, execution)
      |> SPARQL.Algebra.Extend.result_set(extend.var, extend.expr, data, execution)
    end

    def variables(extend) do
      Expression.variables(extend.p)
    end
  end
end
