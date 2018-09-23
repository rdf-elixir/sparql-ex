defmodule SPARQL.Algebra.Distinct do
  defstruct [:expr]

  alias SPARQL.Algebra.Expression

  def result_set(%SPARQL.Query.Result{results: results} = result) do
    %SPARQL.Query.Result{result | results: Enum.uniq(results)}
  end

  defimpl Expression do
    def evaluate(distinct, data, execution) do
      Expression.evaluate(distinct.expr, data, execution)
      |> SPARQL.Algebra.Distinct.result_set()
    end

    def variables(distinct) do
      Expression.variables(distinct.expression)
    end
  end
end
